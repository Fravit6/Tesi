<?php

/*
 * Otteni un topic dato l'id
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      int 	id 		@required
 *
 * Url:
 *      http://localhost/youcare/topic/getById.php?id=XXX
 *
 * Output:
 *      200 - {"id": "XXX", "data": "XXX", "idAutore": "XXX", "nomeAutore": "XXX", "titolo": "XXX", "testo": "XXX"}
 *      404 - responseMessage: Nessun Topic Trovato.
 *      503 - responseMessage: Parametro non corretto.
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// includo database.php e topic.php per poterli usare
include_once '../config/database.php';
include_once '../models/topic.php';


// Controllo che il parametro sia stato passato
if ( !isset($_GET['id']) || $_GET['id'] == null ) {
    // Nessun id ricevuto: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametro id assente.")
    );
    die;
}


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Topic
$topic = new Topic($db);
$topic->id = $_GET['id'];

// Eseguo la query
$stmt = $topic->getTopicById();

// Errori con la query
if ($stmt['responseCode'] != 200) {
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametro non corretto.")
    );
    die;
}

// Se vengono trovati topic nel db
if ( $stmt['responseList']->rowCount() > 0 ) {
    while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $topic_arr = array(
            "id"  => $id,
            "data" => $data,
            "idAutore" => $idAutore,
            "nomeAutore" => $nomeAutore,
            "titolo" => $titolo,
            "testo" => $testo
        );
    }

    // Restituisco il topic con codice 200
    http_response_code(200);
    echo json_encode($topic_arr);

} else {

    // Nessun topic trovato: errore 404
    http_response_code(404);
    echo json_encode(
        array("responseMessage" => "Nessun Topic Trovato.")
    );
}
?>