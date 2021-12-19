import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parente.dart';
import '../models/utente.dart';
import '../models/questionario.dart';
import '../widget/titolo_con_divider.dart';
import '../widget/button_full_width.dart';

/*
 * Pagina con il form per l'inoltro del questionario
 */
class QuestionarioPage extends StatefulWidget {
  static const pageUrl = '/questionario';

  @override
  _QuestionarioPageState createState() => _QuestionarioPageState();
}

class _QuestionarioPageState extends State<QuestionarioPage> {
  Utente user;
  String idUtente;
  List<Parente> listaParenti;
  Questionario questionario;
  String nome = ' ';

  bool _isInit = true; // Se devo fare il rendering del widget
  bool _isLoading = false; // Se sto caricando il questionario

  // Dopo che il widget è stato inizializzato
  @override
  void didChangeDependencies() {
    // Qui ci arrivo diverse volte ma devo scaricare il questionario solo una volta...
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });

      // Prelevo l'utente dal Provider
      user = Provider.of<Utente>(context, listen: false);

      // Prelevo l'id del parente passato dal widget che ha fatto partire il cambio di page
      String idParente = ModalRoute.of(context).settings.arguments as String;
      //print('QuestionarioPage: $idParente');


      // Se non c'è un id vuol dire che è l'utente principale
      if (idParente == null) {
        idParente = user.userId;
        nome = user.nome;
        questionario = Provider.of<Questionario>(context, listen: false);
        idUtente = user.userId;

        // Se ho passato l'id devo compilare il questionario per un parente
      } else {
        listaParenti = user.parentiGestiti;
        Parente p = listaParenti.firstWhere((parente) => parente.userId == idParente);
        nome = p.nome;
        idUtente = idParente;
      }

      // Alla fine scarico l'ultimo questionario di giornata dal server
      Provider.of<Questionario>(context)
          .getUltimoQuestionario(idUtente: idUtente)
          .then((trovato) {
            //print('Risultato getUltimoQuestionario: $trovato');
            // Se non lo trovo ne imposto uno vuoto
            if (!trovato)
              questionario = Questionario(user.authToken, idUtente);
            // Altrimenti scarico il questionario aggiornato dal Provider
            else
              questionario = Provider.of<Questionario>(context, listen: false);

            //print('Questionario definitivo: ${questionario.toString()}');

            setState(() {
              _isLoading = false;
            });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  Widget buildInputRigaSwitch(
    IconData icon,
    String label,
    bool value,
    Function toggleFunction,
  ) {
    /*
     * LayoutBuilder() è il widget che gestisce il rendering del widget contenuto
     *
     * Ha una proprietà builder alla quale dobbiamo passare un context e constraints,
     * uso constraints per calcolare le dimensioni del widget contenuto
     */
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: <Widget>[
            Container(
              width: constraints.maxWidth * 0.15,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColorDark,
                size: 40,
              ),
            ),
            Container(
              width: constraints.maxWidth * 0.60,
              padding: EdgeInsets.only(left: 20),
              // FittedBox restringe il contenuto affinché non vada in overflow rispetto al contenitore
              // In questo caso il testo non va a capo ma si restringe
              child: Text(label),
            ),
            Container(
              width: constraints.maxWidth * 0.25,
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Switch.adaptive(
                activeColor: Theme.of(context).primaryColor,
                value: value,
                onChanged: (newVal) {
                  setState(() {
                    toggleFunction();
                    value = newVal;
                  });
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildInputRigaPiuMeno(
      IconData icon,
      String label,
      double value,
      int cifreDecimali,
      String suffisso,
      Function valuePiu,
      Function valueMeno) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Row(
          children: <Widget>[
            Container(
              width: constraints.maxWidth * 0.15,
              child: Icon(
                icon,
                color: Theme.of(context).primaryColorDark,
                size: 40,
              ),
            ),
            Container(
              width: constraints.maxWidth * 0.60,
              padding: EdgeInsets.only(left: 20),
              // FittedBox restringe il contenuto affinché non vada in overflow rispetto al contenitore
              // In questo caso il testo non va a capo ma si restringe
              child: Text(label),
            ),
            Container(
              width: constraints.maxWidth * 0.25,
              //padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: <Widget>[
                  Text(
                    value.toStringAsFixed(cifreDecimali),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    suffisso,
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 14,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Material(
                          type: MaterialType.transparency,
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColorDark,
                                  width: 1.0),
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0),
                              onTap: () {
                                setState(() {
                                  valuePiu();
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.add,
                                  size: 24.0,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Material(
                          type: MaterialType.transparency,
                          child: Ink(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColorDark,
                                  width: 1.0),
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              //This keeps the splash effect within the circle
                              borderRadius: BorderRadius.circular(1000.0),
                              onTap: () {
                                setState(() {
                                  valueMeno();
                                });
                              },
                              child: Padding(
                                padding: EdgeInsets.all(6.0),
                                child: Icon(
                                  Icons.remove,
                                  size: 24.0,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }



  // Mostra un popUp con gli avvisi
  void _showDialog({String message, bool isError = false}) async {
    if (isError)
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Errore:'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      );
    else
      await showDialog(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: Text(
            'Questionario Inoltrato!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Questionario',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Center(child: Text('Questo è il questionario per:')),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        nome,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TitoloConDivider('Temperatura Corporea'),
                    buildInputRigaPiuMeno(
                      Icons.thermostat_rounded,
                      'Temperatura',
                      questionario.temp,
                      1,
                      '°',
                      questionario.tempPiu,
                      questionario.tempMeno,
                    ),
                    TitoloConDivider('Sintomi Base'),
                    buildInputRigaSwitch(
                      Icons.local_fire_department,
                      'Mal di gola',
                      questionario.malDiGola,
                      questionario.toggleMalDiGola,
                    ),
                    buildInputRigaSwitch(
                      Icons.flash_on_rounded,
                      'Mal di testa',
                      questionario.malDiTesta,
                      questionario.toggleMalDiTesta,
                    ),
                    buildInputRigaSwitch(
                      Icons.accessibility_new_rounded,
                      'Dolori Muscolari',
                      questionario.doloriMuscolari,
                      questionario.toggleDoloriMuscolari,
                    ),
                    buildInputRigaSwitch(
                      Icons.face,
                      'Nausea',
                      questionario.nausea,
                      questionario.toggleNausea,
                    ),
                    buildInputRigaSwitch(
                      Icons.face,
                      'Tosse',
                      questionario.tosse,
                      questionario.toggleTosse,
                    ),
                    buildInputRigaSwitch(
                      Icons.face,
                      'Respiro corto',
                      questionario.respiroCorto,
                      questionario.toggleRespiroCorto,
                    ),
                    TitoloConDivider('Indicatori Psicologici'),
                    buildInputRigaSwitch(
                      Icons.looks_rounded,
                      'Umore',
                      questionario.umore,
                      questionario.toggleUmore,
                    ),
                    TitoloConDivider('Altri Indicatori'),
                    buildInputRigaPiuMeno(
                      Icons.shutter_speed_rounded,
                      'Saturazione Ossigeno',
                      questionario.saturazioneOssigeno,
                      1,
                      '%',
                      questionario.saturazioneOssigenoPiu,
                      questionario.saturazioneOssigenoMeno,
                    ),
                    buildInputRigaPiuMeno(
                      Icons.face,
                      'Frequenza Respiro',
                      questionario.freqRespiro,
                      0,
                      'atti/min',
                      questionario.freqRespiroPiu,
                      questionario.freqRespiroMeno,
                    ),
                    buildInputRigaPiuMeno(
                      Icons.face,
                      'Frequenza Cardiaca',
                      questionario.freqCardiaca,
                      0,
                      'b/m',
                      questionario.freqCardiacaPiu,
                      questionario.freqCardiacaMeno,
                    ),
                    buildInputRigaPiuMeno(
                      Icons.speed_rounded,
                      'Pressione Massima',
                      questionario.pressioneMassima,
                      0,
                      'mmHg',
                      questionario.pressioneMassimaPiu,
                      questionario.pressioneMassimaMeno,
                    ),
                    ButtonFullWidth(
                      () async {
                        questionario.setData();

                        // Upload del questionario sul server
                        try {
                          //print('QuestionarioPage: Invio al server il questionario di: $idUtente');
                          //bool res = await Provider.of<Questionario>(context, listen: false).uploadQuestionario(idUtente: idUtente);
                          bool res = await questionario.uploadQuestionario(idUtente: idUtente);

                          if (res == true) {
                            //print(questionario.toString());
                            const String message = 'Questionario Inoltrato!';
                            _showDialog(message: message, isError: false);

                            // Il server ha risposto negativamente
                          } else {
                            const String errorMessage = 'Errore nell\'upload del questionario. Riprova.';
                            _showDialog(message: errorMessage, isError: true);
                          }

                        // Errori con la richiesta
                        } catch (error) {
                          const String errorMessage = 'Errore nell\'upload del questionario. Riprova.';
                          _showDialog(message: errorMessage, isError: true);
                        }
                      },
                      'Invia Questionario',
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
