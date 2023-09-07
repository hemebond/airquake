void() gv1_steer =
{
  local entity veh;
  local vector v0,v1,v2,v3;
  local float tmp;

  veh = self.enemy;

  tmp=vlen(self.velocity) * 0.06;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  //if(self.enemy.speed>110)
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
    veh.speed = veh.speed - v3_z * 5;
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
    }
    if (veh.speed >= tmp )
    {
      veh.speed = veh.speed - 4;
      if (veh.speed < tmp)
        veh.speed = tmp;
    }
    else
    {
      veh.speed = veh.speed + 3;
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
  else if (self.weapon == IT_WEP2)
    v1 = GV_aim(0.93, 1800);
  else
    v1 = GV_aim(1, -100);

  if (!self.trigger_field)
    return;

  v2 = veh.angles; v2_x = 0 - v2_x;
  makevectors(v2);
  v1 = normalize (v1);
  traceline(veh.origin + v_right * 16, veh.origin + v1 * 200 + v_right * 16, FALSE, veh);
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

void() gv1_attack =
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
      AC_spike(self.enemy.origin + v_forward * 10 + v_right * 16, v2, world);
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
  else if (self.weapon == IT_WEP2)
  {
    if (self.ammo_amsl >= 1)
    {
      v2 = GV_aim(0.93, 1800);
      makevectors(v1);
      if (self.ammo_amsl & 1)
        AC_heatseeker(e.origin + v_right * 16 - v_up * 4, v_forward, self.enemy.trigger_field);
      else
        AC_heatseeker(e.origin + v_right * 16 + v_up * 4, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_nails = self.ammo_amsl = self.ammo_amsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 0.8;
  }
};

void() gv1_currentammo =
{
  self.ammo_shells = self.ammo_auto;
  self.ammo_nails = self.ammo_amsl;
  self.ammo_rockets = 0;
  self.ammo_cells = 0;

  if (self.weapon == IT_WEP1)
	//Geapon("auto");//Tei
    self.weaponmodel = "progs/v_auto.mdl";
  else if (self.weapon == IT_WEP2)
	//Geapon("sam");//Tei
    self.weaponmodel = "progs/v_sam.mdl";
  else if (self.weapon == IT_WEP3)
	//Geapon("none");//Tei
    self.weaponmodel = "";
  else if (self.weapon == IT_WEP4)
	//Geapon("none");//Tei
    self.weaponmodel = "";
};

void() start_groundveh1 =
{
  local entity e, e2;

  setsize (self, '-16 -16 -24', '16 16 24');
  self.takedamage = DAMAGE_NO;

  // Create the veh -> self.enemy
  e = spawn();

  //setmodel (e, "progs/msamba.mdl");
  setmodel (e, "newmedia/msam.md2"); //Tei


  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(self, e2.origin);
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "tank";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY; //NONE;
  setsize (e, '-16 -16 -24', '16 16 16');
  e.solid = SOLID_SLIDEBOX;
//  e.touch = T_ACTouch;
  e.health = 400;
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
  e.armorvalue = 15;

  self.toyview = 0;

  // Create the missile tubes
  // == vehicle.oldenemy
  e = spawn();
  // setmodel (e, "progs/msamtb.mdl");
  setmodel (e, "newmedia/msamturret.md2");//Tei

  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.enemy.oldenemy = e;
  e.colormap = self.colormap;

  self.th_missile = gv1_attack;
  self.th_run = gv1_steer;
  self.th_melee = gv1_currentammo;

  self.ammo_shells = self.ammo_auto = 200;
  self.ammo_nails = self.ammo_amsl = 16 * wepmulti;
  self.ammo_rockets = 0;
  self.ammo_cells = 0;

  self.items = IT_WEP1 | IT_WEP2;

  droptofloor();
  if (!checkbottom(self))
  {
    traceline(self.origin, self.origin + '0 0 -10000', TRUE, self);
    self.origin_z = trace_endpos_z + 30;
  }
  setorigin(self.enemy, self.origin);
  setorigin(self.enemy.oldenemy, self.origin);
  self.velocity = '0 0 0';
  self.movedir = '0 0 0';
  self.oldenemy.style = 32;
};
