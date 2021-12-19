<?php
/*
 * Footer
 */
?>


<section id="container_subfooter" class="footer_container page_container">

	<div class="widget_footer">
		<p class="titolo_widget">Contatti</p>
		<hr>
		<p class="testo_widget"><a href="mailto:info@youcare.it" target="_blank">info@youcare.it</a> <br/>Via Mario Rossi 12, Milano <br/>P.Iva 123456789</p>
	</div>

	<div class="widget_footer">
		<p class="titolo_widget">Privacy</p>
		<hr>
		<p class="testo_widget"><a href="#">Cookie Policy</a> <br/><a href="#">Privacy Policy</a></p>		
	</div>

</section>


<!-- <div id="policy_alert">
	<p>
		Questo sito utilizza cookie tecnici e, previo tuo consenso, cookie di profilazione, di terze parti, a scopi pubblicitari e per migliorare servizi ed esperienza dei lettori. Per maggiori informazioni o negare il consenso, leggi l&#039;informativa estesa. Se decidi di continuare la navigazione o chiudendo questo banner, invece, presti il consenso all&#039;uso di tutti i cookie.
	</p>
	<div id="bottoni_policy">
		<a href="#" onclick="chiudiPolicy();return false;" id="bottone_ok">OK</a>
		<a href="/privacy-policy/#cookie" id="bottone_more">Leggi di pi&ugrave;</a>
	</div>	
</div> -->




</body>

<script type="text/javascript">

	// Funzioni per manipolare i cookie
	function setCookie(cname, cvalue) {
		document.cookie = cname + "=" + cvalue + "; path=/";
	}
	function getCookie(cname) {
		var name = cname + "=";
		var decodedCookie = decodeURIComponent(document.cookie);
		var ca = decodedCookie.split(';');
		for(var i = 0; i <ca.length; i++) {
			var c = ca[i];
			while (c.charAt(0) == ' ') {
	  		c = c.substring(1);
			}
			if (c.indexOf(name) == 0) {
	  		return c.substring(name.length, c.length);
			}
		}
		return "";
	}


	
	// Apro il menu da mobile
	function apriMenu() {
		if (document.getElementById("menu_mobile").classList.contains('aperto')) {
			document.getElementById("menu_mobile").classList.remove('aperto');
			document.getElementById('menu_mobile').style.height = '0';
		} else {
			document.getElementById("menu_mobile").classList.add('aperto');
			document.getElementById('menu_mobile').style.height = '100%';
		}
	}



	var acc = document.getElementsByClassName("accordion");
	var i;

	for (i = 0; i < acc.length; i++) {
		acc[i].addEventListener("click", function() {
			this.classList.toggle("active");
			var panel = this.nextElementSibling;
			if (panel.style.display === "block") {
				panel.style.display = "none";
			} else {
				panel.style.display = "block";
			}
		});
	}


	// Controllo se ho già visto l'alert per le policy
	/*var vista = getCookie("alert_policy");
	if (vista != "visto") {
		document.getElementById("policy_alert").style.display = 'flex'; 
	}*/

	// Chiudo l'alert per la privacy policy
	/*function chiudiPolicy() {
		setCookie("alert_policy","visto");
		setTimeout(function(){ // dopo 300 millisecondi scompare del tutto
			document.getElementById("policy_alert").style.display = 'none';
		}, 300);
		document.getElementById("policy_alert").style.opacity = '0';
	}*/


</script>

</html>