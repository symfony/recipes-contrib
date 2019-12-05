# This file contains a user story for demonstration only.
# Learn how to get started with Behat and BDD on Behat's website:
# http://behat.org/en/latest/quick_start.html

Feature: advanceddemo
  Afin de tester plus de possibilités
  En temps qu'experimentateur
  Je veux un scenario de demonstration plus évolué

  Scenario: Je défini des variables qui seront utilisés pour la demo
		Given Je defini que "mailTo" vaut "test@yopmail.com"
		Given Je defini que "mailFrom" vaut "test@test.fr"
		Given Je defini que "mailSubject" vaut "sujet de message"
		Given Je defini que "mailBody" vaut "contenu du message"
		
	@javascript	
  Scenario: Test de vidage des mails dans Yopmail	
		#Given J'envoie un mail de "{mailFrom}" à "{mailTo}" avec pour sujet "{mailSubject}" et message "{mailBody}"
		#And J'affiche un message dans la console "une pause de 30 secondes pour attendre la reception du mail"
		#And J'attends 30 secondes
		When Je me connecte sur Yopmail avec le compte "{mailTo}"
		Then Dans Yopmail j'efface les mails


# TODO : plus de scenraios avancés