import 'package:flutter/foundation.dart'; // Mi permette di usare le funzioni di flutter (@required)

/*
 * Oggetto risposta ad un topic del forum
 */
class RispostaTopic {
  final String id;
  final String testo;
  final String idAutore;
  final String nomeAutore;
  final DateTime data;

  RispostaTopic({
    this.id,
    @required this.testo,
    @required this.idAutore,
    @required this.nomeAutore,
    @required this.data,
  });

  @override
  String toString() {
    return 'RispostaTopic{id: $id, testo: $testo, nomeAutore: $nomeAutore, idAutore: $idAutore, data: $data}';
  }
}
