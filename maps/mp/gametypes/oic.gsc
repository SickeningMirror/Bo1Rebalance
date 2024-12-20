#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_gametype_variants;
main()
{
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	maps\mp\gametypes\_globallogic_utils::registerTimeLimitDvar( level.gameType, 10, 0, 1440 );
	maps\mp\gametypes\_globallogic_utils::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic_utils::registerRoundLimitDvar( level.gameType, 1, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerRoundWinLimitDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic_utils::registerNumLivesDvar( level.gameType, 3, 0, 10 );
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onSpawnPlayerUnified = ::onSpawnPlayerUnified;
	level.giveCustomLoadout = ::giveCustomLoadout;
	level.onPlayerKilled = ::onPlayerKilled;
	level.onPlayerDamage = ::onPlayerDamage;
	level.onWagerAwards = ::onWagerAwards;
	game["dialog"]["gametype"] = "start_gen";
	game["dialog"]["wm_2_lives"] = "oic_2life";
	game["dialog"]["wm_final_life"] = "oic_finallife";
	
	PrecacheString( &"MPUI_PLAYER_KILLED" );
	PrecacheString( &"MP_PLUS_ONE_BULLET" );
	PrecacheString( &"MP_OIC_SURVIVOR_BONUS" );
	
	setscoreboardcolumns( "kills", "deaths", "stabs", "survived" );
}
onPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( ( sMeansOfDeath == "MOD_PISTOL_BULLET" ) || ( sMeansOfDeath == "MOD_RIFLE_BULLET" ) || ( sMeansOfDeath == "MOD_HEAD_SHOT" ) )
	{
		
		iDamage = 999999;
	}
	
	return iDamage;
}
giveCustomLoadout()
{
	self maps\mp\gametypes\_wager::setupBlankRandomPlayer();	
	
	weapon = "m1911_mp";
	self giveWeapon( weapon );
	self giveWeapon( "knife_mp" );
	self switchToWeapon( weapon );
	clipAmmo = 1;
	if( isDefined( self.pers["clip_ammo"] ) )
	{
		clipAmmo = self.pers["clip_ammo"];
		self.pers["clip_ammo"] = undefined;
	}
	self SetWeaponAmmoClip( weapon, clipAmmo );
	stockAmmo = 0;
	if( isDefined( self.pers["stock_ammo"] ) )
	{
		stockAmmo = self.pers["stock_ammo"];
		self.pers["stock_ammo"] = undefined;
	}
	self SetWeaponAmmoStock( weapon, stockAmmo );
	
	self setSpawnWeapon( weapon );
	
	self setPerk( "specialty_unlimitedsprint" );

	self.pers["hasRadar"] = true;
	self.hasSpyplane = true;
	
	return weapon;
}
onStartGameType()
{
	setClientNameMode("auto_change");
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "allies", &"OBJECTIVES_DM" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveText( "axis", &"OBJECTIVES_DM" );
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		maps\mp\gametypes\_globallogic_ui::setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
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
	allowed[0] = "oic";
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	maps\mp\gametypes\_spawning::create_map_placed_influencers();
	
	level.displayRoundEndText = false;
	
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.overridePlayerScore = true;
		level.displayRoundEndText = true;
		level.onEndGame = ::onEndGame;
	}
	
	setdvar( "scr_disable_cac", 1 );
	makedvarserverinfo( "scr_disable_cac", 1 );
	setdvar( "scr_disable_weapondrop", 1 );
	setdvar( "scr_game_perks", 0 );
	level.killstreaksenabled = 0;
	level.hardpointsenabled = 0;
	setDvar( "xblive_wagermatch", 1 );
	setDvar( "scr_xpscale", 1 );	
	
	setdvar( "ammocounterhide", 1 );
	makedvarserverinfo( "ammocounterhide", 1 );
	setMatchFlag( "ammocounterhide", 1 );
	setdvar( "actionslotshide", 1 );
	makedvarserverinfo( "actionslotshide", 1 );
	
	level thread watchElimination();
	
	registerScoreInfo();
	
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "allies", &"OBJECTIVES_OIC_HINT" );
	maps\mp\gametypes\_globallogic_ui::setObjectiveHintText( "axis", &"OBJECTIVES_OIC_HINT" );
}
registerScoreInfo()
{
	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 100 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_75", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_50", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist_25", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "suicide", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "teamkill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "dogkill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "dogassist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterkill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_75", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_50", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "helicopterassist_25", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "spyplanekill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "spyplaneassist", 0 );
}
onSpawnPlayerUnified()
{
	maps\mp\gametypes\_spawning::onSpawnPlayer_Unified();
	
	livesLeft = self.pers["lives"];
	if ( livesLeft == 2 )
	{
		self maps\mp\gametypes\_wager::wagerAnnouncer( "wm_2_lives" );
	}
	else if ( livesLeft == 1 )
	{
		self maps\mp\gametypes\_wager::wagerAnnouncer( "wm_final_life" );
	}
}
onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );
	self spawn( spawnPoint.origin, spawnPoint.angles, "oic" );
}
onEndGame( winningPlayer )
{
	if ( isDefined( winningPlayer ) && isPlayer( winningPlayer ) )
		[[level._setPlayerScore]]( winningPlayer, [[level._getPlayerScore]]( winningPlayer ) + 1 );	
}
onStartWagerSidebets()
{
	thread saveOffAllPlayersAmmo();
}
saveOffAllPlayersAmmo()
{
	wait 1.0;
	for( playerIndex = 0 ; playerIndex < level.players.size ; playerIndex++ )
	{
		player = level.players[playerIndex];
		if( !isDefined( player ) )
			continue;
		if( player.pers["lives"] == 0 )
			continue;
		currentWeapon = player GetCurrentWeapon();
		player.pers["clip_ammo"] = player GetWeaponAmmoClip( currentWeapon );
		player.pers["stock_ammo"] = player GetWeaponAmmoStock( currentWeapon );
	}
}
onWagerFinalizeRound()
{
	
	playersLeft = maps\mp\gametypes\_gametype_variants::GetPlayersLeft();
	lastManStanding = playersLeft[0];
	sideBetPool = 0;
	sideBetWinners = [];
	players = level.players;
	for ( playerIndex = 0 ; playerIndex < players.size ; playerIndex++ )
	{
		if ( isDefined( players[playerIndex].pers["sideBetMade"] ) )
		{
			sideBetPool += GetDvarInt( #"scr_wagerSideBet" );
			if ( players[playerIndex].pers["sideBetMade"] == lastManStanding.name )
			{
				sideBetWinners[ sideBetWinners.size ] = players[ playerIndex ];
			}
		}
	}
	if( sideBetWinners.size == 0 )
		return;
	sideBetPayout = int( sideBetPool / sideBetWinners.size );
	for ( index = 0 ; index < sideBetWinners.size ; index++ )
	{
		player = sideBetWinners[ index ];
		player.pers["wager_sideBetWinnings"] += sideBetPayout;
	}
}
onPlayerKilled( eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration )
{
	if ( isDefined( attacker ) && isPlayer( attacker ) && self != attacker )
	{
		attacker GiveAmmo( 1 );
		attacker thread maps\mp\gametypes\_wager::queueWagerPopup( &"MPUI_PLAYER_KILLED", 0, &"MP_PLUS_ONE_BULLET" );
		attacker playLocalSound( "mpl_oic_bullet_pickup" );
	}
}
GiveAmmo( amount )
{		
	currentWeapon = self getCurrentWeapon();
	clipAmmo = self GetWeaponAmmoClip( currentWeapon );
	self SetWeaponAmmoClip( currentWeapon, clipAmmo + amount );
}
watchElimination()
{
	level endon( "game_ended" );
	
	for ( ;; )
	{
		level waittill( "player_eliminated" );
		players = level.players;
		for ( i = 0 ; i < players.size ; i++ )
		{
			if ( IsDefined( players[i] ) && ( IsAlive( players[i] ) || players[i].pers["lives"] > 0 ) )
			{
				players[i].pers["survived"]++;
				players[i].survived = players[i].pers["survived"];
				
				players[i] thread maps\mp\gametypes\_wager::queueWagerPopup( &"MP_OIC_SURVIVOR_BONUS", 10 );
				score = maps\mp\gametypes\_globallogic_score::_getPlayerScore( players[i] );
				maps\mp\gametypes\_globallogic_score::_setPlayerScore( players[i], score + 10 );
			}
		}
	}
}
onWagerAwards()
{
	stabs = self maps\mp\gametypes\_globallogic_score::getPersStat( "stabs" );
	if ( !IsDefined( stabs ) )
		stabs = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", stabs, 0 );
	
	longshots = self maps\mp\gametypes\_globallogic_score::getPersStat( "longshots" );
	if ( !IsDefined( longshots ) )
		longshots = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", longshots, 1 );
	
	bestKillstreak = self maps\mp\gametypes\_globallogic_score::getPersStat( "best_kill_streak" );
	if ( !IsDefined( bestKillstreak ) )
		bestKillstreak = 0;
	self maps\mp\gametypes\_persistence::setAfterActionReportStat( "wagerAwards", bestKillstreak, 2 );
}