import 'dart:convert';
import 'dart:async'; // Per il timer

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Per memorizzare i dati sul device
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';
import '../models/http_exception.dart';

/*
 * Provider delle operazioni tra utente e Firebase
 */
class Auth with ChangeNotifier {

  // Campi Firebase
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  // Campi personalizzati
  String nome;
  String cognome;
  String codFiscale;
  String codTessera;
  bool notifiche;

  /*
   * Getter
   */
  // Controllo se l'attuale utente è autenticato
  bool get isAuth {
    return token != null;
  }

  // Ottengo la stringa token di Firebase
  String get token {
    if (_expiryDate != null && _expiryDate.isAfter(DateTime.now()))
      return _token;

    return null;
  }

  String get userId {
    return _userId;
  }

  /*
   * Metodi
   */
  // Registrazione di un nuovo utente
  Future<void> signup(
    String nome,
    String cognome,
    String codFiscale,
    String codTessera,
    String email,
    String password,
    bool ricordami,
  ) async {

    // Se si sta provando a registrare un parente gestito da altri
    String idTrovato;
    String oldId;
    String idUtenteGestore;
    bool exParente = false;

    /*
     * STEP 1: Controllo che il codFiscale non sia occupato
     */
    try {

      // Scarico la lista dei Codici Fiscali e controllo se il codFiscale è libero
      //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json';
      String url = APIURL + 'codiciFiscali.json';
      final getCodFiscaliResponse = await http.get(url);
      final codFiscaliData = json.decode(getCodFiscaliResponse.body) as Map<String, dynamic>;
      if (codFiscaliData == null) return;
      codFiscaliData.forEach((codFiscaleUtente, userIdUtente) {
        if (codFiscaleUtente == codFiscale) {
          print('Esiste già un utente con questo codFiscale.');
          idTrovato = userIdUtente;
          //throw HttpException("CODFISCALE_OCCUPATO");
        }
      });


    // Eventuali errori con la chiamata
    } catch (error) {
      throw error;
    }



    /*
     * STEP 2: Creo il nuovo utente di Firebase
     */
    //String url = 'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey';
    String url = AUTH_URL + 'accounts:signUp?key=$apiKey';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      // Controllo gli errori (es: email già iscritta)
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        print('responseData[\'error\']: ${responseData['error']}');
        throw HttpException(responseData['error']['message']);
      }
      // Salvo il token di Firebase
      _token = responseData['idToken'];
      // Salvo l'id dell'utente di Firebase
      _userId = responseData['localId'];
      // Imposto la scadenza del token
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));

      // Salvo i campi dell'utente
      this.nome = nome;
      this.cognome = cognome;
      this.codFiscale = codFiscale;
      this.codTessera = codTessera;
      this.notifiche = true;


      /*
       * STEP 2.bis: Controllo se il codFiscale è di un parente che si sta registrando come utente
       */
      if (idTrovato != null) {

        //print('T: $_token');

        print('Esiste già un utente con questo codFiscale: $idTrovato');
        final filtri = 'orderBy="userId"&equalTo="$idTrovato"';
        //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$_token&$filtri';
        url = APIURL + 'utenti.json?auth=$_token&$filtri';
        final userResponse = await http.get(url);
        final userDataMap = json.decode(userResponse.body) as Map<String, dynamic>;
        if (userDataMap == null) return;
        userDataMap.forEach((userId, userData) async {
          if (userData['idUtenteGestore'] != null) {
            exParente = true;
            oldId = userId;
            idUtenteGestore = userData['idUtenteGestore'];
            print('Questo utente è gestito da: ${userData['idUtenteGestore']}');
          } else {
            print('Questo utente non è gestito da nessuno.');
            throw HttpException("CODFISCALE_OCCUPATO");
          }

        });
      }


      print(exParente);


      // Qui le strade si differenziano in due casi: nuovo utente e ex-parente!
      /*
       * (EX-PARENTE)
       * STEP 3: Aggiorno la voce dell'ex-parente (nella folder "utenti")
       */
      if (exParente) {
        print('Aggiorno l\'id del vecchio parente ($oldId) con quello nuovo di Firebase ($_userId)');
        //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti/$oldId.json?auth=$_token';
        url = APIURL + 'utenti/$oldId.json?auth=$_token';
        await http.patch(url,
            body: json.encode({
              'idUtenteGestore': null,
              'userId': _userId,
              'email': email,
            }));

        print('Id ex-parente aggiornato!');


        /*
         * STEP 4: Aggiorno la chiave del codFiscale in Firebase (nella folder "codiciFiscali")
         */
        url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json?auth=$_token';
        url = APIURL + 'codiciFiscali.json?auth=$_token';
        final responseSetCodFiscale = await http.patch(url,
            body: json.encode({
              '$codFiscale': _userId
            }));

        // Controllo gli errori
        final responseDataSetCodFiscale = json.decode(responseSetCodFiscale.body);
        if (responseDataSetCodFiscale['error'] != null) {
          print('responseDataGetCodFiscale[\'error\']: ${responseDataSetCodFiscale['error']}');
          throw HttpException("ERROR");
        }



        /*
         * STEP 5: Aggiungo l'utente localmente
         */
        // Faccio partire il timer per il logout
        _autoLogout();

        notifyListeners();

        // Memorizzo i dati sul device
        final prefs = await SharedPreferences.getInstance();
        // se ho oggetti complessi li devo convertire in JSON
        final userData = json.encode({
          'token': _token,
          'userId': _userId,
          'expiryDate': _expiryDate.toIso8601String(),
          'email': ricordami ? email : null,
          'password': ricordami ? password : null,
          'ricordami': ricordami,
        });
        prefs.setString('userData', userData);




        final nomeParente = nome + ' ' + cognome;
        // Aggiungo un campo per le notifiche su Firestore
        FirebaseFirestore.instance
            .collection('notifiche')
            .doc(idUtenteGestore)
            .set({
          'idParente': _userId,
          'idUtGes': idUtenteGestore,
          'codFiscaleParente': codFiscale,
          'nomeParente': nomeParente,
        });



      } else {
        /*
         * (NUOVO UTENTE)
         * STEP 3: Creo una nuova voce utente (nella folder "utenti")
         */
        //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$_token';
        String url = APIURL + 'utenti.json?auth=$_token';
        final response2 = await http.post(url,
            body: json.encode({
              'userId': _userId,
              'email': email,
              'nome': nome,
              'cognome': cognome,
              'codFiscale': codFiscale,
              'codTessera': codTessera,
              'notifiche': true
            }));

        // Controllo gli errori
        final responseData2 = json.decode(response2.body);
        if (responseData2['error'] != null) {
          print('responseData2[\'error\']: ${responseData2['error']}');
          //throw HttpException(responseData2['error']['message']);
          throw HttpException("CODFISCALE_OCCUPATO");
        }

          /*
           * STEP 4: Aggiungo la nuova entry per il nuovo Codice Fiscale nel DB di Firebase (nella folder "codiciFiscali")
           */
          //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json?auth=$_token';
          url = APIURL + 'codiciFiscali.json?auth=$_token';
          final responseGetCodFiscale = await http.patch(url,
              body: json.encode({
                '$codFiscale': _userId
              }));

          // Controllo gli errori
          final responseDataGetCodFiscale = json.decode(responseGetCodFiscale.body);
          if (responseDataGetCodFiscale['error'] != null) {
            print('responseDataGetCodFiscale[\'error\']: ${responseDataGetCodFiscale['error']}');
            throw HttpException("CODFISCALE_OCCUPATO");
          }


          /*
           * STEP 5: Aggiungo l'utente localmente
           */
          // Faccio partire il timer per il logout
          _autoLogout();

          notifyListeners();

          // Memorizzo i dati sul device
          final prefs = await SharedPreferences.getInstance();
          // se ho oggetti complessi li devo convertire in JSON
          final userData = json.encode({
            'token': _token,
            'userId': _userId,
            'expiryDate': _expiryDate.toIso8601String(),
            'email': ricordami ? email : null,
            'password': ricordami ? password : null,
            'ricordami': ricordami,
          });
          prefs.setString('userData', userData);

      }




      //print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
  }

  // Login
  Future<void> login(String email, String password, bool ricordami) async {

    //var url = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey';
    var url = AUTH_URL + 'accounts:signInWithPassword?key=$apiKey';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      // Controllo gli errori
      final responseData = json.decode(response.body);
      if (responseData['error'] != null)
        throw HttpException(responseData['error']['message']);

      // Salvo il token di Firebase
      _token = responseData['idToken'];
      // Salvo l'id dell'utente di Firebase
      _userId = responseData['localId'];
      // Imposto la scadenza del token
      //_expiryDate = DateTime.now().add(Duration(seconds: 180));
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));

      print('Token: $_token');

      // Scarico i dati dell'utente dal DB di Firebase (nella folder "utenti")
      // ATTENZIONE: per poter filtrare by id devi impostare una nuova regola nel db di Firebase!
      final filtri = 'orderBy="userId"&equalTo="$_userId"';
      //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$_token&$filtri';
      url = APIURL + 'utenti.json?auth=$_token&$filtri';
      final loginResponse = await http.get(url);
      final loginData = json.decode(loginResponse.body) as Map<String, dynamic>;
      if (loginData == null) return;
      loginData.forEach((userId, userData) {
        this.nome = userData['nome'];
        this.cognome = userData['cognome'];
        this.codFiscale = userData['codFiscale'];
        this.codTessera = userData['codTessera'];
        this.notifiche = userData['notifiche'];
      });

      // Faccio partire il timer per il logout
      _autoLogout();

      // Memorizzo i dati sul device
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String(),
        'email': ricordami ? email : null,
        'password': ricordami ? password : null,
        'ricordami': ricordami,
      });
      prefs.setString('userData', userData);
      notifyListeners();

      //print(json.decode(response.body));
    } catch (error) {
      throw error;
    }
  }

  // AutoLogin all'avvio
  // Restituisce un Future che a sua volta restituisce un booleano
  // che indica se l'autoLogin è andato a buon fine o meno
  Future<bool> tryAutoLogin() async {

    // Prelevo le informazioni dal device
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    // Estraggo la scadenza del token
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // Se il token è scaduto ma l'utente ha memorizzato le credenziali
    if (expiryDate.isBefore(DateTime.now()) && extractedUserData['ricordami']) {

      // Provo ad effettuare il login con le credenziali memorizzate
      if (extractedUserData['email'] != null && extractedUserData['password'] != null)
        await login(extractedUserData['email'], extractedUserData['password'], true);

    // Se il token è ancora valido
    } else {

      // Sostituisco i valori con quelli del dispositivo
      _token = extractedUserData['token'];
      _userId = extractedUserData['userId'];
      _expiryDate = expiryDate;

      // Prelevo dal DB di Firebase gli altri campi dell'utente
      final filtri = 'orderBy="userId"&equalTo="$_userId"';
      //var url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$_token&$filtri';
      var url = APIURL + 'utenti.json?auth=$_token&$filtri';
      final loginResponse = await http.get(url);
      final loginData = json.decode(loginResponse.body) as Map<String, dynamic>;
      if (loginData == null) return false;
      loginData.forEach((userId, userData) {
        this.nome = userData['nome'];
        this.cognome = userData['cognome'];
        this.codFiscale = userData['codFiscale'];
        this.codTessera = userData['codTessera'];
        this.notifiche = userData['notifiche'];
      });

      notifyListeners();

      // Avvio il timer per il logout automatico
      _autoLogout();

      // Confermo l'avvenuto login
      return true;
    }

    // Anche se non dovrei arrivare mai qui...
    return false;
  }

  // Invalido il token per eseguire il logout
  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    // Cancello i dati memorizzati sul device per evitare l'autoLogin
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
    //prefs.clear() // cancella tutto
  }

  // Timer automatico per il logout alla scadenza del token
  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }


}
