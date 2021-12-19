<?php

/*
 * Otteni la lista di parenti dell'utente
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      int(11)     idUtenteGestore         @required
 *      String      token                   @required
 *
 * Url:
 *      http://localhost/youcare/utente/getParenti.php?idUtenteGestore=XXX&token=XXX
 *
 * Output:
 *      200 - {"parenti": [parente1, parente2, ...]}
 *      403 - responseMessage: Accesso negato.
 *      404 - responseMessage: Nessun Parente Trovato.
 *      503 - responseMessage: (Errori vari con parametri)
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
if ( !isset($_GET['idUtenteGestore']) || $_GET['idUtenteGestore'] == null ||
     !isset($_GET['token']) || $_GET['token'] == null ) {
    // Nessun idUtenteGestore o token ricevuto: errore 503
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
$utente->idUtenteGestore = $_GET['idUtenteGestore'];


// Controllo che l'id passato sia dell'utente
if ( strcmp($inToken->data->userId, $_GET['idUtenteGestore']) != 0 ) {
    http_response_code(403);
    echo json_encode(
        array("responseMessage" => "Accesso negato.")
    );
    die;
}



// Eseguo la query
$stmt = $utente->getParenti();

if($stmt['responseCode'] != 200) {
    // Problemi con la query: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametro non corretto")
    );
    die;
}

$num = $stmt['responseList']->rowCount();

// se vengono trovati parenti nel database
if ( $num > 0 ) {
    // array di utenti
    $parenti_arr = [];
    while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $parenti_arr[$userId] = array(
            "userId"  => $userId,
            "nome" => $nome,
            "cognome" => $cognome,
            "codFiscale" => $codFiscale,
            "codTessera" => $codTessera,
            "notifiche" => $notifiche
        );
    }

    // Restituisco gli utenti con codice 200
    http_response_code(200);
    echo json_encode($parenti_arr);

} else {

    // Nessun utente trovato: errore 404
    http_response_code(404);
    echo json_encode(
        array("responseMessage" => "Nessun Parente Trovato.")
    );
}
?>