# Plutonium-T6-Persistent-Upgrades-Tracker
These scripts add live trackers of BO2 Zombies' Persistent Upgrades (A.K.A. persistent perks, permanent perks, permaperks, or perma perks) to be displayed on the HUD for the Plutonium client.  
This is my first experience with GSC modding. So, any feedback and suggestions are appreciated!

![20230607101955_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/f09b8930-616e-4399-9cac-dfdfafb2d85d)
![20230607102139_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/ef05dd97-b468-49eb-8d07-c83bb0b42695)
![20230607102925_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/ca6c23db-881c-41a5-8594-9ad733547c2e)

The option to display detailed variables is disabled by default, meaning that the script will only show the information regarding whether each upgrade is awarded or not. To enable the detailed variables to be displayed, locate the following line in the script:  
`self.custom_detailed_variables[ "all_details" ] =                    0;`  
and change the `0` to `1`.

**DISCLAIMER:** beware that not all variables will display if too many are enabled. Having too many variables enabled can also prevent some HUD elements of the game from loading properly, such as progress bars for placing parts.  
Therefore, I suggest turning off some of the trackers by navigating to `init_detailed_variables_toggles()` and switching the values of the unwanted trackers to `0`

The following table explains which persistent upgrade each code name stands for, as named on the [CoD Wiki Fandom page](https://callofduty.fandom.com/wiki/Persistent_Upgrades), along with notes showing how to obtain and lose each persistent upgrade.
| pers_upgrade code name | Description | To Obtain | To Lose |
| :--------------------: | :---------: | :-------- | :------ |
| board | Steel Barriers | Repair 74 boards from round 10 and onwards. | Do not repair a board during a round. |
| revive | Quick Revive | Complete 17 revives in a single game. | Fail a revive partway through. |
| multikill_headshots | Extra Headshot Damage | Obtain 5 multi-kill collateral headshots. | Obtain 25 non-headshot kills. However, obtaining multi-kill collateral headshots resets this counter. |
| cash_back | Refund on Perks | The first threshold is to purchase 50 perks. After meeting the first threshold, purchase 15 perks and follow each purchase by going into prone within 2.5 seconds of the perk icon appearing. | Fail to go into prone within 2.5 seconds of the perk icon appearing after a perk purchase. |
| insta_kill | Insta-Kill Pro | Avoid killing zombies during 2 consecutive Insta-Kill periods that have been picked up by you. | Get hit during an Insta-Kill period. |
| jugg | Juggernog | Receive 3 deaths on rounds 2 or lower. | Lost at the start of round 15. Although, its effect can remain past round 15 on the match on which it is lost. |
| carpenter | Steel Carpenter Barriers | After picking up a Carpenter power-up, kill a zombie that is out-of-bounds within the period of picking up the Carpenter and receiving the Carpenter points. | After picking up a Carpenter, fail to kill a zombie that is out-of-bounds within the period of picking up the Carpenter and receiving the Carpenter points. |
| flopper | PhD Flopper | Receive 30 damage from a fall at least 6 times. | Receive 50 damage from a fall once. |
| perk_lose | Tombstone | Purchase a perk getting you up to 4 perks on rounds 6 or lower on 3 separate matches. | It can only be lost under certain conditions. For the match it is earned on, you lose it if you purchase a perk on the same round the upgrade is earned on as long as the upgrade was not obtained on round 1. For future matches if the upgrade has not been lost, you lose it if you purchase a perk on the same round on which you have joined the match as long as you did not join on round 1. |
| pistol_points | Double Pistol Points | On and beyond your 8th total zombie kill for the game using a weapon, it is earned after the zombie kill if your accuracy for this match is below or equal to 0.25 | It is lost after the zombie kill if your accuracy for this match is more than 0.25 (Accuracy at the start of the match is 1). |
| double_points | Half-Off | After picking up a Double Points power-up, you must have accumulated a net profit of 2500 points during Double Points by the end of the power-up's period. Bank withdrawals do not contribute towards the net profit. | After picking up a Double Points power-up, gain points for it to be lost at the end of the power-up's period. |
| sniper | Long-shot Sniper Points | Kill 5 zombies distanced 800 units away in one round using a sniper. | Miss 3 sniper shots. Hitting an enemy with a sniper resets this counter. |
| box_weapon | Better Mystery Box Weapons | Accept 5 weapons in a row from the Mystery Box before round 10. | Lost at the start of every round from round 10 and beyond. Cannot be reobtained for the rest of the match. |
| nube | Ray Gun off the Olympia | Obtained by purchasing the Olympia after having increased a "nube kills" counter up to at least 5. The nube kills counter increases upon kills that are not: melee kills, headshot kills, nor kills preceded by a barrier repair; as these actions reset the counter. Additionally, if you have ever completed round 10 or higher on the main modes—including Mob of the Dead and Origins, but not survival nor grief—then the tracker stops increasing, and resets upon the next kill if it is the first time you have completed round 10 or higher. | Lost at the start of every round from round 10 and beyond. |

## Features
### pers_upgrades_live_tracker.gsc
The basic tracking script. It can be modified to show additional trackers by changing some values in the files, though the basic information of whether each upgrade is awarded or not should work with no need for further modification.

### pers_upgrades_live_tracker_chat_commands.gsc
Includes the same features of the previous one, but this script utilises [Resxt's chat commands scripts](https://github.com/Resxt/Plutonium-T6-Scripts/tree/main/chat_commands) to give the ability of enabling and disabling—individual detailed trackers, all the detailed trackers, and the whole tracking HUD—using the in-game chat.

Commands:
| Command | Description | Syntax | Example |
| :------ | :---------- | :----- | :------ |
| !trackerhud | Enables/disables the tracking HUD | `!trackerhud <toggle>` | !trackerhud 0 |
| !trackerhuddetails | Enables/disables detailed trackers | `!trackerhuddetails <variable> <toggle>` | !trackerhuddetails all_details 1 |

Accepted values:
  
`<toggle>`:
- To turn on: `1` or `on`
- To turn off: `0` or `off`
  
`<variable>`:
- `all_details`
- `board_details`
- `revive_details`
- `multikill_headshots_details`
- `cash_back_details`
- `insta_kill_details`
- `jugg_details`
- `carpenter_details`
- `flopper_details`
- `perk_lose_details`
- `pistol_points_details`
- `double_points_details`
- `sniper_details`
- `box_weapon_details`
- `nube_details`

## Installation
1. Navigate to the [Releases](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/releases/latest) page and download the script you desire.
2. Navigate to where the Plutonium T6 scripts folder for Zombies is located, typically: `%localappdata%\Plutonium\storage\t6\scripts\zm`
3. Place the downloaded script file into the directory.
4. In the case you choose to use `pers_upgrades_live_tracker_chat_commands.gsc`, then it's necessary to download [Resxt's chat_commands.gsc script](https://github.com/Resxt/Plutonium-T6-Scripts#how-do-i-download-a-script) and place the `chat_commands.gsc` file in `%localappdata%\Plutonium\storage\t6\scripts\`

## Credits
- [Resxt](https://github.com/Resxt) with the `chat_commands.gsc` script for making it possible to implement `pers_upgrades_live_tracker_chat_commands.gsc`.
