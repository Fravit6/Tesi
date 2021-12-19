<?php

/*
 * Effettua il login per un utente
 * 
 * Richiesta: 
 *		POST
 * 
 * Input:
 *		String(100) email 				@required
 *		String(30)  password 			@required
 *
 * Url:
 * 		http://localhost/youcare/utente/login.php
 *
 * Output:
 *		200 	- responseMessage: Utente creato correttamente.
 *				- token
 *				- scadenza
 *				- userId
 *				- nome
 *				- cognome
 *				- codFiscale
 *				- codTessera
 *				- email
 *				- notifiche
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
use \Firebase\JWT\JWT;

// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();
$utente = new Utente($db);

// Decodifico il JSON ricevuto in PHP
$data = json_decode(file_get_contents("php://input"));

if( !empty($data->email) && !empty($data->password) ) {

	$utente->email = $data->email;	
	$email_exists = $utente->emailExists();

	// Librerie per la generazione del Token
	include_once '../config/core.php';
	include_once '../libs/src/BeforeValidException.php';
	include_once '../libs/src/ExpiredException.php';
	include_once '../libs/src/SignatureInvalidException.php';
	include_once '../libs/src/JWT.php';
	 
	// Controllo se la mail esiste e se la password è corretta
	if ( $email_exists && password_verify($data->password, $utente->password) ) {

	 	// Creo il token
		$token = array(
			"iat" => $creatoIl,
			"exp" => $scadenza,
			"iss" => $emittente,
			"data" => array(
				"userId" => $utente->userId,
				"nome" => $utente->nome,
				"cognome" => $utente->cognome,
				"codFiscale" => $utente->codFiscale,
				"codTessera" => $utente->codTessera,
				"email" => $utente->email
			)
		);		

		// Restituisco il token generato
		http_response_code(200);
		$jwt = JWT::encode($token, $key);
		echo json_encode(
				array(
					"responseMessage" => "Login eseguito con successo.",
					"token" => $jwt,
					"scadenza" => $scadenza,
					"userId" => $utente->userId,
					"nome" => $utente->nome,
					"cognome" => $utente->cognome,
					"codFiscale" => $utente->codFiscale,
					"codTessera" => $utente->codTessera,
					"email" => $utente->email,
					"notifiche" => ($utente->notifiche == 1) ? true : false,
				)
		    );
	 
	} else {
		// 400 Richiesta errata
		http_response_code(400);
		echo json_encode(array(
			"responseCode" => "400",
			"responseMessage" => "Impossibile eseguire il login per l'utente. I dati sono incompleti"
		));
	}

}






?>