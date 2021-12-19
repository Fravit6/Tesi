import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:you_care/models/http_exception.dart';

import '../models/auth.dart';
import '../models/utente.dart';
import '../models/parente.dart';
import './new_familiare_page.dart';
import '../widget/titolo_con_divider.dart';
import '../widget/button_full_width.dart';
import '../widget/riga_label_field_view.dart';
import '../widget/riga_dismissible_impostazioni.dart';
import '../widget/riga_label_field_button.dart';

/*
 * Pagina con le impostazioni
 */
class ImpostazioniPage extends StatelessWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/impostazioni';

  @override
  Widget build(BuildContext context) {
    // Prelevo l'utente dal Provider
    final user = Provider.of<Utente>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TitoloConDivider('Personali'),
            RigaLabelFieldView('Nome', user.nome + ' ' + user.cognome),
            RigaLabelFieldView('Cod. Fiscale', user.codFiscale),
            RigaLabelFieldView('Cod. Tessera', user.codTessera),
            RigaLabelFieldView('Password', '**************'),
            RigaLabelFieldView('Notifiche', '',
                switchValue: user.notifiche,
                switchFunction: user.toggleNotifiche),

            TitoloConDivider('Familiari Gestiti'),
            SezioneParentiGestiti(),

            const SizedBox(height: 30),
            ButtonFullWidth(() {
              Navigator.of(context).pushReplacementNamed('/');
              Provider.of<Auth>(context, listen: false).logout();
            }, 'Logout'),
          ],
        ),
      ),
    );
  }
}


/*
 * Widget con la sezione per l'aggiunta di un nuovo parente
 * e la lista dei parenti gestiti
 */
class SezioneParentiGestiti extends StatefulWidget {
  @override
  _SezioneParentiGestitiState createState() => _SezioneParentiGestitiState();
}

class _SezioneParentiGestitiState extends State<SezioneParentiGestiti> {

  List<Parente> listaParenti;

  var _isInit = true;
  var _isLoading = false;

  // Chiamato dopo il build e dopo initState
  @override
  void didChangeDependencies() {
    // Faccio partire l'animazione del caricamento in attesa del server
    setState(() {
      _isLoading = true;
    });

    // Solo la prima volta
    if (_isInit) {
      // Scarico l'utente dal provider
      final user = Provider.of<Utente>(context, listen: false);

      // Alla fine scarico la lista dei parenti e tolgo l'animazione
      user.getParenti().then((trovati) {
        listaParenti = user.parentiGestiti;
        setState(() {
          _isLoading = false;
        });
      });
    }

    // Mi assicuro di non ripetere alla prossima chiamata
    _isInit = false;
    super.didChangeDependencies();
  }


  // Funzione passata al widget dismissible per eliminare un parente gestito
  Future<bool> _eliminaParente(String idParente) async {

    try {
      await Provider.of<Utente>(context, listen: false).eliminaParente(idParente);
    // Errori
    } catch (error) {
      print('Problema con eliminazione parente');
      print(error);
      return false;
    }

    // Elimino localmente
    listaParenti.removeWhere((parente) => parente.userId == idParente);
    print('Parente eliminato');
    return true;
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Center(child: CircularProgressIndicator()),
      );

    if (listaParenti != null && listaParenti.isNotEmpty) {
      return Column(
        children: <Widget>[
          RigaLabelFieldButton(
              'Nuovo familiare', () =>
              Navigator.of(context).pushNamed(NewFamiliarePage.pageUrl)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            child: Text(
                'Di seguito trovi i familiari che hai registrato per inviarne i questionari.\n'
                    'Per non gestire più un familiare esegui uno swipe verso sinistra.'),
          ),
          ...(listaParenti).map((parente) {
            return RigaDismissibleImpostazioni(
              idParente: parente.userId,
              nomeParente: parente.nome,
              cognomeParente: parente.cognome,
              codFiscaleParente: parente.codFiscale,
              codTesseraParente: parente.codTessera,
              onDelete: () => _eliminaParente(parente.userId),
            );
          }).toList(),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          RigaLabelFieldButton(
              'Nuovo familiare', () =>
              Navigator.of(context).pushNamed(NewFamiliarePage.pageUrl)),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            child: Text(
                'Registra un tuo familiare per poter inviare il questionario al posto suo!\n'
                    'Prenditi cura anche degli altri!'),
          ),
        ],
      );
    }
  }


}
