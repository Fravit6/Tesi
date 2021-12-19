<?php

/*
 * Crea un nuovo questionario dell'utente o del parente
 * 
 * Richiesta: 
 *      POST
 * 
 * Parametri:
 *      String      token                   @required
 *      int(11)     userId                  @required
 *      datetime    data
 *      float       temp
 *      bool        malDiGola
 *      bool        malDiTesta
 *      bool        doloriMuscolari
 *      bool        nausea
 *      bool        tosse
 *      bool        respiroCorto
 *      bool        umore
 *      float       saturazioneOssigeno
 *      float       freqRespiro
 *      float       freqCardiaca
 *      float       pressioneMassima
 *
 * Url:
 *      http://localhost/youcare/questionari/new.php
 *
 * Output:
 *      200 - responseMessage: Questionario creato correttamente.
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
include_once '../models/questionario.php';
include_once '../models/utente.php';
use \Firebase\JWT\JWT;
include_once '../config/core.php';
include_once '../libs/src/BeforeValidException.php';
include_once '../libs/src/ExpiredException.php';
include_once '../libs/src/SignatureInvalidException.php';
include_once '../libs/src/JWT.php';

// Decodifico il JSON ricevuto in PHP
$data = json_decode(file_get_contents("php://input"));

//var_dump($data);

// Controllo se ho ricevuto un id
if ( empty($data->userId) || empty($data->token) ) {
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

// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

// Controllo che l'id passato sia dell'utente
if ( strcmp($inToken->data->userId, $data->userId) != 0 ) {

    // Controllo se è di un parente
    $utente = new Utente($db);
    $utente->userId = $data->userId;
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

// Creo un nuovo oggetto Questionario
$questionario = new Questionario($db);
$questionario->userId = $data->userId;



// Inserisco i valori del nuovo questionario
if (!empty($data->temp)) $questionario->temp = $data->temp;
if (!empty($data->malDiGola)) $questionario->malDiGola = $data->malDiGola;
else $questionario->malDiGola = 0;
if (!empty($data->malDiTesta)) $questionario->malDiTesta = $data->malDiTesta;
else $questionario->malDiTesta = 0;
if (!empty($data->doloriMuscolari)) $questionario->doloriMuscolari = $data->doloriMuscolari;
else $questionario->doloriMuscolari = 0;
if (!empty($data->nausea)) $questionario->nausea = $data->nausea;
else $questionario->nausea = 0;
if (!empty($data->tosse)) $questionario->tosse = $data->tosse;
else $questionario->tosse = 0;
if (!empty($data->respiroCorto)) $questionario->respiroCorto = $data->respiroCorto;
else $questionario->respiroCorto = 0;
if (!empty($data->umore)) $questionario->umore = $data->umore;
else $questionario->umore = 0;
if (!empty($data->saturazioneOssigeno)) $questionario->saturazioneOssigeno = $data->saturazioneOssigeno;
if (!empty($data->freqRespiro)) $questionario->freqRespiro = $data->freqRespiro;
if (!empty($data->freqCardiaca)) $questionario->freqCardiaca = $data->freqCardiaca;
if (!empty($data->pressioneMassima)) $questionario->pressioneMassima = $data->pressioneMassima;




// Se l'utente ha già un questionario di oggi lo aggiorno, altrimenti ne creo uno nuovo
if (($ultimoQuest = _getQuestGiorno($data)) != false) 
    $stmt = $questionario->updateQuestionario($ultimoQuest['data']);
else 
    $stmt = $questionario->newQuestionario();



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






// Funzione che controlla se esiste nel DB un questionario di oggi
// per l'attuale utente
function _getQuestGiorno($data) {
    // Creo un nuovo oggetto Database e ci collego il db
    $database = new Database();
    $db = $database->getConnection();

    // Creo un nuovo oggetto Questionario
    $questionario = new Questionario($db);
    $questionario->userId = $data->userId;
    

    // Prelevo tutti i questionari dell'utente
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

    // se vengono trovati questionari nel database
    if ( $num > 0 ) {
        // array di questionari
        $questionari_arr = [];
        $i = 0;
        while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $questionari_arr[$i++] = array(
                "userId"  => $userId,
                "data" => $data,
                "temp" => $temp,
                "malDiGola" => $malDiGola,
                "malDiTesta" => $malDiTesta,
                "doloriMuscolari" => $doloriMuscolari,
                "nausea" => $nausea,
                "tosse" => $tosse,
                "respiroCorto" => $respiroCorto,
                "umore" => $umore,
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

        // Controllo se l'ultimo questionario è di oggi
        if (strtotime($ultimo['data']) >= strtotime('today'))
            return $ultimo;

        return false;
    }

}


?>
