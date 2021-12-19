import 'package:flutter/material.dart';

/*
 * Widget delle righe dei familiari, possono essere eliminate con uno swipe laterale
 */
class RigaDismissibleImpostazioni extends StatelessWidget {
  final String idParente;
  final String nomeParente;
  final String cognomeParente;
  final String codFiscaleParente;
  final String codTesseraParente;
  final Function onDelete;

  RigaDismissibleImpostazioni({
    @required this.idParente,
    @required this.nomeParente,
    @required this.cognomeParente,
    @required this.codFiscaleParente,
    @required this.codTesseraParente,
    @required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    /*
     * Dismissible permette di eliminare l'elemento con uno swipe orizzontale
     *
     * Necessita di una key per rendere l'elemento unico all'interno dell'albero dei widget
     * Imposto come unico swipe quello destra > sinistra
     */
    return Dismissible(
      // Proprietà Dismissible
      key: ValueKey(idParente),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Sei sicuro?'),
            content: Text('Sei sicuro di non voler più gestire questo familiare? \n'
                'Una volta eliminato non sarà più possibile gestirlo!'),
            actions: <Widget>[
              FlatButton(child: Text('No'), onPressed: () {
                Navigator.of(ctx).pop(false);
              },),
              FlatButton(child: Text('Si'), onPressed: () {
                Navigator.of(ctx).pop(true);
              },),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),

      // Stile Dismissible
      background: Container(
        color: Theme.of(context).errorColor,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Icon(
          Icons.clear,
          color: Colors.white,
          size: 36,
        ),
      ),

      // Contenuto Dismissible
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            title: Text(nomeParente + ' ' + cognomeParente),
            subtitle: Text(codFiscaleParente),
            //trailing: Text('trailing'),
          ),
        ),
      ),
    );
  }
}
