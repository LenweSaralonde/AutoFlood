Changelog
=========

v1.5.2
------
* Added support for {size}, {tanks}, {heals}, and {dps} placeholders in flood messages to show group composition.
* Added support for math operations in placeholders (e.g., {5-heals} will show 1 if you have 4 healers).
* Added special format {need-2/4/14} that automatically lists needed roles with proper pluralization.
* Added support for yell channel (/y or /yell).
* Added multi-channel broadcasting with different intervals (e.g., /floodchan say,yell,guild and /floodrate 60,120,300).
* Fixed handling of numeric channel numbers.
* Fixed timer reset issues when enabling flood or changing settings.
* Restored immediate broadcast when "/flood on" is used.
* Fixed duplicate status messages when using slash commands.
* Improved information display format for better readability.

v1.5.1
------
* Added add-on category.
* TOC bump for WoW Retail 11.1.0, WoW Classic 4.4.2 and WoW Classic Era 1.15.6.

v1.5.0
------
* Updated for WoW Retail patch 10.2.7.
* Updated for WoW Cataclysm Classic patch 4.4.0.
* Updated for WoW Classic patch 1.15.2.

v1.4.6
------
* Updated for WoW patch 10.1.7 and WoW Classic patch 1.14.4.

v1.4.5
------
* Updated for WoW patch 10.1.

v1.4.4
------
* TOC bump for WoW patch 10.0.7.

v1.4.3
------
* TOC bump for WoW patch 10.0.5.
* TOC bump for WoW Classic patch 3.4.1.

v1.4.2
------
* TOC bump for WoW patch 10.0.2.

v1.4.1
------
* TOC bump for WoW patch 10.0.0.

v1.4.0
------
* Configuration is now saved character-wide instead of account-wide. #3
* Wait for the current message to be actually sent before sending the next one. #4
* Added support for instance chat (/i).
* Improved channel setting.

v1.3.3
------
* Added support for Wrath of the Lich King Classic.
* Updated for WoW Retail patch 9.2.7.

v1.3.2
------
* TOC bump for WoW 9.2, WoW BC Classic 2.5.3 and WoW Classic 1.14.2.

v1.3.1
------
* TOC bump for WoW 9.1.5.

v1.3.0
------
* Created TOCs for WoW Retail, Classic and Burning Crusade Classic.

v1.2.4
------
* Updated TOC for WoW patch 9.0.5

v1.2.3
------
* Updated TOC for WoW patch 9.0.2

v1.2.2
------
* Updated for WoW Shadowlands 9.0.1 prepatch

v1.2.1
------
* Rewritten to use MessageQueue

v1.2.1
------
* Fixed initialization issue (at last!)

v1.1
----
* Fixed minor onEvent function bug

v1.0
----
* Initial release