void() xwall_start;

void() xwall_checktrig =
{
  if (time > self.spawn_finished)
  {
    self.think = xwall_start;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = xwall_checktrig;
  self.nextthink = time + 0.1;
};

void() xwall_trigtouch =
{
  self.spawn_finished = time + 1;
};

void() xwall_preparespawn =
{
	self.solid = SOLID_TRIGGER;
  setmodel (self, self.mdl);  // set size and link into world
	self.movetype = MOVETYPE_NONE;
	self.modelindex = 0;
	self.model = "";
  self.touch = xwall_trigtouch;
  self.spawn_finished = time + 1;

  self.think = xwall_checktrig;
  self.nextthink = time + 0.1;
};

void() xwall_trigger =
{
	self.takedamage = DAMAGE_NO;
  self.th_die = SUB_Null;
  self.movetype = MOVETYPE_NONE;

  activator = self.enemy;
	
	SUB_UseTargets();

  setmodel(self, "");
  self.solid = SOLID_NOT;
  self.touch = SUB_Null;
  if (deathmatch == 0)
  {
    self.nextthink = time + 0.1;
    self.think = SUB_Remove;
    return;
  }
  self.nextthink = time + self.wait;
  self.think = xwall_preparespawn;
};

void() xwall_pieces =
{
  if (!deathmatch)
  {
    Throw_ACgib();
    Throw_ACgib();
    Throw_ACgib();
    Throw_ACgib();
  }
  BecomeExplosion ();
};


// TEi
vector (vector pos) SearchSolid =
{
	local float pc;

	while(pointcontents(pos)==CONTENT_EMPTY)
	{
		pos = pos + '0 0 -5';
	}

	return pos;
};
//Tei

void() xwall_boom =
{
  local vector v;
  local entity e;

  v = (self.absmin + self.absmax) * 0.5;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
  WriteCoord (MSG_BROADCAST, v_x);
  WriteCoord (MSG_BROADCAST, v_y);
  WriteCoord (MSG_BROADCAST, v_z);

  if (self.dmg)
  {
    e=spawn();
    setorigin(e, v);
    T_RadiusDamage(e, self, self.dmg, self);
    e.think = xwall_pieces;
    e.nextthink = time + 0.1;
  }
  xwall_trigger();

 //(vector org, vector end, float type, float typelife, float dead, float fxscale, float key ) 
 
 v = SearchSolid(v);
 //StaticFX( v, v,1,1,666,1.3,666);//type=1,life=1 fire 1
 //StaticFX( v, v,2,1,666,1,666);//type=2,life=1 fire 2
 //FX_ScorchFinal(v + '0 0 8');
 //StaticFX( v, v,7,1,666,3,666);//type=7,life=1 dark


 //StaticFX( self.origin + '0 0 -20', self.origin, 2,4,143,2,4);

};

void() xwall_die =
{
	self.enemy = damage_attacker;

  self.think = xwall_boom;
  self.nextthink = self.ltime + 0.3;
};

void() func_xwall_use =
{	// change to alternate textures
	self.frame = 1 - self.frame;
};

void() xwall_start =
{
  setmodel (self, self.mdl);
  self.health = self.max_health;
  self.th_die = xwall_die;
  if (!self.wait)
    self.takedamage = DAMAGE_YES;
  else
    self.takedamage = DAMAGE_AIM;
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
  self.use = func_xwall_use;
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
};

/*QUAKED func_xwall (0 .5 .8) ?
Exploding wall.
*/
void() func_xwall =
{
  setup_teament();

	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
  if (!self.health)
    self.health = 300;
  self.max_health = self.health;
  self.th_die = xwall_die;
  if (self.sounds == 0 || (deathmatch > 0 && cvar("teamplay") == 0))
    self.takedamage = DAMAGE_YES;
  else
    self.takedamage = DAMAGE_AIM;

  if (!self.wait)
    self.wait = 30;

  self.use = func_xwall_use;
	setmodel (self, self.model);
  self.mdl = self.model;
	setsize (self, self.mins , self.maxs);
//  self.movedir = self.maxs - self.mins; 
	setorigin (self, self.origin);
  if (!self.netname)
    self.netname = "building";
};

/*
==========
RUNWAY
=========
*/

void() runway_start;

void() rway_die =
{
  local vector v;
  local entity e;

  v = (self.absmin + self.absmax) * 0.5;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
  WriteCoord (MSG_BROADCAST, v_x);
  WriteCoord (MSG_BROADCAST, v_y);
  WriteCoord (MSG_BROADCAST, v_z);

  if (self.dmg)
  {
    e=spawn();
    setorigin(e, v);
    T_RadiusDamage(e, self, self.dmg, self);
    e.think = xwall_pieces;
    e.nextthink = time + 0.1;
  }

	self.takedamage = DAMAGE_NO;
  self.th_die = SUB_Null;
  self.movetype = MOVETYPE_NONE;
  setmodel(self, "");
  self.solid = SOLID_NOT;
  self.touch = SUB_Null;

/*
	activator = self.enemy;
	
	SUB_UseTargets();
*/

  if (!deathmatch)
  {
    self.nextthink = time + 0.1;
    self.think = SUB_Remove;
    return;
  }
  self.nextthink = time + self.wait;
  self.think = runway_start;
};

void() runway_start =
{
  setmodel (self, self.mdl);
  self.health = self.max_health;
  if (self.health)
  {
    self.th_die = rway_die;
    self.takedamage = DAMAGE_YES;
  }
  else
  {
    self.takedamage = DAMAGE_NO;
  }
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_PUSH;	// so it doesn't get pushed by anything
	self.solid = SOLID_BSP;
	setsize (self, self.mins , self.maxs);
	setorigin (self, self.origin);
};

/*QUAKED func_runway (0 .5 .8) ?
A runway for planes & helos.
*/

void() func_runway =
{
  self.mdl = self.model;
  self.max_health = self.health;

  if (!self.wait)
    self.wait = 60;

  runway_start ();
};


// Tei maps support

void () func_nube =
{
	self.angles = '0 0 0';
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	//self.think = Transient;
	setmodel (self, self.model);
	self.mdl = self.model;
	setsize (self, self.mins, self.maxs);
	setorigin (self, self.origin);
	//self.goalpos = self.origin;
};

void () func_cloud =
{
  func_nube();
};

// Tei maps support
