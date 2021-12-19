<?php

/*
 * Otteni tutti i questionari della piattaforma.
 * Operazione ADMIN.
 * 
 *
 * Output:
 *      
 *      
 */

include_once '././config/database.php';
include_once '././models/questionario.php';
include_once '././models/utente.php';



function getAllQuestionari($idMedico) {

    // Creo un nuovo oggetto Database e ci collego il db
    $database = new Database();
    $db = $database->getConnection();

    // Creo un nuovo oggetto Questionario
    $questionario = new Questionario($db);
    $questionario->idMedicoCurante = $idMedico;


    // Prelevo tutti i questionari dell'utente o del parente
    $stmt = $questionario->getAllQuestionari();

    if($stmt['responseCode'] != 200) {
        echo "<p>Problemi con il download dei questionari. Aggiorna la pagina...</p>";
        return null;
    }

    $num = $stmt['responseList']->rowCount();

    // Se vengono trovati questionari nel database
    if ( $num > 0 ) {
        $questionari_arr = [];
        $i = 0;
        while ($row = $stmt['responseList']->fetch(PDO::FETCH_ASSOC)) {
            extract($row);
            $questionari_arr[$i++] = array(
                "userId"  => $userId,
                "data" => $data,
                "temp" => $temp,
                "malDiGola" => $malDiGola == 1 ? true : false,
                "malDiTesta" => $malDiTesta == 1 ? true : false,
                "doloriMuscolari" => $doloriMuscolari == 1 ? true : false,
                "nausea" => $nausea == 1 ? true : false,
                "tosse" => $tosse == 1 ? true : false,
                "respiroCorto" => $respiroCorto == 1 ? true : false,
                "umore" => $umore == 1 ? true : false,
                "saturazioneOssigeno" => $saturazioneOssigeno,
                "freqRespiro" => $freqRespiro,
                "freqCardiaca" => $freqCardiaca,
                "pressioneMassima" => $pressioneMassima,
                "nome" => $nome,
                "cognome" => $cognome,
                "codFiscale" => $codFiscale,
                "codTessera" => $codTessera,
                "idUtenteGestore" => $idUtenteGestore,
                "email" => $email
            );
        }

        return $questionari_arr;

    } else {
        // Nessun questionario trovato
        echo "<p>Ancora nessun questionario inserito nella piattaforma.</p>";
        return null;
    }
}




function contaQuestionariGiornalieri($questionari_arr) {
    $count = 0;
    foreach ($questionari_arr as $quest) {
        if (date('Y-m-d') == date('Y-m-d', strtotime($quest["data"]))) 
            $count++;
    }
    return $count;
}

function contaQuestionariSintomiGiornalieri($questionari_arr) {
    $count = 0;
    foreach ($questionari_arr as $quest) {
        if (date('Y-m-d') == date('Y-m-d', strtotime($quest["data"]))) 
            if ($quest["malDiGola"] || $quest["malDiTesta"] || $quest["doloriMuscolari"] || $quest["nausea"] ||
                $quest["tosse"] || $quest["respiroCorto"] || $quest["umore"] ) 
                $count++;
    }
    return $count;
}



?>