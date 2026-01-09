void() dummycraft_touch =
{
	if (other.solid == SOLID_TRIGGER)
		return;	// trigger field, do nothing
  if (other == self.goalentity)
    return;
  if (other != world)
  {
    if (!other.takedamage)
      return;
  }
  self.think = self.th_die;
  self.nextthink = time + 0.1;
};

void() dummycraft_die =
{
  self.think = AC_Explode;
  self.nextthink = time + 0.2;
};

void() monster_dummycraft =
{
	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_TOSS;

  if (!self.style)
  {
    self.style = random() * 5.9;
    self.style = floor(self.style) + 1;
  }

  if (self.style == 1)
    setmodel (self, "progs/plane1.mdl");
  else if (self.style == 2)
    setmodel (self, "progs/plane2.mdl");
  else if (self.style == 3)
    setmodel (self, "progs/plane3.mdl");
  else if (self.style == 4)
    setmodel (self, "progs/plane4.mdl");
  else if (self.style == 5)
    setmodel (self, "progs/plane5.mdl");
  else if (self.style == 6)
    setmodel (self, "progs/helo1.mdl");

  setsize (self, '-16 -16 -16', '16 16 16');
  self.netname = "a plane";

  droptofloor();
  if (!self.health)
    self.health = 100;
	self.takedamage = DAMAGE_AIM;

  self.touch = dummycraft_touch;
  self.th_die = dummycraft_die;
};
