<?php
// Inizializzo la sessione
session_start();
 
// Svuoto la sessione
$_SESSION = array();

// E la distruggo
session_destroy();

header("location: login.php");
exit;
?>