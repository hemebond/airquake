void() ac4_currentammo =
{
  self.ammo_shells = self.ammo_auto;
  self.ammo_nails = self.ammo_amsl;
  self.ammo_rockets = self.ammo_bomb;
  self.ammo_cells = self.ammo_smsl;

  if (self.weapon == IT_WEP1)
	//Geapon("auto");
 	self.weaponmodel = "progs/v_auto.mdl";
  else if (self.weapon == IT_WEP2)
	//Geapon("sider");
  self.weaponmodel = "progs/v_sider.mdl";
  else if (self.weapon == IT_WEP3)
	//Geapon("bomb");
   self.weaponmodel = "progs/v_bomb.mdl";
  else if (self.weapon == IT_WEP4)
    	//Geapon("maver");
	self.weaponmodel = "progs/v_maver.mdl";
};

void() ac4_steer =
{
  local entity stemp, stemp2;
  local vector v0,v1,v2,v3;
  local float tmp;

  stemp = self.enemy;
  Steer_plane (70, 70, 120);
  jet_sound();

  /*
  if (self.health < 20 && stemp.model == "progs/plane4.mdl")
    setmodel(stemp, "progs/plane4b.mdl");
  if (self.health >= 20 && stemp.model == "progs/plane4b.mdl")
    setmodel(stemp, "progs/plane4.mdl");
  */
  //FIXME!!

  //Tei
  //if(stemp.speed>95)
	//  CopterSparks(stemp);
  //Tei


  makevectors(stemp.angles);
  v3 = v_forward;
  v3_z = 0 - v3_z;
  if (time >= self.pausetime)
    stemp.speed = stemp.speed - v3_z * 6;
  if (stemp.health > 0)
  {
    if (self.button2)
    {
      if (!stemp.landed)
        stemp.thru = 4;
      if (time >= self.pausetime)
        setplanespeed(350, 2, 3);
      stemp.skin = 0;
	//g_updatesteer(5);//Tei
//      if (!(temp1&4))
//        stemp.effects = 4;
    }
    else
    {
      if (time >= self.pausetime)
      {
        tmp = stemp.thru * 62.5;
        setplanespeed(tmp, 2, 2);
      	//g_updatesteer(4);//Tei FIXME!!

      }
//      stemp.effects = 0;
      if (stemp.skin == 1)
        stemp.skin = 0;
    }
  }
  if (stemp.health < 1)
  {
    tmp = random() * 50;
    self.dmg_take = self.dmg_take + tmp;
    stemp.skin = 0;
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
    v1 = AC_aim(0.97, 1500);
  else if (self.weapon == IT_WEP3)
    v1 = AC_aim(1, -10);
  else if (self.weapon == IT_WEP4)
    v1 = AC_aim(0.93, 2000);
  else
    v1 = AC_aim(1, -10);

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

void() ac4_attack =
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
      v2 = AC_aim(0.97, -700);
      makevectors(v1);
      if (self.ammo_auto & 3)
        AC_bullet(self.enemy.origin + v_forward * 10, v2, world); 
      else
        AC_spike(self.enemy.origin + v_forward * 10, v2, world);
      newmis.touch = ACsuperspike_touch;
      newmis.dmg = 50;
      newmis.nextthink = time + 1;
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
  else if (self.weapon == IT_WEP2)  // sidewinder
  {
    if (self.ammo_amsl >= 1)
    {
      v2 = AC_aim(0.93, 1500);
      makevectors(v1);
      if (self.ammo_rockets & 1)
        AC_sidewinder(self.enemy.origin - v_forward * 10 + v_right * 16, v_forward, self.enemy.trigger_field);
      else
        AC_sidewinder(self.enemy.origin - v_forward * 10 - v_right * 16, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_nails = self.ammo_amsl = self.ammo_amsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 1.2;
  }
  else if (self.weapon == IT_WEP3) // bomb
  {
    if (self.ammo_bomb >= 1)
    {
      AC_bomb(self.enemy.origin - v_up * 10 - v_right * 10, self.enemy.velocity - v_right * 15, world);
      AC_bomb(self.enemy.origin - v_up * 10 + v_right * 10, self.enemy.velocity + v_right * 15, world);
      self.currentammo = self.ammo_rockets = self.ammo_bomb = self.ammo_bomb - 1;
      if (self.currentammo >= 1)
      {
        AC_bomb(self.enemy.origin - v_up * 10 - v_right * 20, self.enemy.velocity - v_right * 45, world);
        AC_bomb(self.enemy.origin - v_up * 10 + v_right * 20, self.enemy.velocity + v_right * 45, world);
        self.currentammo = self.ammo_rockets = self.ammo_bomb = self.ammo_bomb - 1;
      }
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 1.2;
  }
  else if (self.weapon == IT_WEP4)  // big msl
  {
    if (self.ammo_smsl > 0)
    {
      v2 = AC_aim(0.93, 2000);
      makevectors(v1);
      if (self.ammo_smsl & 1)
        AC_maverick(self.enemy.origin - v_up * 10 - v_forward * 10 + v_right * 16, v_forward, self.enemy.trigger_field);
      else
        AC_maverick(self.enemy.origin - v_up * 10 - v_forward * 10 - v_right * 16, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_cells = self.ammo_smsl = self.ammo_smsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 2;
  }
};

void() start_aircraft4 =
{
  local entity e, e2;

  // Create the plane
  // self.enemy is your aircraft (or other vehicle?-).
  e = spawn();
  //setmodel (e, "progs/plane4.mdl");
  setmodel (e, "newmedia/a10.md2");

  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "plane";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY;
  setsize (e, '-16 -16 -16', '16 16 16');
  e.solid = SOLID_SLIDEBOX;
  e.touch = T_ACTouch;
  e.health = 350;
  e.max_health = e.health;
  e.takedamage = DAMAGE_AIM;
  e.th_die = AC_Die;
  e.netname = self.netname;
  e.speed = 250;
  e.thru = 4;

  self.enemy = e;
  e.goalentity = self;
  e.owner = self;
  e.armorvalue = 15;

  self.toyview = 0;

  self.th_missile = ac4_attack;
  self.th_run = ac4_steer;
  self.th_melee = ac4_currentammo;

  self.ammo_shells = self.ammo_auto = 100;
  self.ammo_nails = self.ammo_amsl = 2 * wepmulti;
  self.ammo_rockets = self.ammo_bomb = 6 * wepmulti;
  self.ammo_cells = self.ammo_smsl = 6 * wepmulti;

  Check_startlanded ();
  self.oldenemy.style = 32;
};
