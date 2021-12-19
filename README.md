
![image](https://user-images.githubusercontent.com/19221987/146670463-bf3ce29e-dec0-42e3-ac93-61dd2a945a75.png)
![image](https://user-images.githubusercontent.com/19221987/146670468-dd6c81eb-8891-41ee-a742-184422135ffd.png)
![image](https://user-images.githubusercontent.com/19221987/146670474-0f46ebea-43a7-457a-9c09-0ba221ea9eec.png)
![image](https://user-images.githubusercontent.com/19221987/146670480-d8c8b11d-502e-489a-aa54-561296064532.png)
![image](https://user-images.githubusercontent.com/19221987/146670488-c7cf279d-5081-42a7-8a27-42af525d067e.png)

![image](https://user-images.githubusercontent.com/19221987/146670513-03cb0418-23ea-4848-9a67-c9c001736edf.png)





# App Firebase + DB Locale

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






# App Full Firebase

## App YouCare (versione database Firebase)

Server: https://youcare-3d0ce-default-rtdb.firebaseio.com/

File di configurazione: lib/config.dart


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



## Firebase Realtime Database

Un "dump" del database è salvato in JSON in lib\youcare-3d0ce-default-rtdb-export.json

Tutti gli account creati su Firebase hanno come password "password" (p minuscola)


## Firebase Rule per Realtime Database

```
{
  "rules": {
    "codiciFiscali": {
      // Chiunque può leggere (mi serve per la registrazione)
      ".read": true,
      ".write": "auth != null",
      // Posso solo creare una nuova entry e modificarne una di un mio parente
      "$codFiscIdGen": {
       ".write": "auth != null && (!data.exists() || data.val().contains(auth.uid) || !newData.exists())",
      },
    },

    "questionari": {
      // Accesso solo ai propri dati e a quelli dei parenti gestiti
      "$userId": {
        ".read": "$userId.contains(auth.uid)",
        ".write": "$userId.contains(auth.uid)",
      },
    },

    "topic": {
      ".read": "auth != null",
    	".write": "auth != null",
    },

    "utenti": {
      // L'indice degli utenti
      ".indexOn": ["userId", "idUtenteGestore"],

      // Accesso in lettura solo ai propri dati e a quelli dei parenti gestiti
      ".read": "(auth.uid != null && query.orderByChild == '/userId' && query.equalTo == auth.uid) ||
      					(auth.uid != null && query.orderByChild == '/idUtenteGestore' && query.equalTo == auth.uid)",
    		".write": "auth != null",

      // Accesso in scrittura solo ai propri dati e a quelli dei parenti gestiti
      "$user_id": {
        ".write": "(newData.child('userId').val() == auth.uid || newData.child('idUtenteGestore').val() == auth.uid) ||
        					 (data.child('idUtenteGestore').val() == auth.uid)",

        // Controlli sul campo codFiscale
        "codFiscale": {
          // Posso inserire solo nuovi codFiscale oppure gestire quello dell'utente corrente
          ".validate": "
              !root.child('codiciFiscali').child(newData.val()).exists() ||
              root.child('codiciFiscali').child(newData.val()).val() == newData.child('codFiscale').val()"
        	},
      	},
    },
  },
}
```









# Server PHP e DB

## NOTE DATABASE:

Nella cartella _DB ho caricato il file .zip per la creazione del DB.

Tutte le password memorizzate sono cifrate tramite password_hash(), in chiaro sarebbero tutte "password" (sia per gli utenti che per il medico).


## NOTE VARIE:

Per la configurazione sono presenti alcuni file nella directory config.
* database.php: conserva le credenziali per il DB.
* core.php: conserva le informazioni per le librerie di Firebase per la gestione del token di accesso.
