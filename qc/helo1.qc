void() he1_currentammo =
{
  self.ammo_shells = self.ammo_auto;
  self.ammo_nails = self.ammo_rock;
  self.ammo_rockets = self.ammo_amsl;
  self.ammo_cells = self.ammo_smsl;

  if (self.weapon == IT_WEP1)
    self.weaponmodel = "progs/v_auto.mdl";
  else if (self.weapon == IT_WEP2)
    self.weaponmodel = "progs/v_rock.mdl";
  else if (self.weapon == IT_WEP3)
    self.weaponmodel = "progs/v_sider.mdl";
  else if (self.weapon == IT_WEP4)
    self.weaponmodel = "progs/v_hell.mdl";
};

void() he1_steer =
{
  local entity stemp, stemp2;
  local vector v0,v1,v2,v3;
  local float tmp;
  local float mov;

  stemp = self.enemy;

//  sound
  if (time > self.fly_sound)
  {
    sound (stemp, CHAN_BODY, "engines/chopper.wav", stemp.thru * 0.2 + 0.2, ATTN_NORM);
    self.fly_sound = time + 1;
  }

  self.flags = self.flags - (self.flags & FL_ONGROUND);
  stemp.flags = stemp.flags - (stemp.flags & FL_ONGROUND);

  if (pointcontents(stemp.origin) < CONTENT_EMPTY)
    T_Damage(stemp,stemp,stemp,1000);

  mov = 0;
  if (self.button2)
    mov = 1;

  if (stemp.angles_x < -180) stemp.angles_x = stemp.angles_x + 360;
  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;

  if (stemp.health > 0 && !(stemp.landed))
  {
    v0 = '0 0 0';
    v0_x = 0 - self.v_angle_x;
    if (self.toyview == 4)
      v0_x = 0;

    if (mov)
    {
      v1 = self.v_angle;
      v2 = stemp.angles;
      v3 = v1 - v2;
      v3_x = 0; v3_z = 0;
      
      makevectors (v3);
      tmp = v_forward_x;
      v0_x = v0_x - 40 * tmp;

      tmp = v_forward_y;
      v0_z = v0_z - 40 * tmp;
    }

    if (v0_x < -45) v0_x = -45;
    if (v0_x > 45) v0_x = 45;

    if (self.toyview == 0)
      v0_y = self.v_angle_y;
    else if (self.toyview == 1)
      v0_y = anglemod(self.v_angle_y + 90);
    else if (self.toyview == 2)
      v0_y = anglemod(self.v_angle_y + 180);
    else if (self.toyview == 3)
      v0_y = anglemod(self.v_angle_y + 270);
    else if (self.toyview == 4)
      v0_y = stemp.angles_y;

    v1 = '0 0 0';
    v1_y = anglemod(v0_y - stemp.angles_y);
    if (v1_y > 180)   v1_y = v1_y - 360;
    v1_x = v0_x - stemp.angles_x;

    v2 = '0 0 0';
    if (v1_x < 0) v2_x = -70;
    if (v1_x > 0) v2_x = 70;
    if (fabs(v1_x) < frametime * 70)
    {
      v2_x = 0;
      stemp.angles_x = v0_x;
    }
    if (v1_y < 0) v2_y = -110;
    if (v1_y > 0) v2_y = 110;
    if (fabs(v1_y) < frametime * 110)
    {
      v2_y = 0;
      stemp.angles_y = v0_y;
    }
    else
      stemp.angles_y = anglemod(stemp.angles_y);

    v0_z = v0_z - v2_y * fabs(stemp.angles_x) * 0.01;
    v0_z = v0_z + 45 * self.lefty;
    if (v0_z < -45) v0_z = -45;
    if (v0_z > 45) v0_z = 45;
    v1_z = v0_z - stemp.angles_z;

    if (v1_z < 0)
    {
      v2_z = -100;
      if (v2_z < v1_z * 10)
        v2_z = v1_z * 10;
    }
    if (v1_z > 0)
    {
      v2_z = 100;
      if (v2_z > v1_z * 10)
        v2_z = v1_z * 10;
    }
    if (fabs(v1_z) < v2_z * frametime)
    {
      v2_z = 0;
      stemp.angles_z = 0 - v2_y * 0.3;
    }
    stemp.avelocity = v2;
  }
  if (stemp.landed)
  {
    if (stemp.groundentity.classname != "func_runway" || stemp.thru > 2 || stemp.health < 1)
    {
      stemp.landed = 0;
      stemp.groundentity = world;
//      stemp.velocity_z = 50;
    }
  }

  tmp = stemp.health * 100 / stemp.max_health;
  if (tmp<1) tmp=1;
  if (tmp<self.health)
    self.dmg_take = self.health - tmp;
  self.health = tmp;

  if (self.health < 20 && stemp.model == "progs/helo1.mdl")
    setmodel(stemp, "progs/helo1b.mdl");
  if (self.health >= 20 && stemp.model == "progs/helo1b.mdl")
    setmodel(stemp, "progs/helo1.mdl");

  if (stemp.health < 1)
  {
    tmp = random() * 50;
    self.dmg_take = self.dmg_take + tmp;
    stemp.effects = 4;
  }
  else
    stemp.effects = 0;

  v3 = stemp.angles;
  v3_x = 0 - v3_x;
  makevectors(v3);
  if (stemp.thru != 2 || stemp.health < 1)
  {
    v3 = v_up * 20 * stemp.thru - '0 0 40';
  }
  else
  {
    v3 = v_up * (20 * stemp.thru / v_up_z) - '0 0 40';
  }

  if (time >= self.pausetime)
  {
    self.pausetime = time + 0.1;
    if (!stemp.landed)
    {
      stemp.velocity = stemp.velocity * 0.8 + v3;
      self.armorvalue = vlen(stemp.velocity) / 3.30;
    }
    else
      self.armorvalue = 0;
  }

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

  v2 = self.enemy.angles; v2_x = 0 - v2_x;
  makevectors(v2);
  v2 = v_forward;
  if (self.weapon == IT_WEP1)
  {
    v1 = AC_aim2(0.97, -500);
    if (v2 * v1 < 0.7)
      v1 = AC_aim(0.97, -500);
  }
  else if (self.weapon == IT_WEP2)
    v1 = AC_aim(0.95, -1000);
  else if (self.weapon == IT_WEP3)
    v1 = AC_aim(0.93, 1500);
  else if (self.weapon == IT_WEP4)
    v1 = AC_aim(0.93, 2000);
  else
    v1 = AC_aim(1, -10);

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
    v2 = place_targetbox();
  setorigin(self.trigger_field, v2);
};

void() he1_attack =
{
  local vector v1,v2;
  local entity stemp;

//  W_CheckNoAmmo ();

  v1 = self.enemy.angles; v1_x = 0 - v1_x;
  makevectors(v1);
  v1 = v_forward;

  self.enemy.trigger_field = world;

  if (self.weapon == IT_WEP1)  // mach gun
  {
    if (self.ammo_auto >= 1)
    {
      v2 = AC_aim2(0.97, -500);
      if (v2 * v1 < 0.7)
        v2 = AC_aim(0.97, -500);
      AC_spike(self.enemy.origin + v1 * 10, v2, world);
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
  else if (self.weapon == IT_WEP2)  // rockets
  {
    if (self.ammo_rock >= 1)
    {
      v2 = AC_aim(0.93, -1000);
      if (self.ammo_rock & 1)
        AC_rocket(self.enemy.origin - v_up * 10 - v1 * 10 + v_right * 10, v2, world);
      else
        AC_rocket(self.enemy.origin - v_up * 10 - v1 * 10 - v_right * 10, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_nails = self.ammo_rock = self.ammo_rock - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 0.4;
  }
  else if (self.weapon == IT_WEP3) // sidewinder
  {
    if (self.ammo_amsl >= 1)
    {
      v2 = AC_aim(0.93, 1500);
      if (self.ammo_amsl & 1)
        AC_sidewinder(self.enemy.origin - v1 * 10 + v_right * 16, v1, self.enemy.trigger_field);
      else
        AC_sidewinder(self.enemy.origin - v1 * 10 - v_right * 16, v1, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_rockets = self.ammo_amsl = self.ammo_amsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 1.2;
  }
  else if (self.weapon == IT_WEP4)  // hfire
  {
    if (self.ammo_smsl > 0)
    {
      v2 = AC_aim(0.93, 2000);
      AC_hellfire(self.enemy.origin - v_up * 10 - v1 * 10, v1, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_cells = self.ammo_smsl = self.ammo_smsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 2;
  }
};

void() start_helo1 =
{
  local entity e, e2;

  // Create the plane
  // self.enemy is your aircraft (or other vehicle?-).
  e = spawn();
  setmodel (e, "progs/helo1.mdl");

  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "plane";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY;
  setsize (e, '-16 -16 -16', '16 16 16');
  e.solid = SOLID_SLIDEBOX;
  e.touch = T_HETouch;
  e.health = 200;
  e.max_health = e.health;
  e.takedamage = DAMAGE_AIM;
  e.th_die = HE_Die;
  e.netname = self.netname;
  e.thru = 2;

  self.enemy = e;
  e.goalentity = self;
  e.owner = self;

  self.toyview = 0;

  self.th_missile = he1_attack;
  self.th_run = he1_steer;
  self.th_melee = he1_currentammo;

  self.ammo_shells = self.ammo_auto = 100;
  self.ammo_nails = self.ammo_rock = 16 * wepmulti;
  self.ammo_rockets = self.ammo_amsl = 4 * wepmulti;
  self.ammo_cells = self.ammo_smsl = 4 * wepmulti;

  Check_startlanded ();
};
