
.float flycam; //Tei


float (float n) calcbit =
{
  if (n==0)   return 1;
  if (n==1)   return 2;
  if (n==2)   return 4;
  if (n==3)   return 8;
  if (n==4)   return 16;
  if (n==5)   return 32;
  if (n==6)   return 64;
  if (n==7)   return 128;
  if (n==8)   return 256;
  if (n==9)   return 512;
  if (n==10)   return 1024;
  if (n==11)   return 2048;
  if (n==12)   return 4096;
  if (n==13)   return 8192;
  if (n==14)   return 16384;
  if (n==15)   return 32768;

  return 0;
};

entity (string tstr) checkcli =  // a team entity to be checked
{
  if (tstr == T0)
    return checkcl0;
  else if (tstr == T1)
    return checkcl1;
  else
    return checkcl2;
};

void (string tstr) change_cc =  // called each frame?
{
  local entity e, oe;
  local float tmp;

  if (tstr == T0)
    e = checkcl0;
  else if (tstr == T1)
    e = checkcl1;
  else
    e = checkcl2;

  e = find(e, ts, tstr);
  oe = e;
  while (tmp < 50)
  {
    tmp = tmp + 1;
    if (e.health > 0 && e.takedamage > 0 && e.classname != "player")
    {
      if (tstr == T0)
        checkcl0 = e;
      else if (tstr == T1)
        checkcl1 = e;
      else
        checkcl2 = e;
      return;
    }
    e = find(e, ts, tstr);
    if (e == oe)
    {
      e = world;
      if (tstr == T0)
        checkcl0 = e;
      else if (tstr == T1)
        checkcl1 = e;
      else
        checkcl2 = e;
      return;
    }
    if (!e)
      e = find(e, ts, tstr);
  }
  e = world;
  if (tstr == T0)
    checkcl0 = e;
  else if (tstr == T1)
    checkcl1 = e;
  else
    checkcl2 = e;

  return;
};

/*
float(float n) check_allowed = // Can select a vehicle?
{
  local float tmp;
  tmp = 1;
  while(n > 1)
  {
    tmp = 2 * tmp;
    n = n - 1;
  }
  if (allowedcraft & tmp)
    return TRUE;

  return FALSE;
};

void(float n) add_allowedcraft =  // Add to the bitflag
{
  local float tmp;
  local string str;
  tmp = 1;
  while(n > 1)
  {
    tmp = 2 * tmp;
    n = n - 1;
  }
  if (!allowedcraft & tmp)
  {
    numcraft = numcraft + 1;
  }
  allowedcraft = allowedcraft | tmp;
//  dprint("allowed:");
//  str=ftos(allowedcraft);
//  dprint(str);
//  dprint("\n");
};
*/

float(float n) check_allowed = // Can select a vehicle?
{
  local float tmp;

  tmp = calcbit(n - 1);
  if (teamplay == 0)
  {
    if (allowedcraft & tmp)
      return TRUE;
  }
  else
  {
    if (self.ts == T1)
    {
      if (allow1 & tmp)
        return TRUE;
    }
    if (self.ts == T2)
    {
      if (allow2 & tmp)
        return TRUE;
    }
  }

  return FALSE;
};

void (float n, float t) add_allowedcraft =
{
  local float tmp, f1, f2, f3;

  if (t==1)
    allow1 = allow1 | n;
  else if (t==2)
    allow2 = allow2 | n;
  else
  {
    allowedcraft = allowedcraft | n;

    tmp = 0;f1=0;
    while (tmp < 10)
    {
      f2=calcbit(tmp);
      if (allowedcraft & f2)
        f1 = f1 + 1;     
      tmp = tmp + 1;
    }
    numcraft = f1;
  }
};

void(entity to, entity from, float num) givefrags =
{
  if (to.flags & FL_CLIENT)
    to.frags = to.frags + num;
};

void(entity to, float num) giveteamfrags =
{
  local entity e;
  e = find(world, classname, "player");
  while(e)
  {
    if (e.ts == to.ts)
      e.frags = e.frags + num;
    e = find(e, classname, "player");
  }
};

void(entity to, string str) teamprint =
{
  local entity e;

  e = find(world, classname, "player");
  while(e)
  {
    if (e.ts == to.ts || (e.flags & FL_NOTARGET) != 0 )
      sprint(e, str);
    e = find(e, classname, "player");
  }
};

void() checkground =
{
  if (!(self.flags & FL_ONGROUND))
    return;

  if (self.groundentity.solid != SOLID_BSP)
  {
    self.flags = self.flags - (self.flags & FL_ONGROUND);
    return;
  }
};

vector () place_targetbox =
{
  local entity e;
  local vector v0, v1, v2;

  e = self.enemy;

  v0 = e.trigger_field.origin + (e.trigger_field.mins + e.trigger_field.maxs) * 0.5;
  v1 = normalize(v0 - self.oldenemy.origin) * 200 + frametime * e.velocity;
  traceline(self.oldenemy.origin, self.oldenemy.origin + v1, FALSE, e);
  v2 = self.oldenemy.origin + v1 * (trace_fraction - 0.04 );
  if (e.trigger_field.ts == self.ts && (teamplay > 0 || deathmatch == 0))
	
    self.trigger_field.frame = 3;
  else
  {
	self.trigger_field.frame = 1;
	if (self.Cujo) 
	{
		self.Cujo.enemy = self.oldenemy;//Tei
		self.Cujo.goalentity = self.oldenemy;//Tei
	}
  }

  if (e.trigger_field.owner.classname == "player")
  {
    e.trigger_field.owner.armortype = e.trigger_field.owner.armortype | 1;
  }

  return v2;
};

vector (entity targ) orgia =
{
  local vector v;
  v = targ.origin + (targ.mins + targ.mins) * 0.5;
  return v;
};

void () setup_teament =
{
  if (self.team == 0 || (self.team != 1 && deathmatch == 0))
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (self.value)
  {
    if (!deathmatch)
    {
      if (self.team == 1)
        self.value = 0 - self.value;
    }
  }
};

void (float n, entity to) send_voicemsg =
{
  local entity e;
  local string wave;

  wave = "misc/talk.wav";

  if (n > 0 && n < 10)
  {
    if (n==1)  
      wave = "speech/f2_a.wav";
    else if (n==2)
      wave = "speech/f2_b.wav";
    else if (n==3)
      wave = "speech/f2_c.wav";
    else if (n==4)
      wave = "speech/f2_d.wav";
    else if (n==5)
      wave = "speech/f2_e.wav";
    else if (n==6)
      wave = "speech/f2_f.wav";
    else if (n==7)
      wave = "speech/f2_g.wav";
  }  
  else if (n > 10 && n < 20)
  {
         if (n==11)  
      wave = "speech/f3_a.wav";
    else if (n==12)
      wave = "speech/f3_b.wav";
    else if (n==13)
      wave = "speech/f3_c.wav";
    else if (n==14)
      wave = "speech/f3_d.wav";
    else if (n==15)
      wave = "speech/f3_e.wav";
    else if (n==16)
      wave = "speech/f3_f.wav";
    else if (n==17)
      wave = "speech/f3_g.wav";
  }  
  else if (n > 20 && n < 30)
  {
         if (n==21)  
      wave = "speech/f4_a.wav";
    else if (n==22)
      wave = "speech/f4_b.wav";
    else if (n==23)
      wave = "speech/f4_c.wav";
    else if (n==24)
      wave = "speech/f4_d.wav";
    else if (n==25)
      wave = "speech/f4_e.wav";
    else if (n==26)
      wave = "speech/f4_f.wav";
    else if (n==27)
      wave = "speech/f4_g.wav";
  }  
  else if (n > 30 && n < 40)
  {
         if (n==31)  
      wave = "speech/f5_a.wav";
    else if (n==32)
      wave = "speech/f5_b.wav";
    else if (n==33)
      wave = "speech/f5_c.wav";
    else if (n==34)
      wave = "speech/f5_d.wav";
    else if (n==35)
      wave = "speech/f5_e.wav";
    else if (n==36)
      wave = "speech/f5_f.wav";
    else if (n==37)
      wave = "speech/f5_g.wav";
  }  
  else if (n > 40 && n < 50)
  {
         if (n==41)  
      wave = "speech/f6_a.wav";
    else if (n==42)
      wave = "speech/f6_b.wav";
    else if (n==43)
      wave = "speech/f6_c.wav";
    else if (n==44)
      wave = "speech/f6_d.wav";
    else if (n==45)
      wave = "speech/f6_e.wav";
    else if (n==46)
      wave = "speech/f6_f.wav";
    else if (n==47)
      wave = "speech/f6_g.wav";
  }              
  else if (n > 50 && n < 60)
  {
         if (n==51)  
      wave = "speech/f7_a.wav";
    else if (n==52)
      wave = "speech/f7_b.wav";
    else if (n==53)
      wave = "speech/f7_c.wav";
    else if (n==54)
      wave = "speech/f7_d.wav";
    else if (n==55)
      wave = "speech/f7_e.wav";
    else if (n==56)
      wave = "speech/f7_f.wav";
    else if (n==57)
      wave = "speech/f7_g.wav";
  }  
  else if (n > 60 && n < 70)
  {
         if (n==61)  
      wave = "speech/f8_a.wav";
    else if (n==62)
      wave = "speech/f8_b.wav";
    else if (n==63)
      wave = "speech/f8_c.wav";
    else if (n==64)
      wave = "speech/f8_d.wav";
    else if (n==65)
      wave = "speech/f8_e.wav";
    else if (n==66)
      wave = "speech/f8_f.wav";
    else if (n==67)
      wave = "speech/f8_g.wav";
  }  
  else if (n > 70 && n < 80)
  {
         if (n==71)  
      wave = "speech/fc_1.wav";
    else if (n==72)    
      wave = "speech/fc_2.wav";
    else if (n==73)
      wave = "speech/fc_3.wav";
    else if (n==74)
      wave = "speech/fc_4.wav";
  }  
  else if (n > 80 && n < 90)
  {
         if (n==81)  
      wave = "speech/mc_1.wav";
    else if (n==82)
      wave = "speech/mc_2.wav";
    else if (n==83)
      wave = "speech/mc_3.wav";
    else if (n==84)
      wave = "speech/mc_4.wav";
    else if (n==85)
      wave = "speech/mc_5.wav";
    else if (n==86)
      wave = "speech/mc_6.wav";
    else if (n==87)
      wave = "speech/mc_7.wav";
  }  

  if (to.classname == "player")
  {
    to.noise = wave;
/*
    if (to.enemy.health > 0 && to.enemy.owner == to)
      sound (to.enemy, CHAN_VOICE, wave, 1, ATTN_NORM);
    else
      sound (to, CHAN_VOICE, wave, 1, ATTN_NORM);    
*/
    return;
  }

  e = find(world, classname, "player");
  while(e)
  {
    if (e.ts == to.ts) // && e != self)
    {
//      sound (e, CHAN_VOICE, wave, 1, ATTN_NORM);    
      e.noise = wave;
    }
    e = find(e, classname, "player");
  } 
};
