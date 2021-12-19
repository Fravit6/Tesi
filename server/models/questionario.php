<?php
class Questionario {

	private $conn;
	private $table_name = "questionari";

	// proprietà di un questionario
	public $userId;
	public $data;
	public $temp;
	public $malDiGola;
	public $malDiTesta;
	public $doloriMuscolari;
	public $nausea;
	public $tosse;
	public $respiroCorto;
	public $umore;
	public $saturazioneOssigeno;
	public $freqRespiro;
	public $freqCardiaca;
	public $pressioneMassima;

	// id del medico per le query admin
	public $idMedicoCurante;


	// costruttore
	public function __construct($db) {
		$this->conn = $db;
	}


	/*
	 * OPERAZIONI CRUD:
	 */

	// READ Questionari
	function getQuestionari() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare i questionari.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM " . $this->table_name . " WHERE `userId` = ". $this->userId;

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


	// CREATE Questionario
	function newQuestionario() {
		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile creare il questionario.");

		try {
			
			$query = "INSERT INTO "
					. $this->table_name . 
					" SET 
						userId=:userId, 
						data=:data, 
						temp=:temp, 
						malDiGola=:malDiGola, 
						malDiTesta=:malDiTesta,
						doloriMuscolari=:doloriMuscolari, 
						nausea=:nausea,
						tosse=:tosse,
						respiroCorto=:respiroCorto,
						umore=:umore,
						saturazioneOssigeno=:saturazioneOssigeno,
						freqRespiro=:freqRespiro,
						freqCardiaca=:freqCardiaca,
						pressioneMassima=:pressioneMassima";
			

			$stmt = $this->conn->prepare($query);

			$this->data = date("Y-m-d H:i:s");

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->userId = htmlspecialchars(strip_tags($this->userId));
			//$this->data = htmlspecialchars(strip_tags($this->data));
			$this->temp = htmlspecialchars(strip_tags($this->temp));
			$this->malDiGola = htmlspecialchars(strip_tags($this->malDiGola));
			$this->malDiTesta = htmlspecialchars(strip_tags($this->malDiTesta));
			$this->doloriMuscolari = htmlspecialchars(strip_tags($this->doloriMuscolari));
			$this->nausea = htmlspecialchars(strip_tags($this->nausea));
			$this->tosse = htmlspecialchars(strip_tags($this->tosse));
			$this->respiroCorto = htmlspecialchars(strip_tags($this->respiroCorto));
			$this->umore = htmlspecialchars(strip_tags($this->umore));
			$this->saturazioneOssigeno = htmlspecialchars(strip_tags($this->saturazioneOssigeno));
			$this->freqRespiro = htmlspecialchars(strip_tags($this->freqRespiro));
			$this->freqCardiaca = htmlspecialchars(strip_tags($this->freqCardiaca));
			$this->pressioneMassima = htmlspecialchars(strip_tags($this->pressioneMassima));


			// Binding dei parametri
			$stmt->bindParam(":userId", $this->userId);
			$stmt->bindParam(":data", $this->data);
			$stmt->bindParam(":temp", $this->temp);
			$stmt->bindParam(":malDiGola", $this->malDiGola);
			$stmt->bindParam(":malDiTesta", $this->malDiTesta);
			$stmt->bindParam(":doloriMuscolari", $this->doloriMuscolari);
			$stmt->bindParam(":nausea", $this->nausea);
			$stmt->bindParam(":tosse", $this->tosse);
			$stmt->bindParam(":respiroCorto", $this->respiroCorto);
			$stmt->bindParam(":umore", $this->umore);
			$stmt->bindParam(":saturazioneOssigeno", $this->saturazioneOssigeno);
			$stmt->bindParam(":freqRespiro", $this->freqRespiro);
			$stmt->bindParam(":freqCardiaca", $this->freqCardiaca);
			$stmt->bindParam(":pressioneMassima", $this->pressioneMassima);

			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Questionario creato correttamente.";
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


	// UPDATE Questionario
	function updateQuestionario($dataOld) {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseMessage' => "Impossibile aggiornare il questionario.");

		try {
			
			$query = "UPDATE "
					. $this->table_name . 
					" SET 
						data=:dataNew, 
						temp=:temp, 
						malDiGola=:malDiGola, 
						malDiTesta=:malDiTesta,
						doloriMuscolari=:doloriMuscolari, 
						nausea=:nausea,
						tosse=:tosse,
						respiroCorto=:respiroCorto,
						umore=:umore,
						saturazioneOssigeno=:saturazioneOssigeno,
						freqRespiro=:freqRespiro,
						freqCardiaca=:freqCardiaca,
						pressioneMassima=:pressioneMassima
					  WHERE "
					. $this->table_name .".userId =:userId
					  AND "
					. $this->table_name .".data =:dataOld";
			

			$stmt = $this->conn->prepare($query);

			$this->data = date("Y-m-d H:i:s");

			// strip_tags rimuove i tag html
			// htmlspecialchars rimuove i caratteri html speciali
			$this->userId = htmlspecialchars(strip_tags($this->userId));
			$dataOld = htmlspecialchars(strip_tags($dataOld));
			$this->temp = htmlspecialchars(strip_tags($this->temp));
			$this->malDiGola = htmlspecialchars(strip_tags($this->malDiGola));
			$this->malDiTesta = htmlspecialchars(strip_tags($this->malDiTesta));
			$this->doloriMuscolari = htmlspecialchars(strip_tags($this->doloriMuscolari));
			$this->nausea = htmlspecialchars(strip_tags($this->nausea));
			$this->tosse = htmlspecialchars(strip_tags($this->tosse));
			$this->respiroCorto = htmlspecialchars(strip_tags($this->respiroCorto));
			$this->umore = htmlspecialchars(strip_tags($this->umore));
			$this->saturazioneOssigeno = htmlspecialchars(strip_tags($this->saturazioneOssigeno));
			$this->freqRespiro = htmlspecialchars(strip_tags($this->freqRespiro));
			$this->freqCardiaca = htmlspecialchars(strip_tags($this->freqCardiaca));
			$this->pressioneMassima = htmlspecialchars(strip_tags($this->pressioneMassima));


			// Binding dei parametri
			$stmt->bindParam(":userId", $this->userId);
			$stmt->bindParam(":dataNew", $this->data);
			$stmt->bindParam(":dataOld", $dataOld);
			$stmt->bindParam(":temp", $this->temp);
			$stmt->bindParam(":malDiGola", $this->malDiGola);
			$stmt->bindParam(":malDiTesta", $this->malDiTesta);
			$stmt->bindParam(":doloriMuscolari", $this->doloriMuscolari);
			$stmt->bindParam(":nausea", $this->nausea);
			$stmt->bindParam(":tosse", $this->tosse);
			$stmt->bindParam(":respiroCorto", $this->respiroCorto);
			$stmt->bindParam(":umore", $this->umore);
			$stmt->bindParam(":saturazioneOssigeno", $this->saturazioneOssigeno);
			$stmt->bindParam(":freqRespiro", $this->freqRespiro);
			$stmt->bindParam(":freqCardiaca", $this->freqCardiaca);
			$stmt->bindParam(":pressioneMassima", $this->pressioneMassima);


			// Eseguo la query
			if ($stmt->execute()) {
				$response['responseCode'] = "200";
				$response['responseMessage'] = "Questionario aggiornato correttamente.";
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



	/*
	 * OPERAZIONI ADMIN:
	 */
	// READ Questionari
	function getAllQuestionari() {

		// Array che contiene la risposta della chiamata
		$response = array( 'responseCode' => "400", 'responseList' => "Impossibile trovare i questionari.");

		try {
			// Prelevo tutti i questionari dell'utente
			$query = "SELECT * FROM ". $this->table_name . " t1 JOIN utenti t2 ON t1.userId = t2.userId 
						WHERE 
						t2.idMedicoCurante = :idMedicoCurante";

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
