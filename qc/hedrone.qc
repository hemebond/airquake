void(vector v0) turn_hedrone;
void () hedrone_run;

vector(float minim, float maxdist) Drone_aim =
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
  f2 = minim;
  makevectors (self.angles);
  v1 = v_forward;
  v1_z = 0 - v1_z;
  e = findradius (self.origin, maxdist);
  while (e)
  {
    org = e.origin + (e.mins + e.maxs)*0.5;
    if (e.health && (e.movetype != MOVETYPE_FLY || (flg & 1) == 0 ) )
    {
      traceline (org, self.enemy.origin, TRUE, world);
      //if (e.model == f117)
      //  if (e.skin == 1 && random() < 0.5)
      //    trace_fraction = 0;
      if (trace_fraction == 1)
      {
        v2 = normalize (org - self.origin);
        f1 = v1 * v2;
        if (f1 > f2)
        {
          f2 = f1;
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
  self.aiment = re;
  return (v1);
};

void() he_movetogoal =
{
  local vector v0, v1,v2,v3;
  local float tmp, tmp2;
  local entity e, e2;

  if (!self.goalentity)
    return;

  v1 = self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5;

  e = findradius(self.origin, 256);
  tmp = 256;
  while (e)
  {
    if (e.takedamage && e != self)
    {
      tmp2 = vlen(self.origin - e.origin);
      if (tmp2 < tmp)
      {
        tmp = tmp2;
        v1 = self.origin + normalize(self.origin - e.origin) * 256;
        if (e.classname == "monster_helo" && e.movetarget == self.movetarget)
        {
          self.movetarget = self.goalentity = find(world, targetname, self.goalentity.target);
        }
      }
    }
    e = e.chain;
  }

  v0 = vectoangles(v1 - self.origin);

  tmp = 0;
  traceline(self.origin + '-32 -32 -32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '32 -32 -32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '-32 32 -32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '32 32 -32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '-32 -32 32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '32 -32 32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '-32 32 32', v1, TRUE, world);
  tmp = tmp + trace_fraction;
  traceline(self.origin + '32 32 32', v1, TRUE, world);
  tmp = tmp + trace_fraction;

  if (tmp < 8)
  {
    if (self.goalentity != self.enemy)  // Find a way back to the route
    {
      e = self.movetarget; e2 = e;
      e = find (world, targetname, e.target);
      tmp = 0;
      while (e != e2 && tmp < 8)
      {
        tmp = tmp + 1;
        if (e != world && visible(e))
        {
          self.goalentity = self.movetarget = e;
          e2 = e;
        }
        else
        {
          e = find (world, targetname, e.target);
          if (e == world)
            e = find(world, targetname, self.target);
        }
      }
    }
    if (self.lefty < 0)
      self.lefty = (random() > 0.5);
    if (time > self.search_time)
    {
      self.lefty = 1 - self.lefty;
      self.search_time = time + 30;
    }
    if (self.lefty)
      v0_y = anglemod (v0_y + 90);
    else
      v0_y = anglemod (v0_y - 90);
  }
  else
  {
    self.lefty = -1;
  }
  self.thru = 2;

  v2 = v1 - self.origin; v2_z = 0;
  tmp2 = vlen(v2);

  if (self.origin_z - v1_z > tmp2 * 1)
    self.thru = 1;
  if (v1_z - self.origin_z > tmp2 * 0.5)
    self.thru = 3;
  if (self.origin_z - v1_z > tmp2 * 2 && fabs(self.origin_z - v1_z) > 128)
    self.thru = 0;
  if (v1_z - self.origin_z > tmp2 * 1)
    self.thru = 4;

  v2 = v0; 
  v0_x = 0; v0_z = 0;

  v1 = v2;
  v2 = v1 - self.angles;
  v2_x = 0; v2_z = 0;

  if (self.goalentity == self.enemy)
  {
    if (tmp2 < 256)
    {
      if (fabs(self.origin_z - self.enemy.origin_z) < 256 - tmp2)
      {
        if (self.origin_z > self.enemy.origin_z)
          self.thru = 4;
        else
          self.thru = 0;
      }
      else
      {
        if (self.origin_z > self.enemy.origin_z)
          self.thru = 0;
        else
          self.thru = 4;
      }
      tmp2 = tmp2 * 0.4 - 57;
    }
    else
      tmp2 = 45;
  }
  else
  {
    if (tmp2 < 256)
      tmp2 = 6 + tmp2 * 0.15;
    else
      tmp2 = 45;
    tmp = anglemod (v0_y - self.angles_y);
    if (tmp > 180) tmp = tmp - 360;
    if (fabs(tmp) > 12)
      tmp2 = 0;
  }

  makevectors (v2);
  tmp = v_forward_x;
  v0_x = v0_x - tmp2 * tmp;

  tmp = v_forward_y;
  v0_z = v0_z - tmp2 * tmp;

  v1 = self.angles_y * '0 1 0';
  makevectors(v1);
  v3 = self.origin + self.velocity * 0.8;
  if (self.goalentity == self.enemy)
    tmp = 128;
  else
    tmp = 32;
  if (self.goalentity == self.enemy || vlen(self.goalentity.origin - self.origin) > 64)
  {
    traceline(self.origin, v3 + v_forward * tmp, TRUE, world);
    if (trace_fraction < 1) v0_x = 45;
    traceline(self.origin, v3 - v_forward * tmp, TRUE, world);
    if (trace_fraction < 1) v0_x = -45;
    traceline(self.origin, v3 + v_right * tmp, TRUE, world);
    if (trace_fraction < 1) v0_z = -45;
    traceline(self.origin, v3 - v_right * tmp, TRUE, world);
    if (trace_fraction < 1) v0_z = 45;
    traceline(self.origin, v3 + v_up * tmp, TRUE, world);
    if (trace_fraction < 1)  self.thru = 0;
    traceline(self.origin, v3 - v_up * tmp, TRUE, world);
    if (trace_fraction < 1) self.thru = 4;
  }

  turn_hedrone(v0);
};

void(vector v0) turn_hedrone =
{
  local vector v1,v2,v3;

  if (self.health > 0 && !(self.flags & FL_ONGROUND))
  {
  if (v0_x > 45) v0_x = 45;
  if (v0_x < -45) v0_x = -45;

  v1 = '0 0 0';
  v1_y = anglemod(v0_y - self.angles_y);
  if (v1_y > 180)   v1_y = v1_y - 360;
  v1_x = v0_x - self.angles_x;

  v2 = '0 0 0';
  if (v1_x < 0) v2_x = -90;
  if (v1_x > 0) v2_x = 90;
  if (fabs(v1_x) < 9)
  {
    v2_x = 0;
    self.angles_x = v0_x;
  }
  if (v1_y < 0) v2_y = -110;
  if (v1_y > 0) v2_y = 110;
  if (fabs(v1_y) < 11)
  {
    v2_y = 0;
    self.angles_y = v0_y;
  }
  else
    self.angles_y = anglemod(self.angles_y);

  v0_z = v0_z - v2_y * fabs(self.angles_x) * 0.01;
  if (v0_z < -45) v0_z = -45;
  if (v0_z > 45) v0_z = 45;
    v1_z = v0_z - self.angles_z;

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
      self.angles_z = 0 - v2_y * 0.3;
  }
  self.avelocity = v2;
  }

  if (self.flags & FL_ONGROUND)
  {
    if (self.groundentity.classname != "func_runway" || self.thru > 2)
    {
      self.flags = self.flags - FL_ONGROUND;
      self.groundentity = world;
      self.velocity_z = self.velocity_z + 200;
    }
  }

  if (self.health < 40 && self.model == "progs/helo1.mdl")
    setmodel(self, "progs/helo1b.mdl");

  if (self.health < 1)
  {
    self.effects = 4;
  }
  else
    self.effects = 0;

  v3 = self.angles;
  v3_x = 0 - v3_x;
  makevectors(v3);
  if (self.thru != 2 || self.health < 1)
  {
    v3 = v_up * 20 * self.thru - '0 0 40';
  }
  else
  {
    v3 = v_up * (20 * self.thru / v_up_z) - '0 0 40';
  }

  if (!self.flags & FL_ONGROUND)
    self.velocity = self.velocity * 0.8 + v3;

  if (sky_z && self.origin_z > sky_z)
  {
    if (self.velocity_z > 0)
    {
      self.origin_z = sky_z;
      self.velocity_z = 0;
    }
  }
  Check_minsmaxs (self);
};

void() T_hedroneTouch =  // Crash
{
  local float damg, temp;
  local entity stemp,stemp2;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
  if (other != world)
  {
    if (!other.takedamage && other.solid != SOLID_BSP)
      return;
  }

  if (other.classname == "func_runway")  // works?
  {
    if (fabs(self.angles_x) + fabs(self.angles_z) < 20)
    {
      self.flags = self.flags | FL_ONGROUND;
      self.groundentity = other;
      self.angles_x = 0;
      self.angles_z = 0;
      self.avelocity = '0 0 0';
      self.velocity = '0 0 0';
      self.origin_z = other.origin_z + other.maxs_z + 16;
      return;
    }
  }

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

	// Tei
	//WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	//WriteByte (MSG_BROADCAST, TE_EXPLOSIONSMALL3);
	//WriteCoord (MSG_BROADCAST, self.origin_x);
	//WriteCoord (MSG_BROADCAST, self.origin_y);
	//WriteCoord (MSG_BROADCAST, self.origin_z);
	// Tei


//  self.health = 0;
  T_Damage(other,self,self,240);

  if (other == world || other.health > 0 || (self.health < 1 && time > self.pain_finished) )
  {  // Lethal crashs  (explodes)
    self.origin = self.origin - normalize(self.velocity) * 8;
    T_RadiusDamage (self, self, 160, other);
    if (self.health > 0)
    {
      bprint ("Chopper Drone crashed into ");
      if (other!=world)
      {
        bprint (other.netname);
        bprint ("\n");
      }
      else
      {
        bprint ("the ground\n");
      }
    }
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    T_Damage(self,self,self,1000);   
    self.think = BecomeExplosion;
    self.nextthink = time + 0.1;
  }
  else
  {  // Crashs that kill you more painfully. :)
    if (self.health > 0)
    {
      self.pain_finished = time + 0.3;
      bprint ("Chopper Drone crashed into ");
      if (other!=world)
      {
        bprint (other.netname);
        bprint ("\n");
      }
    }
    T_Damage(self,self,self,1000);   
    self.th_die = SUB_Null;

    if (self.model == "progs/helo1.mdl")
      setmodel(self, "progs/helo1b.mdl");

    self.touch = T_hedroneTouch;
    HE_Fall ();
  }
};

void() hedrone_die =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

  self.pain_finished = time + 0.3;

  /* 
 if (self.model == "progs/helo1.mdl")
    setmodel(self, "progs/helo1b.mdl");
 */
  //FIXME

  self.touch = T_hedroneTouch;
  HE_Fall ();
};

void() hedrone_stand =
{
  local vector v0, v1, v2, v3;
  local float a, b, oth;

  if (time > self.fly_sound)
  {
    sound (self, CHAN_BODY, "engines/chopper.wav", self.thru * 0.2 + 0.2, ATTN_NORM);
    self.fly_sound = time + 1;
  }
  oth = self.thru;
  self.thru = 2;

  v0 = self.angles;
  v0_x = 0 - v0_x;
  makevectors(v0);
  v0 = '0 0 0';
  traceline(self.origin, self.origin + v_forward * 128, TRUE, world);
  v0_x = v0_x + 45 - (trace_fraction * 45);
  traceline(self.origin, self.origin - v_forward * 128, TRUE, world);
  v0_x = v0_x - 45 + (trace_fraction * 45);
  traceline(self.origin, self.origin + v_right * 128, TRUE, world);
  v0_z = v0_z - 45 + (trace_fraction * 45);
  traceline(self.origin, self.origin - v_right * 128, TRUE, world);
  v0_z = v0_z + 45 - (trace_fraction * 45);
  traceline(self.origin, self.origin + v_up * 128, TRUE, world);
  if (trace_fraction < 1 || self.velocity_z > 40)  self.thru = 0;
  traceline(self.origin, self.origin - v_up * 128, TRUE, world);
  if (trace_fraction < 1 || self.velocity_z < -40) self.thru = 4;

  turn_hedrone(v0);

  if (self.thru != oth) self.fly_sound = time;

  if (FindTarget ())
  {
    self.think = hedrone_run ;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = hedrone_stand;
  self.nextthink = time + 0.1;
};

void() hedrone_walk =
{
  local vector v0,v1,v2,v3;
  local float oth;

  oth = self.thru;

  if (time > self.fly_sound)
  {
    sound (self, CHAN_BODY, "engines/chopper.wav", self.thru * 0.2 + 0.2, ATTN_NORM);
    self.fly_sound = time + 1;
  }

  self.enemy = world;
  self.goalentity = self.movetarget;

  if (!self.goalentity)
  {
    turn_hedrone(self.angles_y * '0 1 0');
    self.think = hedrone_stand;
    self.nextthink = time + 0.1;
    return;
  }
  he_movetogoal ();

  if (self.thru != oth) self.fly_sound = time;

  if (FindTarget ())
  {
    self.think = hedrone_run ;
    self.nextthink = time + 0.1;
    return;
  }

  self.think = hedrone_walk;
  self.nextthink = time + 0.1;
};

void() hedrone_run =
{
  local vector v0,v1,v2,v3;
  local float tmp;
  local float oth;

  oth = self.thru;

  if (time > self.fly_sound)
  {
    sound (self, CHAN_BODY, "engines/chopper.wav", self.thru * 0.2 + 0.2, ATTN_NORM);
    self.fly_sound = time + 1;
  }

  if (self.goalentity.health < 1 || self.goalentity.takedamage < 1)
    self.goalentity = world;

  if (!visible(self.goalentity) && self.search_time < time)
    self.goalentity = world;

  if (!self.goalentity)
  {
    turn_hedrone(self.angles_y * '0 1 0');
    self.think = hedrone_walk;
    self.nextthink = time + 0.1;
    return;
  }

  v1 = self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5;
  if (self.attack_state == 0)
  {
    he_movetogoal ();
    if (self.lefty < 0)
      if (random() < 0.1)
      {
        tmp = random();
        if (vlen(v1 - self.origin) < 500)
        {
          if (tmp < 0.6) self.attack_state = 1;
          else self.attack_state = 2;
        }
        else if (vlen(v1 - self.origin) < 1000)
        {
          if (tmp < 0.6) self.attack_state = 2;
          else self.attack_state = 3;
        }
        else
          self.attack_state = 3;
      }
  }
  else
  {
    if (self.attack_state == 1)      // plas
      v2 = v1 + self.goalentity.velocity * 0.00083;
    else if (self.attack_state == 2)         // rock
      v2 = v1 + self.goalentity.velocity * 0.001;
    else if (self.attack_state == 3)         // msl
      v2 = v1;
    v0 = vectoangles(v2 - self.origin);
    if (v0_x > 180) v0_x = v0_x - 360;
    if (v0_x > 45) { v0_x = 0; self.thru = 4; }
    if (v0_x < -45) { v0_x = 0; self.thru = 0; }

    v3 = self.angles_y * '0 1 0'; // v3_x = 0 - v3_x;
    makevectors(v3);
    v3 = self.origin + self.velocity * 0.5;

    traceline(self.origin, v3 + v_forward * 128, FALSE, self);
    if (trace_fraction < 1) { v0_x = 45; self.attack_state = 0; }
    traceline(self.origin, v3 - v_forward * 128, FALSE, self);
    if (trace_fraction < 1) { v0_x = -45; self.attack_state = 0; }
    traceline(self.origin, v3 + v_right * 128, FALSE, self);
    if (trace_fraction < 1) { v0_z = -45; self.attack_state = 0; }
    traceline(self.origin, v3 - v_right * 128, FALSE, self);
    if (trace_fraction < 1) { v0_z = 45; self.attack_state = 0; }
    traceline(self.origin, v3 + v_up * 128, FALSE, self);
    if (trace_fraction < 1 || self.velocity_z > 40)  self.thru = 0;
    traceline(self.origin, v3 - v_up * 128, FALSE, self);
    if (trace_fraction < 1 || self.velocity_z < -40) self.thru = 4;
    turn_hedrone(v0);
    if (self.attack_finished < time)
    {
      self.aiment = world;
      v2 = Drone_aim (0.96, 1500);
      v1 = self.angles; v1_x = 0 - v1_x;
      makevectors (v1);
      if (self.aiment == self.enemy)
      {
        if (self.attack_state == 1)
        {
          v3 = normalize(self.enemy.origin - self.origin);
          if (v3 * v_forward > 0.8)
          {
            AC_spike(self.origin + v_forward * 10, v3, self.enemy);
            self.attack_finished = time + 0.2;
          }
        }
        else if (self.attack_state == 2)
        {
          AC_rocket(self.origin + v_right * 10 + v_forward * 10, v_forward, self.enemy);
          AC_rocket(self.origin - v_right * 10 + v_forward * 10, v_forward, self.enemy);
          self.attack_finished = time + 1;
        }
        else if (self.attack_state == 3)
        {
          AC_heatseeker(self.origin - v_up * 10 + v_forward * 10, v_forward, self.enemy);
          self.attack_finished = time + 2;
        }
      }
    }
    if (!visible (self.enemy))
      self.attack_state = 0;
    if (random () < 0.1)
      self.attack_state = 0;
  }

  if (self.thru != oth) self.fly_sound = time;

  self.think = hedrone_run;
  self.nextthink = time + 0.1;
};

void() hedrone_start =
{
//  local string  stemp;
//  local entity  etemp;

  if (deathmatch > 0 && (self.team == 0 || teamplay == 0))
  {
    remove(self);
    return;
  }

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
    self.think = hedrone_walk;
	}
  else
    self.think = hedrone_stand;

// spread think times so they don't all happen at same time
	self.nextthink = self.nextthink + random()*0.5;
};

void() monster_helo =
{
  if (!deathmatch)
    total_monsters = total_monsters + 1;

  
	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_FLY;

  //setmodel (self, "progs/helo1.mdl");

  setmodel (self, "newmedia/apache.md2");
  GimmeRotor(self, "newmedia/aparotors.md2"); // Tei

  setsize (self, '-16 -16 -16', '16 16 16');
  self.view_ofs = '0 0 1';
  if (!self.health)
    self.health = 200;
  self.netname = "a Chopper";

  setup_teament();

  self.touch = T_hedroneTouch;
  self.th_die = hedrone_die;
  self.th_stand = hedrone_stand;
  self.th_walk = hedrone_walk;
  self.th_run = hedrone_run;
  self.think = hedrone_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
