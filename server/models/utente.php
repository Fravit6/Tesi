<?php
class Utente {

	private $conn;
	private $table_name = "utenti";

	// proprietà di un utente
	public $userId; // autoincrementale
	public $nome;
	public $cognome;
	public $codFiscale;
	public $codTessera;
	public $notifiche;
	public $idUtenteGestore;
	public $email;
	public $password;

	// id del medico per le query admin
	public $idMedicoCurante;

	// costruttore
	public function __construct($db) {
		$this->conn = $db;
	}


	/*
	 * OPERAZIONI CRUD:
	 */

	// READ Utenti ()


	// CREATE PARENTE
	function createParente() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile creare il parente.");

		try {

			$query = "INSERT INTO " . $this->table_name . 
					" SET 
						nome=:nome, 
						cognome=:cognome, 
						codFiscale=:codFiscale, 
						codTessera=:codTessera, 
						notifiche=:notifiche, 
						idUtenteGestore=:idUtenteGestore,
						idMedicoCurante=:idMedicoCurante";

			$stmt = $this->conn->prepare($query);

			// userId è autoincrementale
			$this->idMedicoCurante = 0;

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->nome = htmlspecialchars(strip_tags($this->nome));
			$this->cognome = htmlspecialchars(strip_tags($this->cognome));
			$this->codFiscale = htmlspecialchars(strip_tags($this->codFiscale));
			$this->codTessera = htmlspecialchars(strip_tags($this->codTessera));
			$this->notifiche = htmlspecialchars(strip_tags($this->notifiche));
			$this->idUtenteGestore = htmlspecialchars(strip_tags($this->idUtenteGestore));


			// Binding dei parametri
			$stmt->bindParam(":nome", $this->nome);
			$stmt->bindParam(":cognome", $this->cognome);
			$stmt->bindParam(":codFiscale", $this->codFiscale);
			$stmt->bindParam(":codTessera", $this->codTessera);
			$stmt->bindParam(":notifiche", $this->notifiche);
			$stmt->bindParam(":idUtenteGestore", $this->idUtenteGestore);
			$stmt->bindParam(":idMedicoCurante", $this->idMedicoCurante);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Parente creato correttamente.";
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




	// CREATE UTENTE
	function createUtente() {

		// Salvo una copia della password prima di farne l'hash
		$old_password = $this->password;

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile creare l'utente.");

		try {
			
			$query = "INSERT INTO "
					. $this->table_name . 
					" SET 
						nome=:nome, 
						cognome=:cognome, 
						codFiscale=:codFiscale, 
						codTessera=:codTessera, 
						notifiche=:notifiche,
						email=:email, 
						password=:password,
						idMedicoCurante=:idMedicoCurante";
			

			$stmt = $this->conn->prepare($query);

			// userId è autoincrementale
			$this->idMedicoCurante = 0;

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			//$this->userId = htmlspecialchars(strip_tags($this->userId));
			$this->nome = htmlspecialchars(strip_tags($this->nome));
			$this->cognome = htmlspecialchars(strip_tags($this->cognome));
			$this->codFiscale = htmlspecialchars(strip_tags($this->codFiscale));
			$this->codTessera = htmlspecialchars(strip_tags($this->codTessera));
			$this->notifiche = htmlspecialchars(strip_tags($this->notifiche));
			$this->email = htmlspecialchars(strip_tags($this->email));
			$this->password = htmlspecialchars(strip_tags($this->password));
			
			// hash the password before saving to database
			$this->password  = password_hash($this->password, PASSWORD_BCRYPT);
			$this->password = trim($this->password);

			// Binding dei parametri
			//$stmt->bindParam(":userId", $this->userId);
			$stmt->bindParam(":nome", $this->nome);
			$stmt->bindParam(":cognome", $this->cognome);
			$stmt->bindParam(":codFiscale", $this->codFiscale);
			$stmt->bindParam(":codTessera", $this->codTessera);
			$stmt->bindParam(":notifiche", $this->notifiche);
			$stmt->bindParam(":email", $this->email);
			$stmt->bindParam(":password", $this->password);
			$stmt->bindParam(":idMedicoCurante", $this->idMedicoCurante);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Utente creato correttamente.";
				return $response;
			} 

		// Errore nell'esecuzione della query
		} catch (PDOException $e) {
			// Faccio il roll-back della password
			$this->password = $old_password;

			$response['responseCode'] = $e->getCode();
			$response['responseMessage'] = $e->getMessage();
			return $response;
		}

		// Faccio il roll-back della password
		$this->password = $old_password;
		return $response;
	}



	function getParenti() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare i parenti.");

		try {
			$query = "SELECT * FROM " . $this->table_name . " WHERE `idUtenteGestore` = " . $this->idUtenteGestore;

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



	function getParenteById() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare il parente.");

		try {
			$query = "SELECT * FROM "
					 . $this->table_name . 
					 " WHERE `userId` = " . $this->userId . 
					 " AND `idUtenteGestore` = " . $this->idUtenteGestore;

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




	// DELETE Parente
	function eliminaParente() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile eliminare il parente.");

		try {
			$query = "DELETE FROM " . $this->table_name . " WHERE `userId` = " . $this->userId;

			$stmt = $this->conn->prepare($query);

			// Eseguo la query
			$stmt->execute();

			$response['responseCode'] = "200";
			$response['responseMessage'] = $stmt;
			return $response;


		// Errore nell'esecuzione della query
		} catch (PDOException $e) {
			$response['responseCode'] = $e->getCode();
			$response['responseMessage'] = $e->getMessage();
			return $response;
		}

		return $response;
		
	}





	function getIdGestore() {
		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile trovare l'utente.");

		try {
			$query = "SELECT u.idUtenteGestore FROM "
					. $this->table_name . 
					" u WHERE 
					codFiscale LIKE :codFiscale 
					 AND 
					codTessera = :codTessera";
			

			$stmt = $this->conn->prepare($query);

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->codFiscale = htmlspecialchars(strip_tags($this->codFiscale));
			$this->codTessera = htmlspecialchars(strip_tags($this->codTessera));

			// Binding dei parametri
			$stmt->bindParam(":codFiscale", $this->codFiscale);
			$stmt->bindParam(":codTessera", $this->codTessera);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Utente trovato.";
				$response['responseList'] = $stmt;
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





	function upgradeParente() {
		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile registrare l'utente.");

		try {
			$query = "UPDATE " 
					. $this->table_name . 
					" SET 
					idUtenteGestore = null, 
					email = :email, 
					password = :password 
					 WHERE ("
					. $this->table_name . ".idUtenteGestore IS NOT NULL
					 AND "
					. $this->table_name . ".codFiscale = :codFiscale
					 AND "
					. $this->table_name . ".codTessera = :codTessera)";
			

			$stmt = $this->conn->prepare($query);

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->email = htmlspecialchars(strip_tags($this->email));
			$this->password = htmlspecialchars(strip_tags($this->password));
			$this->codFiscale = htmlspecialchars(strip_tags($this->codFiscale));
			$this->codTessera = htmlspecialchars(strip_tags($this->codTessera));
			
			// hash the password before saving to database
			$this->password  = password_hash($this->password, PASSWORD_BCRYPT);

			// Binding dei parametri
			$stmt->bindParam(":email", $this->email);
			$stmt->bindParam(":password", $this->password);
			$stmt->bindParam(":codFiscale", $this->codFiscale);
			$stmt->bindParam(":codTessera", $this->codTessera);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Utente creato correttamente.";
				$response['responseList'] = $stmt;
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




	// Controlla se esiste un utente con l'email passata e ne preleva i dati
	function emailExists() {

		$query = "SELECT * FROM " . $this->table_name . "
				WHERE email = ? 
				LIMIT 0,1";
	 
		$stmt = $this->conn->prepare($query);
		$this->email = htmlspecialchars(strip_tags($this->email));
		$stmt->bindParam(1, $this->email);
		$stmt->execute();

		if( $stmt->rowCount() > 0 ){
			$row = $stmt->fetch(PDO::FETCH_ASSOC);
			$this->userId = $row['userId'];
			$this->nome = $row['nome'];
			$this->cognome = $row['cognome'];
			$this->codFiscale = $row['codFiscale'];
			$this->codTessera = $row['codTessera'];
			$this->notifiche = $row['notifiche'];
			$this->email = $row['email'];
			$this->password = $row['password'];
	        return true;
	    }

	    return false;
	}




	/*
	 * OPERAZIONI ADMIN:
	 */
	// Get All Utenti
	function getAll() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare gli utenti.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM " . $this->table_name . " 
					 WHERE 
						idMedicoCurante = :idMedicoCurante";

			$stmt = $this->conn->prepare($query);

			$this->idMedicoCurante = htmlspecialchars(strip_tags($this->idMedicoCurante));

			$stmt->bindParam(":idMedicoCurante", $this->idMedicoCurante);

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


}
?>
