import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/utente.dart';
import './questionario_page.dart';
import '../widget/titolo_con_divider.dart';
import '../widget/button_full_width.dart';
import '../widget/sezione_home_assisti_gli_altri.dart';
import '../widget/sezione_home_statistiche.dart';

/*
 * Homepage dell'app con il pulsante per il questionario e le statistiche
 */
class HomePage extends StatelessWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/home';

  @override
  Widget build(BuildContext context) {
    // Scarico l'utente dal provider
    Utente user = Provider.of<Utente>(context);

    return (user == null)
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TitoloConDivider('Questionario'),
                  Text('Ciao, ' + user.nome + '!'),
                  const SizedBox(height: 8),
                  Text('Come ti senti oggi?'),
                  ButtonFullWidth(
                      () => Navigator.pushNamed(
                          context, QuestionarioPage.pageUrl),
                      'Compila il questionario personale'),
                  const SizedBox(height: 40),
                  TitoloConDivider('Assisti gli altri!'),
                  SezioneHomeAssistiGliAltri(),
                  const SizedBox(height: 40),
                  TitoloConDivider('Statistiche Pubbliche'),
                  SezioneHomeStatistiche(),
                ],
              ),
            ),
          );
  }
}
