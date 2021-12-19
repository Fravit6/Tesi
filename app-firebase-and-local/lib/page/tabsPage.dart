import 'package:flutter/material.dart';

import '../page/new_topic_page.dart';
import './homePage.dart';
import './forum_page.dart';
import './assistenza_telefonica_page.dart';
import './impostazioni_page.dart';

/*
 * Footer App con le tabs per la navigazione
 *
 * E' considerata l'homepage dell'app
 */
class TabsPage extends StatefulWidget {
  @override
  _TabsPageState createState() => _TabsPageState();
}

class _TabsPageState extends State<TabsPage> {

  // Lista delle pagine linkate nelle tab
  List<Map<String, Object>> _pages;
  // Pagina selezionata dall'utente
  int _selectedPageIndex = 0;

  /*
   * Funzione per modificare lo stato del Widget e memorizzare la tab premuta
   */
  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  // Costruisco il widget Appbar per modificarlo a piacimento
  Widget buildAppBar() {
    // Se sono nella pagina Forum devo avere il bottone per l'aggiunta in alto
    if (_selectedPageIndex == 1) {
      return AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          _pages[_selectedPageIndex]['title'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () => Navigator.pushNamed(context, NewTopicPage.pageUrl),
            icon: Icon(Icons.add),
            textColor: Colors.white,
            label: Text('Nuovo Topic'),
          ),
        ],
      );
    } else {
      return AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          _pages[_selectedPageIndex]['title'],
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }

  @override
  void initState() {
    _pages = [
      {'page': HomePage(), 'title': 'YouCare'},
      {'page': ForumPage(), 'title': 'Forum'},
      {'page': AssistenzaTelefonicaPage(), 'title': 'Assistenza'},
      {'page': ImpostazioniPage(), 'title': 'Impostazioni'},
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: _pages[_selectedPageIndex]['page'], // Mostra la pagina che è stata selezionata
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage, // Cambia pagina!
        backgroundColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).accentColor,
        selectedItemColor: Theme.of(context).primaryColor,
        // Memorizzo quale tab devo mostrare come "attiva"
        currentIndex: _selectedPageIndex,
        // Le tab hanno un effetto simile ad uno "slider"...
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.chat),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.phone),
            label: 'Assistenza',
          ),
          BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
