import 'package:flutter/foundation.dart'; // Mi permette di usare le funzioni di flutter (@required)

/*
 * Oggetto Parente gestibile da Utente per l'inoltro di questionari
 */
class Parente {

  String userId;
  String nome;
  String cognome;
  String codFiscale;
  String codTessera;

  Parente({
    this.userId,
    this.nome,
    this.cognome,
    this.codFiscale,
    this.codTessera,
  });

}