void() jet_sound =
{
  local float tmp, f1;
  local entity veh;

  veh = self.enemy;

  tmp=veh.speed / 70;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  if (time > self.fly_sound || veh.impulse != tmp)
  {
    f1 = veh.thru * 0.1 + 0.2;
    if (self.button2 && self.style != 3)
      f1 = 1;
    if (tmp == 0)
      sound (veh, CHAN_BODY, "engines/jet0.wav", f1, ATTN_NORM);
    else if (tmp == 1)
      sound (veh, CHAN_BODY, "engines/jet1.wav", f1, ATTN_NORM);
    else if (tmp == 2)
      sound (veh, CHAN_BODY, "engines/jet2.wav", f1, ATTN_NORM);
    else if (tmp == 3)
      sound (veh, CHAN_BODY, "engines/jet3.wav", f1, ATTN_NORM);
    else if (tmp == 4)
      sound (veh, CHAN_BODY, "engines/jet4.wav", f1, ATTN_NORM);
    else if (tmp == 5)
      sound (veh, CHAN_BODY, "engines/jet5.wav", f1, ATTN_NORM);
    else if (tmp == 6)                  
      sound (veh, CHAN_BODY, "engines/jet6.wav", f1, ATTN_NORM);
    else if (tmp == 7)
      sound (veh, CHAN_BODY, "engines/jet7.wav", f1, ATTN_NORM);
    else 
      sound (veh, CHAN_BODY, "engines/jet8.wav", f1, ATTN_NORM);
    self.fly_sound = time + 0.2;
    veh.impulse = tmp;
  }
};

void() plane_upright =
{
  local entity stemp;
  local vector v1;

  stemp = self.enemy;
  if (stemp.classname != "plane")
    return;

  v1 = stemp.angles;

  if (fabs(v1_x) > 90)
  {
    v1_y = anglemod(v1_y + 180);
    v1_z = anglemod(v1_z + 180);
    if (v1_z > 180) v1_z = v1_z - 360;
    stemp.avelocity = '0 0 0' - stemp.avelocity;

    if (v1_x >= 0)
      v1_x = 180 - v1_x;
    else
      v1_x = -180 - v1_x;
  }
  if (fabs(v1_z) > 180)
  {
    if (v1_z > 180)
      v1_z = v1_z - 360;
    else
      v1_z = v1_z + 360;
  }
  stemp.angles = v1;
};

void (vector v0, float sp_x, float sp_y, float sp_st) Turn_plane =
{
  local entity stemp;
  local vector v1,v2,v3;

  stemp = self.enemy;

  v1 = '0 0 0';
  v1_y = anglemod(v0_y - stemp.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;
  v1_x = v0_x - stemp.angles_x;

// new loop code
  if (fabs(v1_y) > 90 && fabs(v1_y) > (180 - fabs(stemp.angles_x + v0_x)) )
  {
    if (v0_x >= 0)
    {
      v0_x = 180 - v0_x;
    }
    else
    {
      v0_x = -180 - v0_x;
    }
    v0_y = anglemod(v0_y + 180);

    v1 = '0 0 0';
    v1_y = anglemod(v0_y - stemp.angles_y);
    if (v1_y > 180)   v1_y = v1_y - 360;
    v1_x = v0_x - stemp.angles_x;
  }

  v2 = '0 0 0';
  if (v1_x < 0) v2_x = 0 - sp_x;
  if (v1_x > 0) v2_x = sp_x;
  if (fabs(v1_x) < frametime * sp_x)
  {
    v2_x = 0;
    stemp.angles_x = v0_x;
  }
  v2_y = v1_y * 5;
  if (v2_y < 0 - sp_y) v2_y = 0 - sp_y;
  if (v2_y > sp_y) v2_y = sp_y;
  if (fabs(v1_y) < frametime * fabs(v2_y))
  {
    v2_y = 0;
    stemp.angles_y = v0_y;
  }
  else
    stemp.angles_y = anglemod(stemp.angles_y);

  v1_z = 0 - v2_y - stemp.angles_z;

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
  if (self.lefty)
    v2_z = self.lefty * 200;
  if (fabs(v1_z) < frametime * fabs(v2_z))
  {
    v2_z = 0;
    stemp.angles_z = 0 - v2_y;
  }

  if (self.lefty)
  {
    makevectors('0 -1 0' * stemp.angles_z);
    v2_y = v_forward_y * sp_y;
  }

  if (stemp.speed < sp_st)
  {
    if (fabs(stemp.angles_x) < 90)
      v2_x = v2_x - sp_st - 100 + stemp.speed;
    else
      v2_x = v2_x + sp_st + 100 - stemp.speed;
  }

  stemp.avelocity = v2;
};

void (float sp_x, float sp_y, float sp_st) Steer_plane =
{
  local entity stemp;
  local vector v0;
  local float tmp;

  stemp = self.enemy;

  if (pointcontents (stemp.origin) < CONTENT_EMPTY)
    T_Damage(stemp,stemp,stemp,1000);

//  if (stemp.angles_x < -180) stemp.angles_x = stemp.angles_x + 360;
//  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;

  stemp.flags = stemp.flags - (stemp.flags & FL_ONGROUND);
  self.flags = self.flags - (self.flags & FL_ONGROUND);
  if (stemp.landed && stemp.health < 1)
    stemp.landed = 0;
  if (stemp.health > 0)
  {
    v0_x = self.v_angle_x;
    if (self.toyview == 4)
      v0_x = 0;
    v0_x = 0 - v0_x;

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

    Turn_plane (v0, sp_x, sp_y, sp_st);
    if (stemp.landed)
    {
      stemp.avelocity = '0 1 0' * stemp.avelocity_y;
      stemp.angles = '0 1 0' * stemp.angles_y;
    }
  }
  if (stemp.landed)
  {
    if (stemp.speed > sp_st && self.v_angle_x < 0) // (stemp.thru > 2 || stemp.skin > 0) && 
    {
      stemp.groundentity = world;
      stemp.landed = 0;
    }
    else
    {
      stemp.origin_z = stemp.groundentity.origin_z + stemp.groundentity.maxs_z + 16;
      stemp.angles_z = stemp.angles_x = 0;
      stemp.velocity_z = 0;
      traceline(stemp.origin, stemp.origin + '0 0 -64', FALSE, self);
      if (trace_ent.classname != "func_runway")
      {
        stemp.groundentity = world;
        stemp.landed = 0;
      } 
    }
  }
  tmp = stemp.health * 100 / stemp.max_health;
  if (tmp<1) tmp=1;
  if (tmp<self.health)
    self.dmg_take = self.health - tmp;
  self.health = tmp;
};

void () Check_startlanded =
{
  local entity stemp;

  stemp = self.enemy;
  traceline(stemp.origin, stemp.origin + '0 0 -128', FALSE, self);
  if (trace_ent.classname == "func_runway")
  {
    stemp.groundentity = trace_ent;
    stemp.landed = 1;
    stemp.speed = 0;
    stemp.thru = 0;
    stemp.origin_z = stemp.groundentity.origin_z + stemp.groundentity.maxs_z + 16;
    stemp.angles_z = stemp.angles_x = 0;
    stemp.velocity = '0 0 0';
  } 
};

void (float tsp, float asp, float dsp) setplanespeed =
{
  local entity stemp;
  stemp = self.enemy;

  if (stemp.landed)
  {
    tsp = tsp * 0.75;
    dsp = dsp * 2;
  }
  else
    asp = asp * 2;

  if (stemp.speed >= tsp)
  {
    stemp.speed = stemp.speed - dsp;
    if (stemp.speed < tsp)
      stemp.speed = tsp;
  }
  else
  {
    stemp.speed = stemp.speed + asp;
    if (stemp.speed > tsp)
      stemp.speed = tsp;
   }
};
