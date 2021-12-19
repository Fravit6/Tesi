import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/utente.dart';
import '../models/topic.dart';
import '../models/topics.dart';
import '../widget/button_full_width.dart';

/*
 * Page per l'inserimento dei topic (da forum_page)
 */
class NewTopicPage extends StatefulWidget {
  static const pageUrl = '/new-topic';

  @override
  _NewTopicPageState createState() => _NewTopicPageState();
}

class _NewTopicPageState extends State<NewTopicPage> {
  // Proprietà per passare il focus ai field
  final _testoFocusNode = FocusNode();

  // Salvo le info del form in una variabile globale
  // Così da accedervi anche dall'esterno del widget Form
  final _form = GlobalKey<FormState>();

  // Creo l'oggetto topic (vuoto e con id=null)
  Topic _editedTopic = Topic(
    id: null,
    titolo: '',
    testo: '',
    idAutore: null,
    data: DateTime.now(),
  );

  // Valori iniziali del form
  var _initValue = {
    'titolo': '',
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

      // E aggiorno il topic inserendo l'id utente e il nome
      _editedTopic = Topic(
        id: null,
        titolo: _editedTopic.titolo,
        testo: _editedTopic.testo,
        idAutore: user.userId,
        nomeAutore: user.cognome + ' ' + user.nome,
        data: _editedTopic.data,
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
      await Provider.of<Topics>(context, listen: false).newTopic(_editedTopic);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Errore!'),
          content: Text('Qualcosa è andato storto con l\'upload del topic. Ritenta.'),
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

    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Nuovo Topic',
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
                            initialValue: _initValue['titolo'],
                            decoration: InputDecoration(labelText: 'Titolo'),
                            textInputAction: TextInputAction.next,
                            // Al completamento passo il focus al field del testo
                            onFieldSubmitted: (value) {
                              FocusScope.of(context).requestFocus(_testoFocusNode);
                            },

                            // Logica di validazione
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Inserisci il titolo del topic.';
                              return null;
                            },

                            onSaved: (value) {
                              _editedTopic = Topic(
                                id: _editedTopic.id,
                                titolo: value,
                                testo: _editedTopic.testo,
                                idAutore: _editedTopic.idAutore,
                                nomeAutore: _editedTopic.nomeAutore,
                                data: _editedTopic.data,
                              );
                            },
                          ),
                          TextFormField(
                            initialValue: _initValue['testo'],
                            decoration: InputDecoration(labelText: 'Testo Topic'),
                            keyboardType: TextInputType.multiline,
                            maxLines: 12,
                            minLines: 6,
                            textInputAction: TextInputAction.done,
                            focusNode: _testoFocusNode,

                            // Logica di validazione
                            validator: (value) {
                              if (value.isEmpty)
                                return 'Inserisci il testo del topic';
                              return null;
                            },

                            onSaved: (value) {
                              _editedTopic = Topic(
                                id: _editedTopic.id,
                                titolo: _editedTopic.titolo,
                                testo: value,
                                idAutore: _editedTopic.idAutore,
                                nomeAutore: _editedTopic.nomeAutore,
                                data: _editedTopic.data,
                              );
                            },

                            // Alla fine faccio il submit
                            onFieldSubmitted: (value) => _saveForm(),
                          ),
                        ],
                      ),
                    ),
                  ),


                  ButtonFullWidth(_saveForm, 'Aggiungi nuovo topic'),
                ],
              ),
            ),
    );
  }
}
