#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\zombies\_zm_pers_upgrades_functions;
#include scripts\chat_commands;

init()
{
    level thread onPlayerConnect();
    CreateCommand( level.chat_commands[ "ports" ], "toggletrackerhud", "function", ::tracker_hud_command );
}

onPlayerConnect()
{
	while( 1 )
	{
		level waittill( "connected", player );
        player thread pers_upgrades_tracker_hud();
	}
}

pers_upgrades_tracker_hud()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    self endon( "custom_pers_upgrades_hud_off" );
    flag_wait( "initial_blackscreen_passed" );
    if( is_true( self.pers_upgrades_tracker_hud_running ) )
    {
        return;
    }
    self.pers_upgrades_tracker_hud_running = 1;

    enabled_variables = [];
    enabled_variables[ "detailed" ] =                       1;  //change this to 1 to display additional variables, change to 0 to hide.
                                                                //due to limitations, some variables may not display even if enabled.
                                                                //on Buried, it's possible to load up to 29 variables.
                                                                //total variables = 31. detailed = 17.

    enabled_variables[ "board_details" ] =                  1;  //1 detailed variable(s)
    enabled_variables[ "revive_details" ] =                 1;  //1 detailed variable(s)
    enabled_variables[ "multikill_headshots_details" ] =    1;  //2 detailed variable(s)
    enabled_variables[ "cash_back_details" ] =              1;  //2 detailed variable(s)
    enabled_variables[ "insta_kill_details" ] =             1;  //1 detailed variable(s)
    enabled_variables[ "jugg_details" ] =                   1;  //1 detailed variable(s)
    enabled_variables[ "carpenter_details" ] =              0;  //0 detailed variable(s)
    enabled_variables[ "flopper_details" ] =                1;  //1 detailed variable(s)
    enabled_variables[ "perk_lose_details" ] =              1;  //2 detailed variable(s)
    enabled_variables[ "pistol_points_details" ] =          1;  //1 detailed variable(s)
    enabled_variables[ "double_points_details" ] =          0;  //0 detailed variable(s)
    enabled_variables[ "sniper_details" ] =                 1;  //2 detailed variable(s)
    enabled_variables[ "box_weapon_details" ] =             1;  //1 detailed variable(s)
    enabled_variables[ "nube_details" ] =                   1;  //2 detailed variable(s)

    if( enabled_variables[ "detailed" ] )
    {
        stats_array = [];
        foreach( pers_upgrade in level.pers_upgrades_keys )
        {
            stats_array[ pers_upgrade ] = [];
        }
    }

    hud_init_done = 0;
    array = [];
    pers_perk_lose_round_stat_set = 0;
    while( 1 )
    {
        if( enabled_variables[ "detailed" ] )
        {
            if( enabled_variables[ "board_details" ] )
            {
                stats_array[ "board" ][ "Boards stat to obtain" ] = self.pers[ "pers_boarding" ] + "/" + level.pers_boarding_number_of_boards_required;
            }
            if( enabled_variables[ "revive_details" ] )
            {
                stats_array[ "revive" ][ "Revives stat to obtain" ] = self.pers[ "pers_revivenoperk" ] + "/" + level.pers_revivenoperk_number_of_revives_required;
            }
            if( enabled_variables[ "multikill_headshots_details" ] )
            {
                stats_array[ "multikill_headshots" ][ "Multi-kill collateral headshots stat to obtain" ] = self.pers[ "pers_multikill_headshots" ] + "/" + level.pers_multikill_headshots_required;
                stats_array[ "multikill_headshots" ][ "Non-headshots stat to lose" ] = self.non_headshot_kill_counter + "/" + level.pers_multikill_headshots_upgrade_reset_counter;
            }
            if( enabled_variables[ "cash_back_details" ] )
            {
                stats_array[ "cash_back" ][ "Perk purchases stat to obtain" ] = self.pers[ "pers_cash_back_bought" ] + "/" + level.pers_cash_back_num_perks_required;
                stats_array[ "cash_back" ][ "Perk purchases followed by prone stat to obtain" ] = self.pers[ "pers_cash_back_prone" ] + "/" + level.pers_cash_back_perk_buys_prone_required;
            }
            if( enabled_variables[ "insta_kill_details" ] )
            {
                stats_array[ "insta_kill" ][ "No-kill insta-kills stat to obtain" ] = self.pers[ "pers_insta_kill" ] + "/" + level.pers_insta_kill_num_required;
            }
            if( enabled_variables[ "jugg_details" ] )
            {
                stats_array[ "jugg" ][ "Low-round deaths stat to obtain" ] = self.pers[ "pers_jugg" ] + "/" + level.pers_jugg_hit_and_die_total;
            }
            if( enabled_variables[ "flopper_details" ] )
            {
                stats_array[ "flopper" ][ "Falls stat to obtain" ] = custom_check_value_func( self.pers_num_flopper_damages ) + "/" + level.pers_flopper_damage_counter;
            }
            if( enabled_variables[ "perk_lose_details" ] )
            {
                stats_array[ "perk_lose" ][ "Low-round 4-perk games stat to obtain" ] = self.pers[ "pers_perk_lose_counter" ] + "/" + level.pers_perk_lose_counter;
                if( isDefined( self.pers_perk_lose_start_round ) && ( self.pers_perk_lose_start_round != 1 ) && !pers_perk_lose_round_stat_set )
                {
                    stats_array[ "perk_lose" ][ "Lost if perk purchased on round" ] = self.pers_perk_lose_start_round;
                    pers_perk_lose_round_stat_set = 1;
                }
                else if( !pers_perk_lose_round_stat_set )
                {
                    stats_array[ "perk_lose" ][ "Lost if perk purchased on round" ] = "";
                }
            }
            if( enabled_variables[ "pistol_points_details" ] )
            {
                stats_array[ "pistol_points" ][ "Accuracy stat" ] = self maps\mp\zombies\_zm_pers_upgrades_functions::pers_get_player_accuracy() + " <= " + level.pers_pistol_points_accuracy;
            }
            if( enabled_variables[ "sniper_details" ] )
            {
                stats_array[ "sniper" ][ "Long-range sniper round kills stat to obtain" ] = custom_check_value_func( self.pers_sniper_kills ) + "/" + level.pers_sniper_round_kills_counter;
                stats_array[ "sniper" ][ "Sniper misses stat to lose" ] = custom_check_value_func( self.num_sniper_misses ) + "/" + level.pers_sniper_misses;
            }
            if( enabled_variables[ "box_weapon_details" ] )
            {
                stats_array[ "box_weapon" ][ "Weapons accepted in a row stat to obtain" ] = self.pers[ "pers_box_weapon_counter" ] + "/" + level.pers_box_weapon_counter;
            }
            if( enabled_variables[ "nube_details" ] )
            {
                stats_array[ "nube" ][ "Maximum round completed stat" ] = self.pers[ "pers_max_round_reached" ] + "/" + level.pers_nube_lose_round;
                stats_array[ "nube" ][ "Nube kills stat" ] = custom_check_value_func( self.pers_num_nube_kills ) + "/" + level.pers_numb_num_kills_unlock;
            }
        }
        
        foreach( pers_upgrade in level.pers_upgrades_keys )
        {
            array[ "^2" + pers_upgrade + " awarded" ] = self.pers_upgrades_awarded[ pers_upgrade ];
            if( enabled_variables[ "detailed" ] )
            {
                if( enabled_variables[ pers_upgrade + "_details" ] )
                {
                    array[ pers_upgrade + " stats:" ] = stats_array[ pers_upgrade ];
                }
            }
        }

        if( !hud_init_done )
        {
            custom_hud = self custom_hud_init( array );
            hud_init_done = 1;
            self thread tracker_hud_toggle_off_watcher( custom_hud );
        }
        else
        {
            custom_hud update_custom_hud( array );
        }

        wait 0.05;
    }
}

custom_check_value_func( variable )
{
    if( isDefined( variable ) )
    {
        return variable;
    }
    return "";
}

custom_hud_init( array )
{
    huds = [];
    relativePoint = undefined;
    xoffset = 0;
    yoffset = 0;
    keys = getArrayKeys( array );
    for( key_index = keys.size - 1; key_index >= 0 ; key_index-- )
    {
        key = keys[ key_index ];
        if( isSubStr( key, "awarded" ) )
        {
            if( yoffset >= 270 )
            {
                relativePoint = "TOP_RIGHT";
                xoffset = -180;
                yoffset = 0;
            }
            huds[ key ] = self createfontstring( "small", 1.2 );
            huds[ key ] setpoint( "TOP_LEFT", relativePoint, xoffset, yoffset );
            huds[ key ].hidewheninmenu = 1;

            yoffset += 15;
            
        }
        else //if( isSubStr( key, "stats:" ) )
        {
            sub_keys = getArrayKeys( array[ key ] );
            for( sub_key_index = sub_keys.size - 1; sub_key_index >= 0 ; sub_key_index-- )
            {
                sub_key = sub_keys[ sub_key_index ];
                huds[ sub_key ] = self createfontstring( "small", 1 );
                huds[ sub_key ] setpoint( "TOP_LEFT", relativePoint, xoffset, yoffset );
                huds[ sub_key ].hidewheninmenu = 1;
                
                yoffset += 15;
            }
        }
    }
    return huds;
}

tracker_hud_toggle_off_watcher( hud )
{
    self waittill( "custom_tracker_hud_toggle_off" );
    hud custom_destroy_tracker_hud();
    self notify( "custom_pers_upgrades_hud_off" );
    self.pers_upgrades_tracker_hud_running = 0;
}

custom_destroy_tracker_hud()
{
    keys = getArrayKeys( self );
    foreach( key in keys )
    {
        if( isSubStr( key, "stats:" ) )
        {
            sub_keys = getArrayKeys( self[ key ] );
            foreach( sub_key in sub_keys )
            {
                self[ sub_key ] destroyelem();
            }
        }
        else //if( isSubStr( key, "awarded" ) )
        {
            self[ key ] destroyelem();            
        }
    }
}

update_custom_hud( array )
{
    foreach( key in getArrayKeys( array ) )
    {
        if( isSubStr( key, "awarded" ) )
        {
            self[ key ] setText( key + ": " + array[ key ] );
        }
        else //if( isSubStr( key, "stats:" ) )
        {
            foreach( sub_key in getArrayKeys( array[ key ] ) )
            {
                self[ sub_key ] setText( sub_key + ": " + array[ key ][ sub_key ] );
            }
        }
    }
    return;
}

tracker_hud_command( args )
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
    if( toLower( toggle ) != "0" && toLower( toggle ) != "off" && toLower( toggle ) != "1" && toLower( toggle ) != "on" )
    {
        return array( "Invalid input", GetDvar("cc_prefix") + "toggletrackerhud" +" only accepts:", "'on' or '1' to enable", "'off' or '0' to disable" );
    }
    else if( toLower( toggle ) == "0" || toLower( toggle ) == "off" )
    {
        if ( !is_true( self.pers_upgrades_tracker_hud_running ) )
        {
            return array( "Error:", GetDvar("cc_prefix") + "toggletrackerhud" +" is already off" );
        }
        self notify( "custom_tracker_hud_toggle_off" );
    }
    else //if( toLower( toggle ) == "1" || toLower( toggle ) == "on" )
    {
        if ( is_true( self.pers_upgrades_tracker_hud_running ) )
        {
            return array( "Error:", GetDvar("cc_prefix") + "toggletrackerhud" +" is already on" );
        }
        self thread pers_upgrades_tracker_hud();
    }
}
