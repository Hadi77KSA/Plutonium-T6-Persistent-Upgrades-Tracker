#define USE_CHAT_COMMANDS 0

#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

#if USE_CHAT_COMMANDS == 1
#include scripts\chat_commands;
#endif

init()
{
	if ( maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active() )
	{
#if USE_CHAT_COMMANDS == 1
		CreateCommand( level.chat_commands["ports"], "put_hud", "function", ::tracker_hud_command );
		CreateCommand( level.chat_commands["ports"], "put_elem", "function", ::tracker_hud_elements_command );
#endif
		level thread onPlayerConnect();
	}
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player init_detailed_variables_toggles();
		player thread pers_upgrades_monitor();
		player thread msg();
	}
}

init_detailed_variables_toggles()
{
	self.pers_upgrades_monitor = [];
	self.pers_upgrades_monitor["all" + "_details"] =                 0; //change this to 1 to display additional variables, change to 0 to hide.

	//due to limitations, some variables may not display even if enabled.
	//on Buried, it's possible to load up to 29 variables.
	//total variables = 31. detailed = 17.

	self.pers_upgrades_monitor["board"] =                            1;
	self.pers_upgrades_monitor["board" + "_details"] =               1; //1 detailed variable(s)
	self.pers_upgrades_monitor["revive"] =                           1;
	self.pers_upgrades_monitor["revive" + "_details"] =              1; //1 detailed variable(s)
	self.pers_upgrades_monitor["multikill_headshots"] =              1;
	self.pers_upgrades_monitor["multikill_headshots" + "_details"] = 1; //2 detailed variable(s)
	self.pers_upgrades_monitor["cash_back"] =                        1;
	self.pers_upgrades_monitor["cash_back" + "_details"] =           1; //2 detailed variable(s)
	self.pers_upgrades_monitor["insta_kill"] =                       1;
	self.pers_upgrades_monitor["insta_kill" + "_details"] =          1; //1 detailed variable(s)
	self.pers_upgrades_monitor["jugg"] =                             1;
	self.pers_upgrades_monitor["jugg" + "_details"] =                1; //1 detailed variable(s)
	self.pers_upgrades_monitor["carpenter"] =                        1;
	//self.pers_upgrades_monitor["carpenter" + "_details"] =           0; //0 detailed variable(s)
	self.pers_upgrades_monitor["flopper"] =                          1;
	self.pers_upgrades_monitor["flopper" + "_details"] =             1; //1 detailed variable(s)
	self.pers_upgrades_monitor["perk_lose"] =                        1;
	self.pers_upgrades_monitor["perk_lose" + "_details"] =           1; //2 detailed variable(s)
	self.pers_upgrades_monitor["pistol_points"] =                    1;
	self.pers_upgrades_monitor["pistol_points" + "_details"] =       1; //1 detailed variable(s)
	self.pers_upgrades_monitor["double_points"] =                    1;
	//self.pers_upgrades_monitor["double_points" + "_details"] =       0; //0 detailed variable(s)
	self.pers_upgrades_monitor["sniper"] =                           1;
	self.pers_upgrades_monitor["sniper" + "_details"] =              1; //2 detailed variable(s)
	self.pers_upgrades_monitor["box_weapon"] =                       1;
	self.pers_upgrades_monitor["box_weapon" + "_details"] =          1; //1 detailed variable(s)
	self.pers_upgrades_monitor["nube"] =                             1;
	self.pers_upgrades_monitor["nube" + "_details"] =                1; //2 detailed variable(s)
}

msg()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
#if USE_CHAT_COMMANDS == 1
	self iPrintLn( "^2Persistent Upgrades Tracker ^5mod by ^6Hadi77KSA" );
#else
	self iPrintLn( "^3Persistent Upgrades Tracker ^5mod by ^6Hadi77KSA" );
#endif
}

pers_upgrades_monitor()
{
	level endon( "end_game" );
	self endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	self endon( "custom_pers_upgrades_hud_off" );
#endif

	if ( level.intermission || !( isdefined( level.pers_upgrades_keys ) && level.pers_upgrades_keys.size > 0 ) )
		return;

	flag_wait( "initial_blackscreen_passed" );
#if USE_CHAT_COMMANDS == 1
	if ( is_true( self.pers_upgrades_tracker_hud_running ) )
		return;

	self.pers_upgrades_tracker_hud_running = 1;
#endif
	pers_upgrades_monitor = [];

	foreach ( pers_upgrade in level.pers_upgrades_keys )
	{
		if ( is_true( self.pers_upgrades_monitor[pers_upgrade] ) )
		{
			pers_upgrades_monitor[pers_upgrade] = self createfontstring( "small", 1.2 );
			pers_upgrades_monitor[pers_upgrade] thread check_pers_upgrade( self, pers_upgrade );

			if ( is_true( self.pers_upgrades_monitor["all" + "_details"] ) && is_true( self.pers_upgrades_monitor[pers_upgrade + "_details"] ) )
			{
				pers_upgrades_monitor[pers_upgrade].stats = [];

				switch ( pers_upgrade )
				{
					case "multikill_headshots":
						pers_upgrades_monitor[pers_upgrade] thread pers_check_for_pers_headshot( self );
						break;
					case "flopper":
						pers_upgrades_monitor[pers_upgrade] thread pers_flopper_damage_counter( self );
						break;
					case "perk_lose":
						pers_upgrades_monitor[pers_upgrade] thread pers_upgrade_perk_lose_bought( self );
						break;
					case "pistol_points":
						pers_upgrades_monitor[pers_upgrade] thread pers_pistol_points_accuracy( self );
						break;
					case "sniper":
						pers_upgrades_monitor[pers_upgrade] thread pers_sniper_player_fires( self );
						break;
					case "nube":
						pers_upgrades_monitor[pers_upgrade] thread pers_nube_weapon_upgrade_check( self );
						break;
					case "board":
					case "revive":
					case "cash_back":
					case "insta_kill":
					case "jugg":
					case "box_weapon":
						foreach ( stat_name in level.pers_upgrades[pers_upgrade].stat_names )
							pers_upgrades_monitor[pers_upgrade] thread check_pers_upgrade_stat( self, stat_name );

						break;
				}
			}
		}
	}

	tracker_hud_positions_and_labels( pers_upgrades_monitor );
#if USE_CHAT_COMMANDS == 1
	self thread on_tracker_hud_toggle_off( pers_upgrades_monitor );
#endif
	self thread remove_tracker_hud_think( pers_upgrades_monitor );
}

check_pers_upgrade( player, pers_upgrade )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif

	for (;;)
	{
		wait 0.05;
		self setValue( player.pers_upgrades_awarded[pers_upgrade] );
	}
}

check_pers_upgrade_stat( player, stat_name )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats[stat_name] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats[stat_name] setValue( player.pers[stat_name] );
	}
}

pers_check_for_pers_headshot( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["pers_multikill_headshots"] = player createfontstring( "small", 1 );
	self.stats["non_headshot_kill_counter"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["pers_multikill_headshots"] setValue( player.pers["pers_multikill_headshots"] );
		self.stats["non_headshot_kill_counter"] setValue( player.non_headshot_kill_counter );
		player waittill( "zom_kill" );
	}
}

pers_flopper_damage_counter( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["pers_num_flopper_damages"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["pers_num_flopper_damages"] setValue( isdefined( player.pers_num_flopper_damages ) ? player.pers_num_flopper_damages : -1 );
		player waittill( "damage" );
	}
}

pers_upgrade_perk_lose_bought( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["pers_perk_lose_counter"] = player createfontstring( "small", 1 );
	self.stats["pers_perk_lose_start_round"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["pers_perk_lose_counter"] setValue( player.pers["pers_perk_lose_counter"] );
		self.stats["pers_perk_lose_start_round"] setValue( ( isdefined( player.pers_perk_lose_start_round ) && player.pers_perk_lose_start_round != 1 ) ? player.pers_perk_lose_start_round : -1 );
		player waittill( "burp" );
		wait 2;
	}
}

pers_pistol_points_accuracy( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["accuracy"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["accuracy"] setValue( player maps\mp\zombies\_zm_pers_upgrades_functions::pers_get_player_accuracy() );
		player waittill( "weapon_fired" );
	}
}

pers_sniper_player_fires( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["pers_sniper_kills"] = player createfontstring( "small", 1 );
	self.stats["num_sniper_misses"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["pers_sniper_kills"] setValue( isdefined( player.pers_sniper_kills ) ? player.pers_sniper_kills : -1 );
		self.stats["num_sniper_misses"] setValue( isdefined( player.num_sniper_misses ) ? player.num_sniper_misses : -1 );
		player waittill( "weapon_fired" );
	}
}

pers_nube_weapon_upgrade_check( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
#if USE_CHAT_COMMANDS == 1
	player endon( "custom_pers_upgrades_hud_off" );
#endif
	self.stats["pers_max_round_reached"] = player createfontstring( "small", 1 );
	self.stats["pers_num_nube_kills"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.stats["pers_max_round_reached"] setValue( player.pers["pers_max_round_reached"] );
		self.stats["pers_num_nube_kills"] setValue( player.pers_num_nube_kills );
		player waittill_any( "pers_stats_end_of_round", "pers_player_zombie_kill" );
	}
}

tracker_hud_positions_and_labels( pers_upgrades_monitor )
{
	point = "TOP_LEFT";
	relativePoint = "TOP_LEFT";
	yoffset = -20;

	foreach ( pers_upgrade, hudelem in pers_upgrades_monitor )
	{
		if ( yoffset >= 123 && relativePoint != "TOP_RIGHT" )
		{
			point = "TOP_RIGHT";
			relativePoint = "TOP_RIGHT";
			yoffset = -20;
		}

		hudelem setpoint( point, relativePoint, 0, yoffset );
		hudelem.hidewheninmenu = 1;

		switch ( pers_upgrade )
		{
			case "board":
				hudelem.label = iString( "^2" + "board" + " awarded: " );
				break;
			case "revive":
				hudelem.label = iString( "^2" + "revive" + " awarded: " );
				break;
			case "multikill_headshots":
				hudelem.label = iString( "^2" + "multikill_headshots" + " awarded: " );
				break;
			case "cash_back":
				hudelem.label = iString( "^2" + "cash_back" + " awarded: " );
				break;
			case "insta_kill":
				hudelem.label = iString( "^2" + "insta_kill" + " awarded: " );
				break;
			case "jugg":
				hudelem.label = iString( "^2" + "jugg" + " awarded: " );
				break;
			case "carpenter":
				hudelem.label = iString( "^2" + "carpenter" + " awarded: " );
				break;
			case "flopper":
				hudelem.label = iString( "^2" + "flopper" + " awarded: " );
				break;
			case "perk_lose":
				hudelem.label = iString( "^2" + "perk_lose" + " awarded: " );
				break;
			case "pistol_points":
				hudelem.label = iString( "^2" + "pistol_points" + " awarded: " );
				break;
			case "double_points":
				hudelem.label = iString( "^2" + "double_points" + " awarded: " );
				break;
			case "sniper":
				hudelem.label = iString( "^2" + "sniper" + " awarded: " );
				break;
			case "box_weapon":
				hudelem.label = iString( "^2" + "box_weapon" + " awarded: " );
				break;
			case "nube":
				hudelem.label = iString( "^2" + "nube" + " awarded: " );
				break;
		}

		yoffset += 13;

		if ( isdefined( hudelem.stats ) )
		{
			foreach ( stat_name, elem in hudelem.stats )
			{
				elem setpoint( point, relativePoint, 0, yoffset );
				elem.hidewheninmenu = 1;

				switch ( stat_name )
				{
					//board
					case "pers_boarding":
						elem.label = iString( "Boards stat to obtain (" + level.pers_boarding_number_of_boards_required + ")" + ": " );
						break;
					//revive
					case "pers_revivenoperk":
						elem.label = iString( "Revives stat to obtain (" + level.pers_revivenoperk_number_of_revives_required + ")" + ": " );
						break;
					//multikill_headshots
					case "pers_multikill_headshots":
						elem.label = iString( "Multi-kill collateral headshots stat to obtain (" + level.pers_multikill_headshots_required + ")" + ": " );
						break;
					case "non_headshot_kill_counter":
						elem.label = iString( "Non-headshots stat to lose (" + level.pers_multikill_headshots_upgrade_reset_counter + ")" + ": " );
						break;
					//cash_back
					case "pers_cash_back_bought":
						elem.label = iString( "Perk purchases stat to obtain (" + level.pers_cash_back_num_perks_required + ")" + ": " );
						break;
					case "pers_cash_back_prone":
						elem.label = iString( "Perk purchases followed by prone stat to obtain (" + level.pers_cash_back_perk_buys_prone_required + ")" + ": " );
						break;
					//insta_kill
					case "pers_insta_kill":
						elem.label = iString( "No-kill insta-kills stat to obtain (" + level.pers_insta_kill_num_required + ")" + ": " );
						break;
					//jugg
					case "pers_jugg":
						elem.label = iString( "Low-round deaths stat to obtain (" + level.pers_jugg_hit_and_die_total + ")" + ": " );
						break;
					//flopper
					case "pers_num_flopper_damages":
						elem.label = iString( "Falls stat to obtain (" + level.pers_flopper_damage_counter + ")" + ": " );
						break;
					//perk_lose
					case "pers_perk_lose_counter":
						elem.label = iString( "Low-round 4-perk games stat to obtain (" + level.pers_perk_lose_counter + ")" + ": " );
						break;
					case "pers_perk_lose_start_round":
						elem.label = iString( "Lost if perk purchased on round: " );
						break;
					//pistol_points
					case "accuracy":
						elem.label = iString( "Accuracy stat (<=" + level.pers_pistol_points_accuracy + ")" + ": " );
						break;
					//sniper
					case "pers_sniper_kills":
						elem.label = iString( "Long-range sniper round kills stat to obtain (>=" + level.pers_sniper_round_kills_counter + ")" + ": " );
						break;
					case "num_sniper_misses":
						elem.label = iString( "Sniper misses stat to lose (" + level.pers_sniper_misses + ")" + ": " );
						break;
					//box_weapon
					case "pers_box_weapon_counter":
						elem.label = iString( "Weapons accepted in a row stat to obtain (" + level.pers_box_weapon_counter + ")" + ": " );
						break;
					//nube
					case "pers_max_round_reached":
						elem.label = iString( "Maximum round completed stat (<" + level.pers_nube_lose_round + ")" + ": " );
						break;
					case "pers_num_nube_kills":
						elem.label = iString( "Nube kills stat (>=" + level.pers_numb_num_kills_unlock + ")" + ": " );
						break;
				}

				yoffset += 11;
			}
		}
	}
}

remove_tracker_hud_think( hud )
{
#if USE_CHAT_COMMANDS == 1
	self endon( "custom_pers_upgrades_hud_off" );
#endif
	waittill_any_ents_two( self, "disconnect", level, "end_game" );
	remove_tracker_hud( hud );
}

remove_tracker_hud( hud )
{
	array1 = array_copy( hud );
	array2 = [];

	foreach ( elem in array1 )
		array2 = maps\mp\_utility::combinearrays( array2, elem.stats );

	array = maps\mp\_utility::combinearrays( array1, array2 );

	foreach ( elem in array )
	{
		elem.parent hud_removechild_from_hud_parent( elem );

		if ( isdefined( elem ) )
			elem destroy();
	}
}

hud_removechild_from_hud_parent( element )
{
	element.parent = undefined;

	if ( self.children[self.children.size - 1] != element )
	{
		self.children[element.index] = self.children[self.children.size - 1];

		if ( isdefined( self.children[element.index] ) )
			self.children[element.index].index = element.index;
	}

	self.children[self.children.size - 1] = undefined;
	element.index = undefined;
}

#if USE_CHAT_COMMANDS == 1
on_tracker_hud_toggle_off( hud )
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self waittill( "custom_tracker_hud_toggle_off" );
	self notify( "custom_pers_upgrades_hud_off" );
	remove_tracker_hud( hud );
	self.pers_upgrades_tracker_hud_running = 0;
}

tracker_hud_command(args)
{
	if (args.size < 1)
	{
		return NotEnoughArgsError(1);
	}

	error = self toggle_tracker_hud(args[0]);

	if (IsDefined(error))
	{
		return error;
	}
}

toggle_tracker_hud( toggle )
{
	if ( !isinarray( array( "1", "on", "0", "off" ), toLower( toggle ) ) )
	{
		error = array( "Invalid input", GetDvar("cc_prefix") + "put_hud" + " only accepts:", "'1' or 'on' to enable", "'0' or 'off' to disable" );
		return error;
	}
	else if ( isinarray( array( "0", "off" ), toLower( toggle ) ) )
	{
		if ( !is_true( self.pers_upgrades_tracker_hud_running ) )
		{
			error = array( "Error:", GetDvar("cc_prefix") + "put_hud" + " is already off" );
			return error;
		}

		self notify( "custom_tracker_hud_toggle_off" );
	}
	else //if ( isinarray( array( "1", "on" ), toLower( toggle ) ) )
	{
		if ( is_true( self.pers_upgrades_tracker_hud_running ) )
		{
			error = array( "Error:", GetDvar("cc_prefix") + "put_hud" + " is already on" );
			return error;
		}

		self thread pers_upgrades_monitor();
	}
}

tracker_hud_elements_command(args)
{
	if (args.size < 2)
	{
		return NotEnoughArgsError(2);
	}

	error = self toggle_tracker_hud_elements(args[0], args[1]);

	if (IsDefined(error))
	{
		return error;
	}
}

toggle_tracker_hud_elements( var, toggle )
{
	if ( !isinarray( getArrayKeys( self.pers_upgrades_monitor ), toLower( var ) ) )
	{
		error = array( "Invalid input", GetDvar("cc_prefix") + "put_elem" + " could not find " + toLower( var ) );
		return error;
	}

	if ( !isinarray( array( "1", "on", "0", "off" ), toLower( toggle ) ) )
	{
		error = array( "Invalid input", GetDvar("cc_prefix") + "put_elem" + " " + toLower( var ) + " only accepts:", "'1' or 'on' to enable", "'0' or 'off' to disable" );
		return error;
	}
	else if ( isinarray( array( "0", "off" ), toLower( toggle ) ) )
	{
		if ( self.pers_upgrades_monitor[var] == 0 )
		{
			error = array( "Error:", var + " is already off" );
			return error;
		}

		self.pers_upgrades_monitor[var] = 0;
		self notify( "custom_tracker_hud_toggle_off" );
		wait 0.05;
		self thread pers_upgrades_monitor();
	}
	else //if ( isinarray( array( "1", "on" ), toLower( toggle ) ) )
	{
		if ( self.pers_upgrades_monitor[var] == 1 )
		{
			error = array( "Error:", var + " is already on" );
			return error;
		}

		self.pers_upgrades_monitor[var] = 1;
		self notify( "custom_tracker_hud_toggle_off" );
		wait 0.05;
		self thread pers_upgrades_monitor();
	}
}
#endif
