-- Version : French ( by LenweSaralonde )
-- Last Update : 22/05/2006

if (GetLocale() == "frFR") then
	AUTOFLOOD_LOAD = "AutoFlood VERSION chargé. Tapez /floodhelp pour obtenir de l'aide."

	AUTOFLOOD_STATS = "\"MESSAGE\" est envoyé toutes les RATE secondes dans le canal /CHANNEL."

	AUTOFLOOD_MESSAGE = "Le message est maintenant \"MESSAGE\"."
	AUTOFLOOD_RATE = "Le message est envoyé toutes les RATE secondes."
	AUTOFLOOD_CHANNEL = "Le message est envoyé dans le canal /CHANNEL."

	AUTOFLOOD_ACTIVE = "AutoFlood est activé."
	AUTOFLOOD_INACTIVE = "AutoFlood est désactivé."

	AUTOFLOOD_ERR_CHAN = "Le canal /CHANNEL est invalide."
	AUTOFLOOD_ERR_RATE = "Vous ne pouvez pas envoyer de messages à moins de RATE secondes d'intervalle."

	AUTOFLOOD_CHANNEL_TITLE = "Canal"
	AUTOFLOOD_RATE_TITLE = "Répéter toutes les minutes"
	AUTOFLOOD_INPUT_TITLE = "Entrée"
	AUTOFLOOD_OUTPUT_TITLE = "Sortie"
	AUTOFLOOD_SAVE_BUTTON = "Sauvegarder"
	AUTOFLOOD_CANCEL_BUTTON = "Annuler"

	AUTOFLOOD_HELP = {
		"===================== Auto Flood =====================",
		"/flood [on|off] : Démarre / arrête l'envoi du message.",
		"/floodmsg <message> : Définit le message à envoyer.",
		"/floodchan <canal> : Définit le canal à utiliser pour l'envoi.",
		"/floodrate <durée> : Définit la période (en secondes) d'envoi du message.",
		"/floodinfo : Affiche les paramètres.",
		"/floodhelp : Affiche ce message d'aide.",
	}
end
