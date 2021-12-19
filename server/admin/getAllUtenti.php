<?php

/*
 * Otteni tutti gli utenti della piattaforma.
 * Operazione ADMIN.
 * 
 *
 * Output:
 *      
 */

include_once '././config/database.php';
include_once '././models/utente.php';


function getAllUtenti($idMedico) {

    // Creo un nuovo oggetto Database e ci collego il db
    $database = new Database();
    $db = $database->getConnection();

    // Creo un nuovo oggetto Utente
    $utente = new Utente($db);
    $utente->idMedicoCurante = $idMedico;


    // Prelevo tutti gli utenti
    $stmt = $utente->getAll();

    if($stmt['responseCode'] != 200) {
        echo "<p>Problemi con il download degli utenti. Aggiorna la pagina...</p>";
        return null;
    }

    $num = $stmt['responseList']->rowCount();

    // Se vengono trovati utenti nel database
    if ( $num > 0 ) {
        $utenti_arr = [];
        $i = 0;
        while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $utenti_arr[$i++] = array(
                "userId"  => $userId,
                "nome" => $nome,
                "cognome" => $cognome,
                "codFiscale" => $codFiscale,
                "codTessera" => $codTessera,
                "idUtenteGestore" => $idUtenteGestore,
                "email" => $email
            );
        }

        return $utenti_arr;

    } else {
        // Nessun utente trovato
        echo "<p>Non ci sono utenti iscritti alla piattaforma.</p>";
        return null;
    }
}

?>