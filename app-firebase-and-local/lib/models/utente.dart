import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import './parente.dart';
import '../models/http_exception.dart';

/*
 * Oggetto Utente
 */
class Utente with ChangeNotifier {
  final String authToken;
  final String userId;
  String nome;
  String cognome;
  String codFiscale;
  String codTessera;
  bool notifiche;
  String idUtenteGestore;
  List<Parente> parentiGestiti = [];

  void toggleNotifiche() {
    notifiche = !notifiche;
    notifyListeners();
  }


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
   * Metodi
   */
  // Scarica dal server la lista dei parenti gestiti da questo utente
  Future<bool> getParenti() async {
    if(authToken == null)
      return false;

    //var url = "http://192.168.1.4/youcare/utente/getParenti.php?idUtenteGestore=$userId&token=$authToken";
    String url = APIURL + 'utente/getParenti.php?idUtenteGestore=$userId&token=$authToken';
    try {
      final downloadResponse = await http.get(url);
      if (downloadResponse.statusCode != 200) return false;
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
     * Creo il nuovo utente sul Server
     */
    //String url = 'http://192.168.1.4/youcare/utente/signUp.php';
    String url = APIURL + 'utente/signUp.php';
    try {
      final response = await http.post(url,
          body: json.encode({
            'idUtenteGestore': this.userId,
            'nome': nome,
            'cognome': cognome,
            'codFiscale': codFiscale,
            'codTessera': codTessera,
          }));

      print(response.body);

      // Controllo gli errori (es: email già iscritta)
      final responseData = json.decode(response.body);
      if (response.statusCode != 200) {

        print('responseData[\'responseCode\']: ${responseData['responseCode']}');
        print('responseData[\'responseMessage\']: ${responseData['responseMessage']}');

        throw HttpException(responseData['responseMessage']);
      }

      //print(json.decode(response.body));
    } catch (error) {
      throw error;
    }

    notifyListeners();
  }


  // Tolgo un parente dalla lista dei gestiti per l'attuale utente
  Future<void> eliminaParente(String parenteId) async {

    //var url = "http://192.168.1.4/youcare/utente/eliminaParente.php?userId=$parenteId&token=$authToken";
    String url = APIURL + 'utente/eliminaParente.php?userId=$parenteId&token=$authToken';
    try {
      await http.get(url);

    } catch (error) {
      print(error);
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
