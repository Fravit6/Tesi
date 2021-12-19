import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/http_exception.dart';
import '../models/utente.dart';
import '../models/auth.dart';

/*
 * Pagina per l'inserimento di un nuovo familiare da gestire
 */
class NewFamiliarePage extends StatefulWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/new-familiare';

  @override
  _NewFamiliarePageState createState() => _NewFamiliarePageState();
}

class _NewFamiliarePageState extends State<NewFamiliarePage> {
  // Proprietà per passare il focus ai field
  final _cognomeFocusNode = FocusNode();
  final _codFiscaleFocusNode = FocusNode();
  final _codTesseraFocusNode = FocusNode();

  // Salvo le info del form in una variabile globale
  // Così da accedervi anche dall'esterno del widget Form
  final _formKey = GlobalKey<FormState>();

  // Map con i dati inseriti dall'utente
  Map<String, String> _parenteData = {
    'nome': ' ',
    'cognome': ' ',
    'codFiscale': ' ',
    'codTessera': ' ',
    'userId': ' ', // Dell'attuale utente
  };

  var _isLoading = false;

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
            'Parente Registrato!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
              child: Text('Puoi vedere i tuoi familiari registrati nelle impostazioni dell\'app.'),
            ),
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

  // Faccio il submit del form
  void _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    // Salvo i valori del form
    _formKey.currentState.save();
    // Inizio animazione
    setState(() {
      _isLoading = true;
    });
    // Eseguo la registrazione
    try {

      // Creo il parente
      await Provider.of<Utente>(context, listen: false).signupParente(
        // Invento un id univoco del parente
        _parenteData['userId'] + _parenteData['codFiscale'],
        _parenteData['nome'],
        _parenteData['cognome'],
        _parenteData['codFiscale'],
        _parenteData['codTessera'],
      );



      // Errori personalizzati
    } on HttpException catch (error) {
      var errorMessage = 'Autenticazione fallita';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Questo indirizzo email è già presente.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Indirizzo email non valido.';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Questa password è troppo debole.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email non trovata.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Password non valida';
      } else if (error.toString().contains('CODFISCALE_OCCUPATO')) {
        errorMessage = 'Questo utente è già gestito.';
      }

      _showDialog(message: errorMessage, isError: true);

      // Errori generici
    } catch (error) {
      print(error);
      const String errorMessage = 'Errore durante l\'aggiunta. Riprova.';
      _showDialog(message: errorMessage, isError: true);
    } finally {
      //print(_parenteData);
      const String message = 'Parente registrato con successo!';
      _showDialog(message: message, isError: false);
    }

    // Fine animazione
    setState(() {
      _isLoading = false;
    });
  }

  // Alla chiusura della page
  @override
  void dispose() {
    // Distruggo i FocusNode per evitare un memory leak
    _cognomeFocusNode.dispose();
    _codFiscaleFocusNode.dispose();
    _codTesseraFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Prelevo l'utente dal Provider
    final user = Provider.of<Utente>(context, listen: false);
    _parenteData['userId'] = user.userId;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Nuovo Familiare',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              Center(child: Text('Iscrivi un nuovo familiare per il quale gestire i questionari!')),
              const SizedBox(height: 8),


              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Nome'),
                        textInputAction: TextInputAction.next,
                        // Al completamento passo il focus al field del cognome
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_cognomeFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Inserisci il nome!';
                          return null;
                        },
                        onSaved: (value) {
                          _parenteData['nome'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Cognome'),
                        textInputAction: TextInputAction.next,
                        focusNode: _cognomeFocusNode,
                        // Al completamento passo il focus al field del Cod. Fiscale
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_codFiscaleFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty) return 'Inserisci il cognome!';
                          return null;
                        },
                        onSaved: (value) {
                          _parenteData['cognome'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Cod. Fiscale'),
                        textInputAction: TextInputAction.next,
                        focusNode: _codFiscaleFocusNode,
                        // Al completamento passo il focus al field del Cod. Tessera
                        onFieldSubmitted: (value) {
                          FocusScope.of(context).requestFocus(_codTesseraFocusNode);
                        },
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Inserisci il codice fiscale!';
                          return null;
                        },
                        onSaved: (value) {
                          _parenteData['codFiscale'] = value;
                        },
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Cod. Tessera Sanitaria'),
                        textInputAction: TextInputAction.done,
                        focusNode: _codTesseraFocusNode,
                        validator: (value) {
                          if (value.isEmpty)
                            return 'Inserisci il codice della tessera sanitaria!';
                          return null;
                        },
                        onSaved: (value) {
                          _parenteData['codTessera'] = value;
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        RaisedButton(
                          child: const Text('REGISTRA PARENTE'),
                          onPressed: _submit,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
