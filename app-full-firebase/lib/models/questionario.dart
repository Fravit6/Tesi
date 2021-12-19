import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config.dart';

/*
 * Oggetto questionario
 */
class Questionario with ChangeNotifier {
  String userId; // Id dell'utente che sta compilando il questionario
  DateTime data;
  double temp = 36.5;
  bool malDiGola = false;
  bool malDiTesta = false;
  bool doloriMuscolari = false;
  bool nausea = false;
  bool tosse = false;
  bool respiroCorto = false;
  bool umore = false;
  double saturazioneOssigeno = 100.0;
  double freqRespiro = 10.0;
  double freqCardiaca = 80.0;
  double pressioneMassima = 150.0;
  // Token utente di Firebase
  final String authToken;


  /*
   * Costruttore
   */
  Questionario(this.authToken, this.userId) : data = DateTime.now();


  /*
   * Setters
   */
  void setData() {
    data = DateTime.now();
  }

  void tempPiu() {
    if (this.temp < 42.5) this.temp += 0.1;
  }
  void tempMeno() {
    if (this.temp > 34) this.temp -= 0.1;
  }

  void toggleMalDiGola() => malDiGola = !malDiGola;
  void toggleMalDiTesta() => malDiTesta = !malDiTesta;
  void toggleDoloriMuscolari() => doloriMuscolari = !doloriMuscolari;
  void toggleNausea() => nausea = !nausea;
  void toggleTosse() => tosse = !tosse;
  void toggleRespiroCorto() => respiroCorto = !respiroCorto;
  void toggleUmore() => umore = !umore;

  void saturazioneOssigenoPiu() {
    if (this.saturazioneOssigeno < 100) this.saturazioneOssigeno += 0.5;
  }
  void saturazioneOssigenoMeno() {
    if (this.saturazioneOssigeno > 85.5) this.saturazioneOssigeno -= 0.5;
  }

  void freqRespiroPiu() {
    if (this.freqRespiro < 45) this.freqRespiro += 1;
  }
  void freqRespiroMeno() {
    if (this.freqRespiro > 5) this.freqRespiro -= 1;
  }

  void freqCardiacaPiu() {
    if (this.freqCardiaca < 150) this.freqCardiaca += 1;
  }
  void freqCardiacaMeno() {
    if (this.freqCardiaca > 34) this.freqCardiaca -= 1;
  }

  void pressioneMassimaPiu() {
    if (this.pressioneMassima < 250) this.pressioneMassima += 1;
  }
  void pressioneMassimaMeno() {
    if (this.pressioneMassima > 60) this.pressioneMassima -= 1;
  }



  /*
   * Metodi
   */
  // Inizializza Questionario
  void _initQuestionario() {
    print('Questionario del giorno non trovato!');
    this.temp = 36.5;
    this.malDiGola = false;
    this.malDiTesta = false;
    this.doloriMuscolari = false;
    this.nausea = false;
    this.tosse = false;
    this.respiroCorto = false;
    this.umore = false;
    this.saturazioneOssigeno = 100.0;
    this.freqRespiro = 10.0;
    this.freqCardiaca = 80.0;
    this.pressioneMassima = 150.0;
    notifyListeners();
  }


  // Download dell'ultimo questionario di giornata dell'utente il cui id è passato in input
  // Restituisce un booleano che indica se è stato trovato o meno
  Future<bool> getUltimoQuestionario({String idUtente}) async {
    String id; // Id per le chiamate a Firebase

    // Se non passo nessun id inoltro il questionario per l'id che ha eseguito il login
    if (idUtente == null)
      id = userId;
    // Se ho ricevuto un id
    else {
      id = idUtente; // Aggiorno l'id per le chiamate a Firebase
      userId = idUtente; // Aggiorno l'id del questionario
    }
    print('getUltimoQuestionario(): idUtente: $idUtente');
    print('getUltimoQuestionario(): id: $id');

    //var url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/questionari/$id.json?auth=$authToken';
    var url = APIURL + 'questionari/$id.json?auth=$authToken';
    try {
      final downloadResponse = await http.get(url);
      final downloadData = json.decode(downloadResponse.body) as Map<String, dynamic>;

      if (downloadData != null) {

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        bool trovato = false;
        downloadData.forEach((questId, questValue) {
          final dataQuest = DateTime.parse(questValue['data']);
          int giorniDiff = DateTime(dataQuest.year, dataQuest.month, dataQuest.day).difference(today).inDays;
          if (giorniDiff == 0) {
            trovato = true;
            print('getUltimoQuestionario(): trovato il questionario del giorno di: ${questValue['userId']}');
            this.data = DateTime.parse(questValue['data']);
            this.temp = double.parse(questValue['temp']);
            this.malDiGola = questValue['malDiGola'];
            this.malDiTesta = questValue['malDiTesta'];
            this.doloriMuscolari = questValue['doloriMuscolari'];
            this.nausea = questValue['nausea'];
            this.tosse = questValue['tosse'];
            this.respiroCorto = questValue['respiroCorto'];
            this.umore = questValue['umore'];
            this.saturazioneOssigeno = double.parse(questValue['saturazioneOssigeno']);
            this.freqRespiro = double.parse(questValue['freqRespiro']);
            this.freqCardiaca = double.parse(questValue['freqCardiaca']);
            this.pressioneMassima = double.parse(questValue['pressioneMassima']);
            notifyListeners();
          }
        });

        // Questionario della giornata non trovato nella lista
        if (trovato)
          return true;
        else {
          _initQuestionario();
          return false;
        }

      // Lista di questionari vuota
      } else {
        _initQuestionario();
        return false;
      }

    } catch (error) {
      print('Errore durante il download del questionario dal server: ');
      print(error);
      throw error;
    }

  }


  // Upload del questionario sul server
  Future<bool> uploadQuestionario({String idUtente}) async {
    String id; // Id per le chiamate a Firebase

    // Se non passo nessun id inoltro il questionario per l'id che ha eseguito il login
    if (idUtente == null)
      id = userId;
    // Se ho ricevuto un id
    else {
      id = idUtente; // Aggiorno l'id per le chiamate a Firebase
      userId = idUtente; // Aggiorno l'id del questionario
    }
    print('uploadQuestionario(): idUtente: $idUtente');
    print('uploadQuestionario(): id: $id');

    // Controllo se l'utente ha già inoltrato un questionario oggi
    //var url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/questionari/$id.json?auth=$authToken';
    var url = APIURL + 'questionari/$id.json?auth=$authToken';
    try {
      final downloadResponse = await http.get(url);
      final downloadData = json.decode(downloadResponse.body) as Map<String, dynamic>;
      if (downloadData != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        var idQuestTrovato;
        downloadData.forEach((questId, questValue) {
          final dataQuest = DateTime.parse(questValue['data']);
          int giorniDiff = DateTime(dataQuest.year, dataQuest.month, dataQuest.day).difference(today).inDays;
          if (giorniDiff == 0) idQuestTrovato = questId.toString();
        });

        if (idQuestTrovato != null) {

          print('uploadQuestionario(): Trovato il quest. di oggi!');

          // Faccio l'upload dei nuovi valori
          //url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/questionari/$userId/$idQuestTrovato.json?auth=$authToken';
          url = APIURL + 'questionari/$userId/$idQuestTrovato.json?auth=$authToken';
          // http.patch = unisci i valori passati con quelli del server
          await http.patch(url, body: json.encode({
            'data': this.data.toIso8601String(),
            'temp': this.temp.toStringAsFixed(2),
            'malDiGola': this.malDiGola,
            'malDiTesta': this.malDiTesta,
            'doloriMuscolari': this.doloriMuscolari,
            'nausea': this.nausea,
            'tosse': this.tosse,
            'respiroCorto': this.respiroCorto,
            'umore': this.umore,
            'saturazioneOssigeno': this.saturazioneOssigeno.toStringAsFixed(2),
            'freqRespiro': this.freqRespiro.toStringAsFixed(2),
            'freqCardiaca': this.freqCardiaca.toStringAsFixed(2),
            'pressioneMassima': this.pressioneMassima.toStringAsFixed(2),
          }));
          notifyListeners();
          return true;
        }
      }

    } catch (error) {
      print('Errore durante l\'upload del questionario sul server: ');
      print(error);
      throw error;
    }



    print('uploadQuestionario(): Secondo try!');
    // Invio il nuovo questionario al Server in formato JSON
    try {
      print('uploadQuestionario(): Provo a inviarne uno nuovo!');

      final response = await http.post(
        url,
        body: json.encode({
          'userId': id, // Id utente principale o parente
          'data': this.data.toIso8601String(),
          'temp': this.temp.toStringAsFixed(2),
          'malDiGola': this.malDiGola,
          'malDiTesta': this.malDiTesta,
          'doloriMuscolari': this.doloriMuscolari,
          'nausea': this.nausea,
          'tosse': this.tosse,
          'respiroCorto': this.respiroCorto,
          'umore': this.umore,
          'saturazioneOssigeno': this.saturazioneOssigeno.toStringAsFixed(2),
          'freqRespiro': this.freqRespiro.toStringAsFixed(2),
          'freqCardiaca': this.freqCardiaca.toStringAsFixed(2),
          'pressioneMassima': this.pressioneMassima.toStringAsFixed(2),
        }),
      );

      print('uploadQuestionario(): Risposta Firebase: ${response.body}');

      if (response.statusCode != 200)
        return false;
      else
        return true;
    } catch (error) {
      print('Errore durante l\'upload del questionario sul server: ');
      print(error);
      throw error;
    }


  }


  @override
  String toString() {
    return 'Questionario{ _userID: $userId, _data: $data , _temp: $temp, _malDiGola: $malDiGola, _malDiTesta: $malDiTesta, _doloriMuscolari: $doloriMuscolari, _nausea: $nausea, _tosse: $tosse, _respiroCorto: $respiroCorto, _umore: $umore, _saturazioneOssigeno: $saturazioneOssigeno, _freqRespiro: $freqRespiro, _freqCardiaca: $freqCardiaca, _pressioneMassima: $pressioneMassima}';
  }







}
