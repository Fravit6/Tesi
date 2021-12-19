<?php
/**
 * Homepage
 *
 */

// Initialize the session
session_start();

// Controllo se ho effettuato il login
if(!isset($_SESSION["loggedin"]) || $_SESSION["loggedin"] !== true){
    header("location: login.php");
    exit;
}


// Informazioni SEO
$meta_title = "Home";
$meta_description = "Teleassistenza medica per il Covid-19.";

include("header.php");

include("admin/getAllUtenti.php");
include("admin/getAllQuestionari.php");


// Dati del medico dal DB
$idMedico = $_SESSION["id"];
$usernameMedico = $_SESSION["username"];
$nomeMedico = $_SESSION["nome"];



// Prelevo le info dal DB
$listaQuest = getAllQuestionari($idMedico);
$listaUtenti = getAllUtenti($idMedico);

$nQuestGiornalieri = contaQuestionariGiornalieri($listaQuest);
$nUtenti = count($listaUtenti);

$rappUtentiQuest = intval( ( $nQuestGiornalieri * 100 ) / $nUtenti );


$nQuestSintomi = contaQuestionariSintomiGiornalieri($listaQuest);

$rappUtentiQuestSintomi = intval( ( $nQuestSintomi * 100 ) / $nUtenti );

?> 



<div id="home_testata" class="page_testata">
	
	<div class="spazio_titolo_pagina">
		<h1 class="titolo_pagina">YouCare</h1>
	</div>
	<div class="spazio_sottotitolo_pagina">
		<p class="sottotitolo_pagina">Ciao <?php echo $nomeMedico; ?>, controlla i parametri dei tuoi assistiti!</p>
	</div>

</div>


<div id="statistiche" class="page_container">

	<h2>Statistiche giornaliere:</h2>

	<div id="spazio_box">
		<div class="box">
			<div class="progress-circle <?php if($rappUtentiQuest > 50) echo "over50"; ?> p<?php echo $rappUtentiQuest; ?>">
				<span><?php echo $rappUtentiQuest; ?>%</span>
				<div class="left-half-clipper">
					<div class="first50-bar"></div>
					<div class="value-bar"></div>
				</div>
			</div>
			<p>Pazienti che oggi hanno inviato il questionario:<br/> <?php echo $nQuestGiornalieri; ?> su <?php echo $nUtenti; ?>.</p>
		</div>
		<div class="box">
			<div class="progress-circle <?php if($rappUtentiQuestSintomi > 50) echo "over50"; ?> p<?php echo $rappUtentiQuestSintomi; ?>">
				<span><?php echo $rappUtentiQuestSintomi; ?>%</span>
				<div class="left-half-clipper">
					<div class="first50-bar"></div>
					<div class="value-bar"></div>
				</div>
			</div>
			<p>Pazienti che oggi hanno riportato sintomi:<br/> <?php echo $nQuestSintomi; ?> su <?php echo $nUtenti; ?></p>
		</div>
	</div>

</div>


<div id="questionari" class="page_container">

	<h2>Questionari degli utenti:</h2>


<?php 

	$html = "";

	$listaQuestDESC = array_reverse($listaQuest); 

	$listaQuestByUser = array();
	foreach ($listaQuestDESC as $key => $item) {
		$listaQuestByUser[$item['userId']][$key] = $item;
	}
	ksort($listaQuestByUser, SORT_NUMERIC);
	/*echo '<pre>';
	print_r($listaQuestByUser);
	echo '</pre>';*/

	foreach ($listaQuestByUser as $key => $questUtente) {

		$intestazioneStampata = false;

		foreach ($questUtente as $questionario) {

			if (!$intestazioneStampata) {
				$html.=  '<button class="accordion">Utente: <strong>'.$questionario["cognome"].' '.$questionario["nome"].'</strong> - Cod.Fiscale: '.$questionario["codFiscale"].'</button>
					<div class="panel" style="display: none">';
				$intestazioneStampata = true;
			}



			$html.= '<div class="quest">';

				$date = date_create($questionario["data"]);
				$date = date_format($date, 'H:i:s d/m/Y');

				$html.= '<p><strong>Data</strong> questionario: '.$date.'</p>';

				$punteggioMEWS = 0;
				if ($questionario["pressioneMassima"] <= 70)
					$punteggioMEWS += 3;
				if ($questionario["pressioneMassima"] >= 71 && $questionario["pressioneMassima"] <= 80)
					$punteggioMEWS += 2;
				if ($questionario["pressioneMassima"] >= 81 && $questionario["pressioneMassima"] <= 100)
					$punteggioMEWS += 1;
				if ($questionario["pressioneMassima"] >= 200)
					$punteggioMEWS += 2;



				if ($questionario["freqCardiaca"] <= 40)
					$punteggioMEWS += 2;
				if ($questionario["freqCardiaca"] >= 41 && $questionario["freqCardiaca"] <= 50)
					$punteggioMEWS += 1;
				if ($questionario["freqCardiaca"] >= 51 && $questionario["freqCardiaca"] <= 100)
					$punteggioMEWS += 0;
				if ($questionario["freqCardiaca"] >= 101 && $questionario["freqCardiaca"] <= 110)
					$punteggioMEWS += 1;
				if ($questionario["freqCardiaca"] >= 111 && $questionario["freqCardiaca"] <= 129)
					$punteggioMEWS += 2;
				if ($questionario["freqCardiaca"] >= 130)
					$punteggioMEWS += 3;



				if ($questionario["freqRespiro"] <= 8)
					$punteggioMEWS += 2;
				if ($questionario["freqRespiro"] >= 9 && $questionario["freqRespiro"] <= 14)
					$punteggioMEWS += 0;
				if ($questionario["freqRespiro"] >= 15 && $questionario["freqRespiro"] <= 20)
					$punteggioMEWS += 1;
				if ($questionario["freqRespiro"] >= 21 && $questionario["freqRespiro"] <= 29)
					$punteggioMEWS += 2;
				if ($questionario["freqRespiro"] >= 30)
					$punteggioMEWS += 3;


				if ($questionario["temp"] < 35)
					$punteggioMEWS += 2;
				if ($questionario["temp"] >= 35 && $questionario["temp"] <= 38.4)
					$punteggioMEWS += 0;
				if ($questionario["temp"] >= 38.5)
					$punteggioMEWS += 2;

				$html.= '<p><strong>Parametri</strong> di riferimento:<br/>';

				$html.= 'Temperatura Corporea: '.$questionario["temp"].'&deg;C<br/>';
				$html.= 'Saturazione Ossigeno: '.$questionario["saturazioneOssigeno"].' %<br/>';
				$html.= 'Freq. Respiratoria: '.$questionario["freqRespiro"].' atti/min<br/>';
				$html.= 'Freq. Cardiaca: '.$questionario["freqCardiaca"].' b/m<br/>';
				$html.= 'Pressione Massima : '.$questionario["pressioneMassima"].' mmHg<br/></p>';

				$html.= '<p><strong>Altri parametri</strong> inoltrati:<br/>';

				if ($questionario["malDiGola"]) $html.= 'Mal di gola<br/>';
				if ($questionario["malDiTesta"]) $html.= 'Mal di testa<br/>';
				if ($questionario["doloriMuscolari"]) $html.= 'Dolori Muscolari<br/>';
				if ($questionario["nausea"]) $html.= 'Nausea<br/>';
				if ($questionario["tosse"]) $html.= 'Tosse<br/>';
				if ($questionario["respiroCorto"]) $html.= 'Respiro Corto<br/>';
				if ($questionario["umore"]) $html.= 'Umore<br/>';
				$html.= '</p>';


				$html.= '<p>Punteggio scala <strong>MEWS</strong>: '.$punteggioMEWS.'</p>';


			$html.= '</div><hr>';

		}


		$html.= '</div>';
	}

	echo $html;

?>


</div>



<?php
include("footer.php");


?> 
