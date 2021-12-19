import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
 * Widget che mostra una riga cliccabile con un campo testo e un bottone a destra
 */
class RigaLabelFieldButton extends StatelessWidget {
  final String label;
  final Function onClick;

  RigaLabelFieldButton(this.label, this.onClick);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        return GestureDetector(
          onTap: onClick,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    width: constraints.maxWidth * 0.40,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    iconSize: 20,
                    padding: const EdgeInsets.all(2.0),
                    icon: Icon(Icons.arrow_forward_ios_rounded),
                    color: Theme.of(context).primaryColor,
                    onPressed: onClick,
                  ),
                ]),
          ),
        );
      },
    );
  }
}
