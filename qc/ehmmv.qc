/*
===============
Enemy humvee
===============
*/

void() ehmmv_sound =
{
  local float tmp;

  tmp=fabs(self.speed) * 0.05;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  if (time > self.fly_sound || self.impulse != tmp)
  {
    if (tmp == 0)
      sound (self, CHAN_BODY, "engines/car0.wav", 0.2, ATTN_NORM);
    else if (tmp == 1)
      sound (self, CHAN_BODY, "engines/car1.wav", 0.3, ATTN_NORM);
    else if (tmp == 2)
      sound (self, CHAN_BODY, "engines/car2.wav", 0.4, ATTN_NORM);
    else if (tmp == 3)
      sound (self, CHAN_BODY, "engines/car3.wav", 0.5, ATTN_NORM);
    else if (tmp == 4)
      sound (self, CHAN_BODY, "engines/car4.wav", 0.6, ATTN_NORM);
    else if (tmp == 5)
      sound (self, CHAN_BODY, "engines/car5.wav", 0.7, ATTN_NORM);
    else if (tmp == 6)
      sound (self, CHAN_BODY, "engines/car6.wav", 0.8, ATTN_NORM);
    else if (tmp == 7)
      sound (self, CHAN_BODY, "engines/car7.wav", 0.9, ATTN_NORM);
    else 
      sound (self, CHAN_BODY, "engines/car8.wav", 1.0, ATTN_NORM);
    self.fly_sound = time + 1;
    self.impulse = tmp;
  }
};

void() ehmmv_stand =
{
  ehmmv_sound();
  if (self.speed > 0)
  {
    self.speed = self.speed - 5;
    if (self.speed < 0) self.speed = 0;
  }
  walkmove(self.angles_y, self.speed * 0.1);
  tilt_etank();
  turn_eturret(self.angles, 100);

  if (FindTarget ())
  {
    self.think = self.th_run;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = ehmmv_stand;
  self.nextthink = time + 0.1;
};

void() ehmmv_walk =
{
  local vector v0, v1;
  ehmmv_sound();
  if (FindTarget ())
  {
    self.think = self.th_run;
    self.nextthink = time + 0.1;
    return;
  }
  self.enemy = world;
  if (!self.movetarget)
  {
    self.think = ehmmv_stand;
    self.nextthink = time + 0.1;
    return;
  }
  v0 = vectoangles(self.movetarget.origin - self.origin);
  v1_y = anglemod(v0_y - self.angles_y);
  if (v1_y > 180) v1_y = v1_y - 360;
  if (fabs(v1_y) > 10)
  {
    if (v1_y < 0)
      self.angles_y = anglemod(self.angles_y - 10);
    if (v1_y > 0)
      self.angles_y = anglemod(self.angles_y + 10);
  }
  else
  {
    self.angles_y = v0_y;
  }

  if (fabs(v1_y) < 45)
  {
    if (self.speed < 160)
    {
      self.speed = self.speed + 5;
      if (self.speed > 160) self.speed = 160;
    }
  }
  else
  {
    if (self.speed > 0)
    {
      self.speed = self.speed - 5;
      if (self.speed < 0) self.speed = 0;
    }
  }

  walkmove(self.angles_y, self.speed * 0.1);
  tilt_etank();
  v0 = vectoangles(self.movetarget.origin - self.origin);
  turn_eturret(v0, 100);
  self.think = ehmmv_walk;
  self.nextthink = time + 0.1;
};

void() ehmmv_run =
{
  local vector v0, v1, v2;
  local float tmp, dist;
  FindTarget ();
  ehmmv_sound();

  if (self.enemy.health < 1 || self.enemy.takedamage < 1)
    self.enemy = world;

  if (!visible(self.enemy) && self.search_time < time)
    self.enemy = world;
  else
    self.search_time = time + 30;

  v0 = vectoangles(self.movetarget.origin - self.origin);
  v1_y = anglemod(v0_y - self.angles_y);
  if (v1_y > 180) v1_y = v1_y - 360;
  if (fabs(v1_y) > 10)
  {
    if (v1_y < 0)
      self.angles_y = anglemod(self.angles_y - 10);
    if (v1_y > 0)
      self.angles_y = anglemod(self.angles_y + 10);
  }
  else
  {
    self.angles_y = v0_y;
  }

  if (fabs(v1_y) < 45)
  {
    tmp = 160;
    dist = vlen(self.movetarget.origin - self.origin);
    if (dist < 256)
      tmp = 80;
  }
  else
    tmp = 0;

  if (self.speed < tmp)
  {
    self.speed = self.speed + 15;
    if (self.speed > tmp) self.speed = tmp;
  }
  if (self.speed > tmp)
  {
    self.speed = self.speed - 15;
    if (self.speed < tmp) self.speed = tmp;
  }

  walkmove(self.angles_y, self.speed * 0.1);
  tilt_etank();

  if (self.enemy == world)
  {
    self.think = self.th_walk;
    self.nextthink = time + 0.1;
    return;
  }

  dist = vlen(self.enemy.origin - self.origin);
  if (dist < 1800 && self.ammo_rockets > 0)
    self.attack_state = 2;   // stinger
  else if (dist < 800)
    self.attack_state = 1;   // autocan
  else
    self.attack_state = 0;

  v1 = orgia(self.enemy);
  v0 = vectoangles(v1 - self.origin);
  makevectors(v0);
  v2 = v_forward;
  v2_z = 0 - v2_z;

  turn_eturret(v0, 100);
  v1 = self.tur2.angles; v1_x = 0 - v1_x;
  if (self.attack_finished < time && self.attack_state > 0)
  {
    traceline(self.origin, self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5, FALSE, self);
    if (trace_ent == self.enemy)
    {
      makevectors(v1);
      if (self.attack_state == 1)
      {
        if (v_forward * v2 > 0.97)
        {
          AC_spike(self.origin + v_forward * 10, v_forward, self.enemy);
          self.attack_finished = time + 0.1;
          self.effects = self.effects | EF_MUZZLEFLASH;
        }
      }
      else
      {
        if (v_forward * v2 > 0.95)
        {
          AC_stinger(self.origin + v_forward * 10, v_forward, self.enemy);
          self.attack_finished = time + 1.5;
          self.ammo_rockets = self.ammo_rockets - 1;
          self.effects = self.effects | EF_MUZZLEFLASH;
        }
      }
    }
  }

  self.think = ehmmv_run;
  self.nextthink = time + 0.1;
};

void() ehmmv_start =
{
  if (deathmatch > 0 && (self.team == 0 || teamplay == 0))
  {
    remove(self);
    return;
  }

	self.takedamage = DAMAGE_AIM;

  self.view_ofs = '0 0 1';
	
	self.flags = self.flags | FL_MONSTER;

  self.tur1 = spawn();
  setorigin(self.tur1, self.origin);
  //setmodel(self.tur1, "progs/humtr.mdl");
  setmodel(self.tur1, "newmedia/brdgun.md2");

  self.tur2 = spawn();
  setorigin(self.tur2, self.origin);

  //setmodel(self.tur2, "progs/humtb.mdl");
  setmodel(self.tur2, "newmedia/brdturret.md2");

  self.tur1.aiment = self.tur2;
  self.tur1.movetype = MOVETYPE_FOLLOW;
  self.tur1.aiment = self.tur2;

  self.tur2.aiment = self;
  self.tur2.movetype = MOVETYPE_FOLLOW;
  self.tur2.aiment = self;

	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
    self.think = self.th_walk;
	}
  else
    self.think = self.th_stand;

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() monster_ehmmv =
{
  self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_STEP; // ?

  if (!deathmatch)
    total_monsters = total_monsters + 1;

  //setmodel(self, "progs/humba.mdl");
  setmodel(self, "newmedia/brd.md2");

  setsize (self, '-16 -16 -24', '16 16 8');
  self.view_ofs = '0 0 1';
  if (!self.health)
    self.health = 150;  // same as for players...
  self.netname = "an Armoured Car";

  if (self.team == 0 || (self.team != 1 && deathmatch == 0))
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (!self.ammo_rockets)
    self.ammo_rockets = 8;

  self.th_die = etank_die;
  self.th_stand = ehmmv_stand;
  self.th_walk = ehmmv_walk;
  self.th_run = ehmmv_run;  
  self.think = ehmmv_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
