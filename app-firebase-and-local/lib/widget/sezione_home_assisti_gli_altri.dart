import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/parente.dart';
import '../models/utente.dart';
import '../page/questionario_page.dart';
import '../page/new_familiare_page.dart';
import './button_full_width.dart';

/*
 * Widget in home con i radio bottoni per la scelta del parente
 */
class SezioneHomeAssistiGliAltri extends StatefulWidget {
  @override
  _SezioneHomeAssistiGliAltriState createState() => _SezioneHomeAssistiGliAltriState();
}

class _SezioneHomeAssistiGliAltriState extends State<SezioneHomeAssistiGliAltri> {
  // Valore da memorizzare per la scelta del parente per il questionario
  String _idParenteSelezionato = ' ';

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
          Text(
              'Questa è un\'app di "buon vicinato", puoi aiutare un amico o parente nella lotta al Covid-19.\n\n'
              'Prenditi cura anche degli altri! \n Compila il questionario per gli utenti precedentemente registrati:'),
          const SizedBox(height: 10),
          ...(listaParenti).map((parente) {
            return Column(
              children: [
                RadioListTile(
                  contentPadding: EdgeInsets.all(0.0),
                  value: parente.userId,
                  groupValue: _idParenteSelezionato,
                  title: Text(
                    parente.nome + ' ' + parente.cognome,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (val) => setState(() => _idParenteSelezionato = val),
                ),
                Divider(color: Colors.black12, height: 2),
              ],
            );
          }).toList(),
          ButtonFullWidth(() {
            if (_idParenteSelezionato != ' ')
              return Navigator.of(context).pushNamed(QuestionarioPage.pageUrl,
                  arguments: _idParenteSelezionato);
            else
              return showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('Errore:'),
                  content: Text('Seleziona il parente per il quale vuoi inoltrare il questionario'),
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
          }, 'Compila il questionario'),
        ],
      );
    } else {
      return Column(
        children: <Widget>[
          Text(
              'Questa è un\'app di "buon vicinato", puoi aiutare un amico o parente nella lotta al Covid-19.\n\n'
              'Registra un tuo familiare per poter inviare il questionario al posto suo!'
              'Prenditi cura anche degli altri!\n'),
          ButtonFullWidth(
              () => Navigator.of(context).pushNamed(NewFamiliarePage.pageUrl),
              'Aggiungi parente'),
        ],
      );
    }
  }
}
