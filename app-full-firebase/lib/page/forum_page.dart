import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano

import '../models/topic.dart';
import '../models/topics.dart';
import '../page/single_topic_page.dart';
import '../page/new_topic_page.dart';
import '../widget/button_full_width.dart';

/*
 * Pagina Forum con i vari Topic e i pulsanti per crearne uno nuovo
 */
class ForumPage extends StatefulWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/forum';

  @override
  _ForumPageState createState() => _ForumPageState();
}

class _ForumPageState extends State<ForumPage> {
  bool _isInit = true; // Se devo fare il rendering del widget
  bool _isLoading = false; // Se sto caricando i topic

  // Dopo che il widget è stato inizializzato
  @override
  void didChangeDependencies() {
    // Qui ci arrivo diverse volte ma devo scaricare i topic solo una volta...
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Topics>(context, listen: false).getTopics().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }

    _isInit = false;
    super.didChangeDependencies();
  }

  // Vai alla page del singolo topic
  void selezionaTopic(BuildContext ctx, String idTopic) {
    Navigator.of(ctx).pushNamed(
      SingleTopicPage.pageUrl,
      arguments: idTopic,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Imposto la lingua locale alle date...
    initializeDateFormatting('it_IT', null);

    final mediaQuery = MediaQuery.of(context);

    // Scarico i topic dal provider (in ordine inverso)
    List<Topic> allTopic = Provider.of<Topics>(context).allTopic.reversed.toList();

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // 80vh (tolto il bottone finale e il padding del telefono
                    height: (mediaQuery.size.height - mediaQuery.padding.top - 100) * 0.8,
                    child: ListView.builder(
                      itemCount: allTopic.length,
                      itemBuilder: (ctx, index) {
                        return InkWell(
                          onTap: () => selezionaTopic(context, allTopic[index].id),
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: new Container(
                                          padding:
                                              new EdgeInsets.only(right: 2.0),
                                          child: new Text(
                                            allTopic[index].titolo,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline3,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        DateFormat.yMMMd('it_IT')
                                            .format(allTopic[index].data),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Flexible(
                                        child: new Container(
                                          padding:
                                              new EdgeInsets.only(right: 2.0),
                                          child: new Text(
                                            allTopic[index].testo,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Divider(
                                  height: 10,
                                  thickness: 3,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ButtonFullWidth(() => Navigator.pushNamed(context, NewTopicPage.pageUrl), 'Nuovo Topic'),
                ],
              ),
            ),
          );
  }
}
