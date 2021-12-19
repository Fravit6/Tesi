<?php

/*
 * Otteni tutti gli utenti (BLOCCATA!)
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      null
 *
 * Url:
 *      http://localhost/youcare/utente/read.php
 *
 * Output:
 *      200 - {"utenti": [utente1, utente2, ...]}
 *      404 - message: Nessun Utente Trovato.
 *      
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// includo database.php e utente.php per poterli usare
include_once '../config/database.php';
include_once '../models/utente.php';



    // Accesso negato!: errore 403
    http_response_code(403);
    echo json_encode(
        array("message" => "Accesso non consentito.")
    );
    die;






// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Utente
$utente = new Utente($db);

// query products
$stmt = $utente->read();
$num = $stmt->rowCount();

// se vengono trovati utenti nel database
if ( $num > 0 ) {
    // array di utenti
    $utenti_arr = array();
    $utenti_arr["utenti"] = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $utente_item = array(
            "userId"  => $userId,
            "nome" => $nome,
            "cognome" => $cognome,
            "codFiscale" => $codFiscale,
            "codTessera" => $codTessera,
            "notifiche" => $notifiche,
            "idUtenteGestore" => $idUtenteGestore
        );
        array_push($utenti_arr["utenti"], $utente_item);
    }

    // Restituisco gli utenti con codice 200
    http_response_code(200);
    echo json_encode($utenti_arr);

} else {

    // Nessun utente trovato: errore 404
    http_response_code(404);
    echo json_encode(
        array("message" => "Nessun Utente Trovato.")
    );
}
?>