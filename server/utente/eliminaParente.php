<?php

/*
 * Elimina un parente
 * 
 * Richiesta: 
 *		GET
 * 
 * Input:		
 * 		int(11) 	userId		@required
 *      String      token       @required
 *
 * Url:
 * 		http://localhost/youcare/utente/eliminaParente.php?userId=XXX&token=XXX
 *
 * Output:
 *		200 - responseMessage: Parente eliminato correttamente.
 *      403 - responseMessage: Accesso negato.
 *		503 - responseMessage: (Errori vari con parametri)
 *		
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';
include_once '../models/utente.php';
use \Firebase\JWT\JWT;
include_once '../config/core.php';
include_once '../libs/src/BeforeValidException.php';
include_once '../libs/src/ExpiredException.php';
include_once '../libs/src/SignatureInvalidException.php';
include_once '../libs/src/JWT.php';


// Controllo di aver ricevuto i parametri
if ( !isset($_GET['userId']) || $_GET['userId'] == null ||
     !isset($_GET['token']) || $_GET['token'] == null ) {
    // Nessun userId o token ricevuto: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametri mancanti.")
    );
    die;
}


// Decodifico il token
$inToken = null;
try {
    $inToken = JWT::decode($_GET['token'], $key, array('HS256'));
} catch (Exception $e) {
    http_response_code(403);
    echo json_encode(
        array("responseMessage" => "Accesso negato, token scaduto o non valido.")
    );
    die;
}


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Creo un nuovo oggetto Utente
$utente = new Utente($db);
$utente->userId = $_GET['userId'];





// Controllo se l'id passato è di un parente
$utente = new Utente($db);
$utente->userId = $_GET['userId'];
$utente->idUtenteGestore = $inToken->data->userId;
$stmtParente = $utente->getParenteById();

// Se non vengono trovati parenti nel database
$num = $stmtParente['responseList']->rowCount();
if ( $stmtParente['responseCode'] != 200 || $num <= 0 ) {
    http_response_code(403);
    echo json_encode(
        array("responseMessage" => "Accesso negato.")
    );
    die;
}


// Eseguo la query
$stmt = $utente->eliminaParente();


if ( strcmp ( $stmt['responseCode'], "200" ) == 0 ) {
	http_response_code(200);
	echo json_encode(array("responseMessage" => "Parente eliminato correttamente."));
} else {
	// 503 servizio non disponibile
	http_response_code(503);
	echo json_encode(array(
		"responseCode" => $stmt['responseCode'],
		"responseMessage" => $stmt['responseMessage']
	));
}


?>