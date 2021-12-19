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

  // Ottengo la stringa token
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

    var idOldGestore;

    /*
     * Creo il nuovo utente sul Server
     */
    //String url = 'http://192.168.1.4/youcare/utente/signUp.php';
    String url = APIURL + 'utente/signUp.php';
    try {
      final responseSignUp = await http.post(url,
          body: json.encode({
            'nome': nome,
            'cognome': cognome,
            'codFiscale': codFiscale,
            'codTessera': codTessera,
            'email': email,
            'password': password,
          }));


      // Controllo gli errori (es: email già iscritta)
      final responseDataSignUp = json.decode(responseSignUp.body);
      if (responseSignUp.statusCode != 200) {
        print('responseData[${responseDataSignUp['responseCode']}]: ${responseDataSignUp['responseMessage']}');
        throw HttpException(responseDataSignUp['responseMessage']);
      }

      // Se ho aggiornato un ex parente salvo l'id per le notifiche
      if (responseDataSignUp['isAnUpgrade']) {
        idOldGestore = responseDataSignUp['idOldGestore'];
      }


      // Effettuo il login
      //var urlLogin = 'http://192.168.1.4/youcare/utente/login.php';
      String urlLogin = APIURL + 'utente/login.php';
      final responseLogin = await http.post(urlLogin,
          body: json.encode({
            'email': email,
            'password': password
          }));

      // Controllo gli errori (es: email già iscritta)
      final responseDataLogin = json.decode(responseLogin.body);
      if (responseLogin.statusCode != 200) {
        print('responseData[${responseDataLogin['responseCode']}]: ${responseDataLogin['responseMessage']}');
        throw HttpException(responseDataLogin['responseMessage']);
      }

      // Salvo il token del Server
      _token = responseDataLogin['token'];
      // Salvo l'id dell'utente del Server
      _userId = responseDataLogin['userId'];
      // Imposto la scadenza del token
      //_expiryDate = DateTime.now().add(Duration(seconds: 180));
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(responseDataLogin['scadenza'] * 1000);

      this.nome = responseDataLogin['nome'];
      this.cognome = responseDataLogin['cognome'];
      this.codFiscale = responseDataLogin['codFiscale'];
      this.codTessera = responseDataLogin['codTessera'];
      this.notifiche = responseDataLogin['notifiche'];


      // Se ho appena registrato un ex parente
      if (responseDataSignUp['isAnUpgrade']) {
        final nomeParente = nome + ' ' + cognome;
        // Aggiungo un campo per le notifiche su Firestore
        FirebaseFirestore.instance
            .collection('notifiche')
            .doc(idOldGestore)
            .set({
          'idParente': _userId,
          'idUtGes': idOldGestore,
          'codFiscaleParente': codFiscale,
          'nomeParente': nomeParente,
        });
      }


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




  // Login
  Future<void> login(String email, String password, bool ricordami) async {

    //var url = 'http://192.168.1.4/youcare/utente/login.php';
    String url = APIURL + 'utente/login.php';

    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password
          }));

      // Controllo gli errori (es: email già iscritta)
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {
        print('responseData[${responseData['responseCode']}]: ${responseData['responseMessage']}');
        throw HttpException(responseData['responseMessage']);
      }

      // Salvo il token del Server
      _token = responseData['token'];
      // Salvo l'id dell'utente del Server
      _userId = responseData['userId'];
      // Imposto la scadenza del token
      //_expiryDate = DateTime.now().add(Duration(seconds: 180));
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(responseData['scadenza'] * 1000);

      this.nome = responseData['nome'];
      this.cognome = responseData['cognome'];
      this.codFiscale = responseData['codFiscale'];
      this.codTessera = responseData['codTessera'];
      this.notifiche = responseData['notifiche'];


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
  Future<bool> tryAutoLogin() async {

    // Prelevo le informazioni dal device
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) return false;

    final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;

    // Estraggo la scadenza del token
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    // Se il token è scaduto
    if (expiryDate.isBefore(DateTime.now()))
      return false;

    if (extractedUserData['ricordami'] &&
        extractedUserData['email'] != null &&
        extractedUserData['password'] != null) {
        await login(extractedUserData['email'], extractedUserData['password'], true)
            .then((_) {
              return true;
            });
    }

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
    //prefs.clear() // Cancella tutto
  }

  // Timer automatico per il logout alla scadenza del token
  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }


}
