void() drone_auto =
{
  local vector v0;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  AC_spike(self.origin + v_forward * 10, v_forward, self.enemy);
  self.effects = self.effects | EF_MUZZLEFLASH;
  self.attack_finished = time + 0.1;
};

void() drone_cannon =
{
  local vector v0;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  AC_spike(self.origin + v_forward * 10, v_forward, self.enemy);

  newmis.touch = ACprojectile_touchboom;
  newmis.dmg = 50;
  newmis.nextthink = time + 1;
  self.effects = self.effects | EF_MUZZLEFLASH;
  self.attack_finished = time + 0.2;
};

void() drone_bombs =
{
  local vector v0;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  AC_bomb(self.origin - v_up * 10 - v_right * 10, self.velocity - v_right * 15, self.enemy);
  AC_bomb(self.origin - v_up * 10 + v_right * 10, self.velocity + v_right * 15, self.enemy);
  AC_bomb(self.origin - v_up * 10 - v_right * 20, self.velocity - v_right * 45, self.enemy);
  AC_bomb(self.origin - v_up * 10 + v_right * 20, self.velocity + v_right * 45, self.enemy);
};

void() drone_pave =
{
  local vector v0;
  local entity e;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  e = self.enemy;
  self.enemy = find(world, targetname, self.killtarget);
  AC_paveway(self.origin - v_up * 10, self.velocity - v_right * 15, self.enemy);
  self.enemy = e;
};

void() drone_maver =
{
  local vector v0;
  local entity e;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  e = self.enemy;
  self.enemy = find(world, targetname, self.killtarget);
  AC_maverick(self.origin - v_up * 10, v_forward, self.enemy);
  self.enemy = e;
};

void() drone_sider =
{
  local vector v0;
  local entity e;

  v0 = self.angles;
  v0_x = 0 - v0_x;

  makevectors(v0);

  AC_sidewinder(self.origin - v_up * 10, v_forward, self.enemy);
  self.attack_finished = time + 2;
};

void() drone2_fly =
{
  local vector v0,v1,v2,v3;
  local float ab, dist, r, mr;
  local entity temp;

  FindTarget();

  if (!self.movetarget)
  {
    self.movetarget = find(world, targetname, self.target);
  }

  if (self.search_time < time)
  {
    v2 = normalize(self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5 - self.origin);
    temp = find(world, noise, self.noise);
    mr = 0;
    while (temp)
    {
      if (temp.classname == "path_corner")
      {
        v1 = normalize(temp.origin - self.origin);
        r = v1 * v2;
        if (r > mr)
        {
          if (visible(temp))
          {
            self.movetarget = temp;
            mr = r;
          }
        }
      }
      temp = find(temp, noise, self.noise);
    }
    self.search_time = time + 2;
  }

  if (self.enemy)
  {
    if (!visible(self.enemy))
    {
      self.enemy = world;
    }
  }

  self.goalentity = self.movetarget;
  v1 = self.goalentity.origin;
  v3 = normalize(v1 - self.origin);  

//  v0 = self.angles; v0_x = 0 - v0_x;
//  makevectors (v0);
  v2 = normalize (self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5 - self.origin);

  if (v3 * v2 > 0.8)
  {
    self.goalentity = self.enemy;
    v1 = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5;
  }

  dist = vlen(v1 - self.origin);

  if (self.trigger_field != world && self.trigger_field != self.movetarget)
  {
    ab = vlen(self.trigger_field.origin - self.origin);
    ab = ab / vlen(self.goalentity.origin - self.trigger_field.origin);
    ab = ab * 0.7 + 0.4;
    if (ab > 1) ab = 1;
    v1 = self.trigger_field.origin + (self.goalentity.origin - self.trigger_field.origin) * ab;
    if (ab == 1)
    {
      self.trigger_field = self.goalentity;
      self.goalentity = self.goalentity.goalentity;
      self.movetarget = self.goalentity;
    }
  }

  v0 = vectoangles(v1 - self.origin);
  v1 = '0 0 0';
  v1_y = anglemod(v0_y - self.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;
  v1_x = anglemod(v0_x - self.angles_x);
  if (v1_x > 180)   v1_x = v1_x - 360;

  v2 = '0 0 0';
  if (v1_x < 0) v2_x = 0 - self.weapon;
  if (v1_x > 0) v2_x = self.weapon;
  if (fabs(v1_x) < self.weapon * 0.1)
  {
    v2_x = 0;
    self.angles_x = v0_x;
  }
  v2_y = v1_y * 5;
  if (v2_y < 0 - self.weapon) v2_y = 0 - self.weapon;
  if (v2_y > self.weapon) v2_y = self.weapon;
  if (fabs(v1_y) < self.weapon * 0.1)
  {
    v2_y = 0;
    self.angles_y = v0_y;
  }

  if (self.enemy == self.goalentity)
  {
    if (fabs(v1_y) < 25 && fabs(v1_x) < 25 && self.health < 120)
    {
      ab = 1;
      self.thru = 4;
    }
    else
    {
      ab = 0;
      if (fabs(v1_y) < 90 && fabs(v1_x) < 90)
        self.thru = 4;
      else
        self.thru = 3;
    }
  }
  else
  {
    self.thru = 4; ab = 0;
  }

  v1_z = 0 - v2_y - self.angles_z;

  if (v1_z < 0)
  {
    v2_z = -200;
    if (v2_z < v1_z * 10)
      v2_z = v1_z * 10;
  }
  if (v1_z > 0)
  {
    v2_z = 200;
    if (v2_z > v1_z * 10)
      v2_z = v1_z * 10;
  }
  if (fabs(v1_z) < 5)
  {
    v2_z = 0;
    self.angles_z = 0 - v2_y;
  }

    self.avelocity = v2;
    if (self.flags & FL_ONGROUND)
    {
      self.flags = self.flags - FL_ONGROUND;
      self.groundentity = world;
    }

    if (self.health < self.max_health * 0.2)
    {
      if (self.model == self.noise1)
        setmodel(self, self.noise2);
    }
    else
    {
      if (self.model == self.noise2)
        setmodel(self, self.noise1);
    }

    if (ab) 
    {
      self.skin = 1;
      if (!(temp1&4))
        self.effects = 4;
    }
    else
    {
      self.skin = 0;
      self.effects = 0;
    }

  makevectors(self.angles);
  v3 = v_forward;
  v3_z = 0 - v3_z;

  if (self.enemy != world && self.attack_finished < time)
  {
    v0 = self.enemy.origin + (self.enemy.mins + self.enemy.maxs) * 0.5 - self.origin;
    v2 = normalize (v0);

    if (v2 * v3 > 0.9)
    {
      if (self.style == 1 || self.style == 5)
      {
        if (vlen(v0) < 800)
          self.th_melee ();
        else if (vlen(v0) < 1600)
          self.th_missile ();
      }
      else
      {
        if (vlen(v0) < 1400)
          self.th_melee ();
      }
    }
  }


    if (!ab)
      self.speed = self.thru * 75;
    else
      self.speed = 500;

    self.velocity = v3 * self.speed;

  drone_sound();

  self.think = drone2_fly;
  self.nextthink = time + 0.1;
};

void() drone2_start =
{
//  local string  stemp;
//  local entity  etemp;

  if (deathmatch > 0 && (self.team == 0 || teamplay == 0))
  {
    remove(self);
    return;
  }

  if (!deathmatch)
    total_monsters = total_monsters + 1;

	self.takedamage = DAMAGE_AIM;

  self.view_ofs = '0 0 1';
//  self.use = monster_use;
	
	self.flags = self.flags | FL_MONSTER;
	
	if (self.target)
	{
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		if (!self.movetarget)
		{
			dprint ("Monster can't find target at ");
			dprint (vtos(self.origin));
			dprint ("\n");
		}
	}

// spread think times so they don't all happen at same time
  self.think = drone2_fly;
	self.nextthink = self.nextthink + random()*0.5;
};

void() monster_drone2 =
{
	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_FLY;

  self.style = self.sounds;

  if (self.style == 2)
  {
    self.noise1 = "newmedia/f16.md2";
    self.noise2 = "newmedia/f16.md2";
    self.max_health = 250;
    self.netname = "Fighter Bomber";
    self.th_missile = drone_maver;
    self.th_melee = drone_sider;
    self.weapon = 90;
  }
  else if (self.style == 3)
  {
    self.noise1 = "newmedia/f117.md2"; //"progs/plane3.mdl";
    self.noise2 = "newmedia/f117.md2";
    self.max_health = 200;
    self.netname = "Stealth Fighter";
    self.th_missile = drone_pave;
    self.th_melee = drone_sider;
    self.weapon = 80;
  }
  else if (self.style == 4)
  {
    self.noise1 = "newmedia/a10.md2";
    self.noise2 = "newmedia/a10.md2";
    self.max_health = 350;
    self.netname = "A-10";
    self.th_missile = drone_bombs;
    self.th_melee = drone_cannon;
    self.weapon = 70;
  }
  else if (self.style == 5)
  {
    self.noise1 = "newmedia/f22.md2";
    self.noise2 = "newmedia/f22.md2";
    self.max_health = 170;
    self.netname = "X-29";
    self.th_missile = drone_sider;
    self.th_melee = drone_auto;
    self.weapon = 110;
  }
  else
  {
    self.style = 1;
    self.noise1 = "newmedia/f18.md2";
    self.noise2 = "newmedia/f18.md2";
    self.max_health = 200;
    self.netname = "Dogfighter";
    self.th_missile = drone_sider;
    self.th_melee = drone_auto;
    self.weapon = 100;
  }

  setmodel (self, self.noise1);
  setsize (self, '-16 -16 -16', '16 16 16');
  if (!self.health)
    self.health = self.max_health;

  setup_teament();

  self.touch = T_DroneTouch;
  self.th_die = drone_die;
  self.th_stand = drone2_fly;
  self.th_walk = drone2_fly;
  self.th_run = drone2_fly;

  self.think = drone2_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
