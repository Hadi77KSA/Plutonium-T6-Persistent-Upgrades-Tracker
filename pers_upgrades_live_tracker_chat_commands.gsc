#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include scripts\chat_commands;

init()
{
	if ( maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active() )
	{
		CreateCommand( level.chat_commands["ports"], "put_hud", "function", ::tracker_hud_command );
		CreateCommand( level.chat_commands["ports"], "put_elem", "function", ::tracker_hud_elements_command );
		level thread onPlayerConnect();
	}
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player init_detailed_variables_toggles();
		player thread pers_upgrades_tracker_hud();
		player thread display_mod_message();
	}
}

init_detailed_variables_toggles()
{
	self.pers_upgrades_tracker_toggles = [];
	self.pers_upgrades_tracker_toggles["all_details"] =                 0; //change this to 1 to display additional variables, change to 0 to hide.

	//due to limitations, some variables may not display even if enabled.
	//on Buried, it's possible to load up to 29 variables.
	//total variables = 31. detailed = 17.

	self.pers_upgrades_tracker_toggles["board"] =                       1;
	self.pers_upgrades_tracker_toggles["board_details"] =               1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["revive"] =                      1;
	self.pers_upgrades_tracker_toggles["revive_details"] =              1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["multikill_headshots"] =         1;
	self.pers_upgrades_tracker_toggles["multikill_headshots_details"] = 1; //2 detailed variable(s)
	self.pers_upgrades_tracker_toggles["cash_back"] =                   1;
	self.pers_upgrades_tracker_toggles["cash_back_details"] =           1; //2 detailed variable(s)
	self.pers_upgrades_tracker_toggles["insta_kill"] =                  1;
	self.pers_upgrades_tracker_toggles["insta_kill_details"] =          1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["jugg"] =                        1;
	self.pers_upgrades_tracker_toggles["jugg_details"] =                1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["carpenter"] =                   1;
	//self.pers_upgrades_tracker_toggles["carpenter_details"] =           0; //0 detailed variable(s)
	self.pers_upgrades_tracker_toggles["flopper"] =                     1;
	self.pers_upgrades_tracker_toggles["flopper_details"] =             1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["perk_lose"] =                   1;
	self.pers_upgrades_tracker_toggles["perk_lose_details"] =           1; //2 detailed variable(s)
	self.pers_upgrades_tracker_toggles["pistol_points"] =               1;
	self.pers_upgrades_tracker_toggles["pistol_points_details"] =       1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["double_points"] =               1;
	//self.pers_upgrades_tracker_toggles["double_points_details"] =       0; //0 detailed variable(s)
	self.pers_upgrades_tracker_toggles["sniper"] =                      1;
	self.pers_upgrades_tracker_toggles["sniper_details"] =              1; //2 detailed variable(s)
	self.pers_upgrades_tracker_toggles["box_weapon"] =                  1;
	self.pers_upgrades_tracker_toggles["box_weapon_details"] =          1; //1 detailed variable(s)
	self.pers_upgrades_tracker_toggles["nube"] =                        1;
	self.pers_upgrades_tracker_toggles["nube_details"] =                1; //2 detailed variable(s)
}

display_mod_message()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^2Persistent Upgrades Tracker ^5mod by ^6Hadi77KSA" );
}

pers_upgrades_tracker_hud()
{
	level endon( "end_game" );
	self endon( "disconnect" );
	self endon( "custom_pers_upgrades_hud_off" );

	if ( level.intermission || !( isdefined( level.pers_upgrades_keys ) && level.pers_upgrades_keys.size > 0 ) )
		return;

	flag_wait( "initial_blackscreen_passed" );

	if ( is_true( self.pers_upgrades_tracker_hud_running ) )
		return;

	self.pers_upgrades_tracker_hud_running = 1;
	pers_upgrades_tracker_stats = self init_pers_upgrades_tracker_array();

	foreach ( pers_upgrade, pers_upgrade_tracker in pers_upgrades_tracker_stats )
	{
		pers_upgrade_tracker thread pers_upgrade_track_awarded( self, pers_upgrade );

		if ( isdefined( pers_upgrade_tracker.upgrade_stats ) )
		{
			switch ( pers_upgrade )
			{
				case "multikill_headshots":
					pers_upgrade_tracker thread pers_multikill_headshots_track_detailed( self );
					break;
				case "flopper":
					pers_upgrade_tracker thread pers_flopper_track_detailed( self );
					break;
				case "perk_lose":
					pers_upgrade_tracker thread pers_perk_lose_track_detailed( self );
					break;
				case "pistol_points":
					pers_upgrade_tracker thread pers_pistol_points_track_detailed( self );
					break;
				case "sniper":
					pers_upgrade_tracker thread pers_sniper_track_detailed( self );
					break;
				case "nube":
					pers_upgrade_tracker thread pers_nube_track_detailed( self );
					break;
				case "board":
				case "revive":
				case "cash_back":
				case "insta_kill":
				case "jugg":
				case "box_weapon":
					foreach ( stat_name in level.pers_upgrades[pers_upgrade].stat_names )
						pers_upgrade_tracker thread generic_pers_upgrade_track_detailed( self, stat_name );

					break;
			}
		}
	}

	tracker_hud_positions_and_labels( pers_upgrades_tracker_stats );
	self thread on_tracker_hud_toggle_off( pers_upgrades_tracker_stats );
	self thread remove_tracker_hud_think( pers_upgrades_tracker_stats );
}

init_pers_upgrades_tracker_array()
{
	pers_upgrades_tracker_array = [];

	foreach ( pers_upgrade in level.pers_upgrades_keys )
	{
		if ( is_true( self.pers_upgrades_tracker_toggles[pers_upgrade] ) )
		{
			pers_upgrades_tracker_array[pers_upgrade] = self createfontstring( "small", 1.2 );

			if ( is_true( self.pers_upgrades_tracker_toggles["all_details"] ) && is_true( self.pers_upgrades_tracker_toggles[pers_upgrade + "_details"] ) )
				pers_upgrades_tracker_array[pers_upgrade].upgrade_stats = [];
		}
	}

	return pers_upgrades_tracker_array;
}

pers_upgrade_track_awarded( player, pers_upgrade )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );

	for (;;)
	{
		wait 0.05;
		self setValue( player.pers_upgrades_awarded[pers_upgrade] );
	}
}

generic_pers_upgrade_track_detailed( player, stat_name )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats[stat_name] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats[stat_name] setValue( player.pers[stat_name] );
	}
}

pers_multikill_headshots_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["pers_multikill_headshots"] = player createfontstring( "small", 1 );
	self.upgrade_stats["non_headshot_kill_counter"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["pers_multikill_headshots"] setValue( player.pers["pers_multikill_headshots"] );
		self.upgrade_stats["non_headshot_kill_counter"] setValue( player.non_headshot_kill_counter );
		player waittill( "zom_kill" );
	}
}

pers_flopper_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["pers_num_flopper_damages"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["pers_num_flopper_damages"] setValue( custom_check_value_func( player.pers_num_flopper_damages ) );
		player waittill( "damage" );
	}
}

pers_perk_lose_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["pers_perk_lose_counter"] = player createfontstring( "small", 1 );
	self.upgrade_stats["pers_perk_lose_start_round"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["pers_perk_lose_counter"] setValue( player.pers["pers_perk_lose_counter"] );

		if ( !isdefined( player.pers_perk_lose_start_round ) || player.pers_perk_lose_start_round == 1 )
			self.upgrade_stats["pers_perk_lose_start_round"] setValue( -1 );
		else
			self.upgrade_stats["pers_perk_lose_start_round"] setValue( player.pers_perk_lose_start_round );

		player waittill( "burp" );
		wait 2;
	}
}

pers_pistol_points_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["accuracy"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["accuracy"] setValue( player maps\mp\zombies\_zm_pers_upgrades_functions::pers_get_player_accuracy() );
		player waittill( "weapon_fired" );
	}
}

pers_sniper_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["pers_sniper_kills"] = player createfontstring( "small", 1 );
	self.upgrade_stats["num_sniper_misses"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["pers_sniper_kills"] setValue( custom_check_value_func( player.pers_sniper_kills ) );
		self.upgrade_stats["num_sniper_misses"] setValue( custom_check_value_func( player.num_sniper_misses ) );
		player waittill( "weapon_fired" );
	}
}

pers_nube_track_detailed( player )
{
	level endon( "end_game" );
	player endon( "disconnect" );
	player endon( "custom_pers_upgrades_hud_off" );
	self.upgrade_stats["pers_max_round_reached"] = player createfontstring( "small", 1 );
	self.upgrade_stats["pers_num_nube_kills"] = player createfontstring( "small", 1 );

	for (;;)
	{
		wait 0.05;
		self.upgrade_stats["pers_max_round_reached"] setValue( player.pers["pers_max_round_reached"] );
		self.upgrade_stats["pers_num_nube_kills"] setValue( player.pers_num_nube_kills );
		player waittill_any( "pers_stats_end_of_round", "pers_player_zombie_kill" );
	}
}

custom_check_value_func( variable )
{
	if ( !isdefined( variable ) )
		return -1;

	return variable;
}

tracker_hud_positions_and_labels( pers_upgrades_tracker_array )
{
	point = "TOP_LEFT";
	relativePoint = "TOP_LEFT";
	yoffset = -20;

	foreach ( pers_upgrade, pers_upgrade_tracker in pers_upgrades_tracker_array )
	{
		if ( yoffset >= 123 && relativePoint != "TOP_RIGHT" )
		{
			point = "TOP_RIGHT";
			relativePoint = "TOP_RIGHT";
			yoffset = -20;
		}

		pers_upgrade_tracker setpoint( point, relativePoint, 0, yoffset );
		pers_upgrade_tracker.hidewheninmenu = 1;

		switch ( pers_upgrade )
		{
			case "board":
				pers_upgrade_tracker.label = &"^2board awarded: ";
				break;
			case "revive":
				pers_upgrade_tracker.label = &"^2revive awarded: ";
				break;
			case "multikill_headshots":
				pers_upgrade_tracker.label = &"^2multikill_headshots awarded: ";
				break;
			case "cash_back":
				pers_upgrade_tracker.label = &"^2cash_back awarded: ";
				break;
			case "insta_kill":
				pers_upgrade_tracker.label = &"^2insta_kill awarded: ";
				break;
			case "jugg":
				pers_upgrade_tracker.label = &"^2jugg awarded: ";
				break;
			case "carpenter":
				pers_upgrade_tracker.label = &"^2carpenter awarded: ";
				break;
			case "flopper":
				pers_upgrade_tracker.label = &"^2flopper awarded: ";
				break;
			case "perk_lose":
				pers_upgrade_tracker.label = &"^2perk_lose awarded: ";
				break;
			case "pistol_points":
				pers_upgrade_tracker.label = &"^2pistol_points awarded: ";
				break;
			case "double_points":
				pers_upgrade_tracker.label = &"^2double_points awarded: ";
				break;
			case "sniper":
				pers_upgrade_tracker.label = &"^2sniper awarded: ";
				break;
			case "box_weapon":
				pers_upgrade_tracker.label = &"^2box_weapon awarded: ";
				break;
			case "nube":
				pers_upgrade_tracker.label = &"^2nube awarded: ";
				break;
		}

		yoffset += 13;

		if ( isdefined( pers_upgrade_tracker.upgrade_stats ) )
		{
			foreach ( upgrade_stat, upgrade_stat_tracker in pers_upgrade_tracker.upgrade_stats )
			{
				upgrade_stat_tracker setpoint( point, relativePoint, 0, yoffset );
				upgrade_stat_tracker.hidewheninmenu = 1;

				switch ( upgrade_stat )
				{
					//board
					case "pers_boarding":
						upgrade_stat_tracker.label = &"Boards stat to obtain: ";
						break;
					//revive
					case "pers_revivenoperk":
						upgrade_stat_tracker.label = &"Revives stat to obtain: ";
						break;
					//multikill_headshots
					case "pers_multikill_headshots":
						upgrade_stat_tracker.label = &"Multi-kill collateral headshots stat to obtain: ";
						break;
					case "non_headshot_kill_counter":
						upgrade_stat_tracker.label = &"Non-headshots stat to lose: ";
						break;
					//cash_back
					case "pers_cash_back_bought":
						upgrade_stat_tracker.label = &"Perk purchases stat to obtain: ";
						break;
					case "pers_cash_back_prone":
						upgrade_stat_tracker.label = &"Perk purchases followed by prone stat to obtain: ";
						break;
					//insta_kill
					case "pers_insta_kill":
						upgrade_stat_tracker.label = &"No-kill insta-kills stat to obtain: ";
						break;
					//jugg
					case "pers_jugg":
						upgrade_stat_tracker.label = &"Low-round deaths stat to obtain: ";
						break;
					//flopper
					case "pers_num_flopper_damages":
						upgrade_stat_tracker.label = &"Falls stat to obtain: ";
						break;
					//perk_lose
					case "pers_perk_lose_counter":
						upgrade_stat_tracker.label = &"Low-round 4-perk games stat to obtain: ";
						break;
					case "pers_perk_lose_start_round":
						upgrade_stat_tracker.label = &"Lost if perk purchased on round: ";
						break;
					//pistol_points
					case "accuracy":
						upgrade_stat_tracker.label = &"Accuracy stat: ";
						break;
					//sniper
					case "pers_sniper_kills":
						upgrade_stat_tracker.label = &"Long-range sniper round kills stat to obtain: ";
						break;
					case "num_sniper_misses":
						upgrade_stat_tracker.label = &"Sniper misses stat to lose: ";
						break;
					//box_weapon
					case "pers_box_weapon_counter":
						upgrade_stat_tracker.label = &"Weapons accepted in a row stat to obtain: ";
						break;
					//nube
					case "pers_max_round_reached":
						upgrade_stat_tracker.label = &"Maximum round completed stat: ";
						break;
					case "pers_num_nube_kills":
						upgrade_stat_tracker.label = &"Nube kills stat: ";
						break;
				}

				yoffset += 11;
			}
		}
	}
}

remove_tracker_hud_think( hud )
{
	waittill_any_ents_two( self, "disconnect", level, "end_game" );
	remove_tracker_hud( hud );
}

remove_tracker_hud( hud )
{
	header_elems = array_copy( hud );
	sub_elems = [];

	foreach ( elem in header_elems )
		sub_elems = maps\mp\_utility::combinearrays( sub_elems, elem.upgrade_stats );

	total_elems = maps\mp\_utility::combinearrays( header_elems, sub_elems );

	foreach ( elem in total_elems )
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

		self thread pers_upgrades_tracker_hud();
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

toggle_tracker_hud_elements( variable_to_toggle, toggle )
{
	if ( !isinarray( getArrayKeys( self.pers_upgrades_tracker_toggles ), toLower( variable_to_toggle ) ) )
	{
		error = array( "Invalid input", GetDvar("cc_prefix") + "put_elem" + " could not find " + toLower( variable_to_toggle ) );
		return error;
	}

	if ( !isinarray( array( "1", "on", "0", "off" ), toLower( toggle ) ) )
	{
		error = array( "Invalid input", GetDvar("cc_prefix") + "put_elem" + " " + toLower( variable_to_toggle ) + " only accepts:", "'1' or 'on' to enable", "'0' or 'off' to disable" );
		return error;
	}
	else if ( isinarray( array( "0", "off" ), toLower( toggle ) ) )
	{
		if ( self.pers_upgrades_tracker_toggles[variable_to_toggle] == 0 )
		{
			error = array( "Error:", variable_to_toggle + " is already off" );
			return error;
		}

		self.pers_upgrades_tracker_toggles[variable_to_toggle] = 0;
		self notify( "custom_tracker_hud_toggle_off" );
		wait 0.05;
		self thread pers_upgrades_tracker_hud();
	}
	else //if ( isinarray( array( "1", "on" ), toLower( toggle ) ) )
	{
		if ( self.pers_upgrades_tracker_toggles[variable_to_toggle] == 1 )
		{
			error = array( "Error:", variable_to_toggle + " is already on" );
			return error;
		}

		self.pers_upgrades_tracker_toggles[variable_to_toggle] = 1;
		self notify( "custom_tracker_hud_toggle_off" );
		wait 0.05;
		self thread pers_upgrades_tracker_hud();
	}
}
