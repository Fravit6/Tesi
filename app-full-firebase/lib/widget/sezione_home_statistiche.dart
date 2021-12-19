import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';

/*
 * Widget della sezione delle statistiche in Home
 */
class SezioneHomeStatistiche extends StatefulWidget {
  @override
  _SezioneHomeStatisticheState createState() => _SezioneHomeStatisticheState();
}

class _SezioneHomeStatisticheState extends State<SezioneHomeStatistiche> {
  int _currentSelection = 0;
  Map<int, Widget> _children = {
    0: Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 40),
      child: Text(
        'Dati App',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    ),
    1: Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 40),
      child: Text(
        'Sintomi',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          alignment: Alignment.center,
          child: MaterialSegmentedControl(
            children: _children,
            selectionIndex: _currentSelection,
            borderColor: Color.fromRGBO(200, 200, 200, 1),
            selectedColor: Theme.of(context).primaryColor,
            unselectedColor: Colors.white,
            borderRadius: 40.0,
            //disabledChildren: [3],
            onSegmentChosen: (index) {
              setState(() {
                _currentSelection = index;
              });
            },
          ),
        ),
        (_currentSelection == 0)
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Column(
                    children: <Widget>[
                      Image.asset(
                        'assets/images/grafico-utenti-small.jpg',
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Text(
                            'Quante più persone utilizzano quest’app tanto più possiamo essere precisi con le statistiche che ti mostriamo. Condividila con amici e parenti per aiutarci nella lotta al Covid-19'),
                      ),
                    ],
                  ),
                ),
              )
            : Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/statistiche-small.jpg',
                  fit: BoxFit.fitWidth,
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}