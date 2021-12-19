const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
// Qui inserisco le funzioni server di Firebase

// Trigger per la creazione di un nuovo messaggio
// (in pratica qualsiasi documento in notifiche/xxx)
exports.myFunction = functions.firestore
    .document("notifiche/{message}")
    .onCreate((snap, context) => {
      return admin.messaging().sendToTopic("parReg", {
        notification: {
          title: "Parente registrato",
          body: snap.data().nomeParente+" si è iscritto all'app!",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      });
    });
