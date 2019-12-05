# This file contains a user story for demonstration only.
# Learn how to get started with Behat and BDD on Behat's website:
# http://behat.org/en/latest/quick_start.html

Feature: demo
  Afin de tester que l'extension froggdev/behat-contexts soit bien installé
  En temps qu'experimentateur
  Je veux un scenario de demonstration

	# Le tag @Javascript est neccessaire pour l'ouverture du navigateur, 
	# sans ce TAG pas de test via Selenium
  @javascript
  Scenario: Test sur Google
    When Je vais sur la page "http://www.google.com"
		Then Je devrai être sur la page "https://www.google.com/?gws_rd=ssl"
    And Je devrai voir le texte "Recherche Google"
    But Je ne devrai pas voir le texte "Recherche Qwant"		
		Given Je prends une capture d'écran "test.png"
