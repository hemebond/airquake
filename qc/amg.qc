void() amg_aim;
void() amg_launch;
void() amg_run;
void() start_monster_amg;

/*
==============================================================================

AMG

==============================================================================
*/
void() amg_stand     =[      0,       amg_stand    ] {
  checkground();
  if (!self.flags&FL_ONGROUND)
    T_Damage(self, world, world, 1000);

  if (self.owner.classname == "player")
  {
    self.enemy = self;
    amg_aim ();
    return;
  }


  if (!FindTarget ())
  {
    self.enemy = world;
    amg_aim ();
  }
  else
  {
    self.think = amg_run ;
    self.nextthink = time + 0.1;
    return;
  }
};

void() amg_walk     =[      0,       amg_stand    ] {  };

void() amg_run     =[      0,       amg_run    ] {
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
  amg_aim ();
};

void() amg_death =
{
  self.trigger_field.think = BecomeExplosion;
  self.trigger_field.nextthink = time + 0.1;
  if (!deathmatch)
    remove(self);
  else
  {
    setmodel(self, "");
    self.takedamage = 0;
    self.think = start_monster_amg;
    self.nextthink = time + self.wait;
//dprint("gonna resp\n");
  }
};

void() amg_die =
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
  amg_death();
};

void() amg_aim =
{
  local vector dir, vtemp, org, vel, src;
  local float dist, ff;

  src = self.origin + '0 0 10';

  if (self.owner.classname != "player")
  {
  if (self.enemy == world)
    org = src + self.movedir;
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
  dist = vlen (vtemp - src);
  dist = dist / 1500;
  self.speed = dist;
  org = org + vel * dist;
  dir = vectoangles (org - src);
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
  if (dir_x < -15)
    dir_x = -15;
  if (dir_x > 15)
    dir_x = 15;
  if (dir_y < -15)
    dir_y = -15;
  if (dir_y > 15)
    dir_y = 15;

  self.trigger_field.angles_x = anglemod(self.trigger_field.angles_x + dir_x);
  self.angles_y = anglemod(self.angles_y + dir_y);
  self.trigger_field.angles_y = self.angles_y;

  if (self.owner.classname != "player")
  {
  if (self.enemy)
  {
    if (time > self.attack_finished)
    {
      makevectors(self.trigger_field.angles);
      v_forward_z = 0 - v_forward_z;
      dir = normalize(org - src);
      if (dir * v_forward > 0.97)
      {
        traceline(self.origin, org, TRUE, world);
        if (trace_fraction == 1 && dist <= 1)
          ff = 1; 
      }
    }
  }
  }
  if (time > self.attack_finished && ff == 1)
  {
    self.th_missile ();
  }

};

void() amg_launch =
{
  local vector v1;
  local float tmp;

  if (!self.ammo_cells)
    return;
  self.ammo_cells = self.ammo_cells - 1;

  v1 = self.trigger_field.angles;
  v1_x = 0 - v1_x;
  makevectors (v1);
  v1 = v_forward;

  tmp = self.ammo_cells & 3;
  self.effects = self.effects | EF_MUZZLEFLASH;

  if (random() < 0.3)
  {
  if (tmp == 0)
    AC_spike(self.origin + v1 * 16 + v_up * 6 + v_right * 4, v1, self.enemy);
  else if (tmp == 1)
    AC_spike(self.origin + v1 * 16 + v_up * 6 - v_right * 4, v1, self.enemy);
  else if (tmp == 2)
    AC_spike(self.origin + v1 * 16 + v_up * 14 + v_right * 4, v1, self.enemy);
  else if (tmp == 3)
    AC_spike(self.origin + v1 * 16 + v_up * 14 - v_right * 4, v1, self.enemy);
  }
  else
  {
  if (tmp == 0)
    AC_bullet(self.origin + v1 * 16 + v_up * 6 + v_right * 4, v1, self.enemy);
  else if (tmp == 1)
    AC_bullet(self.origin + v1 * 16 + v_up * 6 - v_right * 4, v1, self.enemy);
  else if (tmp == 2)
    AC_bullet(self.origin + v1 * 16 + v_up * 14 + v_right * 4, v1, self.enemy);
  else if (tmp == 3)
    AC_bullet(self.origin + v1 * 16 + v_up * 14 - v_right * 4, v1, self.enemy);
  }

  if (self.spawnflags & 2)
  {
    newmis.touch = ACprojectile_touchboom;
    newmis.dmg = 50;
    newmis.nextthink = time + 1;
    self.attack_finished = time + 0.2;
  }
  else
    self.attack_finished = time + 0.1;
};

//=================================================================

void() start_monster_amg =
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

  setmodel (self, "progs/amgba.mdl");
  setsize (self, '-16 -16 -20', '16 16 16');

  self.th_stand = amg_stand;
  self.th_walk = amg_walk;
  self.th_run = amg_run;
  self.th_die = amg_die;
  self.th_missile = amg_launch;

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
  setmodel(stemp, "progs/amgtb.mdl");
  self.trigger_field = stemp;
  stemp.angles = self.angles;
  setorigin(stemp, self.origin);
  self.ammo_cells = self.aflag;

  self.th_stand ();
};

/*QUAKED monster_amg (1 0 0) (-16 -16 -20) (16 16 16) Ambush
*/
void() monster_amg =
{
  local vector v1;

  precache_model ("progs/amgba.mdl");
  precache_model ("progs/amgtb.mdl");

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

  self.think = start_monster_amg;
  self.nextthink = time + 0.1 + random() * 0.3;
};
