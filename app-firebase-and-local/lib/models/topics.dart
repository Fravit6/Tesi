import 'dart:convert'; // Converte gli oggetti Dart in JSON

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config.dart';
import './rispostaTopic.dart';
import './topic.dart';

/*
 * Oggetto lista di tutti i topic del forum
 */
class Topics with ChangeNotifier {
  List<Topic> _allTopic = [];

  // Token utente di Firebase
  final String authToken;
  final String userId;

  /*
   * Costruttore
   */
  Topics(this.authToken, this.userId);

  /*
   * Getters
   */
  // Restituisco la List di tutti i topics come copia usando l'operatore "..."
  // i metodi in ascolto non devono modificare la lista originale!
  List<Topic> get allTopic {
    return [..._allTopic];
  }

  /*
   * Metodi
   */
  // Scarico i topic dal server
  Future<void> getTopics() async {

    //String url = 'http://192.168.1.4/youcare/topic/getAll.php';
    String url = APIURL + 'topic/getAll.php';
    try {
      final response = await http.get(url);
      if (response.statusCode != 200) return;

      // Estraggo il body della risposta e ne faccio il cast
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // Se non ci sono topic...
      if (extractedData == null) return;

      // Estraggo i singoli topic
      final List<Topic> topicScaricati = [];

      extractedData.forEach((topicId, topicData) {
        topicScaricati.add(Topic(
          id: topicData['id'].toString(),
          titolo: topicData['titolo'],
          testo: topicData['testo'],
          idAutore: topicData['idAutore'].toString(),
          nomeAutore: topicData['nomeAutore'],
          data: DateTime.parse(topicData['data']),
          risposte: ((topicData['risposte'] as List<dynamic>) != null)
              ? (topicData['risposte'] as List<dynamic>)
              .map(
                (item) => RispostaTopic(
                    //id: json.decode(response.body)['name'],
                    data: DateTime.parse(item['data']),
                    idAutore: item['idAutore'],
                    nomeAutore: item['nomeAutore'],
                    testo: item['testo'],
                  )
               ).toList()
              : [],
        ));
      });

      _allTopic = topicScaricati;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // Upload del nuovo topic sul server
  Future<bool> newTopic(Topic topic) async {

    print(authToken);

    //String url = 'http://192.168.1.4/youcare/topic/new.php';
    String url = APIURL + 'topic/new.php';


    // Invio il nuovo topic al Server in formato JSON
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'token': authToken,
          'idAutore': topic.idAutore,
          'nomeAutore': topic.nomeAutore,
          'titolo': topic.titolo,
          'testo': topic.testo,
        }),
      );



      if (response.statusCode != 200) {
        print(response.body);
        return false;
      } else {
        // Aggiungo il topic appena creato
        _allTopic.add(topic);
        notifyListeners();
        return true;
      }
    } catch (error) {
      print('Errore durante l\'upload del topic sul server: ');
      print(error);
      throw error;
    }
  }

  // Upload della risposta al topic sul server
  Future<void> uploadRispostaTopic(String topicPadreId, RispostaTopic editedRisposta) async {
    // Prelevo l'index del topic al quale allegare la risposta
    int indexTopicPadre = _allTopic.indexWhere((topic) => topic.id == topicPadreId);
    _allTopic[indexTopicPadre].addRisposta(editedRisposta);

    // Aggiungo la risposta sul server
    //String url = 'http://192.168.1.4/youcare/risposte/new.php';
    String url = APIURL + 'risposte/new.php';

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'token': authToken,
          'topicId': topicPadreId,
          'autoreId': editedRisposta.idAutore,
          'nomeAutore': editedRisposta.nomeAutore,
          'testo': editedRisposta.testo,
        }),
      );

      print(response.body);

      if (response.statusCode != 200) {
        print(response.body);
        return false;
      } else {
        notifyListeners();
        return true;
      }
    } catch (error) {
      print('Errore durante l\'upload della risposta sul server: ');
      print(error);
      throw error;
    }

  }
}
