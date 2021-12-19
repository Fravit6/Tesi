<?php
// Variabili globali del progetto


// Mostra errori server
error_reporting(E_ALL);
 
// Fuso orario di default
date_default_timezone_set('Europe/Rome');
 
// Variabili usate per creare il token di accesso
$key = "kiaveSegretissima123456789";
$creatoIl = time();
$scadenza = $creatoIl + (60 * 60 * 24 * 7); // Valido per una settimana
$emittente = "http://localhost/youcare/";

?>