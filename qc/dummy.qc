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
    setmodel (self, "newmedia/f16.md2");
  else if (self.style == 2)
    setmodel (self, "newmedia/f18.md2");
  else if (self.style == 3)
    setmodel (self, "newmedia/f117.md2");
  else if (self.style == 4)
    setmodel (self, "newmedia/a10.md2");
  else if (self.style == 5)
    setmodel (self, "newmedia/f22.md2");
  else if (self.style == 6)
    setmodel (self, "newmedia/helo.md2");

  setsize (self, '-16 -16 -16', '16 16 16');
  self.netname = "a plane";

  droptofloor();
  if (!self.health)
    self.health = 100;
	self.takedamage = DAMAGE_AIM;

  self.touch = dummycraft_touch;
  self.th_die = dummycraft_die;
};
