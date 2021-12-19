import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/utente.dart';
import '../models/rispostaTopic.dart';
import '../models/topic.dart';
import '../models/topics.dart';
import '../widget/button_full_width.dart';


/*
 * Page per l'inserimento dei topic (da forum_page)
 */
class NewTopicRispostaPage extends StatefulWidget {
  static const pageUrl = '/new-risposta';

  @override
  _NewTopicRispostaPageState createState() => _NewTopicRispostaPageState();
}

class _NewTopicRispostaPageState extends State<NewTopicRispostaPage> {

  // Id del topic al quale allegare la risposta
  String topicPadreId;

  // Proprietà per passare il focus ai field
  final _testoFocusNode = FocusNode();

  // Salvo le info del form in una variabile globale
  // Così da accedervi anche dall'esterno del widget Form
  final _form = GlobalKey<FormState>();

  // Creo l'oggetto topic (vuoto e con id=null)
  RispostaTopic _editedRisposta = RispostaTopic(
    id: null,
    testo: '',
    idAutore: null,
    nomeAutore: '',
    data: DateTime.now(),
  );

  // Valori iniziali del form
  var _initValue = {
    'testo': '',
  };
  var _isInit = true;
  var _isLoading = false;

  // Chiamato dopo il build e dopo initState
  @override
  void didChangeDependencies() {
    // Solo la prima volta
    if (_isInit) {
      // Prelevo l'utente dal Provider
      final user = Provider.of<Utente>(context, listen: false);

      // E aggiorno la risposta inserendo l'id utente e il nome
      _editedRisposta = RispostaTopic(
        id: null,
        testo: _editedRisposta.testo,
        idAutore: user.userId,
        nomeAutore: user.cognome + ' ' + user.nome,
        data: _editedRisposta.data,
      );
    }

    // Mi assicuro di non ripetere alla prossima chiamata
    _isInit = false;
    super.didChangeDependencies();
  }

  // Alla chiusura della page
  @override
  void dispose() {
    // Distruggo i FocusNode e i Controller per evitare un memory leak
    _testoFocusNode.dispose();
    super.dispose();
  }

  // Valido e prelevo i dati inseriti dall'utente
  Future<void> _saveForm() async {
    // Triggero tutti i metodi validator dei Field
    final isValid = _form.currentState.validate();
    // Se qualche Field ha restituiro un errore non salvo i valori
    if (!isValid) return;

    // Triggero tutti i metodi onSave dei field
    _form.currentState.save();

    // Faccio partire l'animazione del caricamento in attesa del server
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Topics>(context, listen: false).uploadRispostaTopic(topicPadreId, _editedRisposta);
    } catch (error) {
      print(error);
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Errore!'),
          content: Text('Qualcosa è andato storto con l\'upload della risposta. Ritenta.'),
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
    }

    // Fine dell'animazione
    setState(() {
      _isLoading = false;
    });

    // Alla fine chiudo la page e torno indietro
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {

    // Prelevo l'id passato dal widget che ha fatto partire il cambio di page
    topicPadreId = ModalRoute.of(context).settings.arguments;

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Nuova Risposta',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
            color: Colors.white,
          ),
        ],
      ),

      // In caso di attesa del server mostro un loading
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 280,
                    child: Form(
                      // Qui salvo i dati del form
                      key: _form,

                      child: ListView(
                        children: <Widget>[
                          TextFormField(
                            initialValue: _initValue['testo'],
                            decoration: InputDecoration(labelText: 'Testo Risposta'),
                            keyboardType: TextInputType.multiline,
                            maxLines: 12,
                            minLines: 6,
                            textInputAction: TextInputAction.done,
                            focusNode: _testoFocusNode,

                            // Logica di validazione
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Inserisci il testo della risposta';
                              return null;
                            },

                            onSaved: (value) {
                              _editedRisposta = RispostaTopic(
                                id: _editedRisposta.id,
                                testo: value,
                                idAutore: _editedRisposta.idAutore,
                                nomeAutore: _editedRisposta.nomeAutore,
                                data: _editedRisposta.data,
                              );
                            },

                            // Alla fine faccio il submit
                            onFieldSubmitted: (value) => _saveForm(),
                          ),
                        ],
                      ),
                    ),
                  ),


                  ButtonFullWidth(_saveForm, 'Aggiungi nuova risposta'),
                ],
              ),
            ),
    );
  }
}
