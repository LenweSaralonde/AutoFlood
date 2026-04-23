# AutoFlood

AutoFlood periodically sends a single-line message in a chat channel. It's designed for advertisement for guild recruitment, crafting, in-game events...

Commands:

- `/flood [on|off]` : Start / stops sending the message.
- `/floodmsg <message>` : Sets the message. Supports hyperlinks to items, spells, crafts, achievements...
- `/floodchan <channel>` : Sets the channel. Accepted values: say, yell, guild, raid, party, bg, trade, and channel numbers.
- `/floodrate <duration>` : Sets the period (in seconds), minimum 10.
- `/floodinfo` : Displays the message and the parameters.
- `/floodhelp` : Displays the help message.
- `/floodui` : Opens the flood message UI for easier configuration.

Features:

- Supports raid target icons in messages (e.g., {star}, {circle}, {rt1}, {rt2}, etc.)
- GUI for easy message configuration
- Message preview with icon replacements
- Channel selection dropdown
- Adjustable flood rate

The settings are saved per character/realm.

Note: Please use responsibly and in accordance with your server's rules and etiquette.
