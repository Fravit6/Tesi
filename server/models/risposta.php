<?php
class Risposta {

	private $conn;
	private $table_name = "risposte";

	// proprietà di una risposta
	public $id;			// Autoincrementale
	public $topicId;
	public $data;		// Autogenerata qui
	public $autoreId;
	public $nomeAutore;
	public $testo;


	// costruttore
	public function __construct($db) {
		$this->conn = $db;
	}


	/*
	 * OPERAZIONI CRUD:
	 */

	// READ Risposta
	function getRisposte() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare le risposte.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM " . $this->table_name . " WHERE topicId = " .$this->topicId;

			$stmt = $this->conn->prepare($query);

			// Eseguo la query
			$stmt->execute();

			$response['responseCode'] = "200";
			$response['responseList'] = $stmt;
			return $response;


		// Errore nell'esecuzione della query
		} catch (PDOException $e) {
			$response['responseCode'] = $e->getCode();
			$response['responseMessage'] = $e->getMessage();
			return $response;
		}

		return $response;
		
	}


	// CREATE Risposta
	function new() {
		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile creare la risposta.");

		try {
			
			$query = "INSERT INTO "
					. $this->table_name . 
					" SET 
						topicId=:topicId, 
						data=:data, 
						autoreId=:autoreId, 
						nomeAutore=:nomeAutore,
						testo=:testo";
			

			$stmt = $this->conn->prepare($query);

			$this->data = date("Y-m-d H:i:s");

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->topicId = htmlspecialchars(strip_tags($this->topicId));
			$this->autoreId = htmlspecialchars(strip_tags($this->autoreId));
			$this->nomeAutore = htmlspecialchars(strip_tags($this->nomeAutore));
			$this->testo = htmlspecialchars(strip_tags($this->testo));


			// Binding dei parametri
			$stmt->bindParam(":data", $this->data);
			$stmt->bindParam(":topicId", $this->topicId);
			$stmt->bindParam(":autoreId", $this->autoreId);
			$stmt->bindParam(":nomeAutore", $this->nomeAutore);
			$stmt->bindParam(":testo", $this->testo);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Risposta creata correttamente.";
				return $response;
			} 

		// Errore nell'esecuzione della query
		} catch (PDOException $e) {
			$response['responseCode'] = $e->getCode();
			$response['responseMessage'] = $e->getMessage();
			return $response;
		}

		return $response;
	}


	// UPDATE 
	// DELETE
	
	}
?>