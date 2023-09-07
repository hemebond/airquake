void() HE_Fall;

void() T_HETouch =  // Crash
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
    if (!other.takedamage && other.solid < 2)
      return;
  }

  if (other.classname == "func_button")   // ;-)
    return;   

  if (other.classname == "func_runway" && self.health > 0)
  {
    if (fabs(self.angles_x) < 20 && fabs(self.angles_z) < 20)
    {
      if (!self.landed)
        sprint(self.goalentity, "Landed.\n");
      self.landed = 1;
      self.groundentity = other;
      self.angles_x = 0;
      self.angles_z = 0;
      self.avelocity = '0 0 0';
      self.velocity = '0 0 0';
      self.origin_z = other.origin_z + other.maxs_z + 16;
      return;
    }
  }

  //FX_ScorchFinal(self.origin);//Tei
  //FX_Scorch(self.origin);//Tei

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

//  self.health = 0;
  temp = self.goalentity.frags;

  if (other == world || other.health > 0 || (self.health < 1 && time > self.pain_finished) )
  {  // Lethal crashs  (explodes)
    self.origin = self.origin - normalize(self.velocity) * 8;
    setorigin(self.goalentity, self.origin);
    T_RadiusDamage (self, self, 240, self);
    if (self.health > 0)
    {
      self.goalentity.frags = temp - 1;
      bprint (self.goalentity.netname);
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
    self.takedamage = DAMAGE_NO;
    BecomeExplosion ();
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
    T_Damage(self.owner,self.owner,self.owner,1000);
    self.touch = SUB_Null;
  }
  else
  {  // Crashs that kill you more painfully. :)
    T_Damage(other,self,self,240);
    if (self.health > 0)
    {
      self.pain_finished = time + 0.3;
      self.goalentity.frags = temp - 1;
      bprint (self.goalentity.netname);
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

    self.touch = T_HETouch;
    HE_Fall ();
  }
};

void() HE_Fall =
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

  self.velocity = self.velocity + '0 0 -1' * cvar("sv_gravity") * 0.1;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;

  // Tei
  //self.effects3 = EF3_DARKTRAIL;
  // Tei

  self.think = HE_Fall;
  self.nextthink = time + 0.1;
};

void() HE_Die =
{
//  self.goalentity.enemy = world;

	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte (MSG_BROADCAST, TE_EXPLOSION);
	WriteCoord (MSG_BROADCAST, self.origin_x);
	WriteCoord (MSG_BROADCAST, self.origin_y);
	WriteCoord (MSG_BROADCAST, self.origin_z);

//  setmodel(self,"progs/plane1b.mdl");

  self.pain_finished = time + 0.3;

  self.touch = T_HETouch;
  HE_Fall ();
};
