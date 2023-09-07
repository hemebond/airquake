void() gv2_steer =
{
  local entity veh;
  local vector v0,v1,v2,v3;
  local float tmp;

  veh = self.enemy;

  tmp=vlen(self.velocity) * 0.06;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  //if(self.enemy.speed>95)
	//  CopterSparks(veh);
 
  if (time > self.fly_sound || veh.impulse != tmp)
  {
    if (tmp == 0)
      sound (veh, CHAN_BODY, "engines/tank0.wav", 0.2, ATTN_NORM);
    else if (tmp == 1)
      sound (veh, CHAN_BODY, "engines/tank1.wav", 0.3, ATTN_NORM);
    else if (tmp == 2)
      sound (veh, CHAN_BODY, "engines/tank2.wav", 0.4, ATTN_NORM);
    else if (tmp == 3)
      sound (veh, CHAN_BODY, "engines/tank3.wav", 0.5, ATTN_NORM);
    else if (tmp == 4)
      sound (veh, CHAN_BODY, "engines/tank4.wav", 0.6, ATTN_NORM);
    else if (tmp == 5)
      sound (veh, CHAN_BODY, "engines/tank5.wav", 0.7, ATTN_NORM);
    else if (tmp == 6)
      sound (veh, CHAN_BODY, "engines/tank6.wav", 0.8, ATTN_NORM);
    else if (tmp == 7)
      sound (veh, CHAN_BODY, "engines/tank7.wav", 0.9, ATTN_NORM);
    else 
      sound (veh, CHAN_BODY, "engines/tank8.wav", 1.0, ATTN_NORM);
    self.fly_sound = time + 1;
    veh.impulse = tmp;
  }

  tmp = vlen(self.velocity - self.movedir);
  self.movedir = self.velocity;
  if (tmp > 120)
  {
    sound (veh, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
    T_Damage(veh, self.radiuskiller, self.radiuskiller, (tmp - 120) * 0.5);
  }
  if (self.flags & FL_ONGROUND)
    self.radiuskiller = world;

  if (!self.flags & FL_GODMODE)
    Steer_groundveh(100, 70);
  else
    Steer_groundveh(1000, 1000);
  veh.flags = veh.flags - (veh.flags & FL_ONGROUND);

  if (self.flags & FL_ONGROUND)
  {
    if (veh.angles_x > 45) veh.angles_x = 45;
    if (veh.angles_x < -45) veh.angles_x = -45;
    if (veh.angles_z > 60) veh.angles_z = 60;
    if (veh.angles_z < -60) veh.angles_z = -60;
  }
  v1 = veh.angles;
  v1_x = 0 - v1_x;
  makevectors(v1);
  v3 = v_forward;
  if (time >= self.pausetime)
  {
    veh.speed = veh.speed - v3_z * 7;
    tmp = veh.thru * 30;
    if (self.button2)
    {
      tmp = self.v_angle_y - veh.angles_y;
      if (tmp < 0) tmp = tmp + 360;
      if (tmp > 180) tmp = tmp - 360;
      if (fabs(tmp) <= 90)
        tmp = 120;
      else
        tmp = -120;
      if (self.flags & FL_GODMODE)
        tmp = 20 * tmp;
    }
    if (veh.speed >= tmp )
    {
      veh.speed = veh.speed - 5;
      if (veh.speed < tmp)
        veh.speed = tmp;
    }
    else
    {
      veh.speed = veh.speed + 5;
      if (veh.speed > tmp)
        veh.speed = tmp;
    } 
    self.pausetime = time + 0.1;
  }

  self.armorvalue = vlen(self.velocity) / 3.3;
  if (self.flags & FL_ONGROUND)
    self.velocity = self.velocity * 0.5 + v3 * veh.speed * 0.5;

  if (self.trigger_field)
  {
  if (self.weapon == IT_WEP1)
    v1 = GV_aim(0.97, -500);
  if (self.weapon == IT_WEP2)
    v1 = GV_aim(0.97, -800);
  if (self.weapon == IT_WEP3)
    v1 = GV_aim(0.97, -10);
  else if (self.weapon == IT_WEP4)
    v1 = GV_aim(0.93, 1200);
  else
    v1 = GV_aim(1, -100);

  if (!self.trigger_field)
    return;

  if (self.weapon == IT_WEP3)
  {
    self.trigger_field.frame = 0;
    if (self.trigger_field.model != "progs/null.spr")
      setmodel(self.trigger_field, "progs/null.spr");
    return;
  }
  else
  {
    if (self.trigger_field.model == "progs/null.spr")
      setmodel(self.trigger_field, "progs/s_target.spr");
  }

  v2 = veh.angles; v2_x = 0 - v2_x;
  makevectors(v2);
  v1 = normalize (v1);
  traceline(veh.origin, veh.origin + v1 * 200, FALSE, veh);
  if (self.enemy.trigger_field == world)
  {
    v2 = trace_endpos - v1 * 8;
    self.trigger_field.frame = 0;
  }
  else
    v2 = place_targetbox();
  setorigin(self.trigger_field, v2);
  }
};

void() gv2_attack =
{
  local vector v1, v2;
  local entity stemp, e;

  stemp = self.enemy;
  e = stemp.oldenemy;

  v1 = e.angles;
  v1_x = 0 - v1_x;
  
  if (self.weapon == IT_WEP1)
  {
    if (self.ammo_auto >= 1)
    {
      v2 = GV_aim(0.97, -500);
      makevectors(v1);
      if (self.ammo_auto & 1)
        AC_spike(self.enemy.origin + v_forward * 10 - v_right * 8, v2, world);
      else
        AC_spike(self.enemy.origin + v_forward * 10 + v_right * 8, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_shells = self.ammo_auto = self.ammo_auto - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
    {
      sprint (self, "not enough ammo.\n");
    }
    self.attack_finished = time + 0.1;
  }
  if (self.weapon == IT_WEP2)
  {
    if (self.ammo_cell >= 1)
    {
      v2 = GV_aim(0.97, -800);
      makevectors(v1);
      if (self.ammo_cell & 1)
        AC_plasma(self.enemy.origin + v_forward * 10 + v_right * 8, v2, world);
      else
        AC_plasma(self.enemy.origin + v_forward * 10 - v_right * 8, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_nails = self.ammo_cell = self.ammo_cell - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
    {
      sprint (self, "not enough ammo.\n");
    }
    self.attack_finished = time + 0.3;
  }
  if (self.weapon == IT_WEP3)
  {
    if (self.ammo_shel >= 1)
    {
      v2 = GV_aim(0.97, -10);
      makevectors(v1);
      if (self.ammo_shel & 1)
        AC_bomb2(self.enemy.origin + v_forward * 10 + v_right * 8, v2 * 900, world);
      else
        AC_bomb2(self.enemy.origin + v_forward * 10 - v_right * 8, v2 * 900, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_rockets = self.ammo_shel = self.ammo_shel - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
    {
      sprint (self, "not enough ammo.\n");
    }
    self.attack_finished = time + 0.5;
  }
  else if (self.weapon == IT_WEP4)
  {
    if (self.ammo_amsl >= 1)
    {
      v2 = GV_aim(0.93, 1200);
      makevectors(v1);
      if (self.ammo_amsl & 1)
        AC_heatseeker(e.origin + v_right * 8, v_forward, self.enemy.trigger_field);
      else
        AC_heatseeker(e.origin - v_right * 8, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_cells = self.ammo_amsl = self.ammo_amsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 0.8;
  }
};

void() gv2_currentammo =
{
  self.ammo_shells = self.ammo_auto;
  self.ammo_nails = self.ammo_cell;
  self.ammo_rockets = self.ammo_shel;
  self.ammo_cells = self.ammo_amsl;

  if (self.weapon == IT_WEP1)
	//Geapon("auto");
    self.weaponmodel = "progs/v_auto.mdl";
  else if (self.weapon == IT_WEP2)
	//Geapon("plasma");
    self.weaponmodel = "progs/v_plas.mdl";
  else if (self.weapon == IT_WEP3)
	//Geapon("canon");
    self.weaponmodel = "progs/v_cann.mdl";
  else if (self.weapon == IT_WEP4)
	//Geapon("sam");
    self.weaponmodel = "progs/v_sam.mdl";
};

void() start_groundveh2 =
{
  local entity e, e2;

  setsize (self, '-16 -16 -24', '16 16 24');
  //setsize (self, '-15 -8 -5', '12 6 2');//FIXME!!

  self.takedamage = DAMAGE_NO;

  // Create the veh -> self.enemy
  e = spawn();
  //setmodel (e, "progs/tankba.mdl");
  setmodel (e, "newmedia/tankm1.md2"); //Tei

  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(self, e2.origin);
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "tank";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY; //NONE;
  setsize (e, '-16 -16 -24', '16 16 16');//

  //setsize (e, '-15 -8 -5', '12 6 2');//FIXME!!

  e.solid = SOLID_SLIDEBOX;
  e.health = 600;
  e.max_health = e.health;
  e.takedamage = DAMAGE_AIM;
  e.th_die = GV_Die;
  e.netname = self.netname;
  e.speed = 0;
  e.thru = 0;
  self.enemy = e;
  e.goalentity = self;
  e.owner = self;
  e.view_ofs = '0 0 1';
  e.colormap = self.colormap;
  e.armorvalue = 20;

  self.toyview = 0;

  // Create the gun barrels
  // == vehicle.oldenemy
  e = spawn();
  //setmodel (e, "progs/tanktb.mdl");

  setmodel (e, "newmedia/gunm1.md2"); // Tei FIXME!!

  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.enemy.oldenemy = e;
  e.colormap = self.colormap;

  // Create the turret
  // == vehicle.movetarget
  e = spawn();
  //setmodel (e, "progs/tanktr.mdl");
  setmodel (e, "newmedia/turretm1.md2"); // Tei 

  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.enemy.movetarget = e;
  e.colormap = self.colormap;

  self.th_missile = gv2_attack;
  self.th_run = gv2_steer;
  self.th_melee = gv2_currentammo;

  self.ammo_shells = self.ammo_auto = 150;
  self.ammo_nails = self.ammo_cell = 30 * wepmulti;
  self.ammo_rockets = self.ammo_shel = 60 * wepmulti;
  self.ammo_cells = self.ammo_amsl = 6 * wepmulti;

  droptofloor();
  if (!checkbottom(self))
  {
    traceline(self.origin, self.origin + '0 0 -10000', TRUE, self);
    self.origin_z = trace_endpos_z + 30;
  }
  setorigin(self.enemy, self.origin);
  setorigin(self.enemy.oldenemy, self.origin);
  setorigin(self.enemy.movetarget, self.origin);
  self.velocity = '0 0 0';
  self.movedir = '0 0 0';
  self.oldenemy.style = 32;
};
