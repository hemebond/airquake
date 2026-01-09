void() ac1_currentammo =
{
  self.ammo_shells = self.ammo_auto;  
  self.ammo_nails = self.ammo_cell;  
  self.ammo_rockets = self.ammo_rock;  
  self.ammo_cells = self.ammo_amsl;  

/*
	self.items = self.items - ( self.items & (IT_SHELLS | IT_NAILS | IT_ROCKETS | IT_CELLS) );
  if (self.weapon == IT_WEP1)
	{
    self.currentammo = self.ammo_auto;
    self.items = self.items | IT_NAILS;
	}
  else if (self.weapon == IT_WEP2)
	{
    self.currentammo = self.ammo_cells;
    self.items = self.items | IT_CELLS;
	}
  else if (self.weapon == IT_WEP3)
	{
		self.currentammo = self.ammo_cells;
		self.items = self.items | IT_CELLS;
	}
  else if (self.weapon == IT_WEP4)
	{
    self.currentammo = self.ammo_shells;
    self.items = self.items | IT_SHELLS;
	}
  else if (self.weapon == IT_WEP5)
	{
		self.currentammo = self.ammo_rockets;
		self.items = self.items | IT_ROCKETS;
	}
	else
	{
		self.currentammo = 0;
	}
  */
};

void() ac1_steer =
{
  local entity stemp, stemp2;
  local vector v0,v1,v2,v3;
  local float tmp, osk;

  osk = self.skin * 2;

  stemp = self.enemy;
  Steer_plane (100, 100, 200);

  if (self.health < 20 && stemp.model == "progs/plane1.mdl")
    setmodel(stemp, "progs/plane1b.mdl");
  if (self.health >= 20 && stemp.model == "progs/plane1b.mdl")
    setmodel(stemp, "progs/plane1.mdl");

  makevectors(stemp.angles);
  v3 = v_forward;
  v3_z = 0 - v3_z;
  if (time >= self.pausetime)
    stemp.speed = stemp.speed - v3_z * 10;
  if (stemp.health > 0)
  {
    if (self.button2)
    {
      if (!stemp.landed)
        stemp.thru = 4;
      if (time >= self.pausetime)
      {
        if (stemp.speed <= 500)
        {
          stemp.speed = stemp.speed + 8;
          if (stemp.speed > 500)
            stemp.speed = 500;
        }
        else
          stemp.speed = stemp.speed - 4;
      }
      stemp.skin = osk + 1;
      stemp.effects = 4;
    }
    else
    {
      if (time >= self.pausetime)
      {
        tmp = stemp.thru * 75;
        if (stemp.speed >= tmp )
        {
          if (!stemp.landed)
            stemp.speed = stemp.speed - 4;
          else
            stemp.speed = stemp.speed - 8;
          if (stemp.speed < tmp)
            stemp.speed = tmp;
        }
        else
          stemp.speed = stemp.speed + 6;
      }
      stemp.effects = 0;
      stemp.skin = osk;
    }
  }
  if (stemp.health < 1)
  {
    tmp = random() * 50;
    self.dmg_take = self.dmg_take + tmp;
    stemp.skin = osk;
    stemp.effects = 4;
  }
  if (time >= self.pausetime)
    self.pausetime = time + 0.1;
  if (stemp.speed < 0) stemp.speed = 0;
  self.armorvalue = stemp.speed / 3.30;
  stemp.velocity = v3 * stemp.speed;
  if (stemp.landed)
    stemp.velocity_z = 0;
  
  if (sky_z && stemp.origin_z > sky_z)
  {
    if (stemp.velocity_z > 0)
    {
      stemp.origin_z = sky_z;
      stemp.velocity_z = 0;
      if (stemp.angles_x > 0)
        stemp.angles_x = 0;
    }
  }
  Check_minsmaxs (stemp);
  if (stemp.colormap != self.colormap)
    stemp.colormap = self.colormap;
    
  self.oldenemy.velocity = stemp.velocity;

  if (self.weapon == IT_WEP1)
    v1 = AC_aim(0.97, -500);
  else if (self.weapon == IT_WEP2)
    v1 = AC_aim(0.97, -800);
  else if (self.weapon == IT_WEP3)
    v1 = AC_aim(0.93, -1000);
  else if (self.weapon == IT_WEP4)
    v1 = AC_aim(0.93, 1500);
  else
    v1 = AC_aim(1, -100);

  makevectors (self.v_angle);
  v2 = v_up * 24 - v_forward * self.distance;
  traceline(stemp.origin, stemp.origin + v2, FALSE, stemp);
  setorigin(self.oldenemy, trace_endpos + stemp.velocity * frametime);
//  setorigin(self, self.enemy.origin);

  if (!self.trigger_field)
    return;
  v1 = normalize (v1);
  traceline(stemp.origin, stemp.origin + v1 * 200, FALSE, stemp);
  if (self.enemy.trigger_field == world)
  {
    v2 = stemp.origin + v1 * (trace_fraction * 200 - 8);
    self.trigger_field.frame = 0;
  }
  else
  {
    v0 = stemp.trigger_field.origin + (stemp.trigger_field.mins + stemp.trigger_field.maxs) * 0.5;
    v1 = normalize(v0 - self.oldenemy.origin);
    traceline(self.oldenemy.origin, self.oldenemy.origin + v1 * 200, FALSE, stemp);
    v2 = self.oldenemy.origin + v1 * (trace_fraction * 200 - 8 );
    self.trigger_field.frame = 1;
  }
  setorigin(self.trigger_field, v2);
};

void() ac1_attack =
{
  local vector v1,v2;
  local entity stemp;

//  W_CheckNoAmmo ();

  v1 = self.enemy.angles;
  v1_x = 0 - v1_x;
  makevectors(v1);

  self.enemy.trigger_field = world;

  if (self.weapon == IT_WEP1)  // mach gun
  {
    if (self.ammo_auto >= 1)
    {
      v2 = AC_aim(0.97, -500);
      makevectors(v1);
      AC_spike(self.enemy.origin + v_forward * 10, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_shells = self.ammo_auto = self.ammo_auto - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
    {
//      sound (self.enemy, CHAN_ITEM, "weapons/pkup.wav", 1, ATTN_NORM);
      sprint (self, "not enough ammo.\n");
    }
    self.attack_finished = time + 0.1;
  }
  else if (self.weapon == IT_WEP2)  // plasma
  {
    if (self.ammo_cell >= 2)
    {
      v2 = AC_aim(0.97, -800);
      makevectors(v1);
      AC_plasma(self.enemy.origin + v_right * 10, v2, world);
      AC_plasma(self.enemy.origin - v_right * 10, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_nails = self.ammo_cell = self.ammo_cell - 2;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 0.5;
  }
  else if (self.weapon == IT_WEP3)  // rockets
  {
    if (self.ammo_rock >= 1)
    {
      v2 = AC_aim(0.93, -1000);
      makevectors(v1);
      if (self.ammo_rock & 1)
        AC_rocket(self.enemy.origin - v_up * 10 - v_forward * 10 + v_right * 10, v2, world);
      else
        AC_rocket(self.enemy.origin - v_up * 10 - v_forward * 10 - v_right * 10, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_rockets = self.ammo_rock = self.ammo_rock - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 0.4;
  }
  else if (self.weapon == IT_WEP4)  // sidewinder
  {
    if (self.ammo_amsl >= 1)
    {
      v2 = AC_aim(0.93, 1500);
      makevectors(v1);
      if (self.ammo_amsl & 1)
        AC_sidewinder(self.enemy.origin - v_forward * 10 + v_right * 16, v_forward, self.enemy.trigger_field);
      else
        AC_sidewinder(self.enemy.origin - v_forward * 10 - v_right * 16, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_cells = self.ammo_amsl = self.ammo_amsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 1.2;
  }
};

void() start_aircraft1 =
{
  local entity e, e2;

  // Create the plane
  // self.enemy is your aircraft (or other vehicle?-).
  e = spawn();
  setmodel (e, "progs/plane1.mdl");

  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "plane";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY;
  setsize (e, '-16 -16 -16', '16 16 16');
  e.solid = SOLID_SLIDEBOX;
  e.touch = T_ACTouch;
  e.health = 200;
  e.max_health = e.health;
  e.takedamage = DAMAGE_AIM;
  e.th_die = AC_Die;
  e.netname = self.netname;
  e.speed = 300;
  e.thru = 4;

  self.enemy = e;
  e.goalentity = self;
  e.owner = self;

  self.toyview = 0;

  // Create the target box
  // It's called self.trigger_field
  e = spawn();
  setmodel (e, "progs/s_target.spr");
  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.trigger_field = e;

  self.th_missile = ac1_attack;
  self.th_run = ac1_steer;
  self.th_melee = ac1_currentammo;

  self.ammo_shells = self.ammo_auto = 100;
  self.ammo_nails = self.ammo_cell = 20;
  self.ammo_rockets = self.ammo_rock = 10;  
  self.ammo_cells = self.ammo_amsl = 6;

  Check_startlanded ();
};
