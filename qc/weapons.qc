/*
*/
void (entity targ, entity inflictor, entity attacker, float damage) T_Damage;
void () player_run;
void(entity bomb, entity attacker, float rad, entity ignore) T_RadiusDamage;
void(vector org, vector vel, float damage) SpawnBlood;
void() SuperDamageSound;

void() AC_Flare;
void() AC_Die;
vector(float minim, float maxdist) AC_aim;
void() T_ACTouch;
float(entity e, float atype) check_ammo;

// called by worldspawn
void() W_Precache =
{
	precache_sound ("weapons/r_exp3.wav");	// new rocket explosion
	precache_sound ("weapons/rocket1i.wav");	// spike gun
	precache_sound ("weapons/sgun1.wav");
	precache_sound ("weapons/guncock.wav");	// player shotgun
	precache_sound ("weapons/ric1.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric2.wav");	// ricochet (used in c code)
	precache_sound ("weapons/ric3.wav");	// ricochet (used in c code)
	precache_sound ("weapons/spike2.wav");	// super spikes
	precache_sound ("weapons/tink1.wav");	// spikes tink (used in c code)
	precache_sound ("weapons/grenade.wav");	// grenade launcher
	precache_sound ("weapons/bounce.wav");		// grenade bounce
	precache_sound ("weapons/shotgn2.wav");	// super shotgun


	EnginePrecache();// Tei engine

};

float() crandom =
{
	return 2*(random() - 0.5);
};


//============================================================================


vector() wall_velocity =
{
	local vector	vel;
	
	vel = normalize (self.velocity);
	vel = normalize(vel + v_up*(random()- 0.5) + v_right*(random()- 0.5));
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;
	
	return vel;
};


/*
================
SpawnMeatSpray
================
*/
void(vector org, vector vel) SpawnMeatSpray =
{
	local	entity missile, mpuff;
	local	vector	org;

	missile = spawn ();
	missile.owner = self;
	missile.movetype = MOVETYPE_BOUNCE;
	missile.solid = SOLID_NOT;

	makevectors (self.angles);

	missile.velocity = vel;
	missile.velocity_z = missile.velocity_z + 250 + 50*random();

	missile.avelocity = '3000 1000 2000';
	
// set missile duration
	missile.nextthink = time + 1;
	missile.think = SUB_Remove;

	setmodel (missile, "progs/zom_gib.mdl");
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, org);
};

/*
================
SpawnBlood
================
*/
void(vector org, vector vel, float damage) SpawnBlood =
{
//  particle (org, vel*0.1, 73, damage*2);
  particle (org, vel*0.1, 225, damage*2);
};

/*
================
spawn_touchblood
================
*/
void(float damage) spawn_touchblood =
{
	local vector	vel;

	vel = wall_velocity () * 0.2;
	SpawnBlood (self.origin + vel*0.01, vel, damage);
};


/*
================
SpawnChunk
================
*/
void(vector org, vector vel) SpawnChunk =
{
	particle (org, vel*0.02, 0, 10);
};

/*
==============================================================================

MULTI-DAMAGE

Collects multiple small damages into a single damage

==============================================================================
*/

entity	multi_ent;
float	multi_damage;

void() ClearMultiDamage =
{
	multi_ent = world;
	multi_damage = 0;
};

void() ApplyMultiDamage =
{
	if (!multi_ent)
		return;
	T_Damage (multi_ent, self, self, multi_damage);
};

void(entity hit, float damage) AddMultiDamage =
{
	if (!hit)
		return;
	
	if (hit != multi_ent)
	{
		ApplyMultiDamage ();
		multi_damage = damage;
		multi_ent = hit;
	}
	else
		multi_damage = multi_damage + damage;
};

/*
==============================================================================

BULLETS

==============================================================================
*/

/*
================
TraceAttack
================
*/
void(float damage, vector dir) TraceAttack =
{
	local	vector	vel, org;
	
	vel = normalize(dir + v_up*crandom() + v_right*crandom());
	vel = vel + 2*trace_plane_normal;
	vel = vel * 200;

	org = trace_endpos - dir*4;

	if (trace_ent.takedamage)
	{
		SpawnBlood (org, vel*0.2, damage);
		AddMultiDamage (trace_ent, damage);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
};
/*
================
FireBullets

Used by shotgun, super shotgun, and enemy soldier firing
Go to the trouble of combining multiple pellets into a single damage call.
================
*/
void(float shotcount, vector dir, vector spread) FireBullets =
{
	local	vector direction;
	local	vector	src;
	
	makevectors(self.v_angle);

	src = self.origin + v_forward*10;
	src_z = self.absmin_z + self.size_z * 0.7;

	ClearMultiDamage ();
	while (shotcount > 0)
	{
		direction = dir + crandom()*spread_x*v_right + crandom()*spread_y*v_up;

		traceline (src, src + direction*2048, FALSE, self);
		if (trace_fraction != 1.0)
			TraceAttack (4, direction);

		shotcount = shotcount - 1;
	}
	ApplyMultiDamage ();
};

/*
==============================================================================

ROCKETS

==============================================================================
*/

void()	s_explode1	=	[0,		s_explode2] {};
void()	s_explode2	=	[1,		s_explode3] {};
void()	s_explode3	=	[2,		s_explode4] {};
void()	s_explode4	=	[3,		s_explode5] {};
void()	s_explode5	=	[4,		s_explode6] {};
void()	s_explode6	=	[5,		SUB_Remove] {};

void() BecomeExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
	setmodel (self, "progs/s_explod.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();

	// Tei
	//FX_Scorch();
	/*
	traceline(self.origin, self.origin + '0 0 -10', FALSE, self);
	if(trace_fraction != 1)
	    PlaceDecal(trace_endpos+'0 0 1', "progs/scorch.spr");
	*/
	// Tei
};

void() T_MissileTouch =
{
	local float	damg;

	if (other == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

	damg = 100 + random()*20;
	
	if (other.health)
	{
		if (other.classname == "monster_shambler")
			damg = damg * 0.5;	// mostly immune
		T_Damage (other, self, self.owner, damg );
	}

	// don't do radius damage to the other, because all the damage
	// was done in the impact
	T_RadiusDamage (self, self.owner, 120, other);

//	sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	self.origin = self.origin - 8*normalize(self.velocity);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	BecomeExplosion ();
};

/*
===============================================================================

LIGHTNING

===============================================================================
*/

/*
=================
LightningDamage
=================
*/
void(vector p1, vector p2, entity from, float damage) LightningDamage =
{
	local entity		e1, e2;
	local vector		f;
	
	f = p2 - p1;
	normalize (f);
	f_x = 0 - f_y;
	f_y = f_x;
	f_z = 0;
	f = f*16;

	e1 = e2 = world;

	traceline (p1, p2, FALSE, self);
	if (trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
		if (self.classname == "player")
		{
			if (other.classname == "player")
				trace_ent.velocity_z = trace_ent.velocity_z + 400;
		}
	}
	e1 = trace_ent;

	traceline (p1 + f, p2 + f, FALSE, self);
	if (trace_ent != e1 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
	e2 = trace_ent;

	traceline (p1 - f, p2 - f, FALSE, self);
	if (trace_ent != e1 && trace_ent != e2 && trace_ent.takedamage)
	{
		particle (trace_endpos, '0 0 100', 225, damage*4);
		T_Damage (trace_ent, from, from, damage);
	}
};


//=============================================================================

void() spike_touch;
void() superspike_touch;


/*
===============
launch_spike

Used for both the player and the ogre
===============
*/
void(vector org, vector dir) launch_spike =
{
	newmis = spawn ();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
	newmis.touch = spike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
	newmis.nextthink = time + 6;
	setmodel (newmis, "progs/spike.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
};

.float hit_z;
void() spike_touch =
{
local float rand;
	if (other == self.owner)
		return;
  if (other.owner == self.owner)
    return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (9);
		T_Damage (other, self, self.owner, 9);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		
		if (self.classname == "wizspike")
			WriteByte (MSG_BROADCAST, TE_WIZSPIKE);
		else if (self.classname == "knightspike")
			WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		else
			WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};

void() superspike_touch =
{
local float rand;
	if (other == self.owner)
		return;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
// hit something that bleeds
	if (other.takedamage)
	{
		spawn_touchblood (18);
		T_Damage (other, self, self.owner, 18);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_SUPERSPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);

};


/*
===============================================================================

PLAYER WEAPON USE

===============================================================================
*/

void() W_SetCurrentAmmo =
{
//  player_run ();    // get out of any weapon firing states

  if (self.th_melee)
    self.th_melee ();

  if (self.wepv == 1)
    self.weaponframe = 1;
  else
    self.weaponframe = 0;
  if (self.wepv == 2)
    self.weaponmodel = "";
  
//  self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
  if (self.weapon == IT_WEP1)
	{
    self.currentammo = self.ammo_shells;
//    self.items = self.items | IT_SHELLS;
	}
  else if (self.weapon == IT_WEP2)
	{
    self.currentammo = self.ammo_nails;
//    self.items = self.items | IT_NAILS;
	}
  else if (self.weapon == IT_WEP3)
	{
    self.currentammo = self.ammo_rockets;
//    self.items = self.items | IT_ROCKETS;
	}
  else if (self.weapon == IT_WEP4)
	{
    self.currentammo = self.ammo_cells;
//    self.items = self.items | IT_CELLS;
	}
	else
	{
		self.currentammo = 0;
	}

 //g_ammo(self.currentammo);//Tei
};

float() W_BestWeapon =
{
	local	float	it;
	
  if (self.ammo_cells >= 1)
    return IT_WEP4;
  if (self.ammo_rockets >= 1)
    return IT_WEP3;
  if (self.ammo_nails >= 2)
    return IT_WEP2;
  return IT_WEP1;
};

float() W_CheckNoAmmo =
{
  if (self.currentammo > 1)
		return TRUE;

  self.weapon = W_BestWeapon ();

	W_SetCurrentAmmo ();
	
// drop the weapon down
	return FALSE;
};

/*
============
W_ChangeWeapon

============
*/
void() W_ChangeWeapon =
{
	local	float	it, am, fl;
	
	it = self.items;
	am = 0;
  fl = 0;

	if (self.impulse == 1)
	{
    fl = IT_WEP1;
	}
	else if (self.impulse == 2)
	{
    fl = IT_WEP2;
	}
	else if (self.impulse == 3)
	{
    fl = IT_WEP3;
	}		
	else if (self.impulse == 4)
	{
    fl = IT_WEP4;
	}

	self.impulse = 0;
	
	if (!(self.items & fl))
	{	// don't have the weapon or the ammo
		sprint (self, "no weapon.\n");
		return;
	}
	
	if (am)
	{	// don't have the ammo
		sprint (self, "not enough ammo.\n");
		return;
	}
//
// set weapon, set ammo
//
  if (fl!=0)
  {
    self.weapon = fl;  
    W_SetCurrentAmmo ();
//    self.th_melee ();
  }
};

/*
============
CheatCommand
============
*/
void() CheatCommand =
{
	if (deathmatch || coop)
		return;

  self.ammo_rock = 250;
  self.ammo_auto = 250;
  self.ammo_shel = 250;
  self.ammo_cell = 250;
  self.ammo_amsl = 250;
  self.ammo_smsl = 250;
  self.ammo_mine = 250;
  self.ammo_bomb = 250;
  
  self.health = 250;
  check_ammo(self, 0);
	self.impulse = 0;
	W_SetCurrentAmmo ();
};

/*
============
CycleWeaponCommand

Go to the next weapon with ammo
============
*/
void() CycleWeaponCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;
	
	while (1)
	{
		am = 0;

    if (self.weapon == IT_WEP4)
		{
      self.weapon = IT_WEP1;
		}
    else if (self.weapon == IT_WEP1)
		{
      self.weapon = IT_WEP2;
		}
    else if (self.weapon == IT_WEP2)
		{
      self.weapon = IT_WEP3;
		}
    else if (self.weapon == IT_WEP3)
		{
      self.weapon = IT_WEP4;
		}		
	
		if ( (it & self.weapon) && am == 0)
		{
      W_SetCurrentAmmo ();
			return;
		}
	}

};

/*
============
CycleWeaponReverseCommand

Go to the prev weapon with ammo
============
*/
void() CycleWeaponReverseCommand =
{
	local	float	it, am;
	
	it = self.items;
	self.impulse = 0;

	while (1)
	{
		am = 0;

    if (self.weapon == IT_WEP4)
		{
      self.weapon = IT_WEP3;
		}
    else if (self.weapon == IT_WEP3)
		{
      self.weapon = IT_WEP2;
		}
    else if (self.weapon == IT_WEP2)
		{
      self.weapon = IT_WEP1;
		}
    else if (self.weapon == IT_WEP1)
		{
      self.weapon = IT_WEP4;
		}		
	
		if ( (it & self.weapon) && am == 0)
		{
      W_SetCurrentAmmo ();
      return;
		}
	}

};

/*
============
ServerflagsCommand

Just for development
============
*/
void() ServerflagsCommand =
{
	serverflags = serverflags * 2 + 1;
};

void() QuadCheat =
{
	if (deathmatch || coop)
		return;
	self.super_time = 1;
	self.super_damage_finished = time + 30;
	self.items = self.items | IT_QUAD;
	dprint ("quad cheat\n");
};

/*
============
ImpulseCommands

============
*/


//void () FileDetal;
//void () AddLocation;

void () CUJO_CheckImpulses;

void() ImpulseCommands =
{
  local vector v1;
  local entity e;

  if (self.impulse >= 1 && self.impulse <= 4)
	W_ChangeWeapon ();


  CUJO_CheckImpulses ();//Tei
  /*
  if (self.impulse == 132)
	AddLocation();

  if (self.impulse == 133)
	FileDetal();
	*/


  if (self.impulse == 5 && self.attack_finished < time)
  {
    AC_Flare ();
    self.attack_finished = time + 1;
  }
  else   
  if (self.impulse >= 7 && self.impulse <= 8)
  {
    if (self.impulse == 7 && self.enemy.thru > 0)
    {
      self.enemy.thru = self.enemy.thru - 1;
      self.fly_sound = time;
    }
    if (self.impulse == 8 && self.enemy.thru < 4)
    {
      self.enemy.thru = self.enemy.thru + 1;
      self.fly_sound = time;
    }
    if (self.enemy.thru == 0) 
	{
	centerprint(self, "/Athrust: 0%\n");
	//g_updatesteer(0);
	}
    else if (self.enemy.thru == 1)
	{
	 centerprint(self, "/Athrust: 25%\n");
	//g_updatesteer(1);
	}
    else if (self.enemy.thru == 2) 
	{
	centerprint(self, "/Athrust: 50%\n");
	//g_updatesteer(2);
	}
    else if (self.enemy.thru == 3) 
	{
	centerprint(self, "/Athrust: 75%\n");
	//g_updatesteer(3);
	}
    else if (self.enemy.thru == 4) 
	{
	centerprint(self, "/Athrust:100%\n");
	//g_updatesteer(4);
	}
  }
  else
  if (self.impulse == 9)
  {
    self.missileview_on = 1 - self.missileview_on;
    if (self.missileview_on)
	{
      centerprint(self, "/AMissile view on\n");
	//ShowVideo();
	}
    else
	{
      centerprint(self, "/AMissile view off\n");
	//ShowNOVideo();
	}
  }
  else
  if (self.impulse == 11)
		CheatCommand ();
  else
  if (self.impulse == 12)
    CycleWeaponCommand ();
  else
  if (self.impulse == 13)
		ServerflagsCommand (); 
  else
  if (self.impulse == 14)
		CycleWeaponReverseCommand ();
  else
  if (self.impulse == 255)
		QuadCheat ();
  
  if (self.impulse >= 100 && self.impulse <= 104)
  {
    self.toyview = self.impulse - 100;

    v1 = self.enemy.angles;
    v1_x = 0 - v1_x;
    if (self.toyview == 1)
      v1_y = anglemod (270 + v1_y);
    else if (self.toyview == 2)
      v1_y = anglemod (180 + v1_y);
    else if (self.toyview == 3)
      v1_y = anglemod (90 + v1_y);

    if (self.toyview < 4)
    {
      msg_entity = self;

	//SVC_SETVIEW 
      WriteByte  (MSG_ONE, 5);
      WriteEntity(MSG_ONE,self.oldenemy);

	//SVC_SETANGLE
      WriteByte (MSG_ONE, 10);  
      WriteAngle(MSG_ONE, v1_x );
      WriteAngle(MSG_ONE, v1_y );    
      WriteAngle(MSG_ONE, 0);
    }
  }
  if (self.impulse == 105)
    self.toyview = 0;
  if (self.impulse == 110)
    self.lefty = -1;
  if (self.impulse == 111)
    self.lefty = 1;
  if (self.impulse == 109)
    self.lefty = 0;

	self.impulse = 0;
};

/*
============
W_WeaponFrame

Called every frame so impulse events can be handled as well as possible
============
*/

void () DropPalm =
{
	bprint("set palm ");
	bprint(vtos(self.origin));
	bprint("\n;droppalm\n");
	
};


void() W_WeaponFrame =
{
  local float i;
//  self.weaponmodel = "progs/wep0.mdl";
//  self.weaponframe = 0;

  if (self.enemy.owner == self)
    self.th_run ();

	/*
	if (self.impulse == 77)
		DropPalm();
	*/


	ImpulseCommands ();

  if (self.rad_time > time)
    self.armortype = self.armortype | 2;

  self.items = self.items - (self.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3));
  if (self.armortype == 1)
    self.items = self.items + IT_ARMOR1;
  else if (self.armortype == 2)
    self.items = self.items + IT_ARMOR2;
  else if (self.armortype == 3)
    self.items = self.items + IT_ARMOR3;

  self.armortype = 0;

	if (time < self.attack_finished)
		return;

  if (self.button0)
  {
    SuperDamageSound ();
    self.th_missile ();
  }
};

/*
========
SuperDamageSound

Plays sound if needed
========
*/
void() SuperDamageSound =
{
	if (self.super_damage_finished > time)
	{
		if (self.super_sound < time)
		{
			self.super_sound = time + 1;
      sound (self.enemy, CHAN_BODY, "items/damage3.wav", 1, ATTN_NORM);
		}
	}
	return;
};


