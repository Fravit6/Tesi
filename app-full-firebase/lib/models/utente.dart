import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../config.dart';
import './parente.dart';
import '../models/http_exception.dart';

/*
 * Oggetto Utente
 */
class Utente with ChangeNotifier {
  // Token dell'utente, mi serve per le chiamate a Firebase
  final String authToken;
  final String userId;
  String nome;
  String cognome;
  String codFiscale;
  String codTessera;
  bool notifiche;

  // Se è un parente:
  // Id dell'utente che lo ha iscritto come familiare
  String idUtenteGestore;

  // Se è un utente:
  // Lista dei parenti che gestisce (info solo locale)
  List<Parente> parentiGestiti = [];



  Utente({
    @required this.authToken,
    @required this.userId,
    this.nome,
    this.cognome,
    @required this.codFiscale,
    @required this.codTessera,
    this.notifiche,
    this.idUtenteGestore,
  });

  /*
   * Setters
   */
  void toggleNotifiche() {
    notifiche = !notifiche;
    notifyListeners();
  }

  /*
   * Metodi
   */
  // Scarica dal server la lista dei parenti gestiti da questo utente
  Future<bool> getParenti() async {
    if(authToken == null)
      return false;

    // Aggiungi idUtenteGestore alle regole degli indici di Firebase!
    final filtri = 'orderBy="idUtenteGestore"&equalTo="$userId"';
    //var url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$authToken&$filtri';
    var url = APIURL + 'utenti.json?auth=$authToken&$filtri';
    try {
      final downloadResponse = await http.get(url);
      final downloadData = json.decode(downloadResponse.body) as Map<String, dynamic>;
      if (downloadData != null) {
        parentiGestiti.clear();
        downloadData.forEach((parentId, parentValue) {
          parentiGestiti.add(Parente(
            userId: parentValue['userId'], // Questo è l'id del parente
            nome: parentValue['nome'],
            cognome: parentValue['cognome'],
            codFiscale: parentValue['codFiscale'],
            codTessera: parentValue['codTessera'],
          ));
        });

        notifyListeners();
        return true;
      } else
        return false;
    } catch (error) {
      print('Errore durante il download dei parenti dal server: ');
      print(error);
      throw error;
    }
  }



  // Registrazione di un nuovo parente dell'attuale utente
  Future<void> signupParente(
      String parenteId,
      String nome,
      String cognome,
      String codFiscale,
      String codTessera,
      ) async {

    /*
     * STEP 1: Controllo che il codFiscale non sia occupato
     */
    try {
      print('Devo controllare che il codFiscale non sia occupato: $codFiscale');

      // Scarico la lista dei Codici Fiscali e controllo se il codFiscale è libero
      //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json';
      String url = APIURL + 'codiciFiscali.json';
      final getCodFiscaliResponse = await http.get(url);
      final codFiscaliData = json.decode(getCodFiscaliResponse.body) as Map<String, dynamic>;
      if (codFiscaliData == null) return;
      codFiscaliData.forEach((codFiscaleUtente, userIdUtente) {
        if (codFiscaleUtente == codFiscale)
          throw HttpException("CODFISCALE_OCCUPATO");
      });


      // Eventuali errori con le chiamate
    } catch (error) {
      throw error;
    }


    /*
     * STEP 2: Creo un nuovo utente nel DB di Firebase (nella folder "utenti" anche se è un parente)
     */
    try {
      print('Creo parente nella tabella utenti.');
      //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$authToken';
      String url = APIURL + 'utenti.json?auth=$authToken';
      final response = await http.post(url,
          body: json.encode({
            'userId': parenteId,
            'nome': nome,
            'cognome': cognome,
            'codFiscale': codFiscale,
            'codTessera': codTessera,
            'notifiche': true,
            'idUtenteGestore': userId,
          }));

      // Controllo gli errori
      final responseData = json.decode(response.body);
      if (responseData['error'] != null)
        throw HttpException(responseData['error']['message']);


      /*final nomeParente = nome + ' ' + cognome;

      // Faccio l'upload del parente sul Cloud Firestone per le notifiche
      FirebaseFirestore.instance
          .collection('parenti')
          .doc(userId)
          .set({
        'idParente': parenteId,
        'idUtenteGestore': userId,
        'codFiscaleParente': codFiscale,
        'nomeParente': nomeParente,
      });*/



      notifyListeners();

      //print(json.decode(response.body));
    } catch (error) {
      throw error;
    }


    /*
     * STEP 3: Aggiungo la nuova entry per il nuovo Codice Fiscale nel DB di Firebase (nella folder "codiciFiscali")
     */
    try {
      print('Aggiungo entry codFiscale');
      //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json?auth=$authToken';
      String url = APIURL + 'codiciFiscali.json?auth=$authToken';
      final responseGetCodFiscale = await http.patch(url,
          body: json.encode({
            '$codFiscale': parenteId
          }));

      // Controllo gli errori
      final responseDataGetCodFiscale = json.decode(responseGetCodFiscale.body);
      if (responseDataGetCodFiscale['error'] != null) {
        print('responseDataGetCodFiscale[\'error\']: ${responseDataGetCodFiscale['error']}');
        throw HttpException("CODFISCALE_OCCUPATO");
      }
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }




  // Tolgo un parente dalla lista dei gestiti per l'attuale utente
  Future<void> eliminaParente(String parenteId) async {

    try {

      // Scarico la lista di tutti i parenti gestiti per trovare l'id di Firebase
      final filtri = 'orderBy="idUtenteGestore"&equalTo="$userId"';
      //var url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti.json?auth=$authToken&$filtri';
      var url = APIURL + 'utenti.json?auth=$authToken&$filtri';

      final downloadResponse = await http.get(url);
      final downloadData = json.decode(downloadResponse.body) as Map<String, dynamic>;
      String idParenteFirebase, codFiscaleParente;
      downloadData.forEach((idParenteMappa, parentValue) {
        if(parentValue["userId"] == parenteId) {
          codFiscaleParente = parentValue["codFiscale"];
          idParenteFirebase = idParenteMappa;
        }
      });

      // Tolgo il campo idUtenteGestore dal parente
      //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/utenti/$idParenteFirebase.json?auth=$authToken';
      url = APIURL + 'utenti/$idParenteFirebase.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'idUtenteGestore': null
          }));

      // Tolgo il codice fiscale dalla lista
      /*url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/codiciFiscali.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            '$codFiscaleParente': null
          }));*/

      // Controllo gli errori
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }





  @override
  String toString() {
    if (idUtenteGestore != null)
      return 'Parente {userId: $userId, nome: $nome, cognome: $cognome, idUtenteGestore: $idUtenteGestore}';
    return 'Utente {userId: $userId, nome: $nome, cognome: $cognome}';
  }
}
