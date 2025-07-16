# Plutonium-T6-Persistent-Upgrades-Tracker
These scripts add live trackers of BO2 Zombies' Persistent Upgrades (A.K.A. persistent perks, permanent upgrades, permanent perks, perma perks, or permaperks) to be displayed on the HUD for the Plutonium client.  
This is my first experience with GSC modding. So, any feedback and suggestions are appreciated!

![20230607101955_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/f09b8930-616e-4399-9cac-dfdfafb2d85d)
![20230611175353_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/825142b7-533d-4e0f-8b1e-845931b8fb5b)
![20230611175852_1](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/assets/135042368/d305f74e-6395-4be9-80d6-8d7721fe0131)

The option to display detailed variables is disabled by default, meaning that the script will only show the information regarding whether each upgrade is awarded or not. To enable the detailed variables to be displayed, locate the following line in the script:  
`self.custom_detailed_variables["all_details"] = 0;`  
and change the `0` to `1`.

**DISCLAIMER:** beware that not all variables will display if too many are enabled. Having too many variables enabled can also prevent some HUD elements of the game from loading properly, such as progress bars for placing parts.  
Therefore, I suggest turning off some of the trackers by navigating to `init_detailed_variables_toggles()` and switching the values of the unwanted trackers to `0`

The following table explains which persistent upgrade each code name stands for, as named on the [CoD Wiki Fandom page](https://callofduty.fandom.com/wiki/Persistent_Upgrades), along with notes showing how to obtain and lose each persistent upgrade.
| pers_upgrade code name | Description | To Obtain | To Lose |
| :--------------------: | :---------: | :-------- | :------ |
| board | Steel Barriers | Repair 74 boards from round 10 and onwards. | Do not repair a board during a round. |
| revive | Quick Revive | Complete 17 revives in a single game. | Fail a revive partway through. |
| multikill_headshots | Headshot Damage | Obtain 5 collateral headshots multi-kills. | Obtain 25 non-headshot kills. However, obtaining a collateral headshots multi-kill resets this counter. |
| cash_back | Cash Back | The first threshold is to purchase 50 perks. After meeting the first threshold, purchase 15 perks and follow each purchase by going into prone within 2.5 seconds of the perk icon appearing. | Fail to go into prone within 2.5 seconds of the perk icon appearing after a perk purchase. |
| insta_kill | Insta-Kill Pro | Avoid killing zombies during 2 consecutive Insta-Kill periods that have been picked up by you. | Get hit during an Insta-Kill period. |
| jugg | Juggernog | Receive 3 deaths on rounds 2 or lower. | Lost at the start of round 15. Although, its effect can remain past round 15 on the match on which it is lost. |
| carpenter | Steel Carpenter | After picking up a Carpenter power-up, kill a zombie that is out-of-bounds before receiving the Carpenter points. | After picking up a Carpenter, fail to kill a zombie that is out-of-bounds before receiving the Carpenter points. |
| flopper | Flopper | Receive at least 30 damage from a fall 6 times. | Receive at least 50 damage from a fall once. |
| perk_lose | Tombstone | Purchase a perk to fill the 4th perk slot on rounds 6 or lower on 3 separate matches. | It can only be lost under certain conditions. For the match it was earned on, you lose it if you purchase a perk on the same round the upgrade was earned on as long as the upgrade was not obtained on round 1. For future matches if the upgrade has not been lost, you lose it if you purchase a perk on the same round on which you have joined the match as long as you did not join on round 1. |
| pistol_points | Pistol Points | On and beyond your 8th total zombie kill for the game using a weapon, it is earned after the zombie kill if your accuracy for this match is below or equal to 0.25 | It is lost after the zombie kill if your accuracy for this match is more than 0.25 (Accuracy at the start of the match is 1). |
| double_points | Half-Off | After picking up a Double Points power-up, you must have accumulated by the end of the power-up's period a net profit of at least 2500 points during the Double Points period. Bank withdrawals do not contribute towards the earnings. | After picking up a Double Points power-up, gain points for the upgrade to be lost at the end of the power-up's period. |
| sniper | Sniper Points | Kill 5 zombies distanced at least 800 units away from you in one round using a sniper. | Miss 3 sniper shots. Hitting an enemy with a sniper resets this counter. |
| box_weapon | Better Box | Accept 5 weapons in a row from the Mystery Box before round 10. | Lost at the start of every round from round 10 and beyond. Cannot be reobtained for the rest of the match. |
| nube | Ray Gun Wall-Buy | Obtained by purchasing the Olympia after having increased a "nube kills" counter up to a value of at least 5. The nube kills counter increases upon kills that are not: melee kills, headshot kills, nor kills preceded by a barrier repair; as these actions reset the counter. Additionally, if you have ever completed round 10 or higher on the main modes—including Mob of the Dead and Origins, but not survival nor grief—then the tracker stops increasing, and resets upon the next kill if it is the first time you have ever completed round 10 or higher. | Lost at the start of every round from round 10 and beyond. |

## Features
### pers_upgrades_live_tracker.gsc
The basic tracking script. It can be modified to show additional trackers by changing some values in the files, though the basic information of whether each upgrade is awarded or not is toggled on by default with no need for further modification, and trackers of individual upgrades can be disabled by editing the script.

### pers_upgrades_live_tracker_chat_commands.gsc
Includes the same features of the previous one, but this script utilises [Resxt's chat commands scripts](https://github.com/Resxt/Plutonium-T6-Scripts/tree/main/chat_commands) to give the ability of enabling and disabling—individual detailed trackers, all the detailed trackers, and the whole tracking HUD—using the in-game chat.

Commands:
| Command | Description | Syntax | Example |
| :------ | :---------- | :----- | :------ |
| !put_hud | Enables/disables the tracking HUD | `!put_hud <toggle>` | !put_hud 0 |
| !put_elem | Enables/disables individual trackers and/or their detailed trackers | `!put_elem <variable> <toggle>` | !put_elem all_details 1 |

Accepted values:
  
`<toggle>`:
- To turn on: `1` or `on`
- To turn off: `0` or `off`
  
`<variable>`:
- `all_details`
- `board`
- `board_details`
- `revive`
- `revive_details`
- `multikill_headshots`
- `multikill_headshots_details`
- `cash_back`
- `cash_back_details`
- `insta_kill`
- `insta_kill_details`
- `jugg`
- `jugg_details`
- `carpenter`
- `flopper`
- `flopper_details`
- `perk_lose`
- `perk_lose_details`
- `pistol_points`
- `pistol_points_details`
- `double_points`
- `sniper`
- `sniper_details`
- `box_weapon`
- `box_weapon_details`
- `nube`
- `nube_details`

## Installation
1. Navigate to the [Releases](https://github.com/Hadi77KSA/Plutonium-T6-Persistent-Upgrades-Tracker/releases/latest) page and download the script you desire.
2. Navigate to where the Plutonium T6 scripts folder for Zombies is located, typically: `%localappdata%\Plutonium\storage\t6\scripts\zm`
3. Place the downloaded script file into the directory.
4. In the case you choose to use `pers_upgrades_live_tracker_chat_commands.gsc`, then it's necessary to download [Resxt's chat_commands.gsc script](https://github.com/Resxt/Plutonium-T6-Scripts#how-do-i-download-a-script) and place the `chat_commands.gsc` file in `%localappdata%\Plutonium\storage\t6\scripts`

## Credits
- [Resxt](https://github.com/Resxt) with the `chat_commands.gsc` script for making it possible to implement `pers_upgrades_live_tracker_chat_commands.gsc`.
