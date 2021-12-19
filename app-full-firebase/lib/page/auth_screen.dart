import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
import '../models/http_exception.dart';

// Enum per la tipologia di form
enum AuthMode { Signup, Login }

/*
 * Page con il form di Login/Registrazione
 */
class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    // Prelevo le info sulle dimensioni dello schermo del device
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      // resizeToAvoidBottomInset: false,

      body: Stack(
        children: <Widget>[
          // Sfondo pagina
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Color.fromRGBO(43, 172, 212, 1).withOpacity(0.8),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height, // 100vh
              width: deviceSize.width, // 100wh
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 94.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).primaryColor,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'YouCare',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * Widget per il form di autenticazione
 */
class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  // Login o registrazione
  AuthMode _authMode = AuthMode.Login;

  // Map con i dati inseriti dall'utente
  Map<String, String> _authData = {
    'nome': ' ',
    'cognome': ' ',
    'codFiscale': ' ',
    'codTessera': ' ',
    'email': ' ',
    'password': ' ',
  };
  bool _ricordami = false;

  var _isLoading = false;
  final _passwordController = TextEditingController();

  // Mostra un popUp con l'avviso di errore
  void _showErrorDialog(String message) {
    showDialog(
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
  }

  // Faccio il submit del form
  void _submit() async {
    FocusScope.of(context).unfocus();
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
    // Eseguo il Login o la registrazione
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
          _ricordami,
        );
      } else {
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['nome'],
          _authData['cognome'],
          _authData['codFiscale'],
          _authData['codTessera'],
          _authData['email'],
          _authData['password'],
          _ricordami,
        );
      }
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
        errorMessage = 'Il Codice Fiscale inserito è già utilizzato da un altro utente!';
      }

      _showErrorDialog(errorMessage);

      // Errori generici
    } catch (error) {
      print(error);
      const String errorMessage = 'Errore durante l\'autenticazione. Riprova.';
      _showErrorDialog(errorMessage);
    }

    // Fine animazione
    setState(() {
      _isLoading = false;
    });
  }

  // Passo da login a registrazione o viceversa
  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      //margin: EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 760 : 300,
        constraints: BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 760 : 300),
        width: deviceSize.width * 0.85,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Nome'),
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value.isEmpty) return 'Inserisci il nome!';
                            return null;
                          }
                        : null,
                    onSaved: (value) {
                      _authData['nome'] = value;
                    },
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Cognome'),
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value.isEmpty) return 'Inserisci il cognome!';
                            return null;
                          }
                        : null,
                    onSaved: (value) {
                      _authData['cognome'] = value;
                    },
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Cod. Fiscale'),
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value.isEmpty) return 'Inserisci il codice fiscale!';
                            return null;
                          }
                        : null,
                    onSaved: (value) {
                      _authData['codFiscale'] = value;
                    },
                  ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Cod. Tessera Sanitaria'),
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value.isEmpty) return 'Inserisci il codice della tessera sanitaria!';
                            return null;
                          }
                        : null,
                    onSaved: (value) {
                      _authData['codTessera'] = value;
                    },
                  ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Conferma Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Le password non coincidono!';
                            }
                            return null;
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),


                // Checkbox per memorizzare le credenziali
                Row(
                  children: [
                    Checkbox(
                      value: _ricordami,
                      visualDensity: VisualDensity.compact,
                      activeColor: Theme.of(context).primaryColor,
                      onChanged: (bool newValue) => setState(() {_ricordami = newValue;}),
                    ),
                    Text('Ricorda credenziali'),
                  ],
                ),


                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'REGISTRATI'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                  ),

                // Bottone per cambiare modalità login/registrazione
                FlatButton(
                  child: Text('PASSA ${_authMode == AuthMode.Login ? 'ALLA REGISTRAZIONE' : 'AL LOGIN'}'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  // Riduco la parte cliccabile del bottone
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
