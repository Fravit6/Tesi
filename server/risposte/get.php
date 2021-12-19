<?php

/*
 * Otteni tutte le risposte del topic
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      int       	topicId            @required
 *
 * Url:
 *      http://localhost/youcare/risposte/get.php?topicId=XXX
 *
 * Output:
 *      200 - {"risposte": [risposta1, risposta2, ...]}
 *      404 - responseMessage: Nessuna Risposta Trovata.
 *      
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';
include_once '../models/risposta.php';


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();


if ( !isset($_GET['topicId']) || $_GET['topicId'] == null ) {
    // Dati obbligatori mancanti: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametro mancante.")
    );
    die;
}


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Risposta
$risposta = new Risposta($db);
$risposta->topicId = $_GET['topicId'];


// Eseguo la query
$stmt = $risposta->getRisposte();
$num = $stmt['responseList']->rowCount();

// Se vengono trovate risposte nel db
if ( $num > 0 ) {
    // array di risposte
    $risposte_arr = array();
    while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $risposte_arr[$id] = array(
            "id"  => $id,
            "data" => $data,
            "autoreId" => $autoreId,
            "nomeAutore" => $nomeAutore,
            "testo" => $testo
        );
    }

    // Restituisco le risposte con codice 200
    http_response_code(200);
    echo json_encode($risposte_arr);

} else {
    // Nessuna risposta trovata: errore 404
    http_response_code(404);
    echo json_encode(
        array("responseMessage" => "Nessuna Risposta Trovata.")
    );
}
?>