void() tilt_etank =
{
  local entity e;

  checkground();

  e = self.enemy;
  self.enemy = self;
  gv_tilt ();
  self.enemy = e;
  self.angles_x = self.angles_x + self.avelocity_x * 0.1;
  self.angles_z = self.angles_z + self.avelocity_z * 0.1;
  self.avelocity = '0 0 0';
};

void (vector v0, float sp_x) turn_eturret =
{
  local entity stemp;
  local vector v1,v2,v3;
  local float f1,f2,f3;

  stemp = self;

  if (stemp.tur1)
  {
    setorigin(self.tur1, self.origin);
    v0_y = stemp.angles_y - v0_y;
    if (v0_y > 180) v0_y = v0_y - 360;
    if (!self.flags & FL_ONGROUND)  v0_y = 0;
    v1_y = v0_y - stemp.toyview;
    if (v1_y < 0) v1_y = v1_y + 360;
    if (v1_y > 180) v1_y = v1_y - 360;
    v2_y = 0; 
    if (v1_y < 0) v2_y = 0 - sp_x;
    if (v1_y > 0) v2_y = sp_x;
    f1 = fabs(v1_y); f2 = fabs(v2_y) * 0.1;
    if (f1 < f2)
    {
      v2_y = 0;
      stemp.toyview = v0_y;
    }
    else
      stemp.toyview = stemp.toyview + v2_y * 0.1;

    if (stemp.toyview == 0)
      self.tur1.angles = stemp.angles;
    else
    {
      makevectors('0 1 0' * stemp.toyview);
      f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
      v3 = stemp.angles; v3_x = 0 - v3_x;
      makevectors(v3);
      v3 = v_forward * f2 + v_right * f1;
      v3 = vectoangles (v3);
      stemp.tur1.angles = v3;

      f3 = stemp.tur1.angles_y - stemp.angles_y;
      if (f3 < 0) f3 = f3 + 360;
      if (f3 > 180) f3 = f3 - 360;
      stemp.tur1.angles_z = stemp.angles_z * f2 + stemp.angles_x * f1;
    }
    stemp = stemp.tur1;
  }

  if (self.tur2)
  {
    setorigin(self.tur2, self.origin);
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
    f1 = fabs(v1_x); f2 = fabs(v2_x) * 0.1;
    if (f1 < f2)
    {
      v2_x = 0;
      stemp.toyview = v0_x;
    }
    else
      stemp.toyview = stemp.toyview + v2_x * 0.1;

    if (stemp.toyview == 0)
    {
      self.tur2.angles = stemp.angles;
      return;
    }

    makevectors('0 1 0' * stemp.toyview);
    f1 = v_forward_y; f2 = v_forward_x; // sin? cos?
    v3 = stemp.angles; v3_x = 0 - v3_x;
    makevectors(v3);
    v3 = v_forward * f2 + v_up * f1;
    v3 = vectoangles (v3);

    self.tur2.angles = v3;
    f3 = self.tur2.angles_y - stemp.angles_y;
    if (f3 < 0) f3 = f3 + 360;
    if (f3 > 180) f3 = f3 - 360;
    self.tur2.angles_z = stemp.angles_z * f2 - f3 * f1;
  }
};
