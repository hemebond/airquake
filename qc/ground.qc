void(float num_bubbles) DeathBubbles;

void() gv_tilt =
{
  local vector v1, v2, v3, v4;
  local float l1, l2, l3, l4;
  local float r1, r2, w1, w2;
  local entity vehicle;

  vehicle = self.enemy;

  v1 = vehicle.angles_y * '0 1 0';
  makevectors(v1);

  v1 = vehicle.origin + (8 * v_forward) - (8 * v_right);
  v2 = vehicle.origin + (8 * v_forward) + (8 * v_right);
  v3 = vehicle.origin - (8 * v_forward) - (8 * v_right);
  v4 = vehicle.origin - (8 * v_forward) + (8 * v_right);

  traceline (v1 - 16 * v_up, v1 - 80 * v_up, TRUE, vehicle);
  l1 = trace_fraction;
  traceline (v2 - 16 * v_up, v2 - 80 * v_up, TRUE, vehicle);
  l2 = trace_fraction;
  traceline (v3 - 16 * v_up, v3 - 80 * v_up, TRUE, vehicle);
  l3 = trace_fraction;
  traceline (v4 - 16 * v_up, v4 - 80 * v_up, TRUE, vehicle);
  l4 = trace_fraction;

  if (l1 == 1)
    if (l2 == 1)
      if (l3 == 1)
        if (l4 == 1)
        {
          if (vehicle.angles_x > 0 && vehicle.angles_x < 180)
            vehicle.angles_x = vehicle.angles_x - 5;
          return;
        }

  r1 = l1 - l2 + l3 - l4;
  r2 = l1 - l3 + l2 - l4;

  v1 = '0 0.5 0';
  v1_x = r1;
  v1_z = r2;
  v1 = normalize(v1);

  v2_x = v1_x;
  v2_y = v1_z;
  v2_z = v1_y;

  v3 = v_up * v2_z + v_forward * v2_y - v_right * v2_x;
  v3 = normalize (v3);

  if (!w1)
  {
    w2 = (4 - l1 - l2 -l3 -l4) * 64;
    if (w2 > w1)
      w1 = w2;
  }

  makevectors(vehicle.angles);

  v2 = vectoangles(v1);
  v3 = '0 2 0';
  v3_x = anglemod(0 - v2_x);
  v3_y = vehicle.angles_y;
  v3_z = anglemod(v2_y - 90);

  v4 = v3 - vehicle.angles;
  l1 = anglemod(v4_x);
  if (l1 > 180)
    l1 = l1 - 360;
  l2 = anglemod(v4_z);
  if (l2 > 180)
    l2 = l2 - 360;

  vehicle.avelocity_x = l1 * 4;
  vehicle.avelocity_z = l2 * 4;
};                      

void(float fac) hv_tilt =
{
  local vector v1, v2, v3, v4;
  local float l1, l2, l3, l4;
  local float r1, r2, w1, w2;
  local entity vehicle;

  vehicle = self.enemy;

//  dprint(ftos(fac));
//dprint("\n");

  v1 = vehicle.angles_y * '0 1 0';
  makevectors(v1);

  v1 = vehicle.origin + (8 * v_forward) - (8 * v_right);
  v2 = vehicle.origin + (8 * v_forward) + (8 * v_right);
  v3 = vehicle.origin - (8 * v_forward) - (8 * v_right);
  v4 = vehicle.origin - (8 * v_forward) + (8 * v_right);

  w1 = fac * 64;
  traceline (v1 - 16 * v_up, v1 - (16 + w1) * v_up, TRUE, vehicle);
  l1 = trace_fraction;
  if (trace_inwater) l1 = 0.5;
  traceline (v2 - 16 * v_up, v2 - (16 + w1) * v_up, TRUE, vehicle);
  l2 = trace_fraction;
  if (trace_inwater) l2 = 0.5;
  traceline (v3 - 16 * v_up, v3 - (16 + w1) * v_up, TRUE, vehicle);
  l3 = trace_fraction;
  if (trace_inwater) l3 = 0.5;
  traceline (v4 - 16 * v_up, v4 - (16 + w1) * v_up, TRUE, vehicle);
  l4 = trace_fraction;
  if (trace_inwater) l4 = 0.5;

  if (l1 == 1)
    if (l2 == 1)
      if (l3 == 1)
        if (l4 == 1)
        {
          if (vehicle.angles_x > 0 && vehicle.angles_x < 180)
            vehicle.angles_x = vehicle.angles_x - 5;
          return;
        }

  r1 = l1 - l2 + l3 - l4;
  r2 = l1 - l3 + l2 - l4;

  v1 = '0 0.5 0' * (1 / fac);
  v1_x = r1;
  v1_z = r2;
  v1 = normalize(v1);

  v2_x = v1_x;
  v2_y = v1_z;
  v2_z = v1_y;

  v3 = v_up * v2_z + v_forward * v2_y - v_right * v2_x;
  v3 = normalize (v3);

  if (!w1)
  {
    w2 = (4 - l1 - l2 -l3 -l4) * 64;
    if (w2 > w1)
      w1 = w2;
  }

  makevectors(vehicle.angles);

  v2 = vectoangles(v1);
  v3 = '0 2 0';
  v3_x = anglemod(0 - v2_x);
  v3_y = vehicle.angles_y;
  v3_z = anglemod(v2_y - 90);

  if (self.lefty)
  {
    v3_z = v3_z + self.lefty*vehicle.thru*8;
  }

  v4 = v3 - vehicle.angles;
  l1 = anglemod(v4_x);
  if (l1 > 180)
    l1 = l1 - 360;
  l2 = anglemod(v4_z);
  if (l2 > 180)
    l2 = l2 - 360;

  vehicle.avelocity_x = l1 * 4;
  vehicle.avelocity_z = l2 * 4;
};                      

void (vector v0, float sp_x, float sp_y) Turn_groundveh =
{
  local entity stemp;
  local vector v1,v2,v3,v_a;
  local float f1,f2,f3;

  stemp = self.enemy;

  v1 = '0 0 0';
  v1_y = anglemod(v0_y - stemp.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;

  v2_y = 0; //v1_y * 5;
  if (v1_y < 0) v2_y = 0 - sp_y;
  if (v1_y > 0) v2_y = sp_y;
  f1 = fabs(v1_y); f2 = fabs(v2_y) * frametime;
  if (f1 < f2)
  {
    v2_y = 0;
    stemp.angles_y = v0_y;
  }
	
  if (self.lefty)
  {
    v2_y = 0 - self.lefty * sp_y;
  }

  stemp.angles_x = anglemod(stemp.angles_x);
  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;
  stemp.angles_y = anglemod(stemp.angles_y);
  if (stemp.angles_y > 180) stemp.angles_y = stemp.angles_y - 360;
  stemp.angles_z = anglemod(stemp.angles_z);
  if (stemp.angles_z > 180) stemp.angles_z = stemp.angles_z - 360;

  stemp.avelocity_y = v2_y;

  v_a = self.v_angle;
  if (self.oldenemy.toyview & 1)
  {
    if (self.oldenemy.tur1)
    {
      v1 = self.oldenemy.tur1.origin + (self.oldenemy.tur1.mins + self.oldenemy.tur1.maxs) * 0.5;
      v_a = v0 = vectoangles(v1 - self.enemy.origin);
    }
    else
      sp_x = 0;
  }

  if (stemp.movetarget)
  {
    v0_y = stemp.angles_y - v_a_y;
    if (v0_y > 180) v0_y = v0_y - 360;
    if (!self.flags & FL_ONGROUND)  v0_y = 0;
    v1_y = v0_y - stemp.toyview;
    if (v1_y < 0) v1_y = v1_y + 360;
    if (v1_y > 180) v1_y = v1_y - 360;
    v2_y = 0; 
    if (v1_y < 0) v2_y = 0 - sp_x;
    if (v1_y > 0) v2_y = sp_x;
    f1 = fabs(v1_y); f2 = fabs(v2_y) * frametime;
    if (f1 < f2)
    {
      v2_y = 0;
      stemp.toyview = v0_y;
    }
    else
      stemp.toyview = stemp.toyview + v2_y * frametime;

    if (stemp.toyview == 0)
      self.enemy.movetarget.angles = stemp.angles;
    else
    {
      makevectors('0 1 0' * stemp.toyview);
      f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
      v3 = stemp.angles; v3_x = 0 - v3_x;
      makevectors(v3);
      v3 = v_forward * f2 + v_right * f1;
      v3 = vectoangles (v3);
      self.enemy.movetarget.angles = v3;

      f3 = self.enemy.movetarget.angles_y - stemp.angles_y;
      if (f3 < 0) f3 = f3 + 360;
      if (f3 > 180) f3 = f3 - 360;
      self.enemy.movetarget.angles_z = stemp.angles_z * f2 + stemp.angles_x * f1;
    }
    stemp = stemp.movetarget;
  }

  if (self.enemy.oldenemy)
  {
    v0_x = v0_x - stemp.angles_x;
    if (v0_x < 0) v0_x = v0_x + 360;
    if (v0_x > 180) v0_x = v0_x - 360;

    if (v0_x > 80) v0_x = 80;
    if (v0_x < -10) v0_x = -10;
    if (!self.flags & FL_ONGROUND)  v0_x = 0;
    v1_x = v0_x - stemp.toyview;
    v2_x = 0; 
    if (v1_x < 0) v2_x = 0 - sp_x;
    if (v1_x > 0) v2_x = sp_x;
    f1 = fabs(v1_x); f2 = fabs(v2_x) * frametime;
    if (f1 < f2)
    {
      v2_x = 0;
      stemp.toyview = v0_x;
    }
    else
      stemp.toyview = stemp.toyview + v2_x * frametime;

    if (stemp.toyview == 0)
    {
      self.enemy.oldenemy.angles = stemp.angles;
      return;
    }

    makevectors('0 1 0' * stemp.toyview);
    f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
    v3 = stemp.angles; v3_x = 0 - v3_x;
    makevectors(v3);
    v3 = v_forward * f2 + v_up * f1;
    v3 = vectoangles (v3);

    self.enemy.oldenemy.angles = v3;
    f3 = self.enemy.oldenemy.angles_y - stemp.angles_y;
    if (f3 < 0) f3 = f3 + 360;
    if (f3 > 180) f3 = f3 - 360;
    self.enemy.oldenemy.angles_z = stemp.angles_z * f2 - f3 * f1;
  }
};

void (float sp_x, float sp_y) Steer_groundveh =
{
  local entity stemp;
  local vector v0;
  local float tmp;

  stemp = self.enemy;
  if (stemp.owner != self)
    return;

  if (pointcontents(stemp.origin) < CONTENT_EMPTY)
  {
    if (self.pain_finished < time)
    {
      if (self.air_finished < time)
      {
        if (self.style != 9)
          T_Damage(stemp,stemp,stemp,50);
        else
          T_Damage(stemp,stemp,stemp,10);
      }
      self.pain_finished = time + 1;
      DeathBubbles(1);
    }
  }
  else
  {
    if (self.style == 9)
      self.air_finished = time + 10;
  }

  if (stemp.angles_x < -180) stemp.angles_x = stemp.angles_x + 360;
  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;

  stemp.flags = stemp.flags - (stemp.flags & FL_ONGROUND);
  if (stemp.health > 0)
  {
    v0_x = self.v_angle_x;
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

    if (!self.flags & FL_ONGROUND)
      v0_y = stemp.angles_y;
    Turn_groundveh (v0, sp_x, sp_y);
  }
  gv_tilt ();
  tmp = stemp.health * 100 / stemp.max_health;
  if (tmp<1) tmp=1;
  if (tmp<self.health)
    self.dmg_take = self.health - tmp;
  self.health = tmp;

  setorigin(self.enemy, self.origin);
  if (self.enemy.oldenemy)
    setorigin(self.enemy.oldenemy, self.origin);
  if (self.enemy.movetarget)
    setorigin(self.enemy.movetarget, self.origin);
};

void (vector v0, float sp_x, float sp_y) Turn_hover =
{
  local entity stemp;
  local vector v1,v2,v3,v_a;
  local float f1,f2,f3,lck;

  stemp = self.enemy;

  v1 = '0 0 0';
  v1_y = anglemod(v0_y - stemp.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;

  v2_y = 0; //v1_y * 5;
  if (v1_y < 0) v2_y = 0 - sp_y;
  if (v1_y > 0) v2_y = sp_y;
  f1 = fabs(v1_y); f2 = fabs(v2_y) * frametime;
  if (f1 < f2)
  {
    v2_y = 0;
    stemp.angles_y = v0_y;
  }

  stemp.angles_x = anglemod(stemp.angles_x);
  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;
  stemp.angles_y = anglemod(stemp.angles_y);
  if (stemp.angles_y > 180) stemp.angles_y = stemp.angles_y - 360;
  stemp.angles_z = anglemod(stemp.angles_z);
  if (stemp.angles_z > 180) stemp.angles_z = stemp.angles_z - 360;

  stemp.avelocity_y = v2_y;

  v_a = self.v_angle;
  if (self.oldenemy.toyview & 1)
  {
    if (self.oldenemy.tur1)
    {
      v1 = self.oldenemy.tur1.origin + (self.oldenemy.tur1.mins + self.oldenemy.tur1.maxs) * 0.5;
      v_a = v0 = vectoangles(v1 - self.enemy.origin);
    }
    else
      sp_x = 0;
  }

  lck = 0;
  if (fabs(stemp.angles_x) > 45)
    lck = 1;
  if (fabs(stemp.angles_z) > 45)
    lck = 1;

  if (stemp.movetarget)
  {
    v0_y = stemp.angles_y - v_a_y;
    if (v0_y > 180) v0_y = v0_y - 360;
    if (lck)
      v0_y = 0;
    v1_y = v0_y - stemp.toyview;
    if (v1_y < 0) v1_y = v1_y + 360;
    if (v1_y > 180) v1_y = v1_y - 360;
    v2_y = 0; 
    if (v1_y < 0) v2_y = 0 - sp_x;
    if (v1_y > 0) v2_y = sp_x;
    f1 = fabs(v1_y); f2 = fabs(v2_y) * frametime;
    if (f1 < f2)
    {
      v2_y = 0;
      stemp.toyview = v0_y;
    }
    else
      stemp.toyview = stemp.toyview + v2_y * frametime;

    if (stemp.toyview == 0)
      self.enemy.movetarget.angles = stemp.angles;
    else
    {
      makevectors('0 1 0' * stemp.toyview);
      f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
      v3 = stemp.angles; v3_x = 0 - v3_x;
      makevectors(v3);
      v3 = v_forward * f2 + v_right * f1;
      v3 = vectoangles (v3);
      self.enemy.movetarget.angles = v3;

      f3 = self.enemy.movetarget.angles_y - stemp.angles_y;
      if (f3 < 0) f3 = f3 + 360;
      if (f3 > 180) f3 = f3 - 360;
      self.enemy.movetarget.angles_z = stemp.angles_z * f2 + stemp.angles_x * f1;
    }
    stemp = stemp.movetarget;
  }

  if (self.enemy.oldenemy)
  {
    v0_x = v0_x - stemp.angles_x;
    if (v0_x < 0) v0_x = v0_x + 360;
    if (v0_x > 180) v0_x = v0_x - 360;

    if (v0_x > 80) v0_x = 80;
    if (v0_x < -10) v0_x = -10;
    if (lck)
      v0_x = 0;
    v1_x = v0_x - stemp.toyview;
    v2_x = 0; 
    if (v1_x < 0) v2_x = 0 - sp_x;
    if (v1_x > 0) v2_x = sp_x;
    f1 = fabs(v1_x); f2 = fabs(v2_x) * frametime;
    if (f1 < f2)
    {
      v2_x = 0;
      stemp.toyview = v0_x;
    }
    else
      stemp.toyview = stemp.toyview + v2_x * frametime;

    if (stemp.toyview == 0)
    {
      self.enemy.oldenemy.angles = stemp.angles;
      return;
    }

    makevectors('0 1 0' * stemp.toyview);
    f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
    v3 = stemp.angles; v3_x = 0 - v3_x;
    makevectors(v3);
    v3 = v_forward * f2 + v_up * f1;
    v3 = vectoangles (v3);

    self.enemy.oldenemy.angles = v3;
    f3 = self.enemy.oldenemy.angles_y - stemp.angles_y;
    if (f3 < 0) f3 = f3 + 360;
    if (f3 > 180) f3 = f3 - 360;
    self.enemy.oldenemy.angles_z = stemp.angles_z * f2 - f3 * f1;
  }
};

void (float sp_x, float sp_y) Steer_hover =
{
  local entity stemp;
  local vector v0;
  local float tmp;

  stemp = self.enemy;
  if (stemp.owner != self)
    return;

  if (pointcontents(self.enemy.origin) < CONTENT_EMPTY && self.pain_finished < time)
  {
    T_Damage(stemp,stemp,stemp,50);
    self.pain_finished = time + 1;
  }

  if (stemp.angles_x < -180) stemp.angles_x = stemp.angles_x + 360;
  if (stemp.angles_x > 180) stemp.angles_x = stemp.angles_x - 360;

  stemp.flags = stemp.flags - (stemp.flags & FL_ONGROUND);
  if (stemp.health > 0)
  {
    v0_x = self.v_angle_x;
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

    Turn_hover (v0, sp_x, sp_y);
  }
  tmp = fabs(stemp.thru);
  hv_tilt (0.5 + tmp);
  tmp = stemp.health * 100 / stemp.max_health;
  if (tmp<1) tmp=1;
  if (tmp<self.health)
    self.dmg_take = self.health - tmp;
  self.health = tmp;

//  setorigin(self, self.oldenemy.origin);
};

vector(float minim, float maxdist) GV_aim =
{
  local entity e, re;
  local float f1,f2,flg;
  local vector v1,v2,org;

  flg = 0;
  if (maxdist < 0)
  {
    flg = flg + 1;
    maxdist = 0 - maxdist;
  }

  re = world;
  makevectors (self.enemy.oldenemy.angles);
  v1 = v_forward;
  v1_z = 0 - v1_z;
  e = findradius (self.enemy.origin, maxdist);
  while (e)
  {
    org = e.origin + (e.mins + e.maxs)*0.5;
    if (e.takedamage > 1 && (e.movetype != MOVETYPE_FLY || (flg & 1) == 0 ) )
    {
      traceline (org, self.enemy.origin, TRUE, world);
      if (e.model == "progs/plane3.mdl")
        if (e.skin == 1 && random() < 0.5)
          trace_fraction = 0;
      if (e.solid == SOLID_BSP)
      {
        f1 = vlen(org - self.enemy.origin);
        f2 = vlen(e.size);
        if (f2 > f1)
          trace_fraction = 0;
      }
      else if (teamplay)
      {
        if ((temp1&8)>0 && e.ts == self.ts)
          trace_fraction = 0;
        else if (e.ts == self.ts && re.ts != self.ts && re != world)
          trace_fraction = 0;
      }
      if (deathmatch && !teamplay)
      {
        if (e.owner.classname != "player")
          trace_fraction = 0;
      }
      if (trace_inopen && trace_inwater)
        trace_fraction = 0;
      if (trace_fraction == 1)
      {
        v2 = normalize (org - self.enemy.origin);
        f1 = v1 * v2;
        if (f1 > minim)
        {
          minim = f1;
          re = e;
        }
      }
    }
    e = e.chain;
  }

  if (re != world)
  {
    org = re.origin + (re.mins + re.maxs)*0.5;
    v1 = normalize (org - self.enemy.origin);  
  }
  self.enemy.trigger_field = re;
  return (v1);
};

void() GV_Die =
{
  self.owner.takedamage = 2;
  T_Damage(self.owner, self.owner, self.owner, 1000);
  self.takedamage = 0;
  if (self.oldenemy)
    remove(self.oldenemy);
  if (self.movetarget)
    remove(self.movetarget);
  AC_Explode();
};

