import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
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
class HomePage extends StatefulWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/home';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Utente user;


  @override
  void initState() {
    super.initState();


    // Scarico l'utente dal provider
    user = Provider.of<Utente>(context, listen: false);


    if (!kIsWeb) {
      // Non so cosa faccia...
      FirebaseMessaging.instance
          .getInitialMessage()
          .then((RemoteMessage message) {
        if (message != null) {
          print('getInitialMessage(): $message');
        }
      });

      // Potrei utilizzare il token del dispositivo per inviare notifiche
      // a singoli dispositivi
      //var token = FirebaseMessaging.instance.getToken();

      // Iscrivo questo dispositivo al topic così da riceverne le notifiche
      FirebaseMessaging.instance.subscribeToTopic('parReg${user.userId}');

      // Notifica mentre l'app è in foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('onMessage: $message');
      });

      // Notifica mentre l'app è in background (NON VA)
      FirebaseMessaging.onBackgroundMessage((RemoteMessage message) {
        print('onBackgroundMessage: $message');
        return null;
      });

      // Evento al click della notifica con app in background (forse anche terminata)
      // La notifica deve avere: click_action: FLUTTER_NOTIFICATION_CLICK
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('onMessageOpenedApp: $message');
      });
    }
  }





  @override
  Widget build(BuildContext context) {
    // Scarico l'utente dal provider (provo a toglierlo perché chiamato prima)
    //Utente user = Provider.of<Utente>(context);

    return SingleChildScrollView(
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
                () => Navigator.pushNamed(context, QuestionarioPage.pageUrl),
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
