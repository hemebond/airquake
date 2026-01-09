void() gv4_steer =
{
  local entity veh;
  local vector v0,v1,v2,v3;
  local vector sp;
  local float tmp, f1, f2;

  veh = self.enemy;

  tmp=veh.speed / ((veh.thru + 1) * 6);
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  if (time > self.fly_sound || veh.impulse != tmp)
  {
    f1 = veh.thru * 0.25;
    if (tmp == 0)
      sound (veh, CHAN_BODY, "engines/hov0.wav", f1, ATTN_NORM);
    else if (tmp == 1)
      sound (veh, CHAN_BODY, "engines/hov1.wav", f1, ATTN_NORM);
    else if (tmp == 2)
      sound (veh, CHAN_BODY, "engines/hov2.wav", f1, ATTN_NORM);
    else if (tmp == 3)
      sound (veh, CHAN_BODY, "engines/hov3.wav", f1, ATTN_NORM);
    else if (tmp == 4)
      sound (veh, CHAN_BODY, "engines/hov4.wav", f1, ATTN_NORM);
    else if (tmp == 5)
      sound (veh, CHAN_BODY, "engines/hov5.wav", f1, ATTN_NORM);
    else if (tmp == 6)
      sound (veh, CHAN_BODY, "engines/hov6.wav", f1, ATTN_NORM);
    else if (tmp == 7)
      sound (veh, CHAN_BODY, "engines/hov7.wav", f1, ATTN_NORM);
    else 
      sound (veh, CHAN_BODY, "engines/hov8.wav", f1, ATTN_NORM);
    self.fly_sound = time + 1;
    veh.impulse = tmp;
  }

  if (!self.flags & FL_GODMODE)
    Steer_hover(100, 100);
  else
    Steer_hover(1000, 1000);

  tmp = vlen(self.velocity - self.movedir);

  self.movedir = self.velocity;
  if (tmp > 120)
  {
    sound (veh, CHAN_VOICE, "player/land2.wav", 1, ATTN_NORM);
    T_Damage(veh, world, world, (tmp - 120) * 0.1);
  }
  veh.flags = veh.flags - (veh.flags & FL_ONGROUND);
  if (veh.thru != 0)
    self.flags = self.flags - (self.flags & FL_ONGROUND);

  v1 = veh.angles;
  v1_x = 0 - v1_x;
  makevectors(v1);
  v3 = v_forward;
  if (time >= self.pausetime)
  {
//    tmp = veh.thru * 60;
    tmp = 0;
    if (self.button2)
    {
      tmp = self.v_angle_y - veh.angles_y;
      if (tmp < 0) tmp = tmp + 360;
      if (tmp > 180) tmp = tmp - 360;
      tmp = 60 * veh.thru;
      if (self.flags & FL_GODMODE)
        tmp = 20 * tmp;
    }
    if (veh.speed >= tmp )
    {
      veh.speed = veh.speed - 8;
      if (veh.speed < tmp)
        veh.speed = tmp;
    }
    else
    {
      veh.speed = veh.speed + 8;
      if (veh.speed > tmp)
        veh.speed = tmp;
    } 

    sp = v3 * veh.speed * 0.1 - '0 0 40';
    if (veh.thru)
    {
      tmp = veh.thru * 18 + 32;
      traceline(veh.origin - v_up * 16, veh.origin - v_up * tmp, FALSE, self);
      f1 = trace_fraction;
      if (trace_inwater)
      {
        if (f1 > 0.6)
          f1 = 0.6;
        if (f1 > 0)
        {
          traceline(veh.origin - v_up * 16, veh.origin - v_up * 22, FALSE, self);
          if (trace_inwater)
            f1 = 0;
        }
        if (f1 > 0.4)
        {
          tmp = fabs(veh.thru) * 9 + 14;
          traceline(veh.origin - v_up * 16, veh.origin - v_up * tmp, FALSE, self);
          if (trace_inwater)
            f1 = 0.4;
        }
        if (f1 > 0.5)
        {
          tmp = fabs(veh.thru) * 9 + 17;
          traceline(veh.origin - v_up * 16, veh.origin - v_up * tmp, FALSE, self);
          if (trace_inwater)
            f1 = 0.5;
        }
      }
      if (f1 < 1)
      {
        sp = sp + v_up * 80 * (1 - f1);
        f1 = self.velocity * v_up;
        v1 = v_up * f1; v2 = self.velocity - v1;
        self.velocity = v1 * 0.8 + v2;
      }
    }
    self.velocity = self.velocity * 0.9 + sp;

    if (veh.speed)
    {
      self.armorvalue = vlen(self.velocity) / 3.3;
      veh.frame = 1;
    }
    else
    {
      self.armorvalue = 0;
      veh.frame = 0;
    }
    self.pausetime = time + 0.1;
  }
//  veh.oldenemy.velocity = veh.velocity;
//  veh.movetarget.velocity = veh.velocity;
  setorigin(self.enemy, self.origin);
  if (self.enemy.oldenemy)
    setorigin(self.enemy.oldenemy, self.enemy.origin);
  if (self.enemy.movetarget)
    setorigin(self.enemy.movetarget, self.enemy.origin);

  if (self.weapon == IT_WEP1)
    v1 = GV_aim(0.97, -500);
  else if (self.weapon == IT_WEP2)
    v1 = GV_aim(0.97, -800);
  else if (self.weapon == IT_WEP3)
    v1 = GV_aim(0.95, -1000);
  else if (self.weapon == IT_WEP4)
    v1 = GV_aim(0.93, 2000);
  else
    v1 = GV_aim(1, -100);

  if (!self.trigger_field)
    return;

  if (self.enemy.trigger_field == world)
  {
    v1 = normalize (v1);
    traceline(veh.origin, veh.origin + v1 * 200, FALSE, veh);
    v2 = trace_endpos - v1 * 8;
    self.trigger_field.frame = 0;
  }
  else
    v2 = place_targetbox();
  setorigin(self.trigger_field, v2);
};

void() gv4_attack =
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
      {
        if (self.ammo_auto & 2)
          AC_bullet(self.enemy.origin - v_right * 8, v2, world);
        else
          AC_spike(self.enemy.origin - v_right * 8, v2, world);
      }
      else
      {
        if (self.ammo_auto & 2)
          AC_bullet(self.enemy.origin - v_right * 8, v2, world);
        else
          AC_spike(self.enemy.origin + v_right * 8, v2, world);
      }
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
    if (self.ammo_cell >= 1)
    {
      v2 = GV_aim(0.97, -800);
      makevectors(v1);
      if (self.ammo_cell & 1)
        AC_plasma(self.enemy.origin - v_right * 8, v2, world);
      else
        AC_plasma(self.enemy.origin + v_right * 8, v2, world);
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
  else if (self.weapon == IT_WEP3)
  {
    if (self.ammo_rock >= 1)
    {
      v2 = GV_aim(0.95, -1000);
      makevectors(v1);
      if (self.ammo_rock & 1)
        AC_rocket(self.enemy.origin - v_right * 8, v2, world);
      else
        AC_rocket(self.enemy.origin + v_right * 8, v2, world);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_rockets = self.ammo_rock = self.ammo_rock - 1;
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
    if (self.ammo_smsl >= 1)
    {
      v2 = GV_aim(0.93, 2000);
      makevectors(v1);
      if (self.ammo_smsl & 1)
        AC_hellfire(e.origin + v_right * 8, v_forward, self.enemy.trigger_field);
      else
        AC_hellfire(e.origin - v_right * 8, v_forward, self.enemy.trigger_field);
      self.enemy.effects = self.enemy.effects | EF_MUZZLEFLASH;
      self.currentammo = self.ammo_cells = self.ammo_smsl = self.ammo_smsl - 1;
      self.enemy.show_hostile = time + 1;
    }
    else
      sprint(self, "not enough ammo.\n");
    self.attack_finished = time + 1.3;
  }
};

void() gv4_currentammo =
{
  self.ammo_shells = self.ammo_auto;
  self.ammo_nails = self.ammo_cell;
  self.ammo_rockets = self.ammo_rock;
  self.ammo_cells = self.ammo_smsl;

  if (self.weapon == IT_WEP1)
    self.weaponmodel = "progs/v_auto.mdl";
  else if (self.weapon == IT_WEP2)
    self.weaponmodel = "progs/v_plas.mdl";
  else if (self.weapon == IT_WEP3)
    self.weaponmodel = "progs/v_rock.mdl";
  else if (self.weapon == IT_WEP4)
    self.weaponmodel = "progs/v_hell.mdl";
};
// HOVER
void() start_groundveh4 =
{
  local entity e, e2;

  self.takedamage = DAMAGE_NO;
  setsize (self, '-16 -16 -24', '16 16 24');
  self.movetype = MOVETYPE_FLY; //WALK;
//  setsize (self, '0 0 0', '0 0 0');

  // Create the veh -> self.enemy
  e = spawn();
  setmodel (e, "progs/hovba.mdl");
  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(self, e2.origin);
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "tank";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY; 
//  setsize (e, '0 0 0', '0 0 0');
  setsize (e, '-16 -16 -24', '16 16 24');
  e.solid = SOLID_SLIDEBOX;
  e.health = 300;
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
  e.armorvalue = 10;

  self.toyview = 0;

  // Create the gun barrels
  // == vehicle.oldenemy
  e = spawn();
  setmodel (e, "progs/hovtb.mdl");
  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.enemy.oldenemy = e;
  e.colormap = self.colormap;

  // Create the turret
  // == vehicle.movetarget
  e = spawn();
  setmodel (e, "progs/hovtr.mdl");
  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.enemy.movetarget = e;
  e.colormap = self.colormap;

  self.th_missile = gv4_attack;
  self.th_run = gv4_steer;
  self.th_melee = gv4_currentammo;

  self.ammo_shells = self.ammo_auto = 100;
  self.ammo_nails = self.ammo_cell = 40 * wepmulti;
  self.ammo_rockets = self.ammo_rock = 10 * wepmulti;
  self.ammo_cells = self.ammo_smsl = 6 * wepmulti;

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
