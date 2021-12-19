<?php
class Topic {

	private $conn;
	private $table_name = "topic";

	// proprietà di un topic
	public $id;			// Autoincrementale
	public $data;		// Autogenerata qui
	public $idAutore;
	public $nomeAutore;
	public $titolo;
	public $testo;


	// costruttore
	public function __construct($db) {
		$this->conn = $db;
	}


	/*
	 * OPERAZIONI CRUD:
	 */

	// READ Topic
	function getAllTopic() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare i topic.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM " . $this->table_name;

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

	function getTopicById() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare il topic.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM " . $this->table_name . " WHERE `id` = ". $this->id;

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


	// CREATE Topic
	function newTopic() {
		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile creare il topic.");

		try {
			
			$query = "INSERT INTO "
					. $this->table_name . 
					" SET 
						data=:data, 
						idAutore=:idAutore, 
						nomeAutore=:nomeAutore, 
						titolo=:titolo,
						testo=:testo";
			

			$stmt = $this->conn->prepare($query);

			$this->data = date("Y-m-d H:i:s");

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->idAutore = htmlspecialchars(strip_tags($this->idAutore));
			$this->nomeAutore = htmlspecialchars(strip_tags($this->nomeAutore));
			$this->titolo = htmlspecialchars(strip_tags($this->titolo));
			$this->testo = htmlspecialchars(strip_tags($this->testo));


			// Binding dei parametri
			$stmt->bindParam(":data", $this->data);
			$stmt->bindParam(":idAutore", $this->idAutore);
			$stmt->bindParam(":nomeAutore", $this->nomeAutore);
			$stmt->bindParam(":titolo", $this->titolo);
			$stmt->bindParam(":testo", $this->testo);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Topic creato correttamente.";
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