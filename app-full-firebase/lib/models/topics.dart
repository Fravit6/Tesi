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
    //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/topic.json?auth=$authToken';
    String url = APIURL + 'topic.json?auth=$authToken';
    try {
      final response = await http.get(url);
      // Estraggo il body della risposta e ne faccio il cast
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      // Se non ci sono topic...
      if (extractedData == null) return;

      // Estraggo i singoli topic
      final List<Topic> topicScaricati = [];

      extractedData.forEach((topicId, topicData) {
        topicScaricati.add(Topic(
          id: topicId,
          titolo: topicData['titolo'],
          testo: topicData['testo'],
          idAutore: topicData['idAutore'],
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

    //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/topic.json?auth=$authToken';
    String url = APIURL + 'topic.json?auth=$authToken';

    // Invio il nuovo topic al Server in formato JSON
    try {

      final response = await http.post(
        url,
        body: json.encode({
          'id': topic.id,
          'titolo': topic.titolo,
          'testo': topic.testo,
          'idAutore': topic.idAutore,
          'nomeAutore': topic.nomeAutore,
          'data': topic.data.toIso8601String(),
          //'risposte': topic.risposte,
        }),
      );

      // Aggiungo il topic appena creato
      _allTopic.add(topic);

      notifyListeners();

      if (response.statusCode != 200) return false;
      else return true;

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
    //String url = 'https://youcare-3d0ce-default-rtdb.firebaseio.com/topic/$topicPadreId.json?auth=$authToken';
    String url = APIURL + 'topic/$topicPadreId.json?auth=$authToken';
    // http.patch = unisci i valori passati con quelli del server
    // i valori non passati a patch non verranno modificati
    await http.patch(url, body: json.encode({
      'risposte': _allTopic[indexTopicPadre].risposte
                    .map((ris) => {
                      //'id': 'idRisposta',
                      'testo': ris.testo,
                      'idAutore': ris.idAutore,
                      'nomeAutore': ris.nomeAutore,
                      'data': ris.data.toIso8601String(),
                    })
                    .toList(),
    }));


    notifyListeners();

  }

}
