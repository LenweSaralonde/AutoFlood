-- Version : French ( by @project-author@ )
-- Last Update : 22/05/2006

if (GetLocale() == "frFR") then
	AUTOFLOOD_LOAD = "AutoFlood VERSION chargé. Tapez /floodhelp pour obtenir de l'aide."

	AUTOFLOOD_MESSAGE_INFO = "Message: \"MESSAGE\""
	AUTOFLOOD_CHANNELS_HEADER = "Diffusion vers:"
	AUTOFLOOD_CHANNEL_RATE = "Canal /CHANNEL: toutes les RATE secondes"

	AUTOFLOOD_MESSAGE = "Le message est maintenant \"MESSAGE\"."
	AUTOFLOOD_RATE = "Le message est envoyé toutes les RATE secondes."
	AUTOFLOOD_CHANNEL = "Le message est envoyé dans le canal /CHANNEL."

	AUTOFLOOD_ACTIVE = "AutoFlood est activé."
	AUTOFLOOD_INACTIVE = "AutoFlood est désactivé."

	AUTOFLOOD_ERR_CHAN = "Le canal /CHANNEL est invalide."
	AUTOFLOOD_ERR_RATE = "Vous ne pouvez pas envoyer de messages à moins de RATE secondes d'intervalle."

	AUTOFLOOD_HELP = {
		"===================== Auto Flood =====================",
		"/flood [on|off] : Démarre / arrête l'envoi du message.",
		"/floodmsg <message> : Définit le message à envoyer. Utilisez {size} pour la taille du groupe, {tanks} pour le nombre de tanks, {heals} pour le nombre de soigneurs, et {dps} pour le nombre de DPS. Les opérations mathématiques comme {5-heals} sont également prises en charge.",
		"  Formats spéciaux:",
		"  - {need-2/4/14} (tanks/soigneurs/dps) Indique les rôles dont vous avez encore besoin.",
		"  - {>10need-2/4/14} N'affiche les rôles nécessaires que si la taille du groupe est supérieure au seuil spécifié (10 dans cet exemple).",
		"/floodchan <canaux> : Définit les canaux à utiliser (séparés par des virgules). Exemple: say,yell,guild",
		"/floodrate <durées> : Définit les périodes en secondes (séparées par des virgules). Exemple: 60,120,300",
		"/floodinfo : Affiche les paramètres.",
		"/floodhelp : Affiche ce message d'aide.",
	}
end
