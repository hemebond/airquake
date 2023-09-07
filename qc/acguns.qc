void() AC_Explode;

void()  s_bexplode0  = [0,   s_bexplode1] {};
void()  s_bexplode1  = [1,   s_bexplode2] {};
void()  s_bexplode2  = [2,   s_bexplode3] {};
void()  s_bexplode3  = [3,   s_bexplode4] {};
void()  s_bexplode4  = [4,   s_bexplode5] {};
void()  s_bexplode5  = [5,   SUB_Remove] {};

void() BigExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
  setmodel (self, "progs/s_bigbom.spr");
	self.solid = SOLID_NOT;
	s_explode1 ();

	// Tei
	//FX_Scorch();
	// Tei

};
/*
====================
 Water zap damage
====================
*/

void(entity inflictor, entity attacker, float damage, entity ignore) WaterRadiusDamage =
{
	local	float 	points;
	local	entity	head;
	local	vector	org;

	head = findradius(inflictor.origin, damage+40);
	
	while (head)
	{
		if (head != ignore)
		{
			if (head.takedamage)
			{
				org = head.origin + (head.mins + head.maxs)*0.5;
				points = 0.5*vlen (inflictor.origin - org);
				if (points < 0)
					points = 0;
				points = damage - points;
				if (head == attacker)
					points = points * 0.5;
				if (points > 0)
				{
          if (CanDamage (head, inflictor) && head.waterlevel>0)
					{	// shambler takes half damage from all explosions
						if (head.classname == "monster_shambler")						
							T_Damage (head, inflictor, attacker, points*0.5);
						else
							T_Damage (head, inflictor, attacker, points);
					}
				}
			}
		}
		head = head.chain;
	}
};

/*
===============================
 Boom funcs for projectiles
===============================
*/

void() ACprojectile_expireboom =
{
  self.takedamage = 0;
  self.health = 0;

  if (self.classname == "mine" && self.owner.classname == "player")
  {
    self.owner.value = self.owner.value - 1;
  }

  T_RadiusDamage (self, self.owner, self.dmg, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

  if (self.enemy.takedamage)
    self.enemy.pdmg = self.enemy.pdmg - self.dmg;

  BecomeExplosion ();
//  BigExplosion ();
};

void() ACprojectile_touchboom =
{
	local float	damg;

  local float tmp;
  local string teststr;

  if (self.classname != "mine")
  {
    if (other == self.owner)
      return;   // don't explode on owner

    if (other.owner == self.owner)
      return;
  }

  self.takedamage = 0;
  self.health = 0;

  if (self.classname == "mine" && self.owner.classname == "player")
  {
    self.owner.value = self.owner.value - 1;
  }

  if (self.enemy.takedamage)
    self.enemy.pdmg = self.enemy.pdmg - self.dmg;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

  damg = self.dmg;

  if (self.classname != "mine")
  { 
    if (other.health>0)
      T_Damage (other, self, self.owner, damg );
    else if (other.classname == "monster_drone")
    {
      other.think = other.th_die;
      other.nextthink = time + 0.1;
      other.takedamage = DAMAGE_NO;
      other.solid = SOLID_NOT;
    }

    T_RadiusDamage (self, self.owner, damg, other);
  }
  else
    T_RadiusDamage (self, self.owner, damg, self);

	self.origin = self.origin - 8*normalize(self.velocity);

	//WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	//WriteByte (MSG_BROADCAST, TE_EXPLOSIONSMALL2);//Tei
	//WriteCoord (MSG_BROADCAST, self.origin_x);
	//WriteCoord (MSG_BROADCAST, self.origin_y);
	//WriteCoord (MSG_BROADCAST, self.origin_z);

  BecomeExplosion ();
//  BigExplosion ();
};

/*
===============================
 Spike autocannon
===============================
*/

void() ACsuperspike_touch =
{
	local float	damg;

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}

  damg = self.dmg;

  if (other.health>0)
    T_Damage (other, self, self.owner, damg );

  T_RadiusDamage (self, self.owner, damg, other);

	self.origin = self.origin - 8*normalize(self.velocity);

/*
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
*/
  sound (self, CHAN_WEAPON, "weapons/r_exp3.wav", 1, ATTN_NORM);
	BecomeExplosion ();
};

void() ACspike_touch =
{
  if (other == self.owner || other.owner == self.owner)
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
    T_Damage (other, self, self.owner, 25);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST, TE_SPIKE);
		WriteCoord (MSG_BROADCAST, self.origin_x);
		WriteCoord (MSG_BROADCAST, self.origin_y);
		WriteCoord (MSG_BROADCAST, self.origin_z);
	}

	remove(self);
};

void(vector org, vector dir, entity targ) AC_spike =
{
  sound (self.enemy, CHAN_WEAPON, "autocann.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACspike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
  newmis.nextthink = time + 0.7;
//  setmodel (newmis, "progs/spike.mdl");
  setmodel (newmis, "progs/bullet.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

  newmis.velocity = dir * 1500;
	
  newmis.alpha = 0.1;//Tei

 /////InFxEnt(3, self, FX_AUTOGUN);// Tei FIXME!! HARD BUG
//  self.lastmiss = newmis;
};

void(vector org, vector dir, entity targ) AC_bullet =  // invis!
{
  sound (self.enemy, CHAN_WEAPON, "autocann.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACspike_touch;
	newmis.classname = "spike";
	newmis.think = SUB_Remove;
  newmis.nextthink = time + 0.7;
//  setmodel (newmis, "progs/spike.mdl");
//  setmodel (newmis, "progs/bullet.mdl");
	setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);		
	setorigin (newmis, org);

  newmis.velocity = dir * 1500;

//  self.lastmiss = newmis;
};

/*
===============================
 Laser Cannons
===============================
*/

void() AClaser_touch =
{
	local vector org;
	
  if (other == self.owner || other.owner == self.owner)
		return;		// don't explode on owner

	if (pointcontents(self.origin) == CONTENT_SKY)
	{
		remove(self);
		return;
	}
	
	sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_STATIC);
	org = self.origin - 8*normalize(self.velocity);

	if (other.health)
	{
    SpawnBlood (org, self.velocity*0.2, 20);
    T_Damage (other, self, self.owner, 20);
	}
	else
	{
		WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, org_x);
		WriteCoord (MSG_BROADCAST, org_y);
		WriteCoord (MSG_BROADCAST, org_z);
	}
	
	remove(self);	
};

void(vector org, vector dir, entity targ) AC_laser =
{
  sound (self.enemy, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	newmis.angles = vectoangles(dir);
	
  newmis.touch = AClaser_touch;
  newmis.classname = "laser";
	newmis.think = SUB_Remove;
  newmis.nextthink = time + 1;
	setorigin (newmis, org);

  newmis.velocity = dir * 1500;
  // Tei
  newmis.alpha = 0.2;
  // Tei
//  self.lastmiss = newmis;
};

void(vector org, vector vec) LaunchLaser =
{
	local	vector	vec;
		
	if (self.classname == "monster_enforcer")
		sound (self, CHAN_WEAPON, "enforcer/enfire.wav", 1, ATTN_NORM);

	vec = normalize(vec);
	
	newmis = spawn();
	newmis.owner = self;
	newmis.movetype = MOVETYPE_FLY;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

	setmodel (newmis, "progs/laser.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	setorigin (newmis, org);

	newmis.velocity = vec * 600;
	newmis.angles = vectoangles(newmis.velocity);

	newmis.nextthink = time + 5;
	newmis.think = SUB_Remove;
	newmis.touch = AClaser_touch;
	// Tei
	newmis.alpha = 0.2;
	// Tei

};

/*
===============================
 Non-guided Rockets
===============================
*/

void(vector org, vector dir, entity targ) AC_rocket =
{
  sound (self.enemy, CHAN_WEAPON, "rocklnch.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

  setmodel (newmis, "progs/rocket1.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 90;
  newmis.classname = "missile";
  newmis.think = ACprojectile_expireboom;
  newmis.nextthink = time + 1;
	setorigin (newmis, org);

	newmis.velocity = dir * 1000;
  self.lastmiss = newmis;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
===============================
 Free fall Bombs
===============================
*/

void() mine_boom =
{
  self.health = 0;
  self.takedamage = 0;
  self.solid = SOLID_NOT;
  self.touch = SUB_Null;
  self.think = ACprojectile_expireboom;
  self.nextthink = time + 0.1 + random() * 0.5;
};

void() mine_activated =
{
  if (time>self.attack_finished)
  {
    self.think = ACprojectile_expireboom;
    self.nextthink = 0.1;
    return;
  }
  traceline(self.origin + '0 0 1', self.origin + '0 0 24', FALSE, self);
  if (trace_fraction < 1)
  {
    self.think = ACprojectile_expireboom;
    self.nextthink = 0.1;
    return;
  }

  self.think = mine_activated;
  self.nextthink = time + 0.1;
};

void() bomb_rotate =
{
  self.angles = vectoangles(self.velocity);

  if (self.classname == "mine")
  {
    if (self.flags & FL_ONGROUND)  // activate the mine
    {
      if (self.groundentity == world || self.groundentity.solid == SOLID_BSP)
      {
        setsize(self, '-8 -8 0', '8 8 8');
        self.movetype = MOVETYPE_TOSS;
        self.th_die = mine_boom;
        self.angles = '0 0 0';
        self.health = 1;
        self.takedamage = DAMAGE_YES;
        self.touch = ACprojectile_touchboom;

        self.think = mine_activated;
        self.nextthink = time + 0.1;   
        return;
      }
      else
      {
        self.flags = self.flags - FL_ONGROUND;
      }
    }
  }

  self.think = bomb_rotate;
  self.nextthink = time + 0.1;

  if (time > self.attack_finished)
    self.think = ACprojectile_expireboom;
};

void(vector org, vector dir, entity targ) AC_bomb =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.movetype = MOVETYPE_BOUNCE;
	newmis.solid = SOLID_BBOX;

  setmodel (newmis, "progs/bomb.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 130;
  newmis.classname = "bomb";
  newmis.think = bomb_rotate; //SUB_Remove;
  newmis.nextthink = time + 0.1;
	setorigin (newmis, org);

  newmis.velocity = dir;
  newmis.attack_finished = time + 10;
//  newmis.avelocity = '-300 0 0';
  self.lastmiss = newmis;
};


//TEi
void(vector org, vector dir, entity targ) AC_bomb2 =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.movetype = MOVETYPE_BOUNCE;
  newmis.solid = SOLID_BBOX;

  setmodel (newmis, "progs/obus.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 130;
  newmis.classname = "bomb";
  newmis.think = bomb_rotate; //SUB_Remove;
  newmis.nextthink = time + 0.1;
	setorigin (newmis, org);

  newmis.velocity = dir;
  newmis.attack_finished = time + 10;
  self.lastmiss = newmis;
  //InFxEnt(110,newmis, FX_FIRE );//Tei
  //InFxEnt(110,newmis, 26 );//Tei

};

void () PREACprojectile_touchboom =
{
	if (self.weapon) 
	{
		self.weapon = self.weapon - 1;
		if (!other.takedamage)
			return;
		if (other.ts == self.owner.ts)
			return;
	}
	self.touch = ACprojectile_touchboom;
	self.think = bomb_rotate;
	self.nextthink = time + 0.1;
};

void ()paveway_fly;

void(vector org, vector dir, entity targ) AC_bomb3 =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;

  newmis.movetype = MOVETYPE_FLY;
  newmis.solid = SOLID_BBOX;

  setmodel (newmis, "progs/obus.mdl");
  setsize (newmis,  '0 0 0','0 0 0');		

  newmis.angles = vectoangles(dir);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 130;
  newmis.classname = "bomb";

  newmis.think = bomb_rotate; //SUB_Remove;

  newmis.nextthink = time + 0.1;

  setorigin (newmis, org);

  newmis.velocity = normalize(dir) * 300;
  newmis.attack_finished = time + 10;

  self.lastmiss = newmis;

  //InFxEnt(110,newmis, FX_FIRE );//Tei
  //InFxEnt(110,newmis, 26 );//Tei
};
//Tei

/*
============
MINES
============
*/



void(vector org, vector dir, entity targ) AC_mine =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);

	newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_BOUNCE;
  newmis.solid = SOLID_SLIDEBOX;

  setmodel (newmis, "progs/mine.mdl");
//  setsize (newmis, '-8 -8 -8', '8 8 8');  
  setsize (newmis, '0 0 0', '0 0 0');  

	newmis.angles = vectoangles(dir);
	
  newmis.dmg = 200;
  newmis.classname = "mine";
  newmis.think = bomb_rotate; //SUB_Remove;
  newmis.nextthink = time + 0.1;
	setorigin (newmis, org);
  newmis.attack_finished = time + 120;

  newmis.velocity = dir;
//  self.lastmiss = newmis;
};

/*
================
PAVEWAY
================
*/

void() paveway_fly =
{
  local vector v0, v1;

  if (self.enemy)
  {
    v0 = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;
    traceline(self.origin, v0, TRUE, world);
    if (trace_fraction != 1)
      self.enemy = world;
    else
      self.movedir = v0;
  }

  v0 = vectoangles(self.movedir - self.origin);
//  v0_x = 0 - v0_x;
  v0_x = v0_x + 2;

  v1 = v0 - self.angles;
  v1_x = anglemod(v1_x);
  if (v1_x > 180) v1_x = v1_x - 360;
  v1_y = anglemod(v1_y);
  if (v1_y > 180) v1_y = v1_y - 360;

  if (v1_x < -50) v1_x = -50;
  if (v1_x >  50) v1_x =  50;
  if (v1_y < -50) v1_y = -50;
  if (v1_y >  50) v1_y =  50;

  makevectors(self.angles);
  self.speed = self.speed - 3 + v_forward_z * 10;
  if (self.speed < 0) self.speed = 0;
  if (self.speed < 300)
    v1_x = (self.speed - 300);

  self.avelocity = v1;

  v_forward_z = 0 - v_forward_z;
  self.velocity = self.speed * v_forward;

  self.think = paveway_fly;
  self.nextthink = time + 0.1;
};

void(vector org, vector dir, entity targ) AC_paveway =
{
  local vector v0;

  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  newmis = spawn();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.enemy = targ;

  if (newmis.enemy == world)
  {
    makevectors(self.v_angle);
//    v0 = self.trigger_field.origin - self.oldenemy.origin - '0 0 1';
    v0 = v_forward;
    traceline(self.oldenemy.origin, self.oldenemy.origin + v0 * 10000, TRUE, world);
    newmis.movedir = trace_endpos;
  }

  newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;

  setmodel (newmis, "progs/pave.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  v0 = normalize(dir);
  newmis.angles = vectoangles(v0);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 220;
  newmis.classname = "missile";

	setorigin (newmis, org);

  if (targ.takedamage)
    targ.pdmg = targ.pdmg + newmis.dmg;
  self.lastmiss = newmis;

  newmis.speed = self.enemy.speed;
  newmis.attack_finished = time + 5;

  newmis.velocity = dir;

  newmis.think = paveway_fly;
  newmis.nextthink = time + 0.1;
};

/*
==================
DETPAK
==================
*/

void() detpak_boom =
{
  self.takedamage = 0;
  self.health = 0;

  if (self.ammo_rockets)
    self.ammo_rockets = self.ammo_rockets - 1;
  if (self.owner.classname == "player" && self.ammo_rockets == 0)
  {
    self.owner.value = self.owner.value - 1;
  }
  T_RadiusDamage (self, self.owner, self.dmg, self);

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

  if (self.enemy.takedamage)
    self.enemy.pdmg = self.enemy.pdmg - self.dmg;

  if (!self.ammo_rockets)
    BecomeExplosion ();
  else
  {
    self.flags = self.flags - (self.flags & FL_ONGROUND);
    self.velocity_x = self.velocity_x + crandom() * 500;
    self.velocity_y = self.velocity_y + crandom() * 500;
    self.velocity_z = self.velocity_z + random() * 500;

    self.think = detpak_boom;
    self.nextthink = time + 0.1;
  }
};

void() detpak_active =
{
  if (self.owner.deadflag)  // ka-boom
    self.attack_finished = time - 0.1;

  if (time > self.attack_finished)
  {
    self.think = detpak_boom;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = detpak_active;
  self.nextthink = time + 0.1;
};

void() detpak_fall =
{
  if (self.flags & FL_ONGROUND)
  {
    if (self.groundentity == world || self.groundentity.solid == SOLID_BSP)
    {
      sound (self, CHAN_WEAPON, "misc/talk.wav", 1, ATTN_NORM);

      setsize(self, '-8 -8 0', '8 8 8');
      self.movetype = MOVETYPE_TOSS;
      self.th_die = detpak_boom;
      self.health = 1;
      self.takedamage = DAMAGE_YES;
      self.touch = SUB_Null;

      self.think = detpak_active; // boom;
      self.nextthink = time + 0.1; //      self.attack_finished;

      return;
    }
    else
      self.flags = self.flags - FL_ONGROUND;
  }

  if (time > self.attack_finished)
  {
    self.think = detpak_boom;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = detpak_fall;
  self.nextthink = time + 0.1;
};

void(vector org, vector dir) AC_detpak =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);

	newmis = spawn ();
  newmis.owner = self;
  newmis.movetype = MOVETYPE_BOUNCE;
  newmis.solid = SOLID_SLIDEBOX;

  setmodel (newmis, "progs/rcbo.mdl");
  setsize (newmis, '0 0 0', '0 0 0');  
	setorigin (newmis, org);

  newmis.angles_y = self.enemy.angles_y;

  newmis.dmg = 200;
  newmis.classname = "detpak";
  newmis.think = detpak_fall;
  newmis.nextthink = time + 0.1;
  newmis.attack_finished = time + 120;
  newmis.ammo_rockets = 3;

  newmis.velocity = dir;
  self.lastmiss = newmis;
};

/*
===============================
 Seeker missiles
===============================
*/

void() ACmissile_home =
{
  local vector dir, vtemp, org;
  local vector v0,v1,v2,v3;
  local float dist;
  if (time > self.attack_finished)
	{
    ACprojectile_expireboom ();
		return;
	}

  if (self.enemy.goalentity.classname == "player" && self.enemy.goalentity.rad_time < time)
  {
    stuffcmd(self.enemy.goalentity, "play in1.wav\n");
    self.enemy.goalentity.rad_time = time + 0.5;
  }

  //if (self.enemy.model == f117 )
  //{  // Lose target w/ some change, if it's stealth..
  //  if (self.enemy.unstealth_finished < time && random() < 0.1)
  //  {
  //    self.think = ACprojectile_expireboom;
  //    self.nextthink = self.attack_finished;
  //    return;
  //  }
  //}
  if (self.angles_x > 180)
    self.angles_x = self.angles_x - 360;

  org = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;

  traceline(self.origin, org, TRUE, self);
  if (trace_fraction != 1 && self.enemy.velocity != '0 0 0')
  {
    self.think = ACprojectile_expireboom;
    self.nextthink = self.attack_finished;
    return;
  }
/*
  if (self.enemy.velocity != '0 0 0') //movetype != MOVETYPE_PUSH)
  {
    dist = vlen (org - self.origin);
    dist = dist / self.speed;
    vtemp = org + self.enemy.velocity * dist;
    traceline(self.origin, vtemp, TRUE, self);
    if (trace_fraction != 1)
    {
      traceline(self.origin, org, TRUE, self);
      if (trace_fraction != 1)
      {
        self.think = ACprojectile_expireboom;
        self.nextthink = self.attack_finished;
        return;
      }
    }
    else
    {
      org = vtemp;
    }
  }
*/
  v0 = vectoangles (org - self.origin);
  if (v0_x > 180) v0_x = v0_x - 360;

  v1 = '0 0 0';
  v1_y = anglemod(v0_y - self.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;
  v1_x = v0_x - self.angles_x;

  v2 = '0 0 0';
  if (v1_x < 0) v2_x = 0 - self.weapon;
  if (v1_x > 0) v2_x = self.weapon;
  if (fabs(v1_x) < self.weapon * 0.1)
  {
    v2_x = 0;
    self.angles_x = v0_x;
  }
  if (v1_y < 0) v2_y = 0 - self.weapon;
  if (v1_y > 0) v2_y = self.weapon;
  if (fabs(v1_y) < self.weapon * 0.1)
  {
    v2_y = 0;
    self.angles_y = v0_y;
  }
  else
    self.angles_y = anglemod(self.angles_y);

//  dprint(vtos(v0));
//  dprint(vtos(self.angles));
//  dprint("\n");
  self.avelocity = v2;

  if (fabs(v1_y) > 90)
  {
    if (fabs(v1_y) > (180 - fabs(self.angles_x + v0_x)) )
    {
      self.angles_y = self.angles_y + 180;
      if (self.angles_x + v0_x >= 0) // loop up
      {
        self.angles_x = 180 - self.angles_x;
      }
      else  // down
      {
        self.angles_x = -180 - self.angles_x;
      }
    }
  }
  makevectors (self.angles);
  dir = v_forward;
  dir_z = 0 - dir_z;
  self.velocity = dir * self.speed;

  self.nextthink = time + 0.1;
  self.think = ACmissile_home; 
};

void(vector org, vector dir, entity targ, float dm) AC_seekingmissile =
{
	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.enemy = targ; 
  if (targ.goalentity.classname == "player")
  {
    sprint(targ.goalentity, "Incoming missile!\n");
    stuffcmd(targ.goalentity, "play in1.wav\n");
    targ.goalentity.rad_time = time + 1;
//    sound (targ, CHAN_ITEM, "in1.wav", 1, ATTN_NORM);
  }
  newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

  setmodel (newmis, "progs/rocket2.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
	newmis.angles = vectoangles(dir);
	
  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = dm;
  newmis.classname = "missile";
  if (newmis.enemy != world)
  {
    newmis.think = ACmissile_home;
    newmis.nextthink = time + 0.1;
  }
  else
    newmis.think = ACprojectile_expireboom;
	setorigin (newmis, org);

  if (targ.takedamage)
    targ.pdmg = targ.pdmg + newmis.dmg;
  self.lastmiss = newmis;

 //InFxEnt(110, newmis, FX_FIRE);//Tei
};

void(vector org, vector dir, entity targ) AC_heatseeker =  // SAM
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 120);

  setmodel (newmis, "progs/rocket2.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 800;
  newmis.weapon = 150;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 800;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

void(vector org, vector dir, entity targ) AC_miniseeker =
{
  sound (self.enemy, CHAN_WEAPON, "rocklnch.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 70);

  setmodel (newmis, "progs/rocket1.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 1000;
  newmis.weapon = 120;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 1.5;
  else
    newmis.nextthink = time + 1.5;

  newmis.velocity = dir * 1000;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
======================
BIGSEEKER
======================
*/

void(vector org, vector dir, entity targ) AC_bigseeker =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 200);

  setmodel (newmis, "progs/rocket2.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 500;
  newmis.weapon = 60;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 500;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
======================
AIM9X SIDEWINDER
======================
*/

void(vector org, vector dir, entity targ) AC_sidewinder =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 120);

  setmodel (newmis, "progs/sider.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 800;
  newmis.weapon = 150;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 800;
  //InFxEnt(110, newmis, FX_SMOKE);//Tei
};

/*
======================
AMRAAM
======================
*/

void(vector org, vector dir, entity targ) AC_amraam =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 140);

  setmodel (newmis, "progs/amraam.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 1000;
  newmis.weapon = 100;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 1000;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
=========
STINGER
=========
*/

void(vector org, vector dir, entity targ) AC_stinger =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 90);

  setmodel (newmis, "progs/sting.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 800;
  newmis.weapon = 180;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 800;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
================
AGM-64X MAVERICK
================
*/

void(vector org, vector dir, entity targ) AC_maverick =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 200);

  setmodel (newmis, "progs/maver.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 500;
  newmis.weapon = 60;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 500;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
================
HELLFIRE
================
*/

void(vector org, vector dir, entity targ) AC_hellfire =
{
  sound (self.enemy, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

  AC_seekingmissile(org, dir, targ, 160);

  setmodel (newmis, "progs/hfire.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		

  newmis.speed = 600;
  newmis.weapon = 75;
  if (newmis.enemy != world)
    newmis.attack_finished = time + 5;
  else
    newmis.nextthink = time + 5;

  newmis.velocity = dir * 600;
  //InFxEnt(110, newmis, FX_FIRE);//Tei
};

/*
===============
 PLASMA GUN
===============
*/
void()  s_pexplode0  = [0,   s_pexplode1] {
//  FX_Scorch();
};
void()  s_pexplode1  = [1,   s_pexplode2] {};
void()  s_pexplode2  = [2,   s_pexplode3] {};
void()  s_pexplode3  = [3,   s_pexplode4] {};
void()  s_pexplode4  = [4,   s_pexplode5] {};
void()  s_pexplode5  = [5,   SUB_Remove] {};

void() PlasmaExplosion =
{
	self.movetype = MOVETYPE_NONE;
	self.velocity = '0 0 0';
	self.touch = SUB_Null;
  setmodel (self, "progs/s_plasma.spr");
	self.solid = SOLID_NOT;
  s_pexplode0 ();
  
};

void() Plasma_Watercheck =
{
  local float  pc;

  pc = pointcontents (self.origin);
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
  {
    sound (self, CHAN_WEAPON, "enforcer/enfstop.wav", 1, ATTN_NORM);

    T_RadiusDamage (self, self.owner, 60, world);   // Damage
    PlasmaExplosion();                         // Explosion sprite
 //   BecomeExplosion();
    return;
  }

  if (time > self.attack_finished)
  {
    PlasmaExplosion();
//    BecomeExplosion();
    return;
  }

  self.think = Plasma_Watercheck;
  self.nextthink = time + 0.1;
};

void() ACplasma_touch =
{
  local float damg;

  if (other == self.owner || other.owner == self.owner)  
    return;   // don't explode on owner

  if (pointcontents(self.origin) == CONTENT_SKY)
  {
    remove(self);
    return;
  }
  damg = 40+random()*40;
 
  if (other.health)
  {
    T_Damage (other, self, self.owner, damg );
  }

  self.origin = self.origin - 8*normalize(self.velocity);

  // Sound from Doom...
  sound (self, CHAN_WEAPON, "dsfirxpl.wav", 1, ATTN_NORM);
  PlasmaExplosion ();
//  BecomeExplosion ();
};

void(vector org, vector dir, entity targ) AC_plasma =
{
  sound (self.enemy, CHAN_WEAPON, "dsplasma.wav", 1, ATTN_NORM);

	newmis = spawn ();
  if (targ != self.enemy)
    newmis.owner = self.enemy;
  else
    newmis.owner = self;
  newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.solid = SOLID_BBOX;
	newmis.effects = EF_DIMLIGHT;

  //setmodel (newmis, "progs/pbullet.mdl");
  setmodel (newmis, "progs/fx_void.mdl");
	setsize (newmis, '0 0 0', '0 0 0');		
  newmis.skin = 1;

  newmis.touch = ACplasma_touch;
  newmis.classname = "plasma";
  newmis.nextthink = time + 0.1;
  newmis.think = Plasma_Watercheck;
  newmis.attack_finished = time + 1.5;
  newmis.enemy = targ;

	setorigin (newmis, org);
  //newmis.effects = newmis.effects | EF_BLUEFIRE; // Tei

  //InFxEnt(110, newmis, FX_FLAREFIRE);//Tei

  newmis.velocity = dir * 1200;
  newmis.avelocity = '300 300 300';  
  self.lastmiss = newmis;

	// strange fx
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST,  52);
	WriteVec ( org );
	WriteVec ( dir * 1199 );
	WriteVec ( '90 90 255' );
	WriteByte( MSG_BROADCAST, 6 );
	WriteByte( MSG_BROADCAST, 1 );
	// strange fx

};

/*
=============
    FLARES
=============
*/

void() flare_touch =
{
  return;
  remove (self);
};

void() AC_Flare =
{
  local entity e;

  newmis = spawn();  
  newmis.solid = SOLID_TRIGGER;
  newmis.movetype = MOVETYPE_BOUNCE;
  newmis.velocity_x = random() * 200 - 100;
  newmis.velocity_y = random() * 200 - 100;
  newmis.velocity_z = random() * 200 - 100;
  newmis.velocity = newmis.velocity + self.enemy.velocity;
  if (self.style > 6)
    newmis.velocity = newmis.velocity + '0 0 600';
  newmis.classname = "flare";
  setmodel (newmis, "progs/flare.spr");//
  setsize (newmis, '0 0 0', '0 0 0');
  setorigin (newmis, self.enemy.origin);
  newmis.nextthink = time + 5;
  newmis.think = SUB_Remove;
  newmis.touch = flare_touch;
  newmis.effects = 4;

 //InFxEnt(110, newmis, FX_FLUXFIRESMALL);//Tei
  e = find (world, classname, "missile");
  while (e)
  {
    if (e.enemy == self.enemy)
    {
      if (random() < 0.5)
      {
        e.enemy.pdmg = e.enemy.pdmg - e.dmg;
        e.enemy = newmis;
//        dprint("Flared\n");
      }
    }
    e = find (e, classname, "missile");
  }
};
