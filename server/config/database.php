<?php

/*
 * Classe per la connessione al DB
 */
class Database {

	// Credenziali
	private $host = "localhost";
	private $db_name = "youcare";
	private $username = "root";
	private $password = "";
	public $conn;

	// Connessione al database
	public function getConnection() {

		$this->conn = null;

		try {
			$this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password, array( PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION));
			$this->conn->exec("set names utf8");

		// Controllo la connessione
		} catch (PDOException $exception) {
			echo "Errore di connessione: " . $exception->getMessage();
		}

		return $this->conn;
		}
	}

?>