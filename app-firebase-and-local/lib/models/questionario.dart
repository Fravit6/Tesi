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
    setData();
    notifyListeners();
  }


  // Download dell'ultimo questionario di giornata dell'utente il cui id è passato in input
  // Restituisce un booleano che indica se è stato trovato o meno
  Future<bool> getUltimoQuestionario({String idUtente}) async {
    String id; // Id per le chiamate al Server

    // Se non passo nessun id inoltro il questionario per l'id che ha eseguito il login
    if (idUtente == null)
      id = userId;
    // Se ho ricevuto un id
    else {
      id = idUtente; // Aggiorno l'id per le chiamate al Server
      userId = idUtente; // Aggiorno l'id del questionario
    }

    print('getUltimoQuestionario(): id: $id');

    //var url = 'http://192.168.1.4/youcare/questionari/getUltimoQuestionario.php?userId=$id&token=$authToken';
    String url = APIURL + 'questionari/getUltimoQuestionario.php?userId=$id&token=$authToken';
    try {
      final downloadResponse = await http.get(url);
      print(downloadResponse.statusCode);
      if (downloadResponse.statusCode != 200) {
        _initQuestionario();
        return false;
      }
      final downloadData = json.decode(downloadResponse.body) as Map<String, dynamic>;

      if (downloadData != null) {
        this.data = DateTime.parse(downloadData['data']);
        this.temp = double.parse(downloadData['temp']);
        this.malDiGola = downloadData['malDiGola'];
        this.malDiTesta = downloadData['malDiTesta'];
        this.doloriMuscolari = downloadData['doloriMuscolari'];
        this.nausea = downloadData['nausea'];
        this.tosse = downloadData['tosse'];
        this.respiroCorto = downloadData['respiroCorto'];
        this.umore = downloadData['umore'];
        this.saturazioneOssigeno = double.parse(downloadData['saturazioneOssigeno']);
        this.freqRespiro = double.parse(downloadData['freqRespiro']);
        this.freqCardiaca = double.parse(downloadData['freqCardiaca']);
        this.pressioneMassima = double.parse(downloadData['pressioneMassima']);
        notifyListeners();

        return true;

        // Questionario della giornata non trovato
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
    String id; // Id per le chiamate al Server

    // Se non passo nessun id inoltro il questionario per l'id che ha eseguito il login
    if (idUtente == null)
      id = userId;
    // Se ho ricevuto un id
    else {
      id = idUtente; // Aggiorno l'id per le chiamate al Server
      userId = idUtente; // Aggiorno l'id del questionario
    }
    print('uploadQuestionario(): idUtente: $idUtente');
    print('uploadQuestionario(): id: $id');

    //String url = 'http://192.168.1.4/youcare/questionari/new.php';
    String url = APIURL + 'questionari/new.php';

    try {

      print(toString());

      final response = await http.post(
        url,
        body: json.encode({
          'token': authToken,
          'userId': id, // Id utente principale o parente
          'data': this.data.toIso8601String(),
          'temp': this.temp.toStringAsFixed(2),
          'malDiGola': (this.malDiGola) ? 1 : 0,
          'malDiTesta': (this.malDiTesta) ? 1 : 0,
          'doloriMuscolari': (this.doloriMuscolari) ? 1 : 0,
          'nausea': (this.nausea) ? 1 : 0,
          'tosse': (this.tosse) ? 1 : 0,
          'respiroCorto': (this.respiroCorto) ? 1 : 0,
          'umore': (this.umore) ? 1 : 0,
          'saturazioneOssigeno': this.saturazioneOssigeno.toStringAsFixed(2),
          'freqRespiro': this.freqRespiro.toStringAsFixed(2),
          'freqCardiaca': this.freqCardiaca.toStringAsFixed(2),
          'pressioneMassima': this.pressioneMassima.toStringAsFixed(2),
        }),
      );

      print('uploadQuestionario(): Risposta Server: ${response.body}');

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
    return 'Questionario{ userID: $userId, data: $data, temp: $temp, malDiGola: $malDiGola, malDiTesta: $malDiTesta, doloriMuscolari: $doloriMuscolari, nausea: $nausea, tosse: $tosse, respiroCorto: $respiroCorto, umore: $umore, saturazioneOssigeno: $saturazioneOssigeno, freqRespiro: $freqRespiro, freqCardiaca: $freqCardiaca, pressioneMassima: $pressioneMassima}';
  }







}
