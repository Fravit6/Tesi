<?php

/*
 * Otteni tutti gli topic
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      null
 *
 * Url:
 *      http://localhost/youcare/topic/getAll.php
 *
 * Output:
 *      200 - {"topic": [topic1, topic2, ...]}
 *      404 - responseMessage: Nessun Topic Trovato.
 *      
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// includo database.php e topic.php per poterli usare
include_once '../config/database.php';
include_once '../models/topic.php';
include_once '../models/risposta.php';


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Topic
$topic = new Topic($db);

// Eseguo la query
$stmt = $topic->getAllTopic();
$num = $stmt['responseList']->rowCount();

// Se vengono trovati topic nel db
if ( $num > 0 ) {
    // array di topic
    $topic_arr = array();
    while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
        extract($row);


        // Carico le risposte del topic

        // Creo un nuovo oggetto Risposta
        $risposta = new Risposta($db);
        $risposta->topicId = $id;

        // Eseguo la query
        $stmt2 = $risposta->getRisposte();
        $num2 = $stmt2['responseList']->rowCount();

        // array di risposte
        $risposte_arr = null;
        // Se vengono trovate risposte nel db
        if ( $num2 > 0 ) {
            $risposte_arr = array();
            while ($row2 = $stmt2['responseList']->fetch(PDO::FETCH_ASSOC)) {
                extract($row2);
                $risposta_item = array(
                    "id"  => $row2['id'],
                    "data" => $row2['data'],
                    "autoreId" => $row2['autoreId'],
                    "nomeAutore" => $row2['nomeAutore'],
                    "testo" => $row2['testo']
                );
                array_push($risposte_arr, $risposta_item);
            }
        }


        $topic_arr[$row['id']] = array(
            "id"  => $row['id'],
            "data" => $row['data'],
            "idAutore" => $row['idAutore'],
            "nomeAutore" => $row['nomeAutore'],
            "titolo" => $row['titolo'],
            "testo" => $row['testo'],
            "risposte" => $risposte_arr
        );
    }

    // Restituisco i topic con codice 200
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