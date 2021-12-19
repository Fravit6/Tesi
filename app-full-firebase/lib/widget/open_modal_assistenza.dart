import 'package:flutter/material.dart';

import '../widget/button_full_width.dart';

/*
 * Widget che mostra il form per l'assistenza telefonica
 */
class OpenModalAssistenza extends StatefulWidget {
  @override
  _OpenModalAssistenzaState createState() => _OpenModalAssistenzaState();
}

class _OpenModalAssistenzaState extends State<OpenModalAssistenza> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
          padding: EdgeInsets.only(
            top: 40,
            left: 10,
            right: 10,
            bottom: 40, // Altezza della tastiera virtuale +10
          ),
          child: Column(
            children: <Widget>[
              Text(
                'Richiedi Assistenza',
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 30),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 80),
                child: Text(
                  'Concorderemo insieme le chiamate e la loro frequenza!',
                  style: Theme.of(context).textTheme.subtitle1,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              // TODO
              ButtonFullWidth(() {}, 'Richiedi Subito'),
            ],
          ),
        ),
    );
  }
}
