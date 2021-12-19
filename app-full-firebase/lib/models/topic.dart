import 'package:flutter/foundation.dart'; // Mi permette di usare le funzioni di flutter (@required)

import './rispostaTopic.dart';

/*
 * Oggetto topic del forum
 */
class Topic {
  final String id;
  final String titolo;
  final String testo;
  final String idAutore;
  final String nomeAutore;
  final DateTime data;
  List<RispostaTopic> risposte = [];

  /*
   * Costruttore
   */
  Topic({
    @required this.id,
    @required this.titolo,
    @required this.testo,
    @required this.idAutore,
    @required this.nomeAutore,
    @required this.data,
    this.risposte,
  });



  /*
   * Metodi
   */
  // Aggiungi risposta al topic
  void addRisposta(RispostaTopic risposta) {

    if (risposte != null)
      risposte.add(risposta);
    else {
      risposte = List<RispostaTopic>();
      risposte.add(risposta);
    }

  }


  @override
  String toString() {
    if (risposte != null && risposte.isNotEmpty)
      return 'Topic{id: $id, titolo: $titolo, idAutore: $idAutore, nomeAutore: $nomeAutore, data: $data, #risposte: ${risposte.length}';
    return 'Topic{id: $id, titolo: $titolo, idAutore: $idAutore, nomeAutore: $nomeAutore, data: $data, 0 risposte}';
  }
}
