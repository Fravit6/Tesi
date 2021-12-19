import './models/topic.dart';
import './models/rispostaTopic.dart';

RispostaTopic ris1 = RispostaTopic(
  id: 'ris1',
  testo: 'Risposta 1: Labore sunt veniam amet est. Minim nisi dolor eu ad '
      'incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat '
      'aliquip occaecat.',
  idAutore: 'fv1',
  data: new DateTime(2021, 1, 1),
);
RispostaTopic ris2 = RispostaTopic(
  id: 'ris2',
  testo: 'Risposta 2: Labore sunt veniam amet est. Minim nisi dolor eu ad '
      'incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat '
      'aliquip occaecat.',
  idAutore: 'user2',
  data: new DateTime(2021, 1, 2),
);
RispostaTopic ris9 = RispostaTopic(
  id: 'ris9',
  testo: 'Risposta 9: Labore sunt veniam amet est. Minim nisi dolor eu ad '
      'incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat '
      'aliquip occaecat.',
  idAutore: 'user9',
  data: new DateTime(2021, 1, 9),
);
RispostaTopic ris3 = RispostaTopic(
  id: 'ris3',
  testo: 'Risposta 3: Labore sunt veniam amet est. Minim nisi dolor eu ad '
      'incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat '
      'aliquip occaecat.',
  idAutore: 'user3',
  data: new DateTime(2021, 1, 3),
);
RispostaTopic ris4 = RispostaTopic(
  id: 'ris4',
  testo: 'Risposta 4: Labore sunt veniam amet est. Minim nisi dolor eu ad '
      'incididunt cillum elit ex ut. Dolore exercitation nulla tempor consequat '
      'aliquip occaecat.',
  idAutore: 'user4',
  data: new DateTime(2021, 1, 4),
);




List<Topic> DUMMY_TOPIC = [
  Topic(
    id: 'topic1',
    titolo:
        'Titolo Topic 1 che ha un titolo lunghissimo che non voglio troncare '
        'in nessun modo perché così ho deciso di fare e quindi va bene '
        'così e basta',
    testo: 'Testo topic 1: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut.\n Dolore exercitation nulla tempor '
        'consequat aliquip occaecat. Labore sunt veniam amet est. Minim '
        'nisi dolor eu ad incididunt cillum elit ex ut. Dolore exercitation '
        'nulla tempor consequat aliquip occaecat.\n\n Labore sunt veniam amet est. '
        'Minim nisi dolor eu ad incididunt cillum elit ex ut. Dolore '
        'exercitation nulla tempor consequat aliquip occaecat. Labore sunt '
        'veniam amet est.\n\n Minim nisi dolor eu ad incididunt cillum elit ex ut. '
        'Dolore exercitation nulla tempor consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 1),
    risposte: [ris1, ris2, ris9, ris4],
  ),
  Topic(
    id: 'topic2',
    titolo: 'Titolo Topic 2',
    testo: 'Testo topic 2: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 2),
    risposte: [ris1, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic3',
    titolo: 'Titolo Topic 3',
    testo: 'Testo topic 3: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 3),
    risposte: [ris1, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic4',
    titolo: 'Titolo Topic 4',
    testo: 'Testo topic 4: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 4),
    risposte: [ris1, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic5',
    titolo: 'Titolo Topic 5',
    testo: 'Testo topic 5: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 5),
    risposte: [ris9, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic6',
    titolo: 'Titolo Topic 6',
    testo: 'Testo topic 6: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 6),
    risposte: [ris1, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic7',
    titolo: 'Titolo Topic 7',
    testo: 'Testo topic 7: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 7),
    risposte: [ris1, ris2, ris3, ris4],
  ),
  Topic(
    id: 'topic8',
    titolo: 'Titolo Topic 8',
    testo: 'Testo topic 8: Labore sunt veniam amet est. Minim nisi dolor eu ad '
        'incididunt cillum elit ex ut. Dolore exercitation nulla tempor '
        'consequat aliquip occaecat.',
    idAutore: 'fv1',
    data: new DateTime(2020, 12, 8),
    risposte: [ris1, ris2, ris3, ris4],
  ),
];
