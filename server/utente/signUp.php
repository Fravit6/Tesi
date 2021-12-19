<?php

/*
 * Registra un nuovo utente o un nuovo parente in base ai parametri passati:
 * 	parente => idUtenteGestore != null
 *  utente 	=> email != null && password != null
 * 
 * Richiesta: 
 *		POST
 * 
 * Input:
 * 		String 		nome 				@required
 * 		String 		cognome 			@required
 * 		String 	 	codFiscale 			@required
 * 		int 	 	codTessera			@required
 * 		bool 		notifiche			
 * 		int 	 	idUtenteGestore		
 *		String 		email
 *		String 		password
 *
 * Url:
 * 		http://localhost/youcare/utente/signUp.php
 *
 * Output:
 *		200 	- responseMessage: Utente creato correttamente 	- isAnUpgrade: bool - idOldGestore: int
 *		400 	- responseMessage: Parametri input errati
 *		503 	- responseMessage: (Errore con la query)
 *		23000 	- responseMessage: "SQLSTATE[23000]: Integrity constraint violation: 1062 Duplicate entry 'XXXX' for key 'codFiscale'"
 *		
 */

//headers
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once '../config/database.php';
include_once '../models/utente.php';

// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();
$utente = new Utente($db);

// Decodifico il JSON ricevuto in PHP
$data = json_decode(file_get_contents("php://input"));

if( !empty($data->nome) &&
	!empty($data->cognome) &&
	!empty($data->codFiscale) &&
	!empty($data->codTessera) ) {

	// Alla fine restituirò se si tratta di un upgrade di un parente
	$isAnUpgrade = false;
	$idOldGestore = null;

	//userId; // Autoincrementale
	$utente->nome = $data->nome;
	$utente->cognome = $data->cognome;
	$utente->codFiscale = $data->codFiscale;
	$utente->codTessera = (int)$data->codTessera;
	if (!empty($data->notifiche)) $utente->notifiche = (int)$data->notifiche;
	else $utente->notifiche = 1;

	// Sto registrando un parente
	if (!empty($data->idUtenteGestore)) {
		$utente->idUtenteGestore = $data->idUtenteGestore;

		$stmt = $utente->createParente();

	// Sto registrando un utente
	} else {
		if( empty($data->email) || empty($data->password) ) {
			http_response_code(400);
			echo json_encode(array(
				"responseCode" => "400",
				"responseMessage" => "Impossibile creare l'utente. I dati sono incompleti"
			));
			die;
		}
		$utente->email = $data->email;
		$utente->password = $data->password;
		$stmt = $utente->createUtente();

		// Un parente si sta registrando come nuovo utente
		// (questo errore esce se l'email e/o il codFiscale sono già inseriti)
		if ($stmt['responseCode'] == 23000) {

			// Ottengo l'id dell'utente che prima gestiva il parente che si sta registrando
			$stmt = $utente->getIdGestore();
			while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
				extract($row);
				$idOldGestore = $row['idUtenteGestore'];
			}

			$stmt = $utente->upgradeParente();
			$isAnUpgrade = true;

			$num = $stmt['responseList']->rowCount();
			// Se non vengono aggiornati utenti
			if ( $num <= 0 ) {
				// 400 Richiesta errata (era solo l'email occupata)
				http_response_code(400);
				echo json_encode(array(
					"responseCode" => "400",
					"responseMessage" => "Utente già registrato nei nostri sistemi."
				));
				die;
			}

		}

	}

	// Mando la query al DB
	if ( strcmp ( $stmt['responseCode'], "200" ) == 0 ) {
		http_response_code(200);
		echo json_encode(array(
			"responseMessage" => "Utente creato correttamente.",
			"isAnUpgrade" => $isAnUpgrade,
			"idOldGestore" => $idOldGestore
		));
	} else {
		// 503 servizio non disponibile
		http_response_code(503);
		echo json_encode(array(
			"responseCode" => $stmt['responseCode'],
			"responseMessage" => $stmt['responseMessage']
		));
	}


} else {
	// 400 Richiesta errata
	http_response_code(400);
	echo json_encode(array(
		"responseCode" => "400",
		"responseMessage" => "Impossibile creare l'utente. I dati sono incompleti."
	));
}
?>
