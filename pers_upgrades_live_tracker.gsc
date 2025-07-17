#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

init()
{
	if ( maps\mp\zombies\_zm_pers_upgrades::is_pers_system_active() )
		level thread onPlayerConnect();
}

onPlayerConnect()
{
	for (;;)
	{
		level waittill( "connected", player );
		player init_detailed_variables_toggles();
		player thread pers_upgrades_monitor();
		player thread display_mod_message();
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

display_mod_message()
{
	self endon( "disconnect" );
	flag_wait( "initial_players_connected" );
	self iPrintLn( "^3Persistent Upgrades Tracker ^5mod by ^6Hadi77KSA" );
}

pers_upgrades_monitor()
{
	level endon( "end_game" );
	self endon( "disconnect" );

	if ( level.intermission || !( isdefined( level.pers_upgrades_keys ) && level.pers_upgrades_keys.size > 0 ) )
		return;

	flag_wait( "initial_blackscreen_passed" );
	pers_upgrades_monitor = [];

	foreach ( pers_upgrade in level.pers_upgrades_keys )
	{
		if ( is_true( self.pers_upgrades_monitor[pers_upgrade] ) )
		{
			pers_upgrades_monitor[pers_upgrade] = self createfontstring( "small", 1.2 );

			if ( is_true( self.pers_upgrades_monitor["all" + "_details"] ) && is_true( self.pers_upgrades_monitor[pers_upgrade + "_details"] ) )
				pers_upgrades_monitor[pers_upgrade].stats = [];
		}
	}

	foreach ( pers_upgrade, hudelem in pers_upgrades_monitor )
	{
		hudelem thread check_pers_upgrade( self, pers_upgrade );

		if ( isdefined( hudelem.stats ) )
		{
			switch ( pers_upgrade )
			{
				case "multikill_headshots":
					hudelem thread pers_check_for_pers_headshot( self );
					break;
				case "flopper":
					hudelem thread pers_flopper_damage_counter( self );
					break;
				case "perk_lose":
					hudelem thread pers_upgrade_perk_lose_bought( self );
					break;
				case "pistol_points":
					hudelem thread pers_pistol_points_accuracy( self );
					break;
				case "sniper":
					hudelem thread pers_sniper_player_fires( self );
					break;
				case "nube":
					hudelem thread pers_nube_weapon_upgrade_check( self );
					break;
				case "board":
				case "revive":
				case "cash_back":
				case "insta_kill":
				case "jugg":
				case "box_weapon":
					foreach ( stat_name in level.pers_upgrades[pers_upgrade].stat_names )
						hudelem thread check_pers_upgrade_stat( self, stat_name );

					break;
			}
		}
	}

	tracker_hud_positions_and_labels( pers_upgrades_monitor );
	self thread remove_tracker_hud_think( pers_upgrades_monitor );
}

check_pers_upgrade( player, pers_upgrade )
{
	level endon( "end_game" );
	player endon( "disconnect" );

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
				hudelem.label = &"^2board awarded: ";
				break;
			case "revive":
				hudelem.label = &"^2revive awarded: ";
				break;
			case "multikill_headshots":
				hudelem.label = &"^2multikill_headshots awarded: ";
				break;
			case "cash_back":
				hudelem.label = &"^2cash_back awarded: ";
				break;
			case "insta_kill":
				hudelem.label = &"^2insta_kill awarded: ";
				break;
			case "jugg":
				hudelem.label = &"^2jugg awarded: ";
				break;
			case "carpenter":
				hudelem.label = &"^2carpenter awarded: ";
				break;
			case "flopper":
				hudelem.label = &"^2flopper awarded: ";
				break;
			case "perk_lose":
				hudelem.label = &"^2perk_lose awarded: ";
				break;
			case "pistol_points":
				hudelem.label = &"^2pistol_points awarded: ";
				break;
			case "double_points":
				hudelem.label = &"^2double_points awarded: ";
				break;
			case "sniper":
				hudelem.label = &"^2sniper awarded: ";
				break;
			case "box_weapon":
				hudelem.label = &"^2box_weapon awarded: ";
				break;
			case "nube":
				hudelem.label = &"^2nube awarded: ";
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
						elem.label = &"Boards stat to obtain: ";
						break;
					//revive
					case "pers_revivenoperk":
						elem.label = &"Revives stat to obtain: ";
						break;
					//multikill_headshots
					case "pers_multikill_headshots":
						elem.label = &"Multi-kill collateral headshots stat to obtain: ";
						break;
					case "non_headshot_kill_counter":
						elem.label = &"Non-headshots stat to lose: ";
						break;
					//cash_back
					case "pers_cash_back_bought":
						elem.label = &"Perk purchases stat to obtain: ";
						break;
					case "pers_cash_back_prone":
						elem.label = &"Perk purchases followed by prone stat to obtain: ";
						break;
					//insta_kill
					case "pers_insta_kill":
						elem.label = &"No-kill insta-kills stat to obtain: ";
						break;
					//jugg
					case "pers_jugg":
						elem.label = &"Low-round deaths stat to obtain: ";
						break;
					//flopper
					case "pers_num_flopper_damages":
						elem.label = &"Falls stat to obtain: ";
						break;
					//perk_lose
					case "pers_perk_lose_counter":
						elem.label = &"Low-round 4-perk games stat to obtain: ";
						break;
					case "pers_perk_lose_start_round":
						elem.label = &"Lost if perk purchased on round: ";
						break;
					//pistol_points
					case "accuracy":
						elem.label = &"Accuracy stat: ";
						break;
					//sniper
					case "pers_sniper_kills":
						elem.label = &"Long-range sniper round kills stat to obtain: ";
						break;
					case "num_sniper_misses":
						elem.label = &"Sniper misses stat to lose: ";
						break;
					//box_weapon
					case "pers_box_weapon_counter":
						elem.label = &"Weapons accepted in a row stat to obtain: ";
						break;
					//nube
					case "pers_max_round_reached":
						elem.label = &"Maximum round completed stat: ";
						break;
					case "pers_num_nube_kills":
						elem.label = &"Nube kills stat: ";
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
	array1 = array_copy( hud );
	array2 = [];

	foreach ( elem in array1 )
		array2 = maps\mp\_utility::combinearrays( array2, elem.upgrade_stats );

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
