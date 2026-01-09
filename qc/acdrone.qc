void() drone_sound =
{
  local float tmp, f1;
  local entity veh;

  veh = self;

  tmp=veh.speed / 70;
  tmp=floor(tmp);
  if (tmp > 8) tmp = 8;

  if (time > self.fly_sound || veh.impulse != tmp)
  {
    f1 = veh.thru * 0.1 + 0.2;
    if ((self.skin&1) > 0 && self.style != 3)
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

void() T_DroneTouch =  // Crash
{
	local float	damg;
  local entity stemp,stemp2;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
  if (other != world)
  {
    if (!other.takedamage && other.solid != SOLID_BSP)
      return;
  }

  T_RadiusDamage (self, self, 240, self);
  WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
  WriteByte (MSG_BROADCAST, TE_EXPLOSION);
  WriteCoord (MSG_BROADCAST, self.origin_x);
  WriteCoord (MSG_BROADCAST, self.origin_y);
  WriteCoord (MSG_BROADCAST, self.origin_z);

  if (other == world || other.health > 0 || (self.health < 1 && time > self.pain_finished))
  {
    if (self.health > 0)
    {
      bprint (self.netname);
      bprint (" crashed into ");
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
  {
    self.pain_finished = time + 0.3;
    if (self.health > 0)
    {
//      self.frags = self.frags - 1;
      bprint (self.netname);
      bprint (" crashed into ");
      if (other!=world)
      {
        bprint (other.netname);
        bprint ("\n");
      }
    }
    T_Damage(self,self,self,1000);   
    setmodel(self,"progs/plane1b.mdl");

    self.touch = T_DroneTouch;
    AC_Fall ();
  }
};

void() drone_die =
{
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

  setmodel(self,"progs/plane1b.mdl");

  self.th_die = AC_Explode;
  self.touch = T_DroneTouch;
  AC_Fall ();
};

void() drone_fly =
{
  local vector v0,v1,v2,v3;
  local float ab;
  if (self.goalentity)
  {
    v1 = self.goalentity.origin;
    if (self.trigger_field)
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
    if (v1_x < 0) v2_x = -50;
    if (v1_x > 0) v2_x = 50;
    if (fabs(v1_x) < 5)
    {
      v2_x = 0;
      self.angles_x = v0_x;
    }
    v2_y = v1_y * 5;
    if (v2_y < -100) v2_y = -100;
    if (v2_y > 100) v2_y = 100;
    if (fabs(v1_y) < 2)
    {
      v2_y = 0;
      self.angles_y = v0_y;
    }
    if (fabs(v1_y) < 25 && fabs(v1_x) < 25 && self.health < 120)
      ab = 1;
    else
      ab = 0;
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
    if (self.health < 40)
    {
      if (self.model == "progs/plane1.mdl")
        setmodel(self, "progs/plane1b.mdl");
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

    self.thru = 4;
    if (!ab)
      self.speed = self.thru * 75;
    else
      self.speed = 500;

    self.velocity = v3 * self.speed;
  }

  drone_sound();

  self.think = drone_fly;
  self.nextthink = time + 0.1;
};

void() drone_start =
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
  self.think = drone_fly;
	self.nextthink = self.nextthink + random()*0.5;
};

void() monster_drone =
{
	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_FLY;

  setmodel (self, "progs/plane1.mdl");
  setsize (self, '-16 -16 -16', '16 16 16');
  if (!self.health)
    self.health = 200;
  self.netname = "Dogfighter";

  setup_teament();

  self.touch = T_DroneTouch;
  self.th_die = drone_die;
  self.think = drone_start;
	self.nextthink = time + 0.1 + random ()*0.1;	
};
