<?php
/**
 * Header del sito
 *
 */


// L'url della home
//$url = $_SERVER['SERVER_NAME'];
$url = "http://localhost/youcare/";

// Il nome del sito
$nome_sito = "YouCare | Teleassistenza Medica";


?><!DOCTYPE html>
<html lang="it-IT">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, maximum-scale=5">
	 
	<link rel="icon" type="image/png" href="img/favicon-16.png" />
	<link rel="apple-touch-icon" href="img/favicon-16.png">
	<link rel="apple-touch-icon" sizes="76x76" href="img/favicon-76.png">
	<link rel="apple-touch-icon" sizes="120x120" href="img/favicon-120.png">
	<link rel="apple-touch-icon" sizes="152x152" href="img/favicon-152.png"> 

	<title><?php echo $meta_title." | ".$nome_sito; ?></title>
	<meta name="description" content="<?php echo $meta_description; ?>" />

	<meta property="og:locale" content="it_IT">
	<meta property="og:type" content="website">
	<meta property="og:title" content="<?php echo $meta_title." | ".$nome_sito; ?>">
	<meta property="og:description" content="<?php echo $meta_description; ?>">
	<meta property="og:url" content="<?php echo $url; ?>">
	<meta property="og:site_name" content="<?php echo $nome_sito; ?>">
	<meta property="og:image" content="<?php echo $url; ?>/img/carlo-di-benedetto-condivisione-social.jpg">
	<meta property="og:image:width" content="1200">
	<meta property="og:image:height" content="630">
	<meta name="twitter:card" content="summary_large_image">
	<meta name="twitter:title" content="<?php echo $meta_title." | ".$nome_sito; ?>">
	<meta name="twitter:description" content="<?php echo $meta_description; ?>">
	<meta name="twitter:image" content="<?php echo $url; ?>/img/carlo-di-benedetto-condivisione-social.jpg">
	
	<link rel="stylesheet" type="text/css" href="style.css">
	<link href="libs/circular-prog-bar.css" media="all" rel="stylesheet" />
</head>
<body>


<header>
	<div id="spazio_logo">
		<a href="/">YouCare</a>
	</div>
	<nav id="spazio_menu">
		<ul>
			<?php if(isset($_SESSION["loggedin"])) { ?>
				<li><a href="#statistiche">Statistiche</a></li>
				<li><a href="#questionari">Questionari</a></li>
				<li><a href="/youcare/logout.php">Logout</a></li>
			<?php } else {?>
				<li><a href="/youcare/login.php">Login</a></li>
			<?php } ?>
		</ul>
	</nav>
	<div id="spazio_menu_mobile">
		<button id="hamburger" onClick="apriMenu()" aria-label="menu"><img src="img/icon/icon-menu.png" alt="menu" width="30" height="30"></button>
	</div>
</header>

<nav id="menu_mobile">
	<ul>
		<?php if(isset($_SESSION["loggedin"])) { ?>
			<li><a href="#statistiche">Statistiche</a></li>
			<li><a href="#questionari">Questionari</a></li>
			<li><a href="/youcare/logout.php">Logout</a></li>
		<?php } else {?>
			<li><a href="/youcare/login.php">Login</a></li>
		<?php } ?>
	</ul>
</nav>