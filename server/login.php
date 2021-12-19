<?php
/*
 * Pagina Login Medico
 */

// Informazioni SEO
$meta_title = "Login";
$meta_description = "Effettua il login a YouCare";


// Inizializzo la sessione
session_start();
 
// Controllo se ho già effettuato il login
if(isset($_SESSION["loggedin"]) && $_SESSION["loggedin"] === true){
	header("location: index.php");
	exit;
}
 
// Include config file
include_once 'config/database.php';
include_once 'models/utente.php';


// Creo un nuovo oggetto Database e ci collego il db
$database = new Database();
$db = $database->getConnection();

$username = $password = "";
$username_err = $password_err = "";
 
// Se ho ricevuto dei dati tramite una richiesta POST
if ($_SERVER["REQUEST_METHOD"] == "POST") {
 
    // Controllo che sia stato inserito un username
    if(empty(trim($_POST["username"]))){
        $username_err = "Inserisci l'username fornito.";
    } else{
        $username = trim($_POST["username"]);
    }
    
    // Verifico che sia stata inserita una password
    if (empty(trim($_POST["password"]))) {
        $password_err = "Inserisci la password fornita.";
    } else {
        $password = trim($_POST["password"]);
    }
    
    // Controllo le credenziali inserite
    if (empty($username_err) && empty($password_err)) {
       
        $sql = "SELECT * FROM medici WHERE username = :username";
        
        if($stmt = $db->prepare($sql)){
            // Faccio il bind dei parametri
            $stmt->bindParam(":username", $param_username, PDO::PARAM_STR);
            
            // Faccio il set dei parametri
            $param_username = trim($_POST["username"]);
            
            // Eseguo la query
            if($stmt->execute()){
                // Se la query ha restituito un medico
                if($stmt->rowCount() == 1){
                    if($row = $stmt->fetch()){
                        $id = $row["id"];
                        $username = $row["username"];
                        $hashed_password = $row["password"];
                        $nomeMedico = $row["nome"];
                        if(password_verify($password, $hashed_password)){
                            // Anche la password è corretta
                            session_start();
                            
                            // Salvo i dati del DB nelle variabili di sessione
                            $_SESSION["loggedin"] = true;
                            $_SESSION["id"] = $id;
                            $_SESSION["username"] = $username;
                            $_SESSION["nome"] = $nomeMedico;                           
                            
                            // Faccio il redirect sulla pagina index
                            header("location: index.php");
                        } else{
                            // La password non è corretta
                            $password_err = "La password inserita non &egrave; corretta.";
                        }
                    }
                } else{
                    // L'username inserito non è nel DB
                    $username_err = "Nessun account Admin con questa username";
                }
            } else{
                echo "Oops! Qualcosa &egrave; andato storto. Riprova fra poco.";
            }

            // Chiudo lo stmt
            unset($stmt);
        }
    }
    
    // Chiudo la connessione
    unset($db);
}


include("header.php");
?>
 



<div id="home_testata" class="page_testata">
	
	<div class="spazio_titolo_pagina">
		<h1 class="titolo_pagina">Login</h1>
	</div>
	<div class="spazio_sottotitolo_pagina">
		<p class="sottotitolo_pagina">Inserisci le tue credenziali per accedere alla piattaforma YouCare.</p>
	</div>

</div>

<div id="login_container_primo" class="page_container">
	<div id="spazio_form">
		<form id="contact-form" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" name="contact-form" method="post">
			<div class="riga_form <?php echo (!empty($username_err)) ? 'has-error' : ''; ?>">
				<input type="text" name="username" placeholder="Username" class="form-control" value="<?php echo $username; ?>" required>
				<span class="help-block"><?php echo $username_err; ?></span>
			</div>
			<div class="riga_form <?php echo (!empty($password_err)) ? 'has-error' : ''; ?>">
				<input type="password" name="password" placeholder="Password" class="form-control" required>
				<span class="help-block"><?php echo $password_err; ?></span>
			</div>
			<div class="riga_form submit">
				<button type="submit" class="" id="button_send" name="invia">
					<span class="load"><i class="fa fa-refresh fa-spin"></i></span>Invia
				</button>
			</div>
		</form>
	</div>  
</div>


<?php
include("footer.php");


?> 
