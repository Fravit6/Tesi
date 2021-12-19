import 'package:flutter/material.dart';

/*
 * Widget che mostra una riga con due campi non modificabili (e uno switch opzionale)
 */
class RigaLabelFieldView extends StatefulWidget {
  final String label;
  final String text;
  bool switchValue;
  final Function switchFunction;

  // switchValue è opzionale in quanto mostra uno switch al posto del testo
  RigaLabelFieldView(this.label, this.text,
      {this.switchValue, this.switchFunction});

  @override
  _RigaLabelFieldViewState createState() => _RigaLabelFieldViewState();
}

class _RigaLabelFieldViewState extends State<RigaLabelFieldView> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 2,
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          child: Row(children: <Widget>[
            Container(
              width: constraints.maxWidth * 0.40,
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            (widget.switchValue != null)
                ? Container(
                    width: 75,
                    height: 20,
                    padding: EdgeInsets.only(left: 0),
                    margin: EdgeInsets.all(0),
                    child: Switch.adaptive(
                      activeColor: Theme.of(context).primaryColor,
                      value: widget.switchValue,
                      onChanged: (newVal) {
                        setState(() {
                          widget.switchFunction();
                          widget.switchValue = newVal;
                        });
                      },
                    ),
                  )
                : Container(
                    width: constraints.maxWidth * 0.60,
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
          ]),
        );
      },
    );
  }
}
