<?php

/*
 * Crea un nuovo topic dell'utente
 * 
 * Richiesta: 
 *      POST
 * 
 * Parametri:
 *      String      token              @required
 *      int       	idAutore           @required
 *      String 		nomeAutore         @required
 *      String 		titolo             @required
 *      String 		testo              @required
 *
 * Url:
 *      http://localhost/youcare/topic/new.php
 *
 * Output:
 *      200 - responseMessage: Topic creato correttamente.
 *      403 - responseMessage: Accesso negato.
 *      503 - responseMessage: (Errori vari con parametri)
 *      
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/database.php';
include_once '../models/topic.php';
include_once '../models/utente.php';
use \Firebase\JWT\JWT;
include_once '../config/core.php';
include_once '../libs/src/BeforeValidException.php';
include_once '../libs/src/ExpiredException.php';
include_once '../libs/src/SignatureInvalidException.php';
include_once '../libs/src/JWT.php';

// Decodifico il JSON ricevuto in PHP
$data = json_decode(file_get_contents("php://input"));

// Controllo se ho ricevuto i parametri richiesti
if ( empty($data->idAutore) || empty($data->nomeAutore) || empty($data->titolo) || empty($data->testo) || empty($data->token) ) {
    // Dati obbligatori mancanti: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametri mancanti.")
    );
    die;
}


// Decodifico il token
$inToken = null;
try {
    $inToken = JWT::decode($data->token, $key, array('HS256'));
} catch (Exception $e) {
    http_response_code(403);
    echo json_encode(
        array("responseMessage" => "Accesso negato, token scaduto o non valido.")
    );
    die;
}


// Controllo che l'id passato sia dell'utente
if ( strcmp($inToken->data->userId, $data->idAutore) != 0 ) {
    http_response_code(403);
    echo json_encode(
        array("responseMessage" => "Accesso negato.")
    );
    die;
}


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Topic
$topic = new Topic($db);
$topic->idAutore = $data->idAutore;
$topic->nomeAutore = $data->nomeAutore;
$topic->titolo = $data->titolo;
$topic->testo = $data->testo;


$stmt = $topic->newtopic();

// Restituisco i risultati della query
if ( strcmp($stmt['responseCode'], "200") == 0 ) {
    http_response_code(200);
    echo json_encode(array("responseMessage" => $stmt['responseMessage']));
} else {
    // 503 servizio non disponibile
    http_response_code(503);
    echo json_encode(array(
        "responseCode" => $stmt['responseCode'],
        "responseMessage" => $stmt['responseMessage']
    ));
}


?>