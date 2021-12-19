# Applicazione YouCare: Server PHP e DB

## NOTE DATABASE:

Nella cartella _DB ho caricato il file .zip per la creazione del DB.

Tutte le password memorizzate sono cifrate tramite password_hash(), in chiaro sarebbero tutte "password" (sia per gli utenti che per il medico).


## NOTE VARIE:

Per la configurazione sono presenti alcuni file nella directory config.
* database.php: conserva le credenziali per il DB.
* core.php: conserva le informazioni per le librerie di Firebase per la gestione del token di accesso. 
