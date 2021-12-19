# you_care_local_app

## App YouCare

Server: http://water.cluelab.di.unisa.it/youcare/

File di configurazione per le API del server: lib/config.dart


## Registrare App su Firebase (android):
La configurazione con Firebase Firestore avviene inserendo il file google-services.json,
(presente in android/app/src/google-services.json). Questo file viene fornito direttamente da Google
all'atto di registrazione di una nuova app android nel progetto Firebase.
Altre modifiche sono state effettuate al file build.gradle (presente nella stessa directory), queste
modifiche sono indipendenti rispetto all'account Google.


## Registrare App su Firebase (web):
Per configurare Firebase con la versione web dell'applicazione si deve inserire uno script
(fornito da Google in fase di registrazione) all'interno di web/index.html.


## Nota Firebase Functions:
Nella cartella "functions" è presente il codice per le funzioni Firebase.
Attenzione: Firebase Functions prevede costi per le chiamate effettuate!
Il file index.js deve essere caricato direttamente sul server.
