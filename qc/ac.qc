void() AC_Fall;
void() fire_touch;

void () cammy_think =
{
  if (self.owner.oldenemy != self)
  {
    remove(self);
    return;
  }

  self.think = cammy_think;
  self.nextthink = time + 1;
};

void () target_think =
{
  if (self.owner.trigger_field != self)
  {
    remove(self);
    return;
  }

  self.think = target_think;
  self.nextthink = time + 1;
};

void () vehicle_think =
{
  if (self.owner.enemy != self)
  {
    if (self.oldenemy)
      remove(self.oldenemy);
    if (self.movetarget)
      remove(self.movetarget);
    remove(self);
    return;
  }

  self.think = vehicle_think;
  self.nextthink = time + 1;
};

void () Create_chasecam =
{
  local entity e;
  // Create chase camera
  // Self.oldenemy is the chase cam
  e = spawn();
  setmodel (e, "progs/null.spr");  // This is a transparent sprite
  setorigin (e, self.origin);
  self.view_ofs = '0 0 1';

  msg_entity = self;           // Camera viewport
  WriteByte (MSG_ONE, 5);      
  WriteEntity (MSG_ONE, e);
  // Turn the camera to the right dir!!
  // (doesn't always work at start?)
  WriteByte (MSG_ONE, 10);
  WriteAngle(MSG_ONE, self.enemy.angles_x);
  WriteAngle(MSG_ONE, self.enemy.angles_y);    
  WriteAngle(MSG_ONE, self.enemy.angles_z);

  e.toyview = 0;
  e.style = 32;

  e.owner = self;
  self.oldenemy = e;
  e.think = cammy_think;
  e.nextthink = time + 1;
};

void(entity e) Check_minsmaxs =
{
  if (minims != '0 0 0')
  {
    if (e.origin_x < minims_x)
      e.origin_x = minims_x;
    if (e.origin_y < minims_y)
      e.origin_y = minims_y;
    if (e.origin_z < minims_z)
      e.origin_z = minims_z;
  }
  if (maxims != '0 0 0')
  {
    if (e.origin_x > maxims_x)
      e.origin_x = maxims_x;
    if (e.origin_y > maxims_y)
      e.origin_y = maxims_y;
    if (e.origin_z > maxims_z)
      e.origin_z = maxims_z;
  }
};

void() Throw_ACgib =
{
  newmis = spawn();  
  newmis.solid = SOLID_TRIGGER;
  newmis.movetype = MOVETYPE_TOSS;
  newmis.velocity_x = random() * 300 - 150;
  newmis.velocity_y = random() * 300 - 150;
  newmis.velocity_z = random() * 150 + 150;
//  newmis.velocity = newmis.velocity + self.velocity;
  newmis.classname = "fireball";
  setmodel (newmis, "progs/lavaball.mdl");
  setsize (newmis, '0 0 0', '0 0 0');
  setorigin (newmis, self.origin);
  newmis.nextthink = time + 5;
  newmis.think = SUB_Remove;
  newmis.touch = fire_touch;
};

void() AC_Explode =
{
  T_RadiusDamage (self, self, 160, self);
	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);
  Throw_ACgib ();
  Throw_ACgib ();
  if (!deathmatch)
  {
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
  }
  BecomeExplosion ();
};

void(entity targ, entity attacker) AC_Obituary =
{
	local	string deathstring, deathstring2;

  if (attacker.owner.classname == "player")
    attacker = attacker.owner;

  if (attacker.classname == "player")
  {
    if (targ.owner == attacker)
    {
      attacker.frags = attacker.frags - 1;
      bprint (targ.owner.netname);
      if (pointcontents(targ.origin) < CONTENT_EMPTY)
        bprint (" goes for a swim\n");
      else
        bprint (" commits self-destruction\n");
      return;
    }
    else if ( (teamplay == 2) && (targ.owner.team > 0) && (targ.owner.team == attacker.team) )
    {
      attacker.frags = attacker.frags - 2;
      deathstring = " has some target practise\n";
      bprint (attacker.netname);
      bprint (deathstring);
      return;
    }
    else
    {
      attacker.frags = attacker.frags + 3;
      deathstring = " is destroyed by ";
      deathstring2 = "\n";
      bprint (targ.owner.netname);
      bprint (deathstring);
      bprint (attacker.netname);
      bprint (deathstring2);
			return;
    }
  }
  else
  {
//    targ.goalentity.frags = targ.goalentity.frags - 1;
    bprint (targ.owner.netname);
			if (attacker.flags & FL_MONSTER)
			{
        if (attacker.classname == "monster_drone")
          bprint (" was destroyed by a drone!\n");
        if (attacker.classname == "monster_helo")
          bprint (" was destroyed by a Chopper\n");
        if (attacker.classname == "monster_sam")
          bprint (" was shot by a SAM launcher\n");
        if (attacker.classname == "monster_aag")
          bprint (" was shot by an Anti-aircraft gun\n");
        if (attacker.classname == "monster_amg")
          bprint (" was shot by a machine gun turret\n");
        if (attacker.classname == "monster_etank")
          bprint (" was destroyed by a tank\n");
        if (attacker.classname == "monster_emsam")
          bprint (" was shot by a mobile SAM\n");
        if (attacker.classname == "monster_ehmmv")
          bprint (" was outgunned by an armoured car\n");

				return;
			}

			// tricks and traps
			if (attacker.classname == "explo_box")
			{
				bprint (" blew up\n");
				return;
			}
			if (attacker.solid == SOLID_BSP && attacker != world)
			{	
				bprint (" was squished\n");
				return;
			}
			if (attacker.classname == "trap_shooter" || attacker.classname == "trap_spikeshooter")
			{
				bprint (" was spiked\n");
				return;
			}
			if (attacker.classname == "fireball")
			{
				bprint (" ate a lavaball\n");
				return;
			}
			if (attacker.classname == "trigger_changelevel")
			{
				bprint (" tried to leave\n");
				return;
			}
      bprint (" exploded\n");
  }
};

vector(float minim, float maxdist) AC_aim =
{
  local entity e, re;
  local float f1,f2,flg,min;
  local vector v1,v2,org;

  min = minim;
  flg = 0;
  if (maxdist < 0)
  {
    flg = flg + 1;
    maxdist = 0 - maxdist;
  }

  re = world;
  makevectors (self.enemy.angles);
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
      if (teamplay)
      {
        if ((temp1&8)>0 && e.ts == self.ts)
          trace_fraction = 0;
        else if (e.ts == self.ts && re.ts != self.ts && re != world)
          trace_fraction = 0;
      }
      else if (deathmatch)
      {
        if (e.owner.classname != "player")
          trace_fraction = 0;
      }
      if (trace_fraction == 1)
      {
        if (trace_inopen && trace_inwater)
          trace_fraction = 0;
        else if (e.solid == SOLID_BSP)
        {
          f1 = vlen(org - self.enemy.origin);
          f2 = vlen(e.size);
          if (f2 > f1)
            trace_fraction = 0;
        }
      }

      if (trace_fraction == 1)
      {
        v2 = normalize (org - self.enemy.origin);
        f1 = v1 * v2;
        if (f1 > minim)
        {
          if (f1 > min || (re.ts == self.ts && e.ts != self.ts))
          {
            min = f1;
            re = e;
          }
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

vector(float minim, float maxdist) AC_aim2 =
{
  local entity e, re;
  local float f1,f2,flg,min;
  local vector v1,v2,org;

  min = minim;
  flg = 0;
  if (maxdist < 0)
  {
    flg = flg + 1;
    maxdist = 0 - maxdist;
  }

  re = world;
  makevectors (self.v_angle); //enemy.angles);
  v1 = v_forward;
//  v1_z = 0 - v1_z;
  e = findradius (self.enemy.origin, maxdist);
  while (e)
  {
    org = e.origin + (e.mins + e.maxs)*0.5;
    if (e != self && e != self.enemy)
    {
      if (e.takedamage > 1 && (e.movetype != MOVETYPE_FLY || (flg & 1) == 0 ) )
      {
        traceline (org, self.oldenemy.origin, TRUE, world);
        if (e.model == "progs/plane3.mdl")
          if (e.skin == 1 && random() < 0.5)
            trace_fraction = 0;
        if (teamplay)
        {
          if ((temp1&8)>0 && e.ts == self.ts)
            trace_fraction = 0;
          else if (e.ts == self.ts && re.ts != self.ts && re != world)
            trace_fraction = 0;
        }
        else if (deathmatch)
        {
          if (e.owner.classname != "player")
            trace_fraction = 0;
        }
        if (trace_fraction == 1)
        {
          if (trace_inopen && trace_inwater)
            trace_fraction = 0;
          else if (e.solid == SOLID_BSP)
          {
            f1 = vlen(org - self.enemy.origin);
            f2 = vlen(e.size);
            if (f2 > f1)
              trace_fraction = 0;
          }
        }

        if (trace_fraction == 1)
        {
          v2 = normalize (org - self.oldenemy.origin);
          f1 = v1 * v2;
          if (f1 > minim)
          {
            if (f1 > min || (re.ts == self.ts && e.ts != self.ts))
            {
              min = f1;
              re = e;
            }
          }
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

void() T_ACTouch =  // Crash
{
  local float damg, temp;
  local entity stemp,stemp2;

	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
  if (other == self.owner || other.owner == self.owner)
    return;
  if (self.owner.flags & FL_GODMODE)
    return;
  if (other != world)
  {
    if (!other.takedamage && other.solid < 2) // != SOLID_BSP?
      return;
  }

  if (other.classname == "func_runway" && self.health > 0)
  {
    if (other == self.groundentity && self.landed > 0)
      return;
    if (fabs(self.angles_x) < 20 && fabs(self.angles_z) < 20)
    {
      traceline(self.origin, self.origin + '0 0 -32', FALSE, self);
      if (trace_ent.classname == "func_runway")
      {
        if (!self.landed)
        {
          sprint(self.owner, "Landed.\n");
          sound(self, CHAN_VOICE, "touchdwn.wav", 1, ATTN_NORM);
        }
        self.landed = 1;
        self.groundentity = other;
        self.angles_x = 0;
        self.angles_z = 0;
        self.avelocity = '0 0 0';
        self.velocity_z = 0;
        self.origin_z = other.origin_z + other.maxs_z + 16;
        return;
      }
    }
  }

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

//  self.health = 0;
  temp = self.owner.frags;

  if (other == world || other.health > 0 || (self.health < 1 && time > self.pain_finished) )
  {  // Lethal crashs  (explodes)
    self.origin = self.origin - normalize(self.velocity) * 8;
    setorigin(self.owner, self.origin);
    T_RadiusDamage (self, self, 160, self);
    if (self.health > 0)
    {
      self.owner.frags = temp - 1;
      bprint (self.owner.netname);
      bprint (" crashed into ");
      if (other!=world)
      {
        if (other.netname)
          bprint (other.netname);
        else
        {
          if (other.classname == "func_xwall")
            bprint ("a building");
          else if (other.classname == "func_runway")
            bprint ("a runway");
        }
        bprint ("\n");
      }
      else
      {
        bprint ("the ground\n");
      }
      self.health = 0;
    }
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    T_Damage(self.owner,self.owner,self.owner,1000);
    self.touch = SUB_Null;
    self.takedamage = 0;
    self.think = BecomeExplosion;
    self.nextthink = time + 0.1;
  }
  else
  {  // Crashs that kill you more painfully. :)
    T_Damage(other,self,self,200);
    if (self.health > 0)
    {
      self.pain_finished = time + 0.3;
      self.owner.frags = temp - 1;
      bprint (self.owner.netname);
      bprint (" crashed into ");
      if (other!=world)
      {
        if (other.netname)
          bprint (other.netname);
        else
        {
          if (other.classname == "func_xwall")
            bprint ("a building");
          else if (other.classname == "func_runway")
            bprint ("a runway");
        }
        bprint ("\n");
      }
    }
    self.health = 0;
    self.th_die = SUB_Null;
//    setmodel(self,"progs/plane1b.mdl");

    self.touch = T_ACTouch;
    AC_Fall ();
  }
};

void() AC_Fall =
{
  local vector v1,v2,v3;

  v1 = '0 0 0';
  v1_x = -70 - self.angles_x;
  v2 = '0 0 360';
  if (v1_x < 0) v2_x = -20;
  if (fabs(v1_x) < 2)
  {
    v2_x = 0;
    self.angles_x = -70;
  }
  self.avelocity = v2;

  makevectors(self.angles);
  v3 = v_forward;
  v3_z = 0 - v3_z;
  self.velocity = v3 * 300;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;

  self.think = AC_Fall;
  self.nextthink = time + 0.1;
};

void() AC_Die =
{
//  self.owner.enemy = world;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

//  setmodel(self,"progs/plane1b.mdl");

  self.pain_finished = time + 0.3;

  self.touch = T_ACTouch;
  AC_Fall ();
};

