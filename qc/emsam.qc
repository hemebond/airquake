/*
===============
Enemy M.SAM
===============
*/

void() emsam_run =
{
  local vector v0, v1;
  local float tmp;

  etank_sound();
  if (self.goalentity.health < 1 || self.goalentity.takedamage < 1)
    self.goalentity = world;

  if (!visible(self.goalentity) && self.search_time < time)
    self.goalentity = world;

  if (!self.goalentity)
  {
    walkmove(self.angles_y, self.speed * 0.1);
    turn_eturret(self.angles_y * '0 1 0', 100);
    self.think = self.th_walk;
    self.nextthink = time + 0.1;
    return;
  }

  v1 = self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5;
  v0 = vectoangles(v1 - self.origin);
  if (visible(self.goalentity) == TRUE)
  {
    self.lefty = -1;
  }
  else
  {
    if (self.search_time < time)
    {
      self.lefty = 1 - self.lefty;
      self.search_time = time + random() * 20 + 10;
    }
    if (self.lefty < 0)
    {
      self.search_time = time + 30;
      if (random() < 0.5)
        self.lefty = 0;
      else
        self.lefty = 1;
    }
    if (self.lefty == 0)
      tmp = 1;
    else
      tmp = -1;
    if (range(self.goalentity) > RANGE_MELEE)
      v0_y = v0_y + tmp * 70;
    else
      v0_y = v0_y + tmp * 100;
  }
//  v1 = self.angles; v1_x = 0 - v1_x;
  makevectors(v0_y * '0 1 0');
  traceline(self.origin + v_right * 11, self.origin + v_right * 11 + v_forward * 128, FALSE, self);
  tmp = trace_fraction;
  traceline(self.origin - v_right * 11, self.origin - v_right * 11 + v_forward * 128, FALSE, self);
  tmp = tmp - trace_fraction;
  if (tmp)
    v0_y = v0_y - tmp * 90;
  v1 = '0 0 0';
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

  if (fabs(v1_y) < 45 && self.attack_finished < time - 1)
  {
    if (self.speed < 120)
    {
      self.speed = self.speed + 5;
      if (self.speed > 120) self.speed = 120;
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

  if (!walkmove(self.angles_y, self.speed * 0.1))
  {
    if (self.lefty >= 0 && self.search_time < time + 10)
    {
      self.lefty = 1 - self.lefty;
      self.search_time = time + 10 + random() * 20;
    }
  }
  tilt_etank();
  v1 = orgia(self.goalentity);
  v0 = vectoangles(v1 - self.origin);
  turn_eturret(v0, 100);
  v1 = self.tur2.angles; v1_x = 0 - v1_x;
  if (self.attack_finished < time)
  {
    traceline(self.origin, self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5, FALSE, self);
    if (trace_ent == self.goalentity)
    {
      makevectors(v1);
      v0 = normalize(self.goalentity.origin - self.origin);
      if (v_forward * v0 > 0.95)
      {
        self.th_missile ();
      }
    }
  }

  self.think = emsam_run;
  self.nextthink = time + 0.1;
};

void() emsam_shoot =
{
  local vector v0;
  v0 = self.tur2.angles;
  v0_x = 0 - v0_x;
  makevectors(v0);
  if (self.ammo_rockets > 0)
  {
    AC_heatseeker(self.origin + v_right * 16 + v_forward * 10, v_forward, self.enemy);
    self.attack_finished = time + 1.5;
    self.ammo_rockets = self.ammo_rockets - 1;
    self.effects = self.effects | EF_MUZZLEFLASH;
  }
  else
  {
    AC_spike(self.origin + v_right * 16 + v_forward * 10, v_forward, self.enemy);
    self.attack_finished = time + 0.2;
    self.effects = self.effects | EF_MUZZLEFLASH;
  }
};

void() emsam_start =
{
  if (deathmatch > 0 && (self.team == 0 || teamplay == 0))
  {
    remove(self);
    return;
  }

	self.takedamage = DAMAGE_AIM;

  self.view_ofs = '0 0 1';
	
	self.flags = self.flags | FL_MONSTER;

  /*
  self.tur1 = spawn();
  setorigin(self.tur1, self.origin);
  setmodel(self.tur1, "progs/msamtr.mdl");
  */
  self.tur2 = spawn();
  setorigin(self.tur2, self.origin);
  setmodel(self.tur2, "progs/msamtb.mdl");

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

void() monster_emsam =
{
  self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_STEP; // ?

  if (!deathmatch)
    total_monsters = total_monsters + 1;

  setmodel(self, "progs/msamba.mdl");
  setsize (self, '-16 -16 -24', '16 16 8');
  self.view_ofs = '0 0 1';
  if (!self.health)
    self.health = 200;  // 400?
  self.netname = "a Tank";

  if (self.team == 0 || (self.team != 1 && deathmatch == 0))
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (!self.ammo_rockets)
    self.ammo_rockets = 4;

  self.th_die = etank_die;
  self.th_stand = etank_stand;
  self.th_walk = etank_walk;
  self.th_run = emsam_run;  
  self.th_missile = emsam_shoot;
  self.think = emsam_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
