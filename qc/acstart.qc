void() start_aircraft =
{
  local entity e, e2;

  // Create the plane
  // self.enemy is your aircraft (or other vehicle?-).
  e = spawn();
  setmodel (e, "newmedia/f18.md2");

  e2 = self.goalentity;  // This is the info_player_* you spawned on.
  setorigin(e, e2.origin);
  e.angles = e2.angles;

  e.classname = "plane";
  e.velocity = '0 0 0';
  e.movetype = MOVETYPE_FLY;
  setsize (e, '-16 -16 -8', '16 16 8');
  e.solid = SOLID_SLIDEBOX;
  e.touch = T_ACTouch;
  e.health = 200;
  e.maxhealth = e.health;
  e.takedamage = DAMAGE_AIM;
  e.th_die = AC_Die;
  e.netname = self.netname;

  self.enemy = e;
  e.goalentity = self;

  self.toyview = 0;

  // Create chase camera
  // Self.oldenemy is the chase cam
  e = spawn();
  setmodel (e, "progs/null.spr");  // This is a transparent sprite
  setorigin (e, self.enemy.origin);
  self.view_ofs = '0 0 1';

  msg_entity = self;           // Camera viewport
  WriteByte (MSG_ONE, 5);      
  WriteEntity (MSG_ONE, e);
  // Turn the camera to the right dir!!
  // (The original way doesn't always work??)
  WriteByte (MSG_ONE, 10);
  WriteAngle(MSG_ONE, self.enemy.angles_x);
  WriteAngle(MSG_ONE, self.enemy.angles_y);    
  WriteAngle(MSG_ONE, self.enemy.angles_z);

  e.owner = self;
  self.oldenemy = e;

  // Create the target box
  // It's called self.trigger_field
  e = spawn();
  setmodel (e, "progs/s_target.spr");
  setorigin (e, self.enemy.origin);
  e.owner = self;
  self.trigger_field = e;
};
