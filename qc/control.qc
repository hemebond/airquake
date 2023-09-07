/*
================
RUNWAY TRIGGERS

self.attack_finished > time :  Anything moving on runway
self.search_time > time     :  Aircraft moving on runway
self.oldenemy               :  Last touched any vehicle..
self.enemy                  :  Last touched plane..
================
*/
void() trigger_runway_touch =
{
  if (other.classname == "player")
    return;

  if (other.owner.classname == "player")
    other.owner.landed = time + 0.5;

  self.attack_finished = time + 0.5;
  self.oldenemy = other;
  if (other.classname == "plane")
  {
    self.search_time = time + 0.5;
    self.enemy = other;
  }
};

void() toffrunway_start =
{
  local entity e;

  if (cvar("deathmatch") == 1 && cvar("teamplay") == 0)
  {  // no control towers in reg. deathmatch
    remove(self);
    return;
  }

  InitTrigger ();
  self.touch = trigger_runway_touch;

  e = find(world, targetname, self.target);
  self.owner = e;
  e.oldenemy = self;
};

/*QUAKED trigger_toffrunway (.5 .5 .5) ?
Use on takeoff runways
*/
void() trigger_toffrunway =
{
  self.think = toffrunway_start;
  self.nextthink = time + 0.2;
};

void() landrunway_start =
{
  local entity e;

  if (cvar("deathmatch") == 1 && cvar("teamplay") == 0)
  {  // no control towers in reg. deathmatch
    remove(self);
    return;
  }

  InitTrigger ();
  self.touch = trigger_runway_touch;

  e = find(world, targetname, self.target);
  self.owner = e;
  e.enemy = self;
};

/*QUAKED trigger_landrunway (.5 .5 .5) ?
Use on landing runways
*/
void() trigger_landrunway =
{
  self.think = landrunway_start;
  self.nextthink = time + 0.2;
};

/*
==============================
info_control

- self.enemy:      a trigger on runway for landings
- self.oldenemy:   a trigger on runway for take-offs
- self.tur1:       player who has landing clearance
- self.tur2:       player who has take-off clearance
- self.goalentity: An entity the control is placed in (buildings etc)
- self.message:    Mission briefing

- self.attack_finished: When landing will be auto-cancelled
- self.search_time    : When take-off will be auto-cancelled
==============================
*/
void() control_think =
{
  if (self.tur1) // landed
  {
    if (self.tur1.landed < time && self.tur1.enemy.landed != 0)
      self.tur1 = world;
    if (self.tur1.enemy.health < 1)
      self.tur1 = world;
    if (self.attack_finished < time)
      self.tur1 = world;
  }
  if (self.tur2) // taken off
  {
    if (self.tur2.landed < time && self.tur2.enemy.landed == 0)
      self.tur2 = world;
    if (self.tur2.enemy.health < 1)
      self.tur2 = world;
    if (self.search_time < time)
      self.tur2 = world;
  }
  self.think = control_think;
  self.nextthink = time + 0.1;
};


void() start_control =
{
  if (self.target)
  {
    self.goalentity = find(world, targetname, self.target);
    self.origin = self.goalentity.origin + (self.goalentity.mins + self.goalentity.maxs) * 0.5;
  }
  setorigin(self, self.origin);
  if (!self.message)
    self.message = "No briefing available.\n";

  self.think = control_think;
  self.nextthink = time + 0.1;
};

/*QUAKED info_control (0 0.5 0) (-4 -4 -4) (4 4 4)
Airport control. Handles base traffic, landing/take-off queues, briefings...
*/
void() info_control =
{
  if (self.team == 0 || (self.team != 1 && deathmatch == 0))
    self.ts = T0;
  else if (self.team == 1)
    self.ts = T1;
  else
    self.ts = T2;

  if (cvar("deathmatch") == 1 && cvar("teamplay") == 0)
  {  // no control towers in reg. deathmatch
    self.think = SUB_Remove;
    self.nextthink = time + 0.1;
    return;
  }

  if (!self.netname)
    self.netname = "Tower";

  self.think = start_control;
  self.nextthink = time + 0.3;
};

// Control tower comm code

/*
0:   Mission briefing
1:   Landing request
2:   Take-off request
3:   Cancel land/toff
4:   Emerg landing
5:   Radars report
*/

void(float f1) comm_control =
{
  local entity e, e2, e3;
  local string teststr;

  if (deathmatch == 1 && teamplay == 0)
    return;

  e2 = world;
  e = find(world, classname, "info_control");
  while (e)
  {
    if (e.ts == self.ts)
      e2 = e;
    e = find(e, classname, "info_control");
  }

  if (!e2)
  {
    sound (self, CHAN_WEAPON, "misc/talk.wav", 0.5, ATTN_NORM);
    sprint(self, "HQ doesn't reply...\n");
    return;
  }

  e = e2;
  if (e.goalentity)
  {
    if (e.goalentity.health < 1)
    {
      sound (self, CHAN_WEAPON, "misc/talk.wav", 0.5, ATTN_NORM);
      sprint(self, e.netname);
      sprint(self, " doesn't reply...\n");
      return;
    }
  }

//  sound (self, CHAN_WEAPON, "misc/talk.wav", 0.5, ATTN_NORM);
  sprint(self, e.netname);
  sprint(self, ": ");
  if (f1 == 0)  //  briefing
  {
    sprint(self, e.message);
    send_voicemsg (82, self);
  }
  if (f1 == 2)  //  ask for landing clearance
  {
    if (self.style > 5)
    {
      sprint(self, "Keep off the runways, pal.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (self.enemy.landed)
    {
      sprint(self, "You're on ground already.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (e.tur1 == self)
    {
      sprint(self, "Cleared for landing already.\n");
      send_voicemsg (0, self);
      return;   
    }

    e2 = e.enemy;
    if (e.tur1)
    {
      sprint(self, "please wait.\n");
      send_voicemsg (73, self);
      return;
    }
    else
    {
      if (e2.search_time > time)
      {
        sprint(self, "Unauthorized aircraft on runway!\n");
        sprint(e2.enemy.owner, "Clear the runway now!\n");
        send_voicemsg (74, e2.enemy.owner);
        return;
      }
      if (e2.attack_finished > time)
      {
        sprint(e2.oldenemy.owner, "Clear the runway now!\n");
        send_voicemsg (74, e2.oldenemy.owner);
      }
      sprint(self, "You are cleared to land\n");
      send_voicemsg (71, self);
      e.tur1 = self;
      e.attack_finished = time + 30;
      return;
    }
  }
  if (f1 == 1)  //  ask for take-off clearance
  {
    if (self.style > 5)
    {
      sprint(self, "Keep off the runways, pal.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (!self.enemy.landed)
    {
      sprint(self, "You're airborne already.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (e.tur2 == self)
    {
      sprint(self, "Cleared for take-off already.\n");
      send_voicemsg (0, self);
      return;   
    }

    e2 = e.oldenemy;
    if (e.tur2)
    {
      sprint(self, "please wait for take-off clearance.\n");
      send_voicemsg (73, self);
      return;
    }
    else
    {
      if (e2.search_time > time)
      {
        sprint(self, "Unauthorized aircraft on runway!\n");
        sprint(e2.enemy.owner, "Clear the runway now!\n");
        send_voicemsg (74, e2.enemy.owner);
        return;
      }
      if (e2.attack_finished > time)
      {
        sprint(e2.oldenemy.owner, "Clear the runway now!\n");
        send_voicemsg (74, e2.oldenemy.owner);
      }
      sprint(self, "You are cleared for take-off\n");
      send_voicemsg (72, self);
      e.tur2 = self;
      e.search_time = time + 30;
      return;
    }
  }
  if (f1 == 3)  // Cancel
  {
    if (self.style > 5 || (e.tur2 != self && e.tur1 != self))
    {
      sprint(self, "Nothing to cancel.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (e.tur2 == self)
    {
      sprint(self, "Take-off clearance cancelled.\n");
      send_voicemsg (0, self);
      e.tur2 = world;
    }
    if (e.tur1 == self)
    {
      sprint(self, "Landing clearance cancelled.\n");
      send_voicemsg (0, self);
      e.tur1 = world;
    }
    return;
  }
  if (f1 == 4)   // Emg landing
  {
    if (self.style > 5)
    {
      sprint(self, "Try again with a plane, man.\n");
      send_voicemsg (0, self);
      return;   
    }
    if (self.health > 50)
    {
      sprint(self, "Ask for normal landing clearance.\n");
      send_voicemsg (73, self);
      return;   
    }

    sound(self, CHAN_VOICE, "speech/rw_a_al2.wav", 1, ATTN_NORM);
    if (e.enemy.attack_finished < time)
    {
      sprint(self, "You can land on the normal runway.\n");
      send_voicemsg (71, self);
      if (e.tur1)
      {
        sprint(e.tur1, "Emergency! Interrupt landing NOW!\n");
        stuffcmd(e.tur1, "play in1.wav\n");
      }
      e.tur1 = self;
      return;   
    }    
    if (e.oldenemy.attack_finished < time)  // take-off
    {
      sprint(self, "You can land on the take-off runway.\n");
      send_voicemsg (71, self);
      if (e.tur2)
      {
        sprint(e.tur2, "Emergency! Interrupt take-off NOW!\n");
        stuffcmd(e.tur2, "play in1.wav\n");
      }
      e.tur2 = self;
      return;   
    }    
  }
  if (f1 == 5)   // radar report
  {
    send_voicemsg (81, self);
    sprint(self, "radar report:\n");
    e2 = find(world, classname, "monster_rad");
    while(e2)
    {
      if (e2.ts == self.ts)
      {
        sprint(self, e2.netname);
        sprint(self, " reports ");
        teststr = ftos(e2.impulse);
        sprint(self, teststr);
        sprint(self," visible enemies\n");
      }
      e2 = find(e2, classname, "monster_rad");     
    }
    return;
  }
  if (f1 == 6)   // mob radar report
  {
    send_voicemsg (83, self);
    sprint(self, "mobile radar report:\n");
    e2 = find(world, classname, "monster_mobrad");
    while(e2)
    {
      if (e2.ts == self.ts)
      {
        sprint(self, e2.netname);
        sprint(self, " reports ");
        teststr = ftos(e2.impulse);
        sprint(self, teststr);
        sprint(self," visible enemies\n");
      }
      e2 = find(e2, classname, "monster_mobrad");     
    }
    return;
  }
};
