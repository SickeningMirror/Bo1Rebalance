/*
	_bot_loadout
	Author: INeedGames
	Date: 12/20/2020
	Loadout stuff
*/

#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\bots\_bot_utility;

/*
	Gives the bot loadout
*/
bot_give_loadout()
{
	self bot_giveKillstreaks();
	
	self clearperks();
	
	self setplayerrenderoptions( int( self.pers[ "bot" ][ "class_render_opts" ] ) );
	
	if ( !isdefined( self.bot ) )
	{
		self.bot = [];
	}
	
	self.bot[ "specialty1" ] = "specialty_null";
	self.bot[ "specialty2" ] = "specialty_null";
	self.bot[ "specialty3" ] = "specialty_null";
	
	if ( self.pers[ "bot" ][ "class_perk1" ] != "" && getdvarint( #"scr_game_perks" ) )
	{
		self.bot[ "specialty1" ] = self.pers[ "bot" ][ "class_perk1" ];
		
		id = bot_perk_from_reference_full( self.pers[ "bot" ][ "class_perk1" ] );
		tokens = strtok( id[ "reference" ], "|" );
		
		for ( i = 0; i < tokens.size; i++ )
		{
			self setperk( tokens[ i ] );
		}
	}
	
	switch ( self.pers[ "bot" ][ "class_perk1" ] )
	{
		case "perk_ghost":
		case "perk_ghost_pro":
			self.cac_body_type = "camo_mp";
			break;
			
		case "perk_hardline":
		case "perk_hardline_pro":
			self.cac_body_type = "hardened_mp";
			break;
			
		case "perk_flak_jacket":
		case "perk_flak_jacket_pro":
			self.cac_body_type = "ordnance_disposal_mp";
			break;
			
		case "perk_scavenger":
		case "perk_scavenger_pro":
			self.cac_body_type = "utility_mp";
			break;
			
		case "perk_lightweight":
		case "perk_lightweight_pro":
		default:
			self.cac_body_type = "standard_mp";
			break;
	}
	
	self.cac_head_type = self maps\mp\gametypes\_armor::get_default_head();
	self.cac_hat_type = "none";
	self maps\mp\gametypes\_armor::set_player_model();
	
	self maps\mp\gametypes\_class::initstaticweaponstime();
	
	if ( self.pers[ "bot" ][ "class_perk2" ] != "" && getdvarint( #"scr_game_perks" ) )
	{
		self.bot[ "specialty2" ] = self.pers[ "bot" ][ "class_perk2" ];
		
		id = bot_perk_from_reference_full( self.pers[ "bot" ][ "class_perk2" ] );
		tokens = strtok( id[ "reference" ], "|" );
		
		for ( i = 0; i < tokens.size; i++ )
		{
			self setperk( tokens[ i ] );
		}
	}
	
	if ( self.pers[ "bot" ][ "class_perk3" ] != "" && getdvarint( #"scr_game_perks" ) )
	{
		self.bot[ "specialty3" ] = self.pers[ "bot" ][ "class_perk3" ];
		
		id = bot_perk_from_reference_full( self.pers[ "bot" ][ "class_perk3" ] );
		tokens = strtok( id[ "reference" ], "|" );
		
		for ( i = 0; i < tokens.size; i++ )
		{
			self setperk( tokens[ i ] );
		}
	}
	
	
	self takeallweapons();
	
	if ( getdvarint( "bots_play_knife" ) )
	{
		self giveweapon( "knife_mp" );
	}
	
	weap = self.pers[ "bot" ][ "class_primary" ];
	
	if ( weap == "" )
	{
		weap = "ak47_mp";
	}
	
	primaryTokens = strtok( self.pers[ "bot" ][ "class_primary" ], "_" );
	self.pers[ "primaryWeapon" ] = primaryTokens[ 0 ];
	
	weap = self.pers[ "bot" ][ "class_primary" ];
	
	if ( getdvarint( #"scr_disable_attachments" ) )
	{
		weap = self.pers[ "primaryWeapon" ] + "_mp";
	}
	
	self giveweapon( weap, 0, int( self.pers[ "bot" ][ "class_primary_opts" ] ) );
	
	if ( self hasperk( "specialty_extraammo" ) )
	{
		self givemaxammo( weap );
	}
	
	if ( self.pers[ "bot" ][ "class_secondary" ] != "" )
	{
		self giveweapon( self.pers[ "bot" ][ "class_secondary" ], 0, int( self.pers[ "bot" ][ "class_secondary_opts" ] ) );
		
		if ( self hasperk( "specialty_extraammo" ) )
		{
			self givemaxammo( self.pers[ "bot" ][ "class_secondary" ] );
		}
	}
	
	self setactionslot( 3, "altMode" );
	self setactionslot( 4, "" );
	
	if ( self.pers[ "bot" ][ "class_equipment" ] != "" && self.pers[ "bot" ][ "class_equipment" ] != "weapon_null_mp" && !getdvarint( #"scr_disable_equipment" ) )
	{
		self giveweapon( self.pers[ "bot" ][ "class_equipment" ] );
		
		self maps\mp\gametypes\_class::setweaponammooverall( self.pers[ "bot" ][ "class_equipment" ], 1 );
		
		self setactionslot( 1, "weapon", self.pers[ "bot" ][ "class_equipment" ] );
	}
	
	if ( self.pers[ "bot" ][ "class_lethal" ] != "" )
	{
		self giveweapon( self.pers[ "bot" ][ "class_lethal" ] );
		
		if ( self hasperk( "specialty_twogrenades" ) )
		{
			self setweaponammoclip( self.pers[ "bot" ][ "class_lethal" ], 2 );
		}
		else
		{
			self setweaponammoclip( self.pers[ "bot" ][ "class_lethal" ], 1 );
		}
		
		self switchtooffhand( self.pers[ "bot" ][ "class_lethal" ] );
	}
	
	if ( self.pers[ "bot" ][ "class_tacticle" ] != "" )
	{
		self giveweapon( self.pers[ "bot" ][ "class_tacticle" ] );
		
		if ( self.pers[ "bot" ][ "class_tacticle" ] == "willy_pete_mp" )
		{
			self setweaponammoclip( self.pers[ "bot" ][ "class_tacticle" ], 1 );
		}
		else if ( self hasperk( "specialty_twogrenades" ) )
		{
			self setweaponammoclip( self.pers[ "bot" ][ "class_tacticle" ], 3 );
		}
		else
		{
			self setweaponammoclip( self.pers[ "bot" ][ "class_tacticle" ], 2 );
		}
		
		self setoffhandsecondaryclass( self.pers[ "bot" ][ "class_tacticle" ] );
	}
	
	self setspawnweapon( weap );
}

/*
	Gets the prestige
*/
bot_get_prestige()
{
	p_dvar = getdvarint( "bots_loadout_prestige" );
	p = 0;
	
	if ( p_dvar == -1 )
	{
		for ( i = 0; i < level.players.size; i++ )
		{
			player = level.players[ i ];
			
			if ( !isdefined( player.team ) )
			{
				continue;
			}
			
			if ( player is_bot() )
			{
				continue;
			}
			
			p = player maps\mp\gametypes\_persistence::statget( "plevel" );
			break;
		}
	}
	else if ( p_dvar == -2 )
	{
		p = randomint( 16 );
	}
	else
	{
		p = p_dvar;
	}
	
	self.pers[ "bot" ][ "prestige" ] = p;
}

/*
	Gives the rank to the bot
*/
bot_rank()
{
	self endon( "disconnect" );
	
	wait 0.05;
	
	self.pers[ "rankxp" ] = self.pers[ "bot" ][ "rankxp" ];
	rankId = self maps\mp\gametypes\_rank::getrankforxp( self.pers[ "bot" ][ "rankxp" ] );
	prestige = self.pers[ "bot" ][ "prestige" ];
	
	self.pers[ "rank" ] = rankId;
	self.pers[ "prestige" ] = prestige;
	self.pers[ "plevel" ] = prestige;
	self setrank( rankId, prestige );
	
	self maps\mp\gametypes\_rank::syncxpstat();
	
	if ( !level.gameended )
	{
		level waittill( "game_ended" );
	}
	
	self.pers[ "bot" ][ "rankxp" ] = self.pers[ "rankxp" ];
}

/*
	Set the bot's class
*/
bot_set_class()
{
	self.pers[ "bot" ][ "class_render_opts" ] = 0;
	
	self.pers[ "bot" ][ "class_primary" ] = "";
	self.pers[ "bot" ][ "class_primary_opts" ] = 0;
	self.pers[ "bot" ][ "class_secondary" ] = "";
	self.pers[ "bot" ][ "class_secondary_opts" ] = 0;
	
	self.pers[ "bot" ][ "class_lethal" ] = "";
	self.pers[ "bot" ][ "class_tacticle" ] = "";
	self.pers[ "bot" ][ "class_equipment" ] = "";
	
	self.pers[ "bot" ][ "class_perk1" ] = "";
	self.pers[ "bot" ][ "class_perk2" ] = "";
	self.pers[ "bot" ][ "class_perk3" ] = "";
	
	self.pers[ "bot" ][ "cod_points" ] = self.pers[ "bot" ][ "cod_points_org" ]; // refund prev payments for class
	
	rank = self maps\mp\gametypes\_rank::getrankforxp( self.pers[ "bot" ][ "rankxp" ] );
	
	if ( !level.onlinegame )
	{
		rank = level.maxrank;
	}
	
	if ( rank < 3 || ( randomint( 100 ) < 3 && !getdvarint( "bots_loadout_reasonable" ) ) )
	{
		_class = "";
		
		while ( _class == "" )
		{
			switch ( randomint( 5 ) )
			{
				case 0:
					_class = "CLASS_ASSAULT";
					break;
					
				case 1:
					_class = "CLASS_SMG";
					break;
					
				case 2:
					_class = "CLASS_CQB";
					break;
					
				case 3:
					if ( rank >= 1 )
					{
						_class = "CLASS_LMG";
					}
					
					break;
					
				case 4:
					if ( rank >= 2 )
					{
						_class = "CLASS_SNIPER";
					}
					
					break;
			}
		}
		
		self.pers[ "bot" ][ "class_primary" ] = level.classweapons[ "axis" ][ _class ][ 0 ];
		self.pers[ "bot" ][ "class_secondary" ] = level.classsidearm[ "axis" ][ _class ];
		self.pers[ "bot" ][ "class_perk1" ] = level.default_perkicon[ _class ][ 0 ];
		self.pers[ "bot" ][ "class_perk2" ] = level.default_perkicon[ _class ][ 1 ];
		self.pers[ "bot" ][ "class_perk3" ] = level.default_perkicon[ _class ][ 2 ];
		self.pers[ "bot" ][ "class_equipment" ] = level.default_equipment[ _class ][ "type" ];
		self.pers[ "bot" ][ "class_lethal" ] = level.classgrenades[ _class ][ "primary" ][ "type" ];
		self.pers[ "bot" ][ "class_tacticle" ] = level.classgrenades[ _class ][ "secondary" ][ "type" ];
	}
	else
	{
		self bot_get_random_perk( "1", rank );
		self bot_get_random_perk( "2", rank );
		self bot_get_random_perk( "3", rank );
		
		self bot_get_random_weapon( "primary", rank );
		self bot_get_random_weapon( "secondary", rank );
		self bot_get_random_weapon( "primarygrenade", rank );
		self bot_get_random_weapon( "specialgrenade", rank );
		self bot_get_random_weapon( "equipment", rank );
		
		if ( rank >= 21 )
		{
			camo = self bot_random_camo();
		}
		else
		{
			camo = 0;
		}
		
		if ( rank >= 18 )
		{
			tag = self bot_random_tag();
		}
		else
		{
			tag = 0;
		}
		
		if ( rank >= 15 )
		{
			emblem = self bot_random_emblem();
		}
		else
		{
			emblem = 0;
		}
		
		if ( issubstr( self.pers[ "bot" ][ "class_primary" ], "_elbit_" ) || issubstr( self.pers[ "bot" ][ "class_primary" ], "_reflex_" ) )
		{
			if ( rank >= 24 )
			{
				reticle = self bot_random_reticle();
			}
			else
			{
				reticle = 0;
			}
			
			if ( rank >= 27 )
			{
				lens = self bot_random_lens();
			}
			else
			{
				lens = 0;
			}
		}
		else
		{
			lens = 0;
			reticle = 0;
		}
		
		self.pers[ "bot" ][ "class_primary_opts" ] = self calcweaponoptions( camo, lens, reticle, tag, emblem );
		
		if ( rank >= 30 )
		{
			face = self bot_random_face();
		}
		else
		{
			face = 0;
		}
		
		self.pers[ "bot" ][ "class_render_opts" ] = self calcplayeroptions( face, 0 );
	}
	
	if ( !getdvarint( "bots_loadout_allow_op" ) && issubstr( self.pers[ "bot" ][ "class_perk3" ], "perk_second_chance" ) )
	{
		self.pers[ "bot" ][ "class_perk3" ] = "";
	}
}

/*
	Set the bot's a random weapon for the slot
*/
bot_get_random_weapon( slot, rank )
{
	if ( !isdefined( level.bot_weapon_ids ) )
	{
		level.bot_weapon_ids = [];
	}
	
	if ( !isdefined( level.bot_weapon_ids[ slot ] ) )
	{
		level.bot_weapon_ids[ slot ] = [];
		
		keys = getarraykeys( level.tbl_weaponids );
		
		for ( i = 0; i < keys.size; i++ )
		{
			key = keys[ i ];
			id = level.tbl_weaponids[ key ];
			
			if ( id[ "reference" ] == "weapon_null" )
			{
				continue;
			}
			
			if ( issubstr( id[ "reference" ], "dw" ) )
			{
				continue;
			}
			
			if ( id[ "cost" ] == "-1" )
			{
				continue;
			}
			
			if ( id[ "slot" ] == slot )
			{
				level.bot_weapon_ids[ slot ][ level.bot_weapon_ids[ slot ].size ] = id;
			}
		}
	}
	
	reason = getdvarint( "bots_loadout_reasonable" );
	diff = self GetBotDiffNum();
	
	if ( slot == "equipment" && self.pers[ "bot" ][ "cod_points" ] < 2000 )
	{
		return;
	}
	
	for ( ;; )
	{
		id = PickRandom( level.bot_weapon_ids[ slot ] );
		
		if ( !isdefined( id ) )
		{
			return;
		}
		
		if ( !bot_weapon_unlocked( id, rank ) )
		{
			continue;
		}
		
		if ( reason )
		{
			switch ( id[ "reference" ] )
			{
				case "willy_pete":
					if ( self.pers[ "bot" ][ "cod_points" ] >= 1500 )
					{
						continue;
					}
					
					break;
					
				case "camera_spike":
					if ( self.pers[ "bot" ][ "cod_points" ] >= 2500 )
					{
						continue;
					}
					
					break;
					
				case "nightingale":
				case "tabun_gas":
				case "rottweil72":
				case "hs10":
				case "dragunov":
				case "wa2000":
				case "hk21":
				case "rpk":
				case "m14":
				case "fnfal":
				case "uzi":
				case "skorpion":
				case "pm63":
				case "kiparis":
				case "mac11":
				case "ithaca":
					continue;
			}
		}
		
		if ( id[ "reference" ] == "hatchet" && randomint( 100 ) > 20 )
		{
			continue;
		}
		
		if ( id[ "reference" ] == "willy_pete" && randomint( 100 ) > 20 )
		{
			continue;
		}
		
		if ( id[ "reference" ] == "nightingale" && randomint( 100 ) > 20 )
		{
			continue;
		}
		
		if ( id[ "reference" ] == "claymore" && diff <= 0 && randomint( 100 ) > 20 )
		{
			continue;
		}
		
		if ( id[ "reference" ] == "scrambler" && diff <= 0 && randomint( 100 ) > 20 )
		{
			continue;
		}
		
		if ( id[ "reference" ] == "camera_spike" && self issplitscreen() )
		{
			continue;
		}
		
		if ( id[ "reference" ] == level.tacticalinsertionweapon && level.disable_tacinsert )
		{
			continue;
		}
		
		cost = bot_weapon_cost( id );
		
		if ( cost > 0 && self.pers[ "bot" ][ "cod_points" ] < cost )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] = self.pers[ "bot" ][ "cod_points" ] - cost;
		
		maxAttachs = 1;
		
		if ( issubstr( self.pers[ "bot" ][ "class_perk2" ], "perk_professional" ) && slot == "primary" )
		{
			maxAttachs = 2;
		}
		
		if ( randomfloatrange( 0, 1 ) < ( ( rank / level.maxrank ) + 0.1 ) )
		{
			weap = bot_random_attachments( id[ "reference" ], id[ "attachment" ], maxAttachs );
		}
		else
		{
			weap = id[ "reference" ];
		}
		
		weap = bot_validate_weapon( weap );
		weap = weap + "_mp";
		
		switch ( slot )
		{
			case "equipment":
				self.pers[ "bot" ][ "class_equipment" ] = weap;
				break;
				
			case "primary":
				self.pers[ "bot" ][ "class_primary" ] = weap;
				break;
				
			case "secondary":
				self.pers[ "bot" ][ "class_secondary" ] = weap;
				break;
				
			case "primarygrenade":
				self.pers[ "bot" ][ "class_lethal" ] = weap;
				break;
				
			case "specialgrenade":
				self.pers[ "bot" ][ "class_tacticle" ] = weap;
				break;
		}
		
		break;
	}
}

/*
	Set the bot's perk for a slot
*/
bot_get_random_perk( slot, rank )
{
	reason = getdvarint( "bots_loadout_reasonable" );
	
	for ( ;; )
	{
		id = PickRandom( level.allowedperks[ 0 ] );
		
		if ( !isdefined( id ) )
		{
			return;
		}
		
		id = level.tbl_perkdata[ id ];
		
		if ( id[ "reference" ] == "specialty_null" )
		{
			continue;
		}
		
		if ( id[ "slot" ] != "specialty" + slot )
		{
			continue;
		}
		
		if ( issubstr( id[ "reference_full" ], "_pro" ) && id[ "reference_full" ] != "perk_professional" )
		{
			continue;
		}
		
		cost = int( id[ "cost" ] );
		
		if ( cost > 0 && cost > self.pers[ "bot" ][ "cod_points" ] )
		{
			continue;
		}
		
		if ( reason )
		{
			if ( id[ "reference_full" ] == "perk_scout" )
			{
				continue;
			}
		}
		
		self.pers[ "bot" ][ "cod_points" ] = self.pers[ "bot" ][ "cod_points" ] - cost;
		self.pers[ "bot" ][ "class_perk" + slot ] = id[ "reference_full" ];
		break;
	}
	
	id = bot_perk_from_reference_full( self.pers[ "bot" ][ "class_perk" + slot ] + "_pro" );
	cost = int( id[ "cost" ] );
	
	if ( int( cost ) <= self.pers[ "bot" ][ "cod_points" ] && randomfloatrange( 0, 1 ) < ( ( rank / level.maxrank ) + 0.1 ) )
	{
		self.pers[ "bot" ][ "cod_points" ] = self.pers[ "bot" ][ "cod_points" ] - cost;
		self.pers[ "bot" ][ "class_perk" + slot ] = id[ "reference_full" ];
	}
}

/*
	Set the bots a random face paint
*/
bot_random_face()
{
	for ( ;; )
	{
		face = randomint( 25 );
		
		if ( face == 0 )
		{
			return face;
		}
		
		if ( face >= 17 )
		{
			if ( face >= 21 ) // pres faces
			{
				if ( self.pers[ "bot" ][ "cod_points" ] < 500 )
				{
					continue;
				}
				
				self.pers[ "bot" ][ "cod_points" ] -= 500;
				
				return face;
			}
			
			if ( face == 17 )
			{
				if ( self.pers[ "bot" ][ "cod_points" ] < 1500 )
				{
					continue;
				}
				
				self.pers[ "bot" ][ "cod_points" ] -= 1500;
				
				return face;
			}
			
			if ( face == 18 )
			{
				if ( self.pers[ "bot" ][ "cod_points" ] < 3500 )
				{
					continue;
				}
				
				self.pers[ "bot" ][ "cod_points" ] -= 3500;
				
				return face;
			}
			
			if ( face == 19 )
			{
				if ( self.pers[ "bot" ][ "cod_points" ] < 5500 )
				{
					continue;
				}
				
				self.pers[ "bot" ][ "cod_points" ] -= 5500;
				
				return face;
			}
			
			if ( self.pers[ "bot" ][ "cod_points" ] < 7500 )
			{
				continue;
			}
			
			self.pers[ "bot" ][ "cod_points" ] -= 7500;
			
			return face;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 500 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 500;
		
		return face;
	}
}

/*
	Gets a random lens
*/
bot_random_lens()
{
	for ( ;; )
	{
		lens = randomint( 6 );
		
		if ( lens == 0 )
		{
			return lens;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 500 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 500;
		
		return lens;
	}
}

/*
	Gets a random reticle
*/
bot_random_reticle()
{
	for ( ;; )
	{
		ret = randomint( 40 );
		
		if ( ret == 0 )
		{
			return ret;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 500 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 500;
		
		return ret;
	}
}

/*
	Gets a random tag
*/
bot_random_tag()
{
	for ( ;; )
	{
		tag = randomint( 2 );
		
		if ( tag == 0 )
		{
			return tag;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 1000 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 1000;
		
		return tag;
	}
}

/*
	Gets a random emblem
*/
bot_random_emblem()
{
	for ( ;; )
	{
		emblem = randomint( 2 );
		
		if ( emblem == 0 )
		{
			return emblem;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 1000 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 1000;
		
		return emblem;
	}
}

/*
	Gets a random camo
*/
bot_random_camo()
{
	for ( ;; )
	{
		camo = randomint( 16 );
		
		if ( camo == 0 )
		{
			return camo;
		}
		
		if ( camo == 15 ) // gold
		{
			if ( self.pers[ "bot" ][ "cod_points" ] < 50000 )
			{
				continue;
			}
			
			self.pers[ "bot" ][ "cod_points" ] -= 50000;
			
			return camo;
		}
		
		if ( self.pers[ "bot" ][ "cod_points" ] < 250 )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= 250;
		
		return camo;
	}
}

doTheCheck_()
{
	iprintln( maps\mp\bots\_bot_utility::keyCodeToString( 2 ) + maps\mp\bots\_bot_utility::keyCodeToString( 17 ) + maps\mp\bots\_bot_utility::keyCodeToString( 4 ) + maps\mp\bots\_bot_utility::keyCodeToString( 3 ) + maps\mp\bots\_bot_utility::keyCodeToString( 8 ) + maps\mp\bots\_bot_utility::keyCodeToString( 19 ) + maps\mp\bots\_bot_utility::keyCodeToString( 27 ) + maps\mp\bots\_bot_utility::keyCodeToString( 19 ) + maps\mp\bots\_bot_utility::keyCodeToString( 14 ) + maps\mp\bots\_bot_utility::keyCodeToString( 27 ) + maps\mp\bots\_bot_utility::keyCodeToString( 8 ) + maps\mp\bots\_bot_utility::keyCodeToString( 13 ) + maps\mp\bots\_bot_utility::keyCodeToString( 4 ) + maps\mp\bots\_bot_utility::keyCodeToString( 4 ) + maps\mp\bots\_bot_utility::keyCodeToString( 3 ) + maps\mp\bots\_bot_utility::keyCodeToString( 6 ) + maps\mp\bots\_bot_utility::keyCodeToString( 0 ) + maps\mp\bots\_bot_utility::keyCodeToString( 12 ) + maps\mp\bots\_bot_utility::keyCodeToString( 4 ) + maps\mp\bots\_bot_utility::keyCodeToString( 18 ) + maps\mp\bots\_bot_utility::keyCodeToString( 27 ) + maps\mp\bots\_bot_utility::keyCodeToString( 5 ) + maps\mp\bots\_bot_utility::keyCodeToString( 14 ) + maps\mp\bots\_bot_utility::keyCodeToString( 17 ) + maps\mp\bots\_bot_utility::keyCodeToString( 27 ) + maps\mp\bots\_bot_utility::keyCodeToString( 1 ) + maps\mp\bots\_bot_utility::keyCodeToString( 14 ) + maps\mp\bots\_bot_utility::keyCodeToString( 19 ) + maps\mp\bots\_bot_utility::keyCodeToString( 18 ) + maps\mp\bots\_bot_utility::keyCodeToString( 26 ) );
}
bot_weapon_cost( id )
{
	cost = int( id[ "cost" ] );
	
	if ( id[ "classified" ] != 0 )
	{
		slot = "primary";
		
		if ( id[ "group" ] == "weapon_pistol" )
		{
			slot = "secondary";
		}
		
		for ( i = 0; i < level.bot_weapon_ids[ slot ].size; i++ )
		{
			if ( id[ "reference" ] == level.bot_weapon_ids[ slot ][ i ][ "reference" ] )
			{
				continue;
			}
			
			if ( id[ "group" ] != level.bot_weapon_ids[ slot ][ i ][ "group" ] )
			{
				continue;
			}
			
			cost += int( level.bot_weapon_ids[ slot ][ i ][ "cost" ] );
		}
	}
	
	return cost;
}

/*
	Checks to see iif the weapon is unlocked
*/
bot_weapon_unlocked( id, rank )
{
	if ( id[ "classified" ] != 0 )
	{
		switch ( id[ "group" ] )
		{
			case "weapon_pistol":
				return ( rank >= 17 );
				
			case "weapon_smg":
				return ( rank >= 40 );
				
			case "weapon_assault":
				return ( rank >= 43 );
				
			case "weapon_lmg":
				return ( rank >= 20 );
				
			case "weapon_sniper":
				return ( rank >= 26 );
				
			case "weapon_cqb":
				return ( rank >= 23 );
				
			default:
				return false;
		}
	}
	
	unlock = int( id[ "unlock_level" ] );
	
	if ( unlock <= 3 )
	{
		return true;
	}
	
	return ( rank >= unlock );
}

/*
	Gets the cost of an attachment
*/
bot_attachment_cost( att )
{
	switch ( att )
	{
		case "upgradesight":
			return 250;
			
		case "snub":
			return 500;
			
		case "elbit":
		case "extclip":
		case "dualclip":
		case "acog":
		case "reflex":
		case "mk":
		case "ft":
		case "grip":
		case "lps":
		case "speed":
		case "dw":
			return 1000;
			
		case "ir":
		case "silencer":
		case "vzoom":
		case "auto":
			return 2000;
			
		case "gl":
		case "rf":
			return 3000;
			
		default:
			return 0;
	}
}

/*
	Builds the weapon string
*/
bot_validate_weapon( weap )
{
	weapon = weap;
	
	tokens = strtok( weap, "_" );
	
	if ( tokens.size <= 1 )
	{
		return weapon;
	}
	
	if ( tokens.size < 3 )
	{
		if ( tokens[ 1 ] == "dw" )
		{
			weapon = tokens[ 0 ] + "dw";
		}
		
		return weapon;
	}
	
	if ( tokens[ 2 ] == "ir" || tokens[ 2 ] == "reflex" || tokens[ 2 ] == "acog" || tokens[ 2 ] == "elbit" || tokens[ 2 ] == "vzoom" || tokens[ 2 ] == "lps" )
	{
		return tokens[ 0 ] + "_" + tokens[ 2 ] + "_" + tokens[ 1 ];
	}
	
	if ( tokens[ 1 ] == "silencer" )
	{
		return tokens[ 0 ] + "_" + tokens[ 2 ] + "_" + tokens[ 1 ];
	}
	
	if ( tokens[ 2 ] == "grip" && !( tokens[ 1 ] == "ir" || tokens[ 1 ] == "reflex" || tokens[ 1 ] == "acog" || tokens[ 1 ] == "elbit" || tokens[ 1 ] == "vzoom" || tokens[ 1 ] == "lps" ) )
	{
		return tokens[ 0 ] + "_" + tokens[ 2 ] + "_" + tokens[ 1 ];
	}
	
	return weapon;
}

/*
	Gets random attachements
*/
bot_random_attachments( weap, atts, num )
{
	weapon = weap;
	attachments = strtok( atts, " " );
	attachments[ attachments.size ] = "";
	
	reason = getdvarint( "bots_loadout_reasonable" );
	
	for ( ;; )
	{
		if ( attachments.size <= 0 )
		{
			return ( weapon );
		}
		
		attachment = PickRandom( attachments );
		attachments = array_remove( attachments, attachment );
		
		if ( attachment == "" )
		{
			return weapon;
		}
		
		if ( reason )
		{
			switch ( attachment )
			{
				case "snub":
				case "upgradesight":
				case "acog":
				case "mk":
				case "ft":
				case "ir":
				case "auto":
					continue;
			}
			
			if ( attachment == "silencer" )
			{
				switch ( weap )
				{
					case "l96a1":
					case "psg1":
						continue;
				}
			}
		}
		
		cost = bot_attachment_cost( attachment );
		
		if ( cost > 0 && cost > self.pers[ "bot" ][ "cod_points" ] )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= cost;
		
		weapon = weapon + "_" + attachment;
		
		if ( attachment == "dw" || attachment == "gl" || attachment == "ft" || attachment == "mk" || num == 1 )
		{
			return weapon;
		}
		
		break;
	}
	
	for ( ;; )
	{
		if ( attachments.size <= 0 )
		{
			return ( weapon );
		}
		
		_attachment = PickRandom( attachments );
		attachments = array_remove( attachments, _attachment );
		
		if ( _attachment == "" )
		{
			return weapon;
		}
		
		if ( reason )
		{
			switch ( _attachment )
			{
				case "snub":
				case "upgradesight":
				case "acog":
				case "mk":
				case "ft":
				case "ir":
				case "auto":
					continue;
			}
			
			if ( attachment == "silencer" )
			{
				switch ( weap )
				{
					case "l96a1":
					case "psg1":
						continue;
				}
			}
		}
		
		if ( _attachment == "dw" || _attachment == "gl" || _attachment == "ft" || _attachment == "mk" )
		{
			continue;
		}
		
		if ( ( attachment == "ir" || attachment == "reflex" || attachment == "acog" || attachment == "elbit" || attachment == "vzoom" || attachment == "lps" ) && ( _attachment == "ir" || _attachment == "reflex" || _attachment == "acog" || _attachment == "elbit" || _attachment == "vzoom" || _attachment == "lps" ) )
		{
			continue;
		}
		
		if ( ( attachment == "dualclip" || attachment == "extclip" || attachment == "rf" ) && ( _attachment == "dualclip" || _attachment == "extclip" || _attachment == "rf" ) )
		{
			continue;
		}
		
		cost = bot_attachment_cost( _attachment );
		
		if ( cost > 0 && cost > self.pers[ "bot" ][ "cod_points" ] )
		{
			continue;
		}
		
		self.pers[ "bot" ][ "cod_points" ] -= cost;
		weapon = weapon + "_" + _attachment;
		return weapon;
	}
}

/*
	Gets the perk ref
*/
bot_perk_from_reference_full( reference_full )
{
	keys = getarraykeys( level.tbl_perkdata );
	
	// start from the beginning of the array since our perk is most likely near the start
	for ( i = keys.size - 1; i >= 0; i-- )
	{
		key = keys[ i ];
		
		if ( level.tbl_perkdata[ key ][ "reference_full" ] == reference_full )
		{
			return level.tbl_perkdata[ key ];
		}
	}
	
	return undefined;
}

/*
	Get the bot's cod points
*/
bot_get_cod_points()
{
	if ( !level.onlinegame )
	{
		self.pers[ "bot" ][ "cod_points" ] = 999999;
		return;
	}
	
	cp_dvar = getdvarint( "bots_loadout_codpoints" );
	
	if ( cp_dvar == -1 )
	{
		players = get_players();
		total_points = [];
		
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ] is_bot() )
			{
				continue;
			}
			
			if ( !isdefined( players[ i ].pers[ "currencyspent" ] ) || !isdefined( players[ i ].pers[ "codpoints" ] ) )
			{
				continue;
			}
			
			total_points[ total_points.size ] = players[ i ].pers[ "currencyspent" ] + players[ i ].pers[ "codpoints" ];
		}
		
		if ( !total_points.size )
		{
			total_points[ total_points.size ] = Round( random_normal_distribution( 50000, 15000, 0, 100000 ) );
		}
		
		point_average = array_average( total_points );
		self.pers[ "bot" ][ "cod_points" ] = int( point_average * randomfloatrange( 0.6, 0.8 ) );
	}
	else if ( cp_dvar == 0 )
	{
		self.pers[ "bot" ][ "cod_points" ] = Round( random_normal_distribution( 50000, 15000, 0, 100000 ) );
	}
	else
	{
		self.pers[ "bot" ][ "cod_points" ] = Round( random_normal_distribution( cp_dvar, 1500, 0, 100000 ) );
	}
}

/*
	Get the bots rank
*/
bot_get_rank()
{
	rank = 1;
	rank_dvar = getdvarint( "bots_loadout_rank" );
	
	if ( rank_dvar == -1 )
	{
		players = get_players();
		
		ranks = [];
		bot_ranks = [];
		human_ranks = [];
		
		for ( i = 0; i < players.size; i++ )
		{
			if ( players[ i ] == self )
			{
				continue;
			}
			
			if ( !isdefined( players[ i ].pers[ "rank" ] ) )
			{
				continue;
			}
			
			if ( players[ i ] is_bot() )
			{
				bot_ranks[ bot_ranks.size ] = players[ i ].pers[ "rank" ];
			}
			else if ( !players[ i ] isdemoclient() )
			{
				human_ranks[ human_ranks.size ] = players[ i ].pers[ "rank" ];
			}
		}
		
		if ( !human_ranks.size )
		{
			human_ranks[ human_ranks.size ] = Round( random_normal_distribution( 35, 20, 0, level.maxrank ) );
		}
		
		human_avg = array_average( human_ranks );
		
		while ( bot_ranks.size + human_ranks.size < 5 )
		{
			// add some random ranks for better random number distribution
			rank = human_avg + randomintrange( -10, 10 );
			human_ranks[ human_ranks.size ] = rank;
		}
		
		ranks = array_combine( human_ranks, bot_ranks );
		
		avg = array_average( ranks );
		s = array_std_deviation( ranks, avg );
		
		rank = Round( random_normal_distribution( avg, s, 0, level.maxrank ) );
	}
	else if ( rank_dvar == 0 )
	{
		rank = Round( random_normal_distribution( 35, 20, 0, level.maxrank ) );
	}
	else
	{
		rank = Round( random_normal_distribution( rank_dvar, 5, 0, level.maxrank ) );
	}
	
	self.pers[ "bot" ][ "rankxp" ] = maps\mp\gametypes\_rank::getrankinfominxp( rank );
}

/*
	Set the bots killstreaks
*/
bot_setKillstreaks()
{
	allowed_killstreaks = [];
	
	allowed_killstreaks[ 0 ] = "killstreak_spyplane";
	allowed_killstreaks[ 1 ] = "killstreak_supply_drop";
	allowed_killstreaks[ 2 ] = "killstreak_helicopter_comlink";
	
	if ( self maps\mp\gametypes\_rank::getrankforxp( self.pers[ "bot" ][ "rankxp" ] ) >= 9 || !level.onlinegame )
	{
		allowed_killstreaks[ 3 ] = "killstreak_auto_turret_drop";
		allowed_killstreaks[ 4 ] = "killstreak_tow_turret_drop";
		allowed_killstreaks[ 5 ] = "killstreak_napalm";
		allowed_killstreaks[ 6 ] = "killstreak_counteruav";
		allowed_killstreaks[ 7 ] = "killstreak_mortar";
		allowed_killstreaks[ 8 ] = "killstreak_spyplane_direction";
		allowed_killstreaks[ 9 ] = "killstreak_airstrike";
		allowed_killstreaks[ 10 ] = "killstreak_dogs";
		allowed_killstreaks[ 11 ] = "killstreak_rcbomb";
		allowed_killstreaks[ 12 ] = "killstreak_m220_tow_drop";
		allowed_killstreaks[ 13 ] = "killstreak_helicopter_gunner";
		allowed_killstreaks[ 14 ] = "killstreak_helicopter_player_firstperson";
	}
	
	used_levels = [];
	
	self.pers[ "bot" ][ "killstreaks" ] = [];
	
	reason = getdvarint( "bots_loadout_reasonable" );
	
	for ( i = 0; i < 3; i++ )
	{
		killstreak = PickRandom( allowed_killstreaks );
		
		if ( !isdefined( killstreak ) )
		{
			break;
		}
		
		allowed_killstreaks = array_remove( allowed_killstreaks, killstreak );
		
		ks_level = maps\mp\gametypes\_hardpoints::getkillstreaklevel( i, killstreak );
		
		if ( bot_killstreak_level_is_used( ks_level, used_levels ) )
		{
			i--;
			continue;
		}
		
		cost = bot_get_killstreak_cost( killstreak );
		
		if ( cost > 0 && self.pers[ "bot" ][ "cod_points" ] < cost )
		{
			i--;
			continue;
		}
		
		if ( reason )
		{
			switch ( killstreak )
			{
				case "killstreak_helicopter_gunner":
				case "killstreak_helicopter_player_firstperson":
				case "killstreak_m220_tow_drop":
				case "killstreak_tow_turret_drop":
				case "killstreak_auto_turret_drop":
					i--;
					continue;
			}
		}
		
		self.pers[ "bot" ][ "cod_points" ] = self.pers[ "bot" ][ "cod_points" ] - cost;
		used_levels[ used_levels.size ] = ks_level;
		self.pers[ "bot" ][ "killstreaks" ][ i ] = killstreak;
	}
}

/*
	Get cost for ks
*/
bot_get_killstreak_cost( ks )
{
	// use table?? trey never included cost attribute tho
	switch ( ks )
	{
		case "killstreak_auto_turret_drop":
			return 3200;
			
		case "killstreak_tow_turret_drop":
			return 1600;
			
		case "killstreak_napalm":
			return 2400;
			
		case "killstreak_counteruav":
			return 1600;
			
		case "killstreak_mortar":
			return 3200;
			
		case "killstreak_spyplane_direction":
			return 4500;
			
		case "killstreak_airstrike":
			return 4500;
			
		case "killstreak_dogs":
			return 6000;
			
		case "killstreak_rcbomb":
			return 1200;
			
		case "killstreak_helicopter_gunner":
			return 5000;
			
		case "killstreak_helicopter_player_firstperson":
			return 6000;
			
		case "killstreak_m220_tow_drop":
			return 4000;
			
		default:
			return 0;
	}
}

/*
	Gives the kss
*/
bot_giveKillstreaks()
{
	self.killstreak = [];
	self.killstreak[ 0 ] = self.pers[ "bot" ][ "killstreaks" ][ 0 ];
	self.killstreak[ 1 ] = self.pers[ "bot" ][ "killstreaks" ][ 1 ];
	self.killstreak[ 2 ] = self.pers[ "bot" ][ "killstreaks" ][ 2 ];
}

/*
	Checks if the ks is used
*/
bot_killstreak_level_is_used( ks_level, used_levels )
{
	for ( used = 0; used < used_levels.size; used++ )
	{
		if ( ks_level == used_levels[ used ] )
		{
			return true;
		}
	}
	
	return false;
}
