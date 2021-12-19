import 'package:flutter/material.dart';

import '../widget/button_full_width.dart';
import '../widget/open_modal_assistenza.dart';

/*
 * Pagina della richiesta di Assistenza Telefonica
 */
class AssistenzaTelefonicaPage extends StatelessWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/assistenza-telefonica';

  /*
   * Mostra pannello in evidenza sulla schermata con il form per l'assistenza telefonica
   * ( dal pulsante ButtonFullWidth() )
   */
  void _startAddNewTransaction(BuildContext ctx) {
    /*
     * Funzione di Flutter per mostrare il pannello in basso
     * Chiede in input il context dell'app e un builder
     * Il builder deve avere come parametro un altro context e restituisce i widget che devono essere inclusi nel pannello
     *
     * In questo caso il widget è gestito all'esterno, gli passo infatti il puntatore della funzione come parametro
     *
     * GestureDetector è il widget che controlla i tap dell'utente, lo utilizzo per agganciare una funzione
     * che non esegue nulla al tap dell'utente (in questo modo non si chiude il pannello al click dell'utente)
     */
    showModalBottomSheet(
      context: ctx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      backgroundColor: Colors.white,
      builder: (bCtx) {
        return GestureDetector(
          onTap: () {},
          child: OpenModalAssistenza(),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Container(
                height: 50,
                color: Colors.white,
              ),
              Positioned(
                right: 50,
                left: 50,
                bottom: 0,
                child: Container(
                  width: 170.0,
                  height: 170.0,
                  decoration: new BoxDecoration(
                    border: Border.all(
                      width: 5,
                      color: Colors.white,
                      style: BorderStyle.solid,
                    ),
                    shape: BoxShape.circle,
                    image: new DecorationImage(
                      fit: BoxFit.cover,
                      image: AssetImage('assets/images/call-center.jpg'),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Text(
                  'Servizio di Tele-Aiuto',
                  style: Theme.of(context).textTheme.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 20),
                  child: Text(
                    'I nostri operatori, secondo le più opportune modalità di approccio di durata e di contenuto, monitorano '
                    'con discrezione le situazioni personali e ambientali, gli eventuali problemi psico-fisici e le '
                    'eventuali condizioni di rischio.\n\n'
                    ' Forniamo anche un adeguato sostegno psicologico anche con funzioni di socializzazione e di risveglio '
                    'degli interessi.\n\n'
                    'Richiedi subito una telefonata e non esitare a chiedere aiuto!',
                    style: Theme.of(context).textTheme.bodyText1,
                    textAlign: TextAlign.left,
                  ),
                ),
                const SizedBox(height: 60),
                ButtonFullWidth(() => _startAddNewTransaction(context),
                    'Richiedi Assistenza'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
