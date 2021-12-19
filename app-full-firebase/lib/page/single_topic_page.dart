import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Lo utilizzo per formattare le date
import 'package:intl/date_symbol_data_local.dart'; // per avere le date in italiano


import '../models/utente.dart';
import '../models/topic.dart';
import '../models/topics.dart';
import '../models/rispostaTopic.dart';
import '../page/new_topic_risposta_page.dart';
import '../widget/titolo_con_divider.dart';
import '../widget/button_full_width.dart';

/*
 * Pagina del topic (accessibile da forum_page)
 *
 * Contiene i dati del topic, le risposte ed i pulsanti per aggiungere una nuova risposta
 */
class SingleTopicPage extends StatelessWidget {
  // Salvo in una proprietà static const il nome della pagina per l'accesso
  // Evito in questo modo di dover riscrivere manualmente la stringa altrove
  static const pageUrl = '/single-topic';

  @override
  Widget build(BuildContext context) {
    // Imposto la lingua locale alle date...
    initializeDateFormatting('it_IT', null);

    // Prelevo l'id passato dal widget che ha fatto partire il cambio di page
    String topicId = ModalRoute.of(context).settings.arguments;

    // Scarico i topic dal provider
    final List<Topic> allTopic = Provider.of<Topics>(context).allTopic;
    // Prelevo il topic by id
    Topic topic = allTopic.firstWhere((topic) => topic.id == topicId);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Topic',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          FlatButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(NewTopicRispostaPage.pageUrl, arguments: topic.id),
            icon: Icon(Icons.add),
            textColor: Colors.white,
            label: Text('Nuova Risposta'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: <Widget>[
              // Intestazione
              Text(
                topic.titolo,
                style: Theme.of(context).textTheme.headline1,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    topic.nomeAutore,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline3,
                  ),
                  Text(
                    DateFormat.yMMMd('it_IT').format(topic.data),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Corpo
              Text(topic.testo),
              const SizedBox(height: 60),

              // Risposte
              if (topic.risposte != null)
                TitoloConDivider('Risposte'),
              if (topic.risposte != null)
                const SizedBox(height: 20),
              if (topic.risposte != null)
              ...(topic.risposte).map((risposta) {
                return Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          risposta.nomeAutore,
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        Text(
                          DateFormat.yMMMd('it_IT').format(risposta.data),
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(risposta.testo),
                    const SizedBox(height: 40),
                  ],
                );
              }).toList(),

              const SizedBox(height: 60),

              // Bottone finale
              ButtonFullWidth(() => Navigator.of(context).pushNamed(NewTopicRispostaPage.pageUrl, arguments: topic.id), 'Aggiungi Risposta'),
            ],
          ),
        ),
      ),
    );
  }
}
