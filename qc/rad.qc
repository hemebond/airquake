void() rad_run;
void() rad_aim;
void() start_monster_rad;
void() rad_assign;

float() RadFindTarget =
{
  local entity  e, client, e2;
  local float   r, mr;
  local string  teststr, dirstr;

// if the first spawnflag bit is set, the monster will only wake up on
// really seeing the player, not another monster getting angry

  if (self.ts == T0)
    teststr = T1;
  else if(self.ts == T1)
  {
    if (deathmatch)
      teststr = T2;
    else
      teststr = T0;
  }
  else
    teststr = T1; 

  mr = 3000;
  if (self.enemy.health > 0)
    mr = vlen(self.enemy.origin - self.origin);

  e = findradius(self.origin, 3000);

  self.impulse = 0;

  while (e)
  {
    if (e.ts == teststr)
    {
      if (e.takedamage == DAMAGE_AIM && e.solid != SOLID_BSP)
      {
        if (e.health > 0 && e.classname != "player")
        {
          if (e.model == "progs/plane3.mdl" && e.unstealth_finished > time)
            self.impulse = self.impulse; // yeah!
          else if (e.model == "progs/humba.mdl" && e.owner.attack_finished < time && e.owner.style == 9)
            self.impulse = self.impulse;
          else
          {
            if (visible(e))
            {
              self.impulse = self.impulse + 1;
              r = vlen(e.origin - self.origin);
              if (r < mr)
              {
                mr = r;
                self.enemy = e;
              }

              if (e.rad_time < time)
              {
                sound(self, CHAN_VOICE, "speech/rw_a_al.wav", 1, ATTN_NORM);
                send_voicemsg(84, self);
                teamprint(self, self.netname);
                teamprint(self,": Enemy ");
                if (e.owner.classname == "player")
                {
                  if (e.owner.style == 1)
                    teamprint(self,"Dogfighter (");
                  else if (e.owner.style == 2)     
                    teamprint(self,"Fighter Bomber (");
                  else if (e.owner.style == 3)
                    teamprint(self,"Stealth Fighter (");
                  else if (e.owner.style == 4)
                    teamprint(self,"Bomber (");
                  else if (e.owner.style == 5)
                    teamprint(self,"X-29 (");
                  else if (e.owner.style == 6)
                    teamprint(self,"Helicopter (");
                  else
                    teamprint(self,"Ground vehicle (");
                }
                else
                {
                  teamprint(self, "vehicle (");
                }
                teamprint(self,e.netname);
                teamprint(self, ") in ");

                v_forward = vectoangles(e.origin - self.origin);
                r = v_forward_y;
                if (r > 67 && r <= 112)
                  dirstr = "north";
                else if (r > 22 && r <= 67)
                  dirstr = "northeast";
                else if (r > 337 || r <= 22)
                  dirstr = "east";
                else if (r > 292 && r <= 337)
                  dirstr = "southeast";
                else if (r > 247 && r <= 292)
                  dirstr = "south";
                else if (r > 202 && r <= 247)
                  dirstr = "southwest";
                else if (r > 157 && r <= 202)
                  dirstr = "west";
                else if (r > 112 && r <= 157)
                  dirstr = "northwest";
                teamprint(self, dirstr);
                if (e.origin_z - self.origin_z > 1000)
                  teamprint(self, " high");
                else if (e.origin_z - self.origin_z < 100)
                  teamprint(self, " low");

                teamprint(self, "\n");
              }
              e.rad_time = time + 3;
            }
          }        
        }    
      }
    }
    e = e.chain;
  }

	return TRUE;
};

/*
==============================================================================

RADAR

==============================================================================
*/
void() rad_stand     =[      0,       rad_stand    ] {
  local entity e;
  local float n;
  checkground();
  if (!(self.flags&FL_ONGROUND))
    T_Damage(self, world, world, 1000);

  if (self.rad_time < time)
  {
    RadFindTarget ();
    self.rad_time = time + 1;
  }

  if (self.enemy != world)
  {
    n = vlen(self.origin - self.enemy.origin);
    if (n > 3000)
      self.enemy = world;
    if (!visible(self.enemy))
      self.enemy = world;
    if (self.enemy.health < 1)
      self.enemy = world;
    if (self.enemy.model == "progs/plane3.mdl" && self.enemy.unstealth_finished < time)
      if (random() < 0.2)
        self.enemy = world;
  }

  if (self.enemy != world && self.attack_finished < time)
  {
    if (visible (self.enemy))
    {
      if (self.enemy.owner.classname == "player")
      {
        if(self.enemy.owner.rad_time < time)
        {
          stuffcmd(self.enemy.owner, "play in2.wav\n");
        }
        self.enemy.owner.armortype = self.enemy.owner.armortype | 1;
      }
      self.attack_finished = time + 1;
      rad_assign();
    }
  }
  rad_aim ();
};

void() rad_walk     =[      0,       rad_stand    ] {  };

void() rad_run     =[      0,       rad_stand    ] { } ;
/*
 {
  FindTarget ();
  if (!CanDamage(self.enemy, self) || !self.enemy.takedamage)
  {
    self.enemy = world;
    self.think = self.th_stand;
    self.nextthink = time + 0.1;
    return;
  }
  aag_aim ();
};
*/
void() rad_death =
{
  self.trigger_field.think = BecomeExplosion;
  self.trigger_field.nextthink = time + 0.1;
  if (!deathmatch)
    remove(self);
  else
  {
    setmodel(self, "");
    self.takedamage = 0;
    self.think = start_monster_rad;
    self.nextthink = time + self.wait;
//dprint("gonna resp\n");
  }
};

void() rad_die =
{
// check for gib
	if (self.health < -90)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
    Throw_ACgib ();
    Throw_ACgib ();
    Throw_ACgib ();
	}
	self.solid = SOLID_NOT;
  rad_death();
};

void() rad_aim =
{
  local vector dir, vtemp, org, vel;
  local float dist;

  dir = self.angles_y * '0 1 0' + '-30 10 0';
  makevectors(dir);

  org = self.origin + v_forward;

  dir = vectoangles (org - self.origin);

  vtemp = '0 0 0';
  vtemp_y = dir_y - self.angles_y;
  vtemp_x = dir_x - self.trigger_field.angles_x;
  dir = '0 0 0';
  if (vtemp_x < 0) vtemp_x = vtemp_x + 360;
  if (vtemp_x > 180) vtemp_x = vtemp_x - 360;
  if (vtemp_y < 0) vtemp_y = vtemp_y + 360;
  if (vtemp_y > 180) vtemp_y = vtemp_y - 360;
  dir = vtemp;
  if (dir_x < -10)
    dir_x = -10;
  if (dir_x > 10)
    dir_x = 10;
  if (dir_y < -10)
    dir_y = -10;
  if (dir_y > 10)
    dir_y = 10;
/*
  if (self.enemy)
  {
    if (vlen(dir)<10)
    {
      if (time > self.attack_finished)
      {
        traceline(self.origin, org, TRUE, world);
        if (trace_fraction == 1 && dist <= 1)
          self.th_missile (); 
        self.attack_finished = time + 0.5;
      }
    }
  }
*/

  self.trigger_field.angles_x = anglemod(self.trigger_field.angles_x + dir_x);
  self.angles_y = anglemod(self.angles_y + dir_y);
  self.trigger_field.angles_y = self.angles_y;
};

void() rad_assign =
{
  local entity e, stemp, temp;
  local float mr, r;

  stemp = self;
  temp = self.enemy;

  e = find(world, ts, self.ts);
  while (e)
  {
    if (e.health > 0)
    {
    if (e.classname == "monster_sam" || e.classname == "monster_aag")
    {
      if (e.th_run)
      {
//      dprint(".");
      if (e.enemy.pdmg > e.enemy.health * 1.5)
        e.enemy = world;

      mr = 3000;
      if (e.enemy)
        mr = vlen(e.enemy.origin - e.origin);

      r = vlen(stemp.enemy.origin - e.origin);
      if (r < mr && temp.pdmg < temp.health * 1.5)
      {
        mr = r;
        traceline(e.origin, self.enemy.origin, TRUE, world);
        if (trace_fraction == 1)
        {
          self = e;
          self.enemy = temp;
          self.think = self.th_run;
          self.nextthink = time + 0.1;
        }
      }
      }
    }
    }
    e = find(e, ts, self.ts);
  }
//    dprint("\n");
  self = stemp;
};

//=================================================================

void() start_monster_rad =
{
  local entity stemp;

  teamplay = cvar("teamplay");
  if (deathmatch > 0)
    if (self.team == 0 || teamplay == 0)
    {
//dprint("fukk!\n");
      remove(self);
      return;
    }

	self.solid = SOLID_SLIDEBOX;
  self.movetype = MOVETYPE_TOSS;
  self.health = self.max_health;

  setmodel (self, "progs/radba.mdl");
  setsize (self, '-16 -16 -24', '16 16 16');

  self.th_stand = rad_stand;
  self.th_walk = rad_walk;
  self.th_run = rad_run;
  self.th_die = rad_die;
  self.th_missile = rad_assign;

  if (!self.netname)
    self.netname = "Radar";

  setorigin(self, self.oldorigin);
  droptofloor();
	self.takedamage = DAMAGE_AIM;

	self.ideal_yaw = self.angles * '0 1 0';
  self.view_ofs = '0 0 1';
	self.use = monster_use;

  if (deathmatch > 0 || self.team != 1)
    self.flags = self.flags | FL_MONSTER;

  stemp = spawn();
  stemp.owner = self;
  stemp.takedamage = DAMAGE_NO;
  setmodel(stemp, "progs/radpl.mdl");
  self.trigger_field = stemp;
  stemp.angles = self.angles;
  setorigin(stemp, self.origin);

  self.th_stand ();
};

/*QUAKED monster_rad (1 0 0) (-16 -16 -24) (16 16 16) 
*/
void() monster_rad =
{
  local vector v1;

  precache_model ("progs/radba.mdl");
  precache_model ("progs/radpl.mdl");

  if (deathmatch == 0 && self.team != 1)
    total_monsters = total_monsters + 1;
  self.oldorigin = self.origin;
  if (!self.health)
    self.health = 100;
  self.max_health = self.health;
  v1 = self.angles_y * '0 1 0' + '-30 0 0';
  makevectors (v1);
  self.movedir = v_forward;

  setup_teament();

  if (!self.wait)
    self.wait = 120;

  self.think = start_monster_rad;
  self.nextthink = time + 0.1 + random() * 0.3;
};
