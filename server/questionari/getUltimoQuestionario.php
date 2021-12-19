<?php

/*
 * Otteni l'ultimo questionario dell'utente o del parente
 * 
 * Richiesta: 
 *      GET
 * 
 * Parametri:
 *      int(11)     userId         @required
 *      String      token          @required
 *
 * Url:
 *      http://localhost/youcare/questionari/getUltimoQuestionario.php?userId=XXX&token=XXX
 *
 * Output:
 *      200 - {"userId": "XXX", "data": "XXX", "temp": "XX", "malDiGola": "1", ...}
 *      403 - responseMessage: Accesso negato.
 *      404 - responseMessage: Nessun Questionario Trovato.
 *      503 - responseMessage: (Errori vari con parametri)
 *      
 */

header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include_once '../config/database.php';
include_once '../models/questionario.php';
include_once '../models/utente.php';
use \Firebase\JWT\JWT;
include_once '../config/core.php';
include_once '../libs/src/BeforeValidException.php';
include_once '../libs/src/ExpiredException.php';
include_once '../libs/src/SignatureInvalidException.php';
include_once '../libs/src/JWT.php';


// Controllo se è stato passato un id
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

// Creo un nuovo oggetto Questionario
$questionario = new Questionario($db);
$questionario->userId = $_GET['userId'];


// Controllo che l'id passato sia dell'utente
if ( strcmp($inToken->data->userId, $_GET['userId']) != 0 ) {

    // Controllo se è di un parente
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

}



// Prelevo tutti i questionari dell'utente o del parente
$stmt = $questionario->getQuestionari();

if($stmt['responseCode'] != 200) {
    // Problemi con la query: errore 503
    http_response_code(503);
    echo json_encode(
        array("responseMessage" => "Parametro non corretto")
    );
    die;
}

$num = $stmt['responseList']->rowCount();

// Se vengono trovati questionari nel database
if ( $num > 0 ) {
    $questionari_arr = [];
    $i = 0;
    while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
        extract($row);
        $questionari_arr[$i++] = array(
            "userId"  => $userId,
            "data" => $data,
            "temp" => $temp,
            "malDiGola" => $malDiGola == 1 ? true : false,
            "malDiTesta" => $malDiTesta == 1 ? true : false,
            "doloriMuscolari" => $doloriMuscolari == 1 ? true : false,
            "nausea" => $nausea == 1 ? true : false,
            "tosse" => $tosse == 1 ? true : false,
            "respiroCorto" => $respiroCorto == 1 ? true : false,
            "umore" => $umore == 1 ? true : false,
            "saturazioneOssigeno" => $saturazioneOssigeno,
            "freqRespiro" => $freqRespiro,
            "freqCardiaca" => $freqCardiaca,
            "pressioneMassima" => $pressioneMassima
        );
    }


    // Prelevo l'ultimo questionario dalla lista
    $ultimo = $questionari_arr[0];
    $data_ultimo = strtotime($questionari_arr[0]['data']);
    foreach ($questionari_arr as $q) {
    	if( strtotime($q['data']) > $data_ultimo ) {
    		$data_ultimo = strtotime($q['data']);
    		$ultimo = $q;
    	}
	}

    // Controllo che l'ultimo questionario è di oggi
    if (date('Y-m-d') == date('Y-m-d', strtotime($ultimo['data']))) {
        // Restituisco l'ultimo questionario con codice 200
        http_response_code(200);
        echo json_encode($ultimo);
        die;
    } else {
        // Nessun questionario trovato: errore 404
        http_response_code(404);
        echo json_encode(
            array("responseMessage" => "Nessun Questionario giornaliero trovato.")
        );
        die;
    }

} else {

    // Nessun questionario trovato: errore 404
    http_response_code(404);
    echo json_encode(
        array("responseMessage" => "Nessun Questionario giornaliero trovato.")
    );
}
?>