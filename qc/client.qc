
// prototypes
void () W_WeaponFrame;
void() W_SetCurrentAmmo;
void() player_pain;
void() player_stand1;
void (vector org) spawn_tfog;
void (vector org, entity death_owner) spawn_tdeath;

float	modelindex_eyes, modelindex_player;



/*
=============================================================================

				LEVEL CHANGING / INTERMISSION

=============================================================================
*/

float	intermission_running;
float	intermission_exittime;

/*QUAKED info_intermission (1 0.5 0.5) (-16 -16 -16) (16 16 16)
This is the camera point for the intermission.
Use mangle instead of angle, so you can set pitch or roll as well as yaw.  'pitch roll yaw'
*/
void() info_intermission =
{
};



void() SetChangeParms =
{
	if (self.health <= 0)
	{
		SetNewParms ();
		return;
	}

// remove items
	self.items = self.items - (self.items & 
	(IT_KEY1 | IT_KEY2 | IT_INVISIBILITY | IT_INVULNERABILITY | IT_SUIT | IT_QUAD) );
	
// cap super health
	if (self.health > 100)
		self.health = 100;
	if (self.health < 50)
		self.health = 50;
	parm1 = self.items;
	parm2 = self.health;
	parm3 = self.armorvalue;
  parm4 = self.ammo_shells;
  parm5 = self.ammo_nails;
	parm6 = self.ammo_rockets;
	parm7 = self.ammo_cells;
	parm8 = self.weapon;
	parm9 = self.armortype * 100;
};

void() SetNewParms =
{

  //test();

  parm1 = IT_WEP1 | IT_WEP2 |
          IT_WEP3 | IT_WEP4;
  parm2 = 100;
	parm3 = 0;
  parm4 = 0;
  parm5 = 0;
  parm6 = 0;
  parm7 = 0;
  parm8 = IT_WEP1;
	parm9 = 0;
};

void() DecodeLevelParms =
{
/*
	if (serverflags)
	{
		if (world.model == "maps/start.bsp")
			SetNewParms ();		// take away all stuff on starting new episode
	}
*/
  // Always give the player full ammo & health in the start. 
  self.items = IT_WEP1 + IT_WEP2 + IT_WEP3 + IT_WEP4; // parm1
  self.health = 100; //parm2;
  self.armorvalue = 0; //parm3;
  self.ammo_shells = 0; //parm4;
  self.ammo_nails = 0; //parm5;
  self.ammo_rockets = 0; //parm6;
  self.ammo_cells = 0; //parm7;
  self.weapon = IT_WEP1; //parm8;
  self.armortype = 0; //parm9 * 0.01;
};

/*
============
FindIntermission

Returns the entity to view from
============
*/
entity() FindIntermission =
{
	local	entity spot;
	local	float cyc;

// look for info_intermission first
	spot = find (world, classname, "info_intermission");
	if (spot)
	{	// pick a random one
		cyc = random() * 4;
		while (cyc > 1)
		{
			spot = find (spot, classname, "info_intermission");
			if (!spot)
				spot = find (spot, classname, "info_intermission");
			cyc = cyc - 1;
		}
		return spot;
	}

// then look for the start position
	spot = find (world, classname, "info_player_start");
	if (spot)
		return spot;
	
// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;
	
	objerror ("FindIntermission: no spot");
};


string nextmap;
void() GotoNextMap =
{
  local string fs;
  local float f1;

	if (cvar("samelevel"))	// if samelevel is set, stay on same level
    localcmd("restart\n");
	else
  {
    if (cvar("noexit") == 0)
      changelevel (nextmap);
    else
    {
      serverflags = serverflags + 1;
      if ((serverflags & 255) >= cvar("noexit"))
        serverflags = serverflags - (serverflags & 255);
      localcmd("exec map");
      f1 = floor((serverflags&255) * 0.1);
      fs = ftos(f1);
      localcmd(fs);
      f1 = (serverflags&255) - (f1 * 10);
      fs = ftos(f1);
      localcmd(fs);
      localcmd(".cfg\n");
    }
  }
};


void() ExitIntermission =
{
// skip any text in deathmatch
  if (deathmatch)
  {
		GotoNextMap ();
		return;
  }
	
	intermission_exittime = time + 1;
	intermission_running = intermission_running + 1;

//
// run some text if at the end of an episode
//
	GotoNextMap();
};

/*
============
IntermissionThink

When the player presses attack or jump, change to the next level
============
*/
void() IntermissionThink =
{
	if (time < intermission_exittime)
		return;

	if (!self.button0 && !self.button1 && !self.button2)
		return;
	
	ExitIntermission ();
};

void() execute_changelevel =
{
	local entity	pos;

	intermission_running = 1;
	
// enforce a wait time before allowing changelevel
	if (deathmatch)
		intermission_exittime = time + 5;
	else
		intermission_exittime = time + 2;

	WriteByte (MSG_ALL, SVC_CDTRACK);
	WriteByte (MSG_ALL, 3);
	WriteByte (MSG_ALL, 3);

	pos = FindIntermission ();

	other = find (world, classname, "player");
	while (other != world)
	{
    if (other.enemy)
      remove(other.enemy);
    if (other.oldenemy)
      remove(other.oldenemy);
    if (other.trigger_field)
      remove(other.trigger_field);
    other.enemy = world;
    other.oldenemy = world;
    other.trigger_field = world;
		other.view_ofs = '0 0 0';
		other.angles = other.v_angle = pos.mangle;
		other.fixangle = TRUE;		// turn this way immediately
//    other.nextthink = time + 0.5;
		other.takedamage = DAMAGE_NO;
		other.solid = SOLID_NOT;
		other.movetype = MOVETYPE_NONE;
		other.modelindex = 0;
		setorigin (other, pos.origin);
//    remove(other);
		other = find (other, classname, "player");
	}

	WriteByte (MSG_ALL, SVC_INTERMISSION);
};


void() changelevel_touch =
{
	local entity	pos;

  if (other.goalentity.classname != "player")
		return;

/*
	if ((cvar("noexit") == 1) || ((cvar("noexit") == 2) && (mapname != "start")))
	{
//    T_Damage (other, self, self, 50000);
		return;
	}
*/

  if (cvar("samelevel") == 2)
    return;

//  if ((cvar("noexit") == 3) && (killed_monsters < total_monsters))
//  return;

  if (!deathmatch)
    if (killedvalues < self.value)
      return;

	if (coop || deathmatch)
	{
		bprint (other.netname);
		bprint (" exited the level\n");
	}
	
	nextmap = self.map;

	SUB_UseTargets ();

  if ( (self.spawnflags & 1) && (deathmatch == 0) )
  { // NO_INTERMISSION
		GotoNextMap();
		return;
  }
	
	self.touch = SUB_Null;

// we can't move people right now, because touch functions are called
// in the middle of C movement code, so set a think time to do it
	self.think = execute_changelevel;
	self.nextthink = time + 0.1;
};

/*QUAKED trigger_changelevel (0.5 0.5 0.5) ? NO_INTERMISSION
When the player touches this, he gets sent to the map listed in the "map" variable.  Unless the NO_INTERMISSION flag is set, the view will go to the info_intermission spot and display stats.
*/
void() trigger_changelevel =
{
	if (!self.map)
		objerror ("chagnelevel trigger doesn't have map");
	
	InitTrigger ();
	self.touch = changelevel_touch;
};


/*
=============================================================================

				PLAYER GAME EDGE FUNCTIONS

=============================================================================
*/

void() set_suicide_frame;

// called by ClientKill and DeadThink
void() respawn =
{
	if (coop)
	{
		// make a copy of the dead body for appearances sake
    //CopyToBodyQue (self);
		// get the spawn parms as they were at level start
		setspawnparms (self);
		// respawn		
		PutClientInServer ();
	}
	else if (deathmatch)
	{
		// make a copy of the dead body for appearances sake
    //CopyToBodyQue (self);
		// set default spawn parms
		SetNewParms ();
		// respawn		
		PutClientInServer ();
	}
	else
	{	// restart the entire server
	    if (self.lives == 1 && self.health < 3)
      		localcmd ("restart\n");
	    else
	    {
      	if (self.health < 3 && (self.enemy.owner != self || self.enemy.health < 1))
               self.lives = self.lives - 1;
    
           setspawnparms (self);     // Now works like coop
           PutClientInServer ();
          }
	}
};


/*
============
ClientKill

Player entered the suicide command
============
*/
void() ClientKill =
{
  if (self.enemy.health < 1)
    return;
  if (self.enemy.owner != self)
    return;
	bprint (self.netname);
	bprint (" suicides\n");
//  set_suicide_frame ();
//  self.modelindex = modelindex_player;
	self.frags = self.frags - 2;	// extra penalty
  T_Damage(self.enemy, self.enemy, self.enemy, 1000);  
};

float(vector v) CheckSpawnPoint =
{
	return FALSE;
};

/*
============
SelectSpawnPoint

Returns the entity to spawn at
============
*/
entity() SelectAirSpawnPoint =
{
  local entity spot, e1, e2;
	local	entity thing;
  local float  pcount, tmp, f1, lop;
  local string teststr;
  local string paeae;

// testinfo_player_start is only found in regioned levels
	spot = find (world, classname, "testplayerstart");
	if (spot)
		return spot;

  if (coop)
    teststr = "info_player_coop";
  else if (deathmatch)
    teststr = "info_player_deathmatch";
  else
    teststr = "info_player_start";

  if (self.style)
    f1 = calcbit(self.style - 1);
  else
    f1 = 0;

  while (1)
  {
    if (deathmatch > 0 && teamplay > 0)
      tmp = 1;
    else
      tmp = 0;

    if (lastspawn.classname == teststr)
      e1 = lastspawn;
    else
      e1 = world;

//    dprint(e1.classname);

    if (self.style) // seek a style start
    {
      e2 = find(e1, classname, teststr);
      lop = 0;
      while (!lop) //e2 != e1)
      {
        if ((e2.sounds & f1)!=0 && ((e2.ts == self.ts && tmp == 1) || (e2.ts == T0 && tmp==0)))
        {
          lastspawn = e2;
          return lastspawn;
        }
        if (e2 == e1) lop = 1;
        e2 = find(e2, classname, teststr);
      }
    }

    // Any start
    e2 = find(e1, classname, teststr);
    lop = 0;
    while (!lop)
    {
      if (e2 != world && (e2.ts == self.ts || tmp == 0))
      {
        lastspawn = e2;
        return lastspawn;
      }
      if (e2 == e1) lop = 1;
      e2 = find(e2, classname, teststr);
    }

    e2 = find(world, classname, teststr); // ANY??
    if (e2 != world)
    {
      lastspawn = e2;
      return lastspawn;
    }
    dprint("no spot found!\n");
    if (lastspawn != world) // If I were spawned before, there's a spot, right?
      return lastspawn;

    teststr = "info_player_start";  // If didn't find coop or DM, use single.
  }
};

/*
===========
PutClientInServer

called each time a player is spawned
============
*/
void() DecodeLevelParms;
void() PlayerDie;


void() PutClientInServer =
{
  local entity spot;

  if (deathmatch == 0 && coop == 0)
    if (!self.lives)
      self.lives = 4 - skill;

//dprint("putclientinserver\n");
  if (self.health != 3)
  {
    spot = SelectAirSpawnPoint ();
//    if (spot.style > 0 && numcraft == 1)
//      self.style = spot.style;
  }
  else
  {
    spot = spawn();
    spot.style = calcbit(self.style - 1);
    spot.origin = self.oldorigin;
    spot.angles = self.angles;
    spot.think = SUB_Remove;
    spot.nextthink = time + 2;
  }

  self.spawnflags = spot.spawnflags & 3;
	self.classname = "player";
//  self.solid = SOLID_SLIDEBOX;
  self.solid = SOLID_NOT;
  self.movetype = 0; //MOVETYPE_WALK;
	self.show_hostile = 0;
	self.max_health = 100;
	self.flags = FL_CLIENT;
	self.super_damage_finished = 0;
	self.radsuit_finished = 0;
	self.invisible_finished = 0;
	self.invincible_finished = 0;
	self.effects = 0;
	self.invincible_time = 0;
  self.distance = 100;
  self.speed = 0;
	self.health = 100;
  self.takedamage = DAMAGE_YES;

	DecodeLevelParms ();
	
//  W_SetCurrentAmmo ();

  stuffcmd(self, "cl_bob 0\n");
  stuffcmd(self, "cl_forwardspeed 1\n");
  stuffcmd(self, "cl_backspeed 1\n");
  stuffcmd(self, "cl_sidespeed 1\n");

	self.attack_finished = time;
	self.th_pain = player_pain;
	self.th_die = PlayerDie;

	self.deadflag = DEAD_NO;
// paustime is set by teleporters to keep the player from moving a while
	self.pausetime = 0;
  self.impulse = 0;

  self.goalentity = spot; 
	self.origin = spot.origin + '0 0 1';
	self.angles = spot.angles;
	self.fixangle = TRUE;		// turn this way immediately

// oh, this is a hack!
	setmodel (self, "progs/eyes.mdl");
	modelindex_eyes = self.modelindex;

	setmodel (self, "progs/player.mdl");
	modelindex_player = self.modelindex;

  self.modelindex = 0;

//  setsize (self, VEC_HULL_MIN, VEC_HULL_MAX);
  setsize (self, '0 0 0', '0 0 0');
	
  self.view_ofs = '0 0 1';

//  player_stand1 ();

  self.toyview = -1;
  self.lefty = 0;

  if (!self.style) self.deadflag = DEAD_DEAD;
  if (!self.ts && !teamplay)
    self.ts = T1;

	if (deathmatch || coop)
	{
		makevectors(self.angles);
		spawn_tfog (self.origin + v_forward*20);
	}

//  spawn_tdeath (self.origin, self);
//  spot = spawn();
};

/*
=============================================================================

				QUAKED FUNCTIONS

=============================================================================
*/


/*QUAKED info_player_start (1 0 0) (-16 -16 -24) (16 16 24)
The normal starting point for a level.
*/
void() info_player_start =
{
  if (!deathmatch)
  {
    self.ts = T0;
    if (!self.sounds)
    {
      allowedcraft = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
      numcraft = 10;
      self.sounds = allowedcraft;
    }
    else
      add_allowedcraft(self.sounds, 0);
  }
};


/*QUAKED info_player_start2 (1 0 0) (-16 -16 -24) (16 16 24)
Only used on start map for the return point from an episode.
*/
void() info_player_start2 =
{
  local float tmp, f1,f2;

  if (!deathmatch)
  {
    self.ts = T0;
    if (!self.sounds)
    {
      allowedcraft = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
      numcraft = 10;
      self.sounds = allowedcraft;
    }
    else
    {
      allowedcraft = allowedcraft | self.sounds;
      tmp = 0;f1=0;
      while (tmp < 10)
      {
        f2=calcbit(tmp);
        if (allowedcraft & f2)
          f1 = f1 + 1;     
        tmp = tmp + 1;
      }
      numcraft = f1;
    }
  }
};


/*
saved out by quaked in region mode
*/
void() testplayerstart =
{
};

/*QUAKED info_player_deathmatch (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for deathmatch games
*/
void() info_player_deathmatch =
{
  if (!self.team)
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (deathmatch)
  {
    if (self.team == 0)
    {
      if (!self.sounds)
      {
        allowedcraft = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
        numcraft = 10;
        self.sounds = allowedcraft;
      }
      else
        add_allowedcraft(self.sounds, 0);
    }
    if (self.team == 1)
    {
      if (!self.sounds)
      {
        allow1 = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
        self.sounds = allow1;
      }
      else
        add_allowedcraft(self.sounds, 1);
    }
    if (self.team == 2)
    {
      if (!self.sounds)
      {
        allow2 = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
        self.sounds = allow2;
      }
      else
        add_allowedcraft(self.sounds, 2);
    }
  }
};

/*QUAKED info_player_coop (1 0 1) (-16 -16 -24) (16 16 24)
potential spawning position for coop games
*/
void() info_player_coop =
{
  if (coop)
  {
    self.ts = T0;
    if (!self.sounds)
    {
      allowedcraft = 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 | 512;
      numcraft = 10;
    }
    else
      add_allowedcraft(self.sounds, 0);
  }
};

/*
===============================================================================

RULES

===============================================================================
*/

/*
go to the next level for deathmatch
only called if a time or frag limit has expired
*/
void() NextLevel =
{
	local entity o;

	if (mapname == "start")
	{
		if (!cvar("registered"))
		{
			mapname = "e1m1";
		}
		else if (!(serverflags & 1))
		{
			mapname = "e1m1";
			serverflags = serverflags | 1;
		}
		else if (!(serverflags & 2))
		{
			mapname = "e2m1";
			serverflags = serverflags | 2;
		}
		else if (!(serverflags & 4))
		{
			mapname = "e3m1";
			serverflags = serverflags | 4;
		}
		else if (!(serverflags & 8))
		{
			mapname = "e4m1";
			serverflags = serverflags - 7;
		}

		o = spawn();
		o.map = mapname;
	}
	else
	{
		// find a trigger changelevel
		o = find(world, classname, "trigger_changelevel");

		// go back to start if no trigger_changelevel
		if (!o)
		{
			mapname = "start";
			o = spawn();
			o.map = mapname;
		}
	}

  if (cvar("samelevel"))
    o.map = mapname;

	nextmap = o.map;
	gameover = TRUE;
	
	if (o.nextthink < time)
	{
		o.think = execute_changelevel;
		o.nextthink = time + 0.1;
	}
};

/*
============
CheckRules

Exit deathmatch games upon conditions
============
*/
void() CheckRules =
{
	local	float		timelimit;
	local	float		fraglimit;
	
	if (gameover)	// someone else quit the game already
		return;
		
	timelimit = cvar("timelimit") * 60;
	fraglimit = cvar("fraglimit");
	
	if (timelimit && time >= timelimit)
	{
		NextLevel ();
		return;
	}
	
	if (fraglimit && self.frags >= fraglimit)
	{
		NextLevel ();
		return;
	}	
};

//============================================================================

string deadstr;

void() PlayerDeathThink =
{
  local entity  old_self, stemp, e, e2;
  local float   forward, tmp, tmp2;
  local string teststr;


    centerprint(self,"/O",deadstr); //Tei

	if ((self.flags & FL_ONGROUND))
	{
		forward = vlen (self.velocity);
		forward = forward - 20;
		if (forward <= 0)
			self.velocity = '0 0 0';
		else	
			self.velocity = forward * normalize(self.velocity);
	}

// wait for all buttons released
	if (self.deadflag == DEAD_DEAD)
	{
    if (self.button2)
			return;
		self.deadflag = DEAD_RESPAWNABLE;
    if (!deathmatch && !coop)
    {
      if (self.health < 3 && self.lives == 1)
	{
        sprint(self, "Game over. Press special or fire to restart\n");
	 //deadstr = RandomMoron(); //Tei
	 //centerprint(self, deadstr); //Tei
	}
      return;
    }
    sprint(self,"Press 1-10 to select your vehicle\n");
    sprint(self,"Press special or fire to start\n"); //, fire to change POV\n");



    if (self.health < 2)
      self.health = 2;
    self.solid = SOLID_NOT;
    self.oldts = self.ts;
		return;
	}

// Now the player is waiting to be respawned... Select plane here

  if (self.enemy != world)
  {
    setorigin(self, self.enemy.origin);
    if (self.enemy.owner == self)
    {
      self.health = 2;
    }
    if (self.enemy.health < 1)
    {
      if (self.enemy.owner == self)
        self.enemy.owner = world;
      self.enemy = world;
    }
  }

  if (self.impulse)
  {
    if (self.impulse < 11)
    {
      if (!check_allowed(self.impulse))
      {
        centerprint(self, "Vehicle not available.\n");
        self.impulse = 0;
      }
    }

    if (self.impulse == 1 && self.style != 1)
    {
      self.style = 1;
      centerprint(self, "/AF-16 Dogfighter\n");
      //GSelected("f16");//Tei
    }
    else
    if (self.impulse == 1)
    {
      self.style = 18;
      centerprint(self, "/ASU-25 Dogfighter\n");
      //GSelected("su25");//Tei
    }
    else if (self.impulse == 2)
    {
      self.style = 2;
      centerprint(self, "/AF-14 Fighter Bomber\n");
      //GSelected("f14");//Tei
    }
    else if (self.impulse == 3)
    {
      self.style = 3;
      centerprint(self, "/AF-117 Stealth Bomber\n");
      //GSelected("f117");//Tei
    }
    else if (self.impulse == 4 && self.style != 4&& self.style != 16)
    {
      self.style = 4;
      centerprint(self, "/AA-10 Tanks Killer\n");
      //GSelected("a10");//Tei
    }
	// Tei a40
    else if (self.impulse == 4 && self.style == 16)
    {
      self.style = 17;
      centerprint(self, "/AA-40 City Killer\n");
      //GSelected("a40");//Tei
    }
	// Tei a40

	// Tei a20
    else if (self.impulse == 4 )
    {
      self.style = 16;
      centerprint(self, "/AA-20 Mech Killer\n");
      //GSelected("a20");//Tei
    }
	// Tei a20

    else if (self.impulse == 5)
    {
      self.style = 5;
      centerprint(self, "/AF-22 Avanced Fighter\n");
      //GSelected("f22");//Tei
    }
    else if (self.impulse == 6 && (self.style != 6) && (self.style != 11)&& (self.style != 12) )
    {
      self.style = 6;
      centerprint(self, "/AHAVOC Defense Copter\n");
      //GSelected("helo");//Tei
    }
    else if (self.impulse == 7)
    {
      self.style = 7;
      centerprint(self, "/AMSAM Antiair Support\n");
      //GSelected("msam");//Tei

    }
    else if (self.impulse == 8)
    {
      self.style = 8;
      centerprint(self, "/AM-1 Abrams Tank\n");
      //GSelected("m1");//Tei
    }
    else if (self.impulse == 9)
    {
      self.style = 9;
      centerprint(self, "/ABRD Multipurpose Car\n");
      //GSelected("brd");//Tei
    }
    else if (self.impulse == 10 && self.style != 10)
    {
      self.style = 10;
      centerprint(self, "/AHover MultiTerrain Hover\n");
      //GSelected("hover");//Tei
    }
    else if (self.impulse == 10 && self.style != 13)
    {
      self.style = 13;
      centerprint(self, "/AP8 MultiTerrain Mech\n");
      //GSelected("mech");//Tei
    }
	// Tei apache
    else if (self.impulse == 6 && self.style == 6 )
    {
      self.style = 11;
      centerprint(self, "/AApache Hunter helicopter \n");
      //GSelected("apache");//Tei
    }
	// Tei apache
	// Tei comanche
    else if (self.impulse == 6 && self.style == 11 )
    {
      self.style = 12;
      centerprint(self, "/AComanche Attack helicopter \n");
      //GSelected("comanche");//Tei
    }
	// Tei comanche

	// Tei orca
    else if (self.impulse == 6 && self.style == 12 )
    {
      self.style = 14;
      centerprint(self, "/AOrca VTOL Hunter\n");
      //GSelected("orca");//Tei
    }
	// Tei orca

 
    if (self.impulse == 15)
    {
      self.skin = self.skin + 1;
      if (self.skin == 3) self.skin = 0;
      teststr = ftos(self.skin);
      sprint(self, "Skin: ");
      sprint(self, teststr);
      sprint(self, "\n");
    }

    if (self.impulse == 21 && (teamplay == 1 || deathmatch == 0)) // use lockturret key to move between turrets :)
    {
      e2 = self.enemy;
      if (e2.classname == "monster_amg" || e2.classname == "monster_aag")
      {
        self.enemy = world;
        e2.owner = world;
      }

      e = find (e2, ts, self.ts);
      while (e != e2)
      {
        if (e.classname == "monster_amg" || e.classname == "monster_aag")
        {
          if (e.owner.classname != "player")
          {
            self.enemy = e;
            e.owner = self;
            e2 = e;
          }
        }
        if (e != e2)
          e = find (e, ts, self.ts);
      }     
    }
    self.impulse = 0;
  }
  if (teamplay)
  {
    if (!self.ts)  // Just connected, no team set
    {
      tmp = 0; tmp2 = 0;
      e = find(world, classname, "player");
      while (e)
      {
        if (e.ts == T1)
          tmp = tmp + 1;
        else if (e.ts == T2)
          tmp2 = tmp2 + 1;
        e = find(e, classname, "player");
      }
      if (tmp2 >= tmp) // assign to blue team
      {
        self.ts = T1;
        if (self.team != 3)
          stuffcmd(self, "color 2\n");
        bprint(self.netname);
        bprint(" joined the Blue team\n");
        self.team = 3;
      }
      else  // red
      {
        self.ts = T2;
        if (self.team != 8)
          stuffcmd(self, "color 7\n");
        bprint(self.netname);
        bprint(" joined the Red team\n");
        self.team = 8;
      }
    }
    if (self.oldts == T2 && self.ts == T2 && self.team == 3)
    {
      bprint(self.netname);
      bprint(" joined the Blue team\n");
      if (self.team != 3)
        stuffcmd(self, "color 2\n");
      self.ts = T1;
      self.health = 2;
    }
    else if (self.oldts == T1 && self.ts == T1 && self.team == 8)
    {
      bprint(self.netname);
      bprint(" joined the Red team\n");
      if (self.team != 8)
        stuffcmd(self, "color 7\n");
      self.ts = T2;
      self.health = 2;
    }
  }

// wait for any button down
  if (!self.button2)
		return;
  if (time < self.pain_finished)
    return;

	self.button0 = 0;
	self.button1 = 0;
	self.button2 = 0;
  respawn();
};


/*
================
PlayerPreThink

Called every frame before physics are run
================
*/
void() PlayerPreThink =
{
	local	float	mspeed, aspeed;
	local	float	r;
  local entity stemp, e;
  local string teststr;

	if (intermission_running)
	{
		IntermissionThink ();	// otherwise a button could be missed between
		return;					// the think tics
	}

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

  if (deathmatch > 0 && teamplay == 1) // Check the colors of self
  {
    if (self.ts == T2)
    {
      if (self.team != 8)
        stuffcmd(self, "color 7\n");
    }
    else
    {
      if (self.team != 3)
        stuffcmd(self, "color 2\n");
    }
  }

	makevectors (self.v_angle);		// is this still used

	CheckRules ();

  if (self.style > 0 && self.style < 6)
    plane_upright ();
  if (self.impulse == 6 && self.enemy.owner == self) 
  {
    self.wepv = self.wepv + 1;
    if (self.wepv == 3) self.wepv = 0;
    self.impulse = 0;
    W_SetCurrentAmmo();
  }
  if (self.impulse == 106)
  { self.speed = -4; self.impulse = 0; }
  if (self.impulse == 107)
  { self.speed = 4; self.impulse = 0; }
  if (self.impulse == 108)
  { self.speed = 0; self.impulse = 0; }
  if (self.impulse == 20)
  {
    self.oldenemy.style = self.oldenemy.style + 8;
    if (self.oldenemy.style > 32)
      self.oldenemy.style = 0;
    self.impulse = 0;
  }
  if (self.impulse == 21 && self.enemy.owner == self && self.style > 6)
  {
    self.oldenemy.toyview = 1 - self.oldenemy.toyview;
    if (self.oldenemy.toyview == 1)
    {
      if (!self.enemy.trigger_field)
      {
        sprint(self, "Angle: ");
        e = self.enemy;
        if (e.movetarget)  e = e.movetarget;
        teststr = ftos(e.toyview);
        sprint(self, teststr);
        sprint(self,"\n");
      }
      else
      {
        self.oldenemy.tur1 = self.enemy.trigger_field;
        sprint(self, "Turret locked\n");
      }
    }
    else
    {
      if (self.oldenemy.tur1)
        self.oldenemy.tur1 = world;
      sprint(self, "Turret unlocked\n");
    }
    self.impulse = 0;
  }
/*
  if (self.impulse >= 120 && self.impulse < 200)
  {
    e = world;
    while (self.impulse > 120)
    {
      e = nextent(e);
      self.impulse = self.impulse - 1;
    }
    eprint(e);
    self.impulse = 0;
  }
  if (self.impulse == 200)
  {
    coredump();
    self.impulse = 0;
  }
*/

  CheckAdminCmd ();

  self.distance = self.distance + self.speed;
  if (self.distance < 0) { self.distance = 0; self.speed = 0; }
  if (self.distance > 1000) { self.distance = 1000; self.speed = 0; }

  if (self.search_time > time && self.impulse == 10 && self.enemy.owner == self)
  {
    if (self.enemy.oldenemy)  remove(self.enemy.oldenemy);
    if (self.enemy.movetarget)  remove(self.enemy.movetarget);
    if (self.trigger_field) remove(self.trigger_field);
    self.movetype = MOVETYPE_NONE;
    self.oldorigin = self.enemy.origin + '0 0 8';
    setorigin(self, self.enemy.origin + '0 0 8');
    setorigin(self.oldenemy, self.enemy.origin + '0 0 8');
    remove (self.enemy);
    self.health = 3;
    self.deadflag = DEAD_DEAD;
    self.impulse = 0;
  }

	if (self.deadflag >= DEAD_DEAD)
	{
		PlayerDeathThink ();
		return;
	}
	
	if (self.deadflag == DEAD_DYING)
		return;	// dying, so do nothing

};
	
/*
================
CheckPowerups

Check for turning off powerups
================
*/
void() CheckPowerups =
{
  return;
};


void() SetCameraPlace =
{
  local entity stemp;
  local float r;
  local vector v1, v2;

  if (self.lastmiss)
  {
    if (self.lastmiss.origin == '0 0 0' || (self.lastmiss.owner != self && self.lastmiss.owner != self.enemy))
    {
      self.lastmiss = world;
    }
  }

  if (self.enemy)
  {
    stemp = self.enemy; 

    if (self.missileview_on == 1 && self.lastmiss.origin != '0 0 0' && (self.lastmiss.owner == self || self.lastmiss.owner == self.enemy))
    {
	stemp = self.lastmiss;
      //ShowCamo();
	
    }
    else
    {
	//UnShowCamo();
    }

    makevectors (self.v_angle);
    r = self.oldenemy.style;
    v_forward = v_up * r - v_forward * self.distance;
    traceline(stemp.origin, stemp.origin + v_up * r, TRUE, world);
    v1 = trace_endpos;
    v2 = stemp.origin + v_forward;
    if (self.style < 7)
      v2 = v2 + stemp.velocity * frametime;
    else if (self.style < 10 || stemp.speed != 0)
      v2 = v2 + self.velocity * frametime;
    traceline(v1, v2, FALSE, self.enemy);
    v_forward = normalize(v2 - v1);
    if (self.enemy != self)
      setorigin(self.oldenemy, trace_endpos - v_forward * 4);
    if (self.enemy != self && (self.style < 7 || self.enemy.owner != self || self.flycam || self.style == 11 || self.style == 12  || self.style == 14|| self.style == 16|| self.style == 17))//Tei
      setorigin(self, self.oldenemy.origin);
    if (self.enemy.owner == self)
    {
      self.enemy.team = self.team;
//      self.enemy.flags = self.enemy.flags - (self.enemy.flags & (FL_GODMODE | FL_NOTARGET));
//      self.enemy.flags = self.enemy.flags | (self.flags & (FL_GODMODE | FL_NOTARGET));
    }
    if (self.enemy.takedamage == 0 && self.enemy.model != "progs/h_player.mdl")
      self.enemy = world;
  }
};

/*
================
PlayerPostThink

Called every frame after physics are run
================
*/
void() PlayerPostThink =
{
	local	float	mspeed, aspeed;
	local	float	r;
  local vector v1;

  local entity e;

//dprint(ftos(wepmulti));
//dprint("\n");

	if (self.view_ofs == '0 0 0')
		return;		// intermission or finale

  if (self.noise != "")
  {
    if (self.enemy.health > 0 && self.enemy.owner == self)
      sound (self.enemy, CHAN_VOICE, self.noise, 1, ATTN_NORM);
    else
      sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);    

    self.noise = "";
  }

  if (self.impulse > 30 && self.impulse < 100)
  {
    if (self.enemy.health > 0)
      send_voicemsg (self.impulse - 30, self.enemy);
    if (self.impulse > 60 && self.impulse < 70)
    {
      comm_control(self.impulse - 61);
    }
    self.impulse == 0;
  }

  if (!self.oldenemy)
    Create_chasecam ();

	if (self.deadflag)
  {
    self.missileview_on = 0;
    self.lastmiss = world;
    SetCameraPlace ();
		return;
  }

// aircraft spawn.. 
  if (self.toyview == -1)
  {

    //UnShowSelected();// Tei

    self.waterlevel = 0;
    self.watertype = -1;
    if (self.style == 1)
      start_aircraft1 ();
    else
    if (self.style == 18) // Tei su25
      start_aircraft8 (); // Tei su25
    else if (self.style == 2)
      start_aircraft2 ();
    else if (self.style == 3)
      start_aircraft3 ();
    else if (self.style == 4)
      start_aircraft4 ();
    else if (self.style == 5)
      start_aircraft5 ();
    else if (self.style == 6)
      start_helo1 ();
    else if (self.style == 14)//Tei orca
      start_helo4 ();// Tei orca
    else if (self.style == 16)
    {
      //self.movetype = MOVETYPE_WALK;
       start_aircraft6 ();
    }
    else if (self.style == 17)
    {
      //self.movetype = MOVETYPE_WALK;
       start_aircraft7 ();
    }
    else if (self.style == 7)
    {
      self.movetype = MOVETYPE_WALK;
      start_groundveh1 ();
    }
    else if (self.style == 8)
    {
      self.movetype = MOVETYPE_WALK;
      start_groundveh2 ();
    }
    else if (self.style == 9)
    {
      self.movetype = MOVETYPE_WALK;
      start_groundveh3 ();
    }
    else if (self.style == 10)
      start_groundveh4 ();
	// Tei mech
    else if (self.style == 13)
     {
      self.movetype = MOVETYPE_WALK;
      start_groundveh5 ();
	}
	// Tei mech
    else if (self.style == 11) //Tei apache
      start_helo2 (); //Tei apache
    else if (self.style == 12) //Tei apache
      start_helo3 (); //Tei apache
    else
      start_aircraft1 ();

    if (self.style < 6 && self.enemy.landed)
      comm_control(1);

    self.missileview_on = 0;
    self.lastmiss = world;

  // Create the target box
  // It's called self.trigger_field
    if (!cvar("no_targetbox"))//Tei
    {
      e = spawn();
      setmodel (e, "progs/s_target.spr");
      setorigin (e, self.enemy.origin);
      e.owner = self;
      self.trigger_field = e;
      e.drawonlytoclient = self;//Tei
    }

    W_SetCurrentAmmo ();
    self.enemy.ts = self.ts;
    self.spawn_finished = time + 1;
    if (self.trigger_field)
    {
      self.trigger_field.think = target_think;
      self.trigger_field.nextthink = time + 1;
    }
    self.enemy.think = vehicle_think;
    self.enemy.nextthink = time + 1;
  }

// If newly respawned, lock the camera straight...
  if (self.spawn_finished > time)
  {
    v1 = self.enemy.angles; // goalentity?
    v1_x = 0 - v1_x;

    msg_entity = self;
    WriteByte  (MSG_ONE, 5);
    WriteEntity(MSG_ONE,self.oldenemy);
    WriteByte (MSG_ONE, 10);  
    WriteAngle(MSG_ONE, v1_x );
    WriteAngle(MSG_ONE, v1_y );    
    WriteAngle(MSG_ONE, 0);
    self.toyview = 0;
    self.v_angle = self.angles = v1; //self.goalentity.angles;
//    self.fixangle = TRUE;
  }

// do weapon stuff

  W_WeaponFrame ();
  SetCameraPlace ();

  if (self.enemy.trigger_field == world)
  {
    self.items = self.items - (self.items & IT_SHELLS);
  }
  else
  {
    self.items = self.items | IT_SHELLS;
  }

  /*
// check to see if player landed and play landing sound	
	if ((self.jump_flag < -300) && (self.flags & FL_ONGROUND) && (self.health > 0))
	{
		if (self.watertype == CONTENT_WATER)
			sound (self, CHAN_BODY, "player/h2ojump.wav", 1, ATTN_NORM);
		else if (self.jump_flag < -650)
		{
			T_Damage (self, world, world, 5); 
			sound (self, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
			self.deathtype = "falling";
		}
		else
			sound (self, CHAN_VOICE, "player/land.wav", 1, ATTN_NORM);

		self.jump_flag = 0;
	}

	if (!(self.flags & FL_ONGROUND))
		self.jump_flag = self.velocity_z;
  */

};


/*
===========
ClientConnect

called when a player connects to a server
============
*/
void() ClientConnect =
{
  local float tmp, tmp2;
  local entity e;
	bprint (self.netname);
	bprint (" entered the game\n");

// a client connecting during an intermission can cause problems
	if (intermission_running)
		ExitIntermission ();
};


/*
===========
ClientDisconnect

called when a player disconnects from a server
============
*/
void() ClientDisconnect =
{
	if (gameover)
		return;
	// if the level end trigger has been activated, just return
	// since they aren't *really* leaving

	// let everyone else know
  ClientKill ();
	bprint (self.netname);
	bprint (" left the game with ");
	bprint (ftos(self.frags));
	bprint (" frags\n");
	sound (self, CHAN_BODY, "player/tornoff2.wav", 1, ATTN_NONE);
	set_suicide_frame ();
};
