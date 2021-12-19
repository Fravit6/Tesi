import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import './models/auth.dart';
import './models/questionario.dart';
import './models/topics.dart';
import './models/utente.dart';
import './page/auth_screen.dart';
import './page/splash_screen.dart';
import './page/tabsPage.dart';
import './page/homePage.dart';
import './page/questionario_page.dart';
import './page/new_topic_page.dart';
import './page/new_topic_risposta_page.dart';
import './page/forum_page.dart';
import './page/single_topic_page.dart';
import './page/assistenza_telefonica_page.dart';
import './page/impostazioni_page.dart';
import './page/new_familiare_page.dart';

void main() async {
  /*
   * SystemChrome è la classe che mi permette di gestire le impostazioni generali dell'app
   * In questo caso disabilito la modalità landscape
   */
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    // ignore: missing_required_param
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Utente>(
          update: (ctx, auth, previousUserData) => Utente(
            authToken: auth.token,
            userId: auth.userId,
            nome: auth.nome,
            cognome: auth.cognome,
            codFiscale: auth.codFiscale,
            codTessera: auth.codTessera,
            notifiche: auth.notifiche,
          ),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Questionario>(
          update: (ctx, auth, previousQuestionarioData) => Questionario(
            auth.token,
            auth.userId,
          ),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth, Topics>(
          update: (ctx, auth, previousTopicsData) => Topics(
            auth.token,
            auth.userId,
          ),
        ),
      ],



      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'YouCare',
          theme: ThemeData(
            primaryColor: Color.fromRGBO(43, 172, 212, 1),
            primaryColorDark: Color.fromRGBO(72, 125, 141, 1),
            accentColor: Color.fromRGBO(151, 151, 151, 1),
            dividerColor: Color.fromRGBO(240, 240, 240, 1),
            fontFamily: 'RobotoCondensed',
            textTheme: ThemeData.light().textTheme.copyWith(
                  headline1: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  headline2: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  headline3: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  subtitle1: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                  bodyText1: TextStyle(
                    fontSize: 14,
                    color: Color.fromRGBO(102, 102, 102, 1),
                  ),
                ),
          ),

          // Se l'utente è autenticato lo indirizzo alla home
          home: auth.isAuth
              ? TabsPage()
          // Altrimenti provo l'autoLogin con i dati memorizzati sul device
              : FutureBuilder(
            future: auth.tryAutoLogin(),
            builder: (ctx, authResultSnapshot) => authResultSnapshot.connectionState == ConnectionState.waiting
                ? SplashScreen() // Mentre viene eseguito l'autoLogin mostro una transizione
                : AuthScreen(),  // Se il login fallisce mostro la pagina per il login manuale
          ),



          // Albero di navigazione dell'app
          routes: {
            HomePage.pageUrl: (ctx) => HomePage(),
            QuestionarioPage.pageUrl: (ctx) => QuestionarioPage(),
            ForumPage.pageUrl: (ctx) => ForumPage(),
            SingleTopicPage.pageUrl: (ctx) => SingleTopicPage(),
            NewTopicPage.pageUrl: (ctx) => NewTopicPage(),
            NewTopicRispostaPage.pageUrl: (ctx) => NewTopicRispostaPage(),
            AssistenzaTelefonicaPage.pageUrl: (ctx) => AssistenzaTelefonicaPage(),
            ImpostazioniPage.pageUrl: (ctx) => ImpostazioniPage(),
            NewFamiliarePage.pageUrl: (ctx) => NewFamiliarePage(),
          },
          // Operazioni in caso di pagine non registrate in routes
          onGenerateRoute: (settings) {
            return MaterialPageRoute(builder: (ctx) => AuthScreen());
          },
          // Operazioni in caso di problemi con tutti i casi precedenti!
          onUnknownRoute: (settings) {
            return MaterialPageRoute(builder: (ctx) => AuthScreen());
          },
        ),
      ),
    );
  }
}
