#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onWagerAwards = ::onWagerAwards;
	game["dialog"]["gametype"] = "gg_start_00";
	
	
	game["dialog"]["wm_promoted"] = "gg_promote";
	game["dialog"]["wm_humiliation"] = "boost_gen_08";
	game["dialog"]["wm_humiliated"] = "boost_gen_09";
	
	level.giveCustomLoadout = ::giveCustomLoadout;
	
	
	if( !isPregameEnabled() )
	{
		PrecacheItem( "m202_flash_wager_mp" );
	}
	
	PrecacheString( &"MPUI_PLAYER_KILLED" );
	PrecacheString( &"MP_GUN_NEXT_LEVEL" );
	PrecacheString( &"MP_GUN_PREV_LEVEL" );
	PrecacheString( &"MP_GUN_PREV_LEVEL_OTHER" );
	PrecacheString( &"MP_HUMILIATION" );
	PrecacheString( &"MP_HUMILIATED" );
	
	addGunToProgression( "makarov_extclip_mp" );
	addGunToProgression( "cz75dw_mp" );
	addGunToProgression( "spas_mp" );
	addGunToProgression( "ithaca_grip_mp" );
	addGunToProgression( "uzi_elbit_silencer_mp" );
	addGunToProgression( "kiparis_rf_mp" );
	addGunToProgression( "ak74u_extclip_mp" );
	addGunToProgression( "famas_silencer_mp" );
	addGunToProgression( "ak47_elbit_mp" );
	addGunToProgression( "m16_dualclip_mp" );
	addGunToProgression( "fnfal_acog_silencer_mp" );
	addGunToProgression( "rpk_reflex_dualclip_mp" );
	addGunToProgression( "m60_ir_mp" );
	addGunToProgression( "dragunov_acog_mp" );
	addGunToProgression( "psg1_vzoom_silencer_mp" );
	addGunToProgression( "l96a1_extclip_mp" );
	addGunToProgression( "m72_law_mp" );
	addGunToProgression( "china_lake_mp" );
	addGunToProgression( "crossbow_explosive_mp", "explosive_bolt_mp" );
	addGunToProgression( "knife_ballistic_mp" );
	
	maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( level.gameType, 10, 0, 1440 );
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( level.gameType, level.gunProgression.size, 0, 5000 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( level.gameType, 1, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	
	setscoreboardcolumns( "kills", "deaths", "stabs", "humiliated" ); 
}
addGunToProgression( gunName, altName )
{
	if ( !IsDefined( level.gunProgression ) )
		level.gunProgression = [];
	
	newWeapon = SpawnStruct();
	newWeapon.names = [];
	newWeapon.names[newWeapon.names.size] = gunName;
	if ( IsDefined( altName ) )
		newWeapon.names[newWeapon.names.size] = altName;
	level.gunProgression[level.gunProgression.size] = newWeapon;
}
giveCustomLoadout( takeAllWeapons, alreadySpawned )
{
	chooseRandomBody = false;
	if ( !IsDefined( alreadySpawned ) || !alreadySpawned )
		chooseRandomBody = true;
	self maps\mp\gametypes\_wager::setupBlankRandomPlayer( takeAllWeapons, chooseRandomBody );
	self DisableWeaponCycling();
	
	if ( !IsDefined( self.gunProgress ) )
		self.gunProgress = 0;
	
	currentWeapon = level.gunProgression[self.gunProgress].names[0];
	self giveWeapon( currentWeapon );
	self switchToWeapon( currentWeapon );
	self giveWeapon( "knife_mp" );

	self.pers["hasRadar"] = true;
	self.hasSpyplane = true;
	
	if ( !IsDefined( alreadySpawned ) || !alreadySpawned )
		self setSpawnWeapon( currentWeapon );
	
	if ( IsDefined( takeAllWeapons ) && !takeAllWeapons )
		self thread takeOldWeapons( currentWeapon );
	else
		self EnableWeaponCycling();
		
	return currentWeapon;
}
takeOldWeapons( currentWeapon )
{
	self endon( "disconnect" );
	self endon( "death" );
	
	for ( ;; )
	{
		self waittill( "weapon_change", newWeapon );
		if ( newWeapon != "none" )
			break;
	}
	
	weaponsList = self GetWeaponsList();
	for ( i = 0 ; i < weaponsList.size ; i++ )
	{
		if ( ( weaponsList[i] != currentWeapon ) && ( weaponsList[i] != "knife_mp" ) )
			self TakeWeapon( weaponsList[i] );
	}
	
	self EnableWeaponCycling();
}
promotePlayer( weaponUsed )
{
	self endon( "disconnect" );
	self endon( "cancel_promotion" );
	level endon( "game_ended" );
	
	wait 0.05; 
	for ( i = 0 ; i < level.gunProgression[self.gunProgress].names.size ; i++ )
	{
		if ( weaponUsed == level.gunProgression[self.gunProgress].names[i] )
		{
			if ( self.gunProgress < level.gunProgression.size-1 )
			{
				self.gunProgress++;
				if ( IsAlive( self ) )
					self thread giveCustomLoadout( false, true );
				self thread maps\mp\gametypes\_wager::queueWagerPopup( &"MPUI_PLAYER_KILLED", 0, &"MP_GUN_NEXT_LEVEL" );
			}
			score = maps\mp\gametypes\_globallogic_score::_getPlayerScore( self );
			if ( score < level.gunProgression.size )
				maps\mp\gametypes\_globallogic_score::_setPlayerScore( self, score + 1 );
			return;
		}
	}
}
demotePlayer()
{
	self endon( "disconnect" );
	self notify( "cancel_promotion" );
	if ( self.gunProgress > 0 )
	{
		score = maps\mp\gametypes\_globallogic_score::_getPlayerScore( self );
		maps\mp\gametypes\_globallogic_score::_setPlayerScore( self, score - 1 );
		self.gunProgress--;
		if ( IsAlive( self ) )
			self thread giveCustomLoadout( false, true );
	}
	self.pers["humiliated"]++;
	self.humiliated = self.pers["humiliated"];
	self thread maps\mp\gametypes\_wager::queueWagerPopup( &"MP_HUMILIATED", 0, &"MP_GUN_PREV_LEVEL", "wm_humiliated" );
}
onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if ( sMeansOfDeath == "MOD_SUICIDE" )
	{
		self thread demotePlayer();
		return;
	}
	
	if ( IsDefined( attacker ) && IsPlayer( attacker ) )
	{
		if ( attacker == self )
		{
			self thread demotePlayer();
			return;
		}
		
		if ( sMeansOfDeath == "MOD_MELEE" )
		{
			self thread demotePlayer();
			attacker thread maps\mp\gametypes\_wager::queueWagerPopup( &"MP_HUMILIATION", 0, &"MP_GUN_PREV_LEVEL_OTHER", "wm_humiliation" );
			return;
		}
		
		attacker thread promotePlayer( sWeapon );
	}
}
onStartGameType()
{
	setDvar( "scr_disable_cac", 1 );
	makedvarserverinfo( "scr_disable_cac", 1 );
	setDvar( "scr_disable_weapondrop", 1 );
	setdvar( "scr_game_perks", 0 );
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;	
	setDvar( "scr_xpscale", 1 );
	setDvar( "ui_allow_teamchange", 0 );
	makedvarserverinfo( "ui_allow_teamchange", 0 );
	setDvar( "ui_weapon_tiers", level.gunProgression.size );
	makedvarserverinfo( "ui_weapon_tiers", level.gunProgression.size );
	setDvar( "xblive_wagermatch", 1 );
	
	setClientNameMode("auto_change");
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"OBJECTIVES_GUN" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"OBJECTIVES_GUN" );
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_GUN" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_GUN" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_GUN_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_GUN_SCORE" );
	}
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"OBJECTIVES_GUN_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"OBJECTIVES_GUN_HINT" );
	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	
	newSpawns = GetEntArray( "mp_wager_spawn", "classname" );
	if (newSpawns.size > 0)
	{
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_wager_spawn" );
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_wager_spawn" );
	}
	else
	{
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
		maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	}
	
	maps\mp\gametypes\_spawning::updateAllSpawnPoints();
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	spawnpoint = maps\mp\gametypes\_spawnlogic::getRandomIntermissionPoint();
	setDemoIntermissionPoint( spawnpoint.origin, spawnpoint.angles );
	
	
	level.useStartSpawns = false;
	
	allowed[0] = "gun";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_spawning::create_map_placed_influencers();
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	
	level.displayRoundEndText = false;
	level.QuickMessageToAll = true;
}
onSpawnPlayerUnified()
{
	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
	self thread infiniteAmmo();
}
onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	self spawn( spawnPoint.origin, spawnPoint.angles, "gun" );
	self thread infiniteAmmo();
}
infiniteAmmo()
{
	self endon( "death" );
	self endon( "disconnect" );
	
	for ( ;; )
	{
		wait( 0.1 );
		
		weapon = self GetCurrentWeapon();
		
		self GiveMaxAmmo( weapon );
	}
}
onWagerAwards()
{
	stabs = self maps\mp\gametypes\_globallogic_score::getPersStat( "stabs" );
	if ( !IsDefined( stabs ) )
		stabs = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", stabs, 0 );
	
	headshots = self maps\mp\gametypes\_globallogic_score::getPersStat( "headshots" );
	if ( !IsDefined( headshots ) )
		headshots = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", headshots, 1 );
	
	bestKillstreak = self maps\mp\gametypes\_globallogic_score::getPersStat( "best_kill_streak" );
	if ( !IsDefined( bestKillstreak ) )
		bestKillstreak = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", bestKillstreak, 2 );
} 
