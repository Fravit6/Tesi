import 'package:flutter/material.dart';

/*
 * Titolo di sezione con linea divisore bicolore
 */
class TitoloConDivider extends StatelessWidget {
  final String testo;

  TitoloConDivider(this.testo);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 30),
        Text(
          testo,
          style: Theme.of(context).textTheme.headline2,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 3,
                color: Color.fromRGBO(232, 232, 232, 1),
              ),
              Container(
                width: 100,
                height: 3,
                color: Theme.of(context).primaryColor,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
