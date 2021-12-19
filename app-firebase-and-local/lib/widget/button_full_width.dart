import 'package:flutter/material.dart';


/*
 * Bottone largo 100%
 */
class ButtonFullWidth extends StatelessWidget {
  final Function function;
  final String testo;

  ButtonFullWidth(this.function, this.testo);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 20),
      child: RaisedButton(
        onPressed: function,
        textColor: Colors.white,
        padding: const EdgeInsets.all(14.0),
        color: Theme.of(context).primaryColor,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)),
        child: Text(
          testo,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
