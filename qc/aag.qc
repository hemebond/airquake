void() aag_aim;
void() aag_launch;
void() aag_run;
void() start_monster_aag;

/*
==============================================================================

AAG

==============================================================================
*/
void() aag_stand     =[      0,       aag_stand    ] {
  checkground();
  if (!self.flags&FL_ONGROUND)
    T_Damage(self, world, world, 1000);


  if (self.owner.classname == "player")
  {
    self.enemy = self;
    aag_aim ();
    return;
  }


  if (!FindTarget ())
  {
    self.enemy = world;
    aag_aim ();
  }
  else
  {
    self.think = aag_run ;
    self.nextthink = time + 0.1;
    return;
  }
};

void() aag_walk     =[      0,       aag_stand    ] {  };

void() aag_run     =[      0,       aag_run    ] {
  checkground();
  if (!self.flags&FL_ONGROUND)
    T_Damage(self, world, world, 1000);
  FindTarget ();
  if (!CanDamage(self.enemy, self) || !self.enemy.takedamage)
  {
    self.enemy = world;
    self.think = self.th_stand;
    self.nextthink = time + 0.1;
    return;
  }
  aag_aim ();
};

void() aag_death =
{
  self.trigger_field.think = BecomeExplosion;
  self.trigger_field.nextthink = time + 0.1;
  if (!deathmatch)
    remove(self);
  else
  {
    setmodel(self, "");
    self.takedamage = 0;
    self.think = start_monster_aag;
    self.nextthink = time + self.wait;
//dprint("gonna resp\n");
  }
};

void() aag_die =
{
// check for gib
	if (self.health < -90)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
	}
	self.solid = SOLID_NOT;
  aag_death();
};

void() aag_aim =
{
  local vector dir, vtemp, org, vel;
  local float dist;
  local float ff;  // fire flag

  if (self.owner.classname != "player")
  {
    if (self.enemy == world)
      org = self.origin + self.movedir;
    else
    {
      org = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;
      if (self.enemy.classname == "tank")
      {
        vel = self.enemy.owner.velocity;
      }
      else
        vel = self.enemy.velocity;

      vtemp = org + vel * self.speed;
    }
    dist = vlen (vtemp - self.origin);
    dist = dist / 1200;
    self.speed = dist;
    org = org + vel * dist;
    dir = vectoangles (org - self.origin);
  }
  else
  {
    dir = self.owner.v_angle;
    dir_x = 0 - dir_x;
    ff = self.owner.button0;
    if (self.owner.enemy != self)
      self.owner = world;
  }

  vtemp = '0 0 0';
  vtemp_y = dir_y - self.angles_y;
  vtemp_x = dir_x - self.trigger_field.angles_x;
  dir = '0 0 0';
  if (vtemp_x < 0) vtemp_x = vtemp_x + 360;
  if (vtemp_x > 180) vtemp_x = vtemp_x - 360;
  if (vtemp_y < 0) vtemp_y = vtemp_y + 360;
  if (vtemp_y > 180) vtemp_y = vtemp_y - 360;
  dir = vtemp;
  if (dir_x < -10)
    dir_x = -10;
  if (dir_x > 10)
    dir_x = 10;
  if (dir_y < -10)
    dir_y = -10;
  if (dir_y > 10)
    dir_y = 10;
  if (self.owner.classname != "player")
  {
    if (self.enemy)
    {
      if (vlen(dir)<10)
      {
        traceline(self.origin, org, TRUE, world);
        if (trace_fraction == 1 && dist <= 1)
          ff = 1;
      }
    }
  }
  if (time > self.attack_finished && ff == 1)
  {
    self.th_missile ();
    self.attack_finished = time + 0.5;
  }

  self.trigger_field.angles_x = anglemod(self.trigger_field.angles_x + dir_x);
  self.angles_y = anglemod(self.angles_y + dir_y);
  self.trigger_field.angles_y = self.angles_y;
};

void() aag_launch =
{
  local vector v1;
  if (!self.ammo_cells)
    return;
  self.ammo_cells = self.ammo_cells - 1;
  makevectors (self.trigger_field.angles);

  v1 = v_forward;
  v1_z = 0 - v1_z;
  if (self.spawnflags & 2)
  {
    if (self.ammo_cells & 1)
      AC_plasma(self.origin + v_right * 14, v1 + crandom() * v_right * 0.04, self.enemy);
    else
      AC_plasma(self.origin - v_right * 14, v1 + crandom() * v_right * 0.04, self.enemy);
    newmis.think = ACprojectile_expireboom;
    if (self.speed < 0.5) self.speed = 0.5;
    newmis.nextthink = time + self.speed;
    newmis.touch = ACprojectile_touchboom;
    newmis.dmg = 60;
    self.enemy.pdmg = self.enemy.pdmg + newmis.dmg;
  }
  else
  {
    if (self.ammo_cells & 1)
      AC_plasma(self.origin + v_right * 14, v1, self.enemy);
    else
      AC_plasma(self.origin - v_right * 14, v1, self.enemy);
  }
};

//=================================================================

void() start_monster_aag =
{
  local entity stemp;

  teamplay = cvar("teamplay");
  if (deathmatch > 0)
    if (self.team == 0 || teamplay == 0)
    {
//dprint("fukk!\n");
      remove(self);
      return;
    }

	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_TOSS;
  self.health = self.max_health;

  setmodel (self, "progs/aagba.mdl");
  setsize (self, '-16 -16 -20', '16 16 16');

  self.th_stand = aag_stand;
  self.th_walk = aag_walk;
  self.th_run = aag_run;
  self.th_die = aag_die;
  self.th_missile = aag_launch;

  if (!self.netname)
    self.netname = "Anti-aircraft gun";

  setorigin(self, self.oldorigin);
  droptofloor();
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
  self.view_ofs = '0 0 1';
	self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;

  stemp = spawn();
  stemp.owner = self;
  stemp.takedamage = DAMAGE_NO;
  setmodel(stemp, "progs/aagtb.mdl");
  self.trigger_field = stemp;
  stemp.angles = self.angles;
  setorigin(stemp, self.origin);
  self.ammo_cells = self.aflag;

  self.th_stand ();
};

/*QUAKED monster_aag (1 0 0) (-16 -16 -20) (16 16 16) Ambush
*/
void() monster_aag =
{
  local vector v1;

  precache_model ("progs/aagba.mdl");
  precache_model ("progs/aagtb.mdl");

  if (!deathmatch)
    total_monsters = total_monsters + 1;
  self.oldorigin = self.origin;
  if (!self.health)
    self.health = 100;
  self.max_health = self.health;
  v1 = self.angles_y * '0 1 0' + '-20 0 0';
  makevectors (v1);
  self.movedir = v_forward;

  setup_teament();

  if (!self.ammo_cells)
    self.ammo_cells = 5000;
  self.aflag = self.ammo_cells;

  if (!self.wait)
    self.wait = 30;

  self.think = start_monster_aag;
  self.nextthink = time + 0.1 + random() * 0.3;
};
