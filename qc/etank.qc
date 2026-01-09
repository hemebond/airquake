/*
===============
Enemy tank
===============
*/

void() etank_sound =
{
  local float tmp;

  tmp=fabs(self.speed) * 0.06;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  if (time > self.fly_sound || self.impulse != tmp)
  {
    if (tmp == 0)
      sound (self, CHAN_BODY, "engines/tank0.wav", 0.2, ATTN_NORM);
    else if (tmp == 1)
      sound (self, CHAN_BODY, "engines/tank1.wav", 0.3, ATTN_NORM);
    else if (tmp == 2)
      sound (self, CHAN_BODY, "engines/tank2.wav", 0.4, ATTN_NORM);
    else if (tmp == 3)
      sound (self, CHAN_BODY, "engines/tank3.wav", 0.5, ATTN_NORM);
    else if (tmp == 4)
      sound (self, CHAN_BODY, "engines/tank4.wav", 0.6, ATTN_NORM);
    else if (tmp == 5)
      sound (self, CHAN_BODY, "engines/tank5.wav", 0.7, ATTN_NORM);
    else if (tmp == 6)
      sound (self, CHAN_BODY, "engines/tank6.wav", 0.8, ATTN_NORM);
    else if (tmp == 7)
      sound (self, CHAN_BODY, "engines/tank7.wav", 0.9, ATTN_NORM);
    else 
      sound (self, CHAN_BODY, "engines/tank8.wav", 1.0, ATTN_NORM);
    self.fly_sound = time + 1;
    self.impulse = tmp;
  }
};

void() etank_die =
{
  self.takedamage = 0;
  if (self.tur1)
    remove(self.tur1);
  if (self.tur2)
    remove(self.tur2);
  AC_Explode();
};

void() etank_stand =
{
  etank_sound();
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

  self.think = etank_stand;
  self.nextthink = time + 0.1;
};

void() etank_walk =
{
  local vector v0, v1;
  etank_sound();
  if (FindTarget ())
  {
    self.think = self.th_run;
    self.nextthink = time + 0.1;
    return;
  }
  self.enemy = world;
  if (!self.movetarget)
  {
    self.think = etank_stand;
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

  walkmove(self.angles_y, self.speed * 0.1);
  tilt_etank();
  v0 = vectoangles(self.movetarget.origin - self.origin);
  turn_eturret(v0, 100);
  self.think = etank_walk;
  self.nextthink = time + 0.1;
};

void() etank_run =
{
  local vector v0, v1, v2;
  local float tmp, dist;
  etank_sound();
  FindTarget ();

  if (self.enemy.health < 1 || self.enemy.takedamage < 1)
    self.enemy = world;

  if (!visible(self.enemy) && self.search_time < time)
    self.enemy = world;

  if (!self.enemy)
  {
    walkmove(self.angles_y, self.speed * 0.1);
    turn_eturret(self.angles_y * '0 1 0', 100);
    self.think = self.th_walk;
    self.nextthink = time + 0.1;
    return;
  }

  if (self.enemy.classname == "tank" || self.enemy.owner.classname != "player")
    self.goalentity = self.enemy;
  else
    self.goalentity = self.movetarget;

  v1 = self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5;
  v0 = vectoangles(v1 - self.origin);
  if (self.goalentity.classname == "path_corner")
  {
    self.lefty = -1;
  }
  else if (visible(self.goalentity) == TRUE && range(self.goalentity) > RANGE_NEAR)
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

  if (fabs(v1_y) < 45)
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

  dist = vlen(self.enemy.origin - self.origin);

  if (dist < 1500)
  {
    self.attack_state = 1;
    if (self.ammo_rockets > 0)
    {
      if (self.enemy.flags & FL_ONGROUND)
        self.attack_state = 2;
      if (self.enemy.classname == "tank")
        self.attack_state = 2;
    }
  }
  else
    self.attack_state = 0;

  v1 = orgia(self.enemy);
  v0 = vectoangles(v1 - self.origin);
  if (self.attack_state == 2)
  {
    if (dist < 280)
      v0 = v0 + '0 0 0';
    else if (dist < 480)
      v0 = v0 + '5 0 0';
    else if (dist < 690)
      v0 = v0 + '10 0 0';
    else if (dist < 1030)
      v0 = v0 + '15 0 0';
    else
      v0 = v0 + '20 0 0';
  }
  makevectors(v0);
  v2 = v_forward;
  v2_z = 0 - v2_z;
//  dprint(vtos(v2));
//  dprint("\n");
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
        if (v_forward * v2 > 0.95)
        {
          AC_plasma(self.origin + v_forward * 10, v_forward, self.enemy);
          self.attack_finished = time + 0.5;
          self.effects = self.effects | EF_MUZZLEFLASH;
        }
      }
      else
      {
        if (v_forward * v2 > 0.95)
        {
          AC_bomb(self.origin + v_forward * 10, v_forward * 900, self.enemy);
          self.attack_finished = time + 1;
          self.ammo_rockets = self.ammo_rockets - 1;
          self.effects = self.effects | EF_MUZZLEFLASH;
        }
      }
    }
  }

  self.think = etank_run;
  self.nextthink = time + 0.1;
};

void() etank_shoot =
{
  local vector v0;
  v0 = self.tur2.angles;
  v0_x = 0 - v0_x;
  makevectors(v0);
  AC_plasma(self.origin + v_forward * 10, v_forward, self.enemy);
};

void() etank_start =
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
  setmodel(self.tur1, "progs/tanktr.mdl");
  self.tur2 = spawn();
  setorigin(self.tur2, self.origin);
  setmodel(self.tur2, "progs/tanktb.mdl");

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

void() monster_etank =
{
  self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_STEP; // ?

  if (!deathmatch)
    total_monsters = total_monsters + 1;

  setmodel(self, "progs/tankba.mdl");
  setsize (self, '-16 -16 -24', '16 16 8');
  self.view_ofs = '0 0 1';
  if (!self.health)
    self.health = 300;  // 500?
  self.netname = "a Tank";

  if (self.team == 0 || (self.team != 1 && deathmatch == 0))
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (!self.ammo_rockets)
    self.ammo_rockets = 10;

  self.th_die = etank_die;
  self.th_stand = etank_stand;
  self.th_walk = etank_walk;
  self.th_run = etank_run;  
  self.th_missile = etank_shoot;
  self.think = etank_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
