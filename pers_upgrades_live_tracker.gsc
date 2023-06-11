#include common_scripts\utility;
#include maps\mp\gametypes_zm\_hud_util;

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    while( 1 )
    {
        level waittill( "connected", player );
        player init_detailed_variables_toggles();
        player thread onPlayerSpawned();
        player thread pers_upgrades_tracker_hud();
    }
}

init_detailed_variables_toggles()
{
    self.custom_detailed_variables = [];
    self.custom_detailed_variables[ "all_details" ] =                   0;  //change this to 1 to display additional variables, change to 0 to hide.
                                                                            //due to limitations, some variables may not display even if enabled.
                                                                            //on Buried, it's possible to load up to 29 variables.
                                                                            //total variables = 31. detailed = 17.

    self.custom_detailed_variables[ "board_details" ] =                 1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "revive_details" ] =                1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "multikill_headshots_details" ] =   1;  //2 detailed variable(s)
    self.custom_detailed_variables[ "cash_back_details" ] =             1;  //2 detailed variable(s)
    self.custom_detailed_variables[ "insta_kill_details" ] =            1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "jugg_details" ] =                  1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "carpenter_details" ] =             0;  //0 detailed variable(s)
    self.custom_detailed_variables[ "flopper_details" ] =               1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "perk_lose_details" ] =             1;  //2 detailed variable(s)
    self.custom_detailed_variables[ "pistol_points_details" ] =         1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "double_points_details" ] =         0;  //0 detailed variable(s)
    self.custom_detailed_variables[ "sniper_details" ] =                1;  //2 detailed variable(s)
    self.custom_detailed_variables[ "box_weapon_details" ] =            1;  //1 detailed variable(s)
    self.custom_detailed_variables[ "nube_details" ] =                  1;  //2 detailed variable(s)
    return;
}

onPlayerSpawned()
{
    self endon( "disconnect" );
    level endon( "end_game" );
    for(;;)
    {
        self waittill( "spawned_player" );
        self iPrintLn( "^2Persistent Upgrades Tracker ^5mod loaded by ^6Hadi77KSA" );
    }
}

pers_upgrades_tracker_hud()
{
    level endon( "end_game" );
    self endon( "disconnect" );
    flag_wait( "initial_blackscreen_passed" );

    toggled_variables = self.custom_detailed_variables;

    if( toggled_variables[ "all_details" ] )
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
        if( toggled_variables[ "all_details" ] )
        {
            if( toggled_variables[ "board_details" ] )
            {
                stats_array[ "board" ][ "Boards stat to obtain" ] = self.pers[ "pers_boarding" ] + "/" + level.pers_boarding_number_of_boards_required;
            }
            if( toggled_variables[ "revive_details" ] )
            {
                stats_array[ "revive" ][ "Revives stat to obtain" ] = self.pers[ "pers_revivenoperk" ] + "/" + level.pers_revivenoperk_number_of_revives_required;
            }
            if( toggled_variables[ "multikill_headshots_details" ] )
            {
                stats_array[ "multikill_headshots" ][ "Multi-kill collateral headshots stat to obtain" ] = self.pers[ "pers_multikill_headshots" ] + "/" + level.pers_multikill_headshots_required;
                stats_array[ "multikill_headshots" ][ "Non-headshots stat to lose" ] = self.non_headshot_kill_counter + "/" + level.pers_multikill_headshots_upgrade_reset_counter;
            }
            if( toggled_variables[ "cash_back_details" ] )
            {
                stats_array[ "cash_back" ][ "Perk purchases stat to obtain" ] = self.pers[ "pers_cash_back_bought" ] + "/" + level.pers_cash_back_num_perks_required;
                stats_array[ "cash_back" ][ "Perk purchases followed by prone stat to obtain" ] = self.pers[ "pers_cash_back_prone" ] + "/" + level.pers_cash_back_perk_buys_prone_required;
            }
            if( toggled_variables[ "insta_kill_details" ] )
            {
                stats_array[ "insta_kill" ][ "No-kill insta-kills stat to obtain" ] = self.pers[ "pers_insta_kill" ] + "/" + level.pers_insta_kill_num_required;
            }
            if( toggled_variables[ "jugg_details" ] )
            {
                stats_array[ "jugg" ][ "Low-round deaths stat to obtain" ] = self.pers[ "pers_jugg" ] + "/" + level.pers_jugg_hit_and_die_total;
            }
            if( toggled_variables[ "flopper_details" ] )
            {
                stats_array[ "flopper" ][ "Falls stat to obtain" ] = custom_check_value_func( self.pers_num_flopper_damages ) + "/" + level.pers_flopper_damage_counter;
            }
            if( toggled_variables[ "perk_lose_details" ] )
            {
                stats_array[ "perk_lose" ][ "Low-round 4-perk games stat to obtain" ] = self.pers[ "pers_perk_lose_counter" ] + "/" + level.pers_perk_lose_counter;
                if( isDefined( self.pers_perk_lose_start_round ) && self.pers_perk_lose_start_round != 1 && !pers_perk_lose_round_stat_set )
                {
                    stats_array[ "perk_lose" ][ "Lost if perk purchased on round" ] = self.pers_perk_lose_start_round;
                    pers_perk_lose_round_stat_set = 1;
                }
                else if( !pers_perk_lose_round_stat_set )
                {
                    stats_array[ "perk_lose" ][ "Lost if perk purchased on round" ] = "";
                }
            }
            if( toggled_variables[ "pistol_points_details" ] )
            {
                stats_array[ "pistol_points" ][ "Accuracy stat" ] = self maps\mp\zombies\_zm_pers_upgrades_functions::pers_get_player_accuracy() + " <= " + level.pers_pistol_points_accuracy;
            }
            if( toggled_variables[ "sniper_details" ] )
            {
                stats_array[ "sniper" ][ "Long-range sniper round kills stat to obtain" ] = custom_check_value_func( self.pers_sniper_kills ) + "/" + level.pers_sniper_round_kills_counter;
                stats_array[ "sniper" ][ "Sniper misses stat to lose" ] = custom_check_value_func( self.num_sniper_misses ) + "/" + level.pers_sniper_misses;
            }
            if( toggled_variables[ "box_weapon_details" ] )
            {
                stats_array[ "box_weapon" ][ "Weapons accepted in a row stat to obtain" ] = self.pers[ "pers_box_weapon_counter" ] + "/" + level.pers_box_weapon_counter;
            }
            if( toggled_variables[ "nube_details" ] )
            {
                stats_array[ "nube" ][ "Maximum round completed stat" ] = self.pers[ "pers_max_round_reached" ] + " < " + level.pers_nube_lose_round;
                stats_array[ "nube" ][ "Nube kills stat" ] = custom_check_value_func( self.pers_num_nube_kills ) + " >= " + level.pers_numb_num_kills_unlock;
            }
        }

        foreach( pers_upgrade in level.pers_upgrades_keys )
        {
            array[ "^2" + pers_upgrade + " awarded" ] = self.pers_upgrades_awarded[ pers_upgrade ];
            if( toggled_variables[ "all_details" ] )
            {
                if( toggled_variables[ pers_upgrade + "_details" ] )
                {
                    array[ pers_upgrade + " stats:" ] = stats_array[ pers_upgrade ];
                }
            }
        }

        if( !hud_init_done )
        {
            custom_hud = self custom_hud_init( array );
            hud_init_done = 1;
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
    point = "TOP_LEFT";
    relativePoint = "TOP_LEFT";
    yoffset = -20;
    keys = getArrayKeys( array );
    for( key_index = keys.size - 1; key_index >= 0; key_index-- )
    {
        key = keys[ key_index ];
        if( isSubStr( key, "awarded" ) )
        {
            if( yoffset >= 123 && relativePoint != "TOP_RIGHT" )
            {
                point = "TOP_RIGHT";
                relativePoint = "TOP_RIGHT";
                yoffset = -20;
            }
            huds[ key ] = self createfontstring( "small", 1.2 );
            huds[ key ] setpoint( point, relativePoint, 0, yoffset );
            huds[ key ].hidewheninmenu = 1;
            switch( getSubStr( key, 2, key.size - 8 ) )
            {
                case "board":
                    huds[ key ].label = &"^2board awarded: ";
                    break;

                case "revive":
                    huds[ key ].label = &"^2revive awarded: ";
                    break;

                case "multikill_headshots":
                    huds[ key ].label = &"^2multikill_headshots awarded: ";
                    break;

                case "cash_back":
                    huds[ key ].label = &"^2cash_back awarded: ";
                    break;

                case "insta_kill":
                    huds[ key ].label = &"^2insta_kill awarded: ";
                    break;

                case "jugg":
                    huds[ key ].label = &"^2jugg awarded: ";
                    break;

                case "carpenter":
                    huds[ key ].label = &"^2carpenter awarded: ";
                    break;

                case "flopper":
                    huds[ key ].label = &"^2flopper awarded: ";
                    break;

                case "perk_lose":
                    huds[ key ].label = &"^2perk_lose awarded: ";
                    break;

                case "pistol_points":
                    huds[ key ].label = &"^2pistol_points awarded: ";
                    break;

                case "double_points":
                    huds[ key ].label = &"^2double_points awarded: ";
                    break;

                case "sniper":
                    huds[ key ].label = &"^2sniper awarded: ";
                    break;

                case "box_weapon":
                    huds[ key ].label = &"^2box_weapon awarded: ";
                    break;

                case "nube":
                    huds[ key ].label = &"^2nube awarded: ";
                    break;

                default:
                    huds[ key ].label = &"^2unknown awarded: ";
            }
            yoffset += 13;
        }
        else //if( isSubStr( key, "stats:" ) )
        {
            sub_keys = getArrayKeys( array[ key ] );
            for( sub_key_index = sub_keys.size - 1; sub_key_index >= 0; sub_key_index-- )
            {
                sub_key = sub_keys[ sub_key_index ];
                huds[ sub_key ] = self createfontstring( "small", 1 );
                huds[ sub_key ] setpoint( point, relativePoint, 0, yoffset );
                huds[ sub_key ].hidewheninmenu = 1;
                switch( sub_key )
                {
                    //board
                    case "Boards stat to obtain":
                        huds[ sub_key ].label = &"Boards stat to obtain: ";
                        break;
                    //revive
                    case "Revives stat to obtain":
                        huds[ sub_key ].label = &"Revives stat to obtain: ";
                        break;
                    //multikill_headshots
                    case "Multi-kill collateral headshots stat to obtain":
                        huds[ sub_key ].label = &"Multi-kill collateral headshots stat to obtain: ";
                        break;
                    case "Non-headshots stat to lose":
                        huds[ sub_key ].label = &"Non-headshots stat to lose: ";
                        break;
                    //cash_back
                    case "Perk purchases stat to obtain":
                        huds[ sub_key ].label = &"Perk purchases stat to obtain: ";
                        break;
                    case "Perk purchases followed by prone stat to obtain":
                        huds[ sub_key ].label = &"Perk purchases followed by prone stat to obtain: ";
                        break;
                    //insta_kill
                    case "No-kill insta-kills stat to obtain":
                        huds[ sub_key ].label = &"No-kill insta-kills stat to obtain: ";
                        break;
                    //jugg
                    case "Low-round deaths stat to obtain":
                        huds[ sub_key ].label = &"Low-round deaths stat to obtain: ";
                        break;
                    //flopper
                    case "Falls stat to obtain":
                        huds[ sub_key ].label = &"Falls stat to obtain: ";
                        break;
                    //perk_lose
                    case "Low-round 4-perk games stat to obtain":
                        huds[ sub_key ].label = &"Low-round 4-perk games stat to obtain: ";
                        break;
                    case "Lost if perk purchased on round":
                        huds[ sub_key ].label = &"Lost if perk purchased on round: ";
                        break;
                    //pistol_points
                    case "Accuracy stat":
                        huds[ sub_key ].label = &"Accuracy stat: ";
                        break;
                    //sniper
                    case "Long-range sniper round kills stat to obtain":
                        huds[ sub_key ].label = &"Long-range sniper round kills stat to obtain: ";
                        break;
                    case "Sniper misses stat to lose":
                        huds[ sub_key ].label = &"Sniper misses stat to lose: ";
                        break;
                    //box_weapon
                    case "Weapons accepted in a row stat to obtain":
                        huds[ sub_key ].label = &"Weapons accepted in a row stat to obtain: ";
                        break;
                    //nube
                    case "Maximum round completed stat":
                        huds[ sub_key ].label = &"Maximum round completed stat: ";
                        break;
                    case "Nube kills stat":
                        huds[ sub_key ].label = &"Nube kills stat: ";
                        break;

                    default:
                        huds[ sub_key ].label = &"unknown stat: ";
                }
                yoffset += 11;
            }
        }
    }
    return huds;
}

update_custom_hud( array )
{
    foreach( key in getArrayKeys( array ) )
    {
        if( isSubStr( key, "awarded" ) )
        {
            self[ key ] setValue( array[ key ] );
        }
        else //if( isSubStr( key, "stats:" ) )
        {
            foreach( sub_key in getArrayKeys( array[ key ] ) )
            {
                self[ sub_key ] setValue( array[ key ][ sub_key ] );
            }
        }
    }
    return;
}
