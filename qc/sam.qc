void() sam_aim;
void() sam_launch;
void() sam_run;
void() start_monster_sam;

/*
==============================================================================

SAM

==============================================================================
*/
void() sam_stand     =[      0,       sam_stand    ] {
  checkground();
  if (!self.flags&FL_ONGROUND)
    T_Damage(self, world, world, 1000);
  if (!FindTarget ())
  {
    self.enemy = world;
    sam_aim ();
  }
  else
  {
    self.think = sam_run ;
    self.nextthink = time + 0.1;
    return;
  }
};

void() sam_walk     =[      0,       sam_stand    ] {  };

void() sam_run     =[      0,       sam_run    ] {
  checkground();
  if (!self.flags&FL_ONGROUND)
    T_Damage(self, world, world, 1000);
  if (!CanDamage(self.enemy, self) || !self.enemy.takedamage)
  {
    self.enemy = world;
    self.think = self.th_stand;
    self.nextthink = time + 0.1;
    return;
  }
  sam_aim ();
};

void() sam_death =
{
  self.trigger_field.think = BecomeExplosion;
  self.trigger_field.nextthink = time + 0.1;
  if (!deathmatch)
    remove(self);
  else
  {
    setmodel(self, "");
    self.takedamage = 0;
    self.think = start_monster_sam;
    self.nextthink = time + self.wait;
  }
};

void() sam_die =
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
  sam_death();
};

void() sam_aim =
{
  local vector dir, vtemp, org;
  local float dist;

  if (self.enemy == world)
    org = self.origin + self.movedir;
  else
    org = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;
  dist = vlen (org - self.origin);
  dir = vectoangles (org - self.origin);

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
  if (self.enemy)
  {
    if (vlen(dir)<10 && dist < 3000)
    {
      if (time > self.attack_finished)
      {
        self.th_missile (); //sam_launch ();
        self.attack_finished = time + 2;
      }
    }
  }

  self.trigger_field.angles_x = anglemod(self.trigger_field.angles_x + dir_x);
  self.angles_y = anglemod(self.angles_y + dir_y);
  self.trigger_field.angles_y = self.angles_y;
};

void() sam_launch =
{
  local vector v1;
  local float tmp;
  if (!self.ammo_rockets)
    return;
  if (self.enemy.pdmg > self.enemy.health * 1.5)
    return;
  self.ammo_rockets = self.ammo_rockets - 1;
  v1 = self.trigger_field.angles;
  v1_x = 0 - v1_x;
  makevectors (v1);

  tmp = (self.ammo_rockets & 3) * 8 - 12 ;
  AC_heatseeker(self.origin + v_up * 8 + v_right * tmp, v_forward, self.enemy);
//  sprint(self.enemy.goalentity, "Incoming SAM!\n");
};

//=================================================================

void() start_monster_sam =
{
  local entity stemp;

  teamplay = cvar("teamplay");
  if (deathmatch > 0 && (self.team == 0 || teamplay == 0))
  {
    remove(self);
    return;
  }

	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_TOSS;
  self.health = self.max_health;
	
  setmodel (self, "progs/samba.mdl");
  setsize (self, '-16 -16 -20', '16 16 16');

  self.th_stand = sam_stand;
  self.th_walk = sam_walk;
  self.th_run = sam_run;
  self.th_die = sam_die;
  self.th_missile = sam_launch;

  if (!self.netname)
    self.netname = "SAM launcher";

  droptofloor();
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
  self.view_ofs = '0 0 1';
	self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;

  stemp = spawn();
  stemp.owner = self;
  stemp.takedamage = DAMAGE_NO;
  setmodel(stemp, "progs/samtb.mdl");
  self.trigger_field = stemp;
  stemp.angles = self.angles;
  setorigin(stemp, self.origin);
  self.ammo_rockets = self.aflag;

  self.th_stand ();
};

/*QUAKED monster_sam (1 0 0) (-16 -16 -24) (16 16 16) Ambush
*/
void() monster_sam =
{
  local vector v1;

  precache_model ("progs/samba.mdl");
  precache_model ("progs/samtb.mdl");

  if (!deathmatch)
    total_monsters = total_monsters + 1;

  self.oldorigin = self.origin;
  if (!self.health)
    self.health = 100;
  self.max_health = self.health;
  v1 = self.angles_y * '0 1 0' + '-45 0 0';
  makevectors (v1);
  self.movedir = v_forward;

  setup_teament();
	
  if (!self.ammo_rockets)
    self.ammo_rockets = 4;
  self.aflag = self.ammo_rockets;

  if (!self.wait)
    self.wait = 30;

  self.think = start_monster_sam;
  self.nextthink = time + 0.1 + random() * 0.3;
};
