/*ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ                            CUJO BOT ver 1.4                           บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

/*
  CUJO 1.4 - Changes

  Added swim code
  New movetogoal code
  fixed ai_face for stuck code
  Yaw rate is now 90 degress

  CUJO 1.3A - Changes

  fixed velocities for jumping down and into water - minimum of 50 forward
  velocity added to all jumps, scaled down distance multiplier a tad for each
  type of jump

  Cujo no longer teleports to owner if he is staying

  In deathmatch, Cujo's will attack one another (really, really cool)
*/

// distance from player before cujo initiates a teleport
float   teleport_dist  = 1500;

// Prototypes

float   ()                                             CUJO_FindTarget; //
void    ()                                             CUJO_ai_stand;   //
void    ()                                             CUJO_pain;       //
void    ()                                             CUJO_die;        //
void    ()                                             CUJO_SightSound; //
void    ()                                             CUJO_FoundTarget;//
void    ()                                             CUJO_HuntTarget; //
void    (float dist)                                   CUJO_ai_walk;    //
void    ()                                             CUJO_ai_turn;    //
void    (float dist)                                   CUJO_ai_run;     //
void    (float dist)                                   CUJO_ai_follow;  //
void    ()                                             CUJO_ai_face;
void    (float d)                                      CUJO_ai_charge;
void    (void () thinkst)                              CUJO_CheckRefire;//
void    ()                                             CUJO_SelfDeactivate;//

void    ()                                             CUJO_TeleportToOwner;//
vector  ()                                             CUJO_SpawnPos;
float   (vector SpawnPos)                              CUJO_CheckSpawnPos;

// Cujo Prototypes - called by player

void () CUJO_Precache;
void () CUJO_Activate;		// Activate Cujo
void () CUJO_Deactivate;	// DeActivate Cujo
void () CUJO_Toggle;		// Toggle Cujo on and off
void () CUJO_AttackToggle;	// Toggle Cujo's auto-firing in auto mode
/*
void ()	CUJO_Attack;		// Have Cujo fire at its current target in auto mode
*/
void ()	CUJO_TeleportHome;	// Have Cujo teleport back to its owner
void ()	CUJO_LightToggle;	// Have Cujo teleport back to its owner
void () CUJO_SetDogView;
void () CUJO_SetPlayerView;
float () CUJO_JumpAI;

// Global Variables

float   goal_range;
float   goal_vis;
float   goal_infront;
float   goal_yaw;
vector  old_player_angles;
string  temp_text;


float   nextthinktime = 0.01;

$cd /raid/quake/id1/models/dog
$origin 0 0 24
$base base
$skin skin

$frame stand1
$frame attack1 attack2 attack3 attack4 attack5 attack6
$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9 walk10 walk11 walk12
$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7

void() CUJO_run1;
void () CUJO_JumpTouch;
float (float start_dist) CUJO_FindLedge;
float (float dist) CUJO_JumpObstructed;
void () CUJO_leap1;

/*
CUJO_allstop

sets the bots velocity to 0
*/

void () CUJO_allstop =
{
  if ((self.flags & FL_ONGROUND))
    self.velocity = '0 0 0';
};

/*
===============
CUJO_slowdown

halves the bot's velocity. used to make him less likely to fall off edges before jumping
===============
*/
void () CUJO_slowdown =
{
  self.velocity = self.velocity * 0.5;
};

/*
===============
CUJO_CheckGap

determines if there is an unwalkable gap directly in front of the bot
checking begins at dist units in front of the bot
===============
*/
float (float dist) CUJO_CheckGap =
{
  local   float   grade, out_dist, down_dist, solid_count;
  local   float   i, trace_dist, fwd_inc, tf_min, tf_max;
  local   vector  org, end;

// call makevectors before calling CheckGap!!!!!!!!!
//  makevectors (self.angles);

  org = self.origin;

  // check 64 units in front, foot level
  traceline (org, org - '0 0 24' + v_forward * (dist), TRUE, self);
  if (trace_fraction != 1.0)
    return FALSE;

  // check 64 units in front, waist level
  traceline (org, org + v_forward * (dist), TRUE, self);
  if (trace_fraction != 1.0)
  return FALSE;

  // check 64 units in front, eye level
  traceline (org, org + '0 0 16' + v_forward * (dist), TRUE, self);
  if (trace_fraction != 1.0)
  return FALSE;

  // no wall detected, so continue looking for gap
  trace_dist = 1000;
  fwd_inc = 8;
  // begin dist units in front of bot at waist level
  org = self.origin + v_forward * dist;
  // end trace_dist units below that
  end = org;
  end_z = end_z - trace_dist;
  solid_count = out_dist = down_dist = 0;

  tf_min = trace_dist;
  tf_max = 0;

  i = 0;
  // continue tracing 8 times, going further out each time
  while (i < 4)
  {
    // trace second line down, add height to down_dist, increment out_dist
    org = org + v_forward * fwd_inc;
    end = end + v_forward * fwd_inc;
    traceline (org, end, TRUE, self);

    // if first trace, set tf_min
    down_dist = trace_fraction * trace_dist;
    if (i == 0)
      tf_min = down_dist;
    else if (i == 3)
      tf_max = down_dist;

    // is their a solid object here < 24 units below bot's feet?
    if (trace_fraction * trace_dist < 48)
      solid_count = solid_count + 1;
    out_dist = out_dist + fwd_inc;

    i = i + 1;
  }

  down_dist = tf_max - tf_min;
  grade = down_dist / out_dist;

  // check for upward slope
//  if (tf_max < tf_min)
//    return FALSE;

  // are both max and min almost equal, but still far below?
  // if so, grade will be close to 0, but there is still a
  // dropoff

  if ((tf_max > (dist + 16)) && (tf_min > (dist + 16)) && (grade < 0.25))
    return TRUE;

  if ((grade > 1.75) && (solid_count < 1))
    return TRUE;
  else
    return FALSE;

};

/*
===============
CUJO_CheckWater

determines if there is an unwalkable gap directly in front of the bot
checking begins at dist units in front of the bot
===============
*/
float (float dist) CUJO_CheckWater =
{
  local   float   grade, out_dist, down_dist, water_count;
  local   float   i, trace_dist, fwd_inc, tf_min, tf_max;
  local   vector  org, end;

// call makevectors before calling CheckWater!!!!!!!!!
//  makevectors (self.angles);

  org = self.origin;

  // check 64 units in front, foot level
  traceline (org, org - '0 0 24' + v_forward * (dist), TRUE, self);
  if (trace_fraction != 1.0)
  {
//    return FALSE;

    // check 64 units in front, waist level
    traceline (org, org + v_forward * (dist), TRUE, self);
    if (trace_fraction != 1.0)
    {
//    return FALSE;

      // check 64 units in front, eye level
      traceline (org, org + '0 0 16' + v_forward * (dist), TRUE, self);
      if (trace_fraction != 1.0)
        return FALSE;
    }
  }
  // no wall detected, so continue looking for water
  trace_dist = 1000;
  fwd_inc = 8;
  // begin dist units in front of bot at waist level
  org = self.origin + v_forward * dist;
  // end trace_dist units below that
  end = org;
  end_z = end_z - trace_dist;
  water_count = 0;

  i = 0;
  // continue tracing 4 times, going further out each time
  while (i < 4)
  {
    // trace second line down, add height to down_dist, increment out_dist
    org = org + v_forward * fwd_inc;
    end = end + v_forward * fwd_inc;
    traceline (org, end, TRUE, self);

    if (trace_inwater)
      water_count = water_count + 1;

    i = i + 1;
  }

  if (water_count >= 3)
    return TRUE;
  else
    return FALSE;

};

/*
===============
CUJO_movetogoal

moves the bot using his velocity vectors, rather than discretely
===============
*/

void (float d) CUJO_movetogoal =
{
  //bprint ("movetogoal not implemented in Quake C! Remove CUJO_movetogoal!\n");
  movetogoal(d * 0.3);
  //CopterSparks();
  //   CopterSparks(self);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ                 Routines called by Cujo, self = Cujo                  บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

/*
======================
CUJO_Msg

bprints the passed strings, without a newline
======================
*/

void (string str1) CUJO_Msg =
{
  if (!self.CUJO_verbose) return;

  if (str1 != "")
    bprint (str1);
};

/*
======================
CUJO_Msgln

bprints the passed strings and a newline
======================
*/

void (string str1) CUJO_Msgln =
{
  if (!self.CUJO_verbose) return;

  if (str1 != "")
    bprint (str1);

  bprint ("\n");
};

/*
======================
CUJO_WaterLevel
======================
*/
float (entity ent) CUJO_WaterLevel =
{
  local   float   pc;

  makevectors (ent.angles);
  pc = pointcontents (ent.origin + v_forward * 16 + v_up * 10);

  // all the way under
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
    return 3;

  pc = pointcontents (ent.origin + v_forward * 16 + v_up * 4);
  // head out
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
    return 2;

  pc = pointcontents (ent.origin + v_forward * 16 - v_up * 12);
  // lower body and/or feet
  if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME) || (pc == CONTENT_LAVA))
    return 1;

  return 0;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_PrintCujoStatus                                                  บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_PrintCujoStatus =

{
  if (!deathmatch)
    sprint (self, "Cujo is not here.\n");
  else
  {
    if (self.Cujo_avail)
      sprint (self, "Cujo is not here.\n");
    else
      sprint (self, "Cujo is not available.\n");
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_ResetGoalEntity                                                  บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_ResetGoalEntity =

{
  self.oldenemy = self.enemy;
  self.enemy = world;

  self.goalentity = self.owner;
  self.movetarget = self.owner;
};

/*
  บ                                   บ
  บ Cujo_bite                         บ
  บ                                   บ
  */

void() CUJO_bite =
{
  local vector	delta;
  local float 	ldmg;

  if (!self.enemy) return;

  CUJO_ai_charge(10);

     emsam_shoot();

  if (!CanDamage (self.enemy, self)) return;

  delta = self.enemy.origin - self.origin;

  if (vlen(delta) > 100) return;

  // does twice the damage of a normal dog and has a random chance
  // of gibbing!

  if ((self.enemy.health < 10) && (random () < 0.1))
  {
    {
      ldmg = 50 * random ();
    }
  }
  else
  {
    ldmg = (random() + random() + random()) * 16;
  }

  T_Damage (self.enemy, self, self, ldmg);
};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_ChangeYaw                    บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_ChangeYaw =
{
  local float		ideal, move;

  current_yaw = anglemod (self.angles_y);
  ideal = self.ideal_yaw;

  if (current_yaw == ideal)
    return;

  move = ideal - current_yaw;
  if (ideal > current_yaw)
  {
    if (move > 180)
      move = move - 360;
  }
  else
  {
    if (move < -180)
      move = move + 360;
  }

  if (move > 0)
  {
    if (move > self.yaw_speed)
    move = self.yaw_speed;
  }
  else
  {
    if (move < 0-self.yaw_speed )
    move = 0-self.yaw_speed;
  }

  current_yaw = anglemod (current_yaw + move);
  if (fabs (ideal - current_yaw) < self.yaw_speed)
    current_yaw = ideal;


  self.angles_y = current_yaw;
};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_jumptouch                    บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void()	CUJO_JumpTouch =
{
  local	float	ldmg;

  if (self.health <= 0) return;

  if (other.takedamage)
  {
    if ( vlen(self.velocity) > 300 )
    {
      // Cujo now has a chance to gib on a jumping attack
      ldmg = 20 + 20*random();

      T_Damage (other, self, self, ldmg);
    }
  }

  self.touch = SUB_Null;
  self.think = CUJO_run1;
  self.nextthink = time + nextthinktime;
};


void() CUJO_stand1	=[	$stand1,	CUJO_stand2	] {CUJO_ai_stand();};
void() CUJO_stand2	=[	$stand1,	CUJO_stand1	] {CUJO_ai_stand();};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_walk1                        บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/


void() CUJO_walk1	=[	$walk1 ,	CUJO_walk2	]
{
  if (random() < 0.2)
    sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);

  CUJO_ai_walk (8);
};


void() CUJO_walk2	=[	$walk2 ,	CUJO_walk3	] {CUJO_ai_walk(8);};
void() CUJO_walk3	=[	$walk3 ,	CUJO_walk4	] {CUJO_ai_walk(8);};
void() CUJO_walk4	=[	$walk4 ,	CUJO_walk5	] {CUJO_ai_walk(8);};
void() CUJO_walk5	=[	$walk5 ,	CUJO_walk6	] {CUJO_ai_walk(8);};
void() CUJO_walk6	=[	$walk6 ,	CUJO_walk7	] {CUJO_ai_walk(8);};
void() CUJO_walk7	=[	$walk7 ,	CUJO_walk8	] {CUJO_ai_walk(8);};
void() CUJO_walk8	=[	$walk8 ,	CUJO_walk9	] {CUJO_ai_walk(8);};
void() CUJO_walk9	=[	$walk9 ,	CUJO_walk10	] {CUJO_ai_walk(8);};
void() CUJO_walk10	=[	$walk10 ,	CUJO_walk11	] {CUJO_ai_walk(8);};
void() CUJO_walk11	=[	$walk11 ,	CUJO_walk12	] {CUJO_ai_walk(8);};
void() CUJO_walk12	=[	$walk12 ,	CUJO_walk1	] {CUJO_ai_walk(8);};


/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_run1                         บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_run1		=[	$walk1  ,	CUJO_run2	]
{
  if (random() < 0.2)
    sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);

  CUJO_ai_run (16);
};

void() CUJO_run2		=[	$walk2  ,	CUJO_run3	] {CUJO_ai_run(32);};
void() CUJO_run3		=[	$walk3  ,	CUJO_run4	] {CUJO_ai_run(32);};
void() CUJO_run4		=[	$walk4  ,	CUJO_run5	] {CUJO_ai_run(20);};
void() CUJO_run5		=[	$walk5  ,	CUJO_run6	] {CUJO_ai_run(64);};
void() CUJO_run6		=[	$walk6  ,	CUJO_run7	] {CUJO_ai_run(32);};
void() CUJO_run7		=[	$walk7  ,	CUJO_run8	] {CUJO_ai_run(16);};
void() CUJO_run8		=[	$walk8  ,	CUJO_run9	] {CUJO_ai_run(32);};
void() CUJO_run9		=[	$walk9  ,	CUJO_run10	] {CUJO_ai_run(32);};
void() CUJO_run10	=[	$walk10  ,	CUJO_run11	] {CUJO_ai_run(20);};
void() CUJO_run11	=[	$walk11  ,	CUJO_run12	] {CUJO_ai_run(64);};
void() CUJO_run12	=[	$walk12  ,	CUJO_run1	] {CUJO_ai_run(32);};

void()	CUJO_follow1	=[	$walk1  ,	CUJO_follow2	]
{
  if (random() < 0.2)
    sound (self, CHAN_VOICE, "dog/idle.wav", 1, ATTN_IDLE);

  CUJO_ResetGoalEntity ();

  CUJO_ai_follow (18);
};
void()	CUJO_follow2	=[	$walk2  ,	CUJO_follow3	] {CUJO_ai_follow (32);};
void()	CUJO_follow3	=[	$walk3  ,	CUJO_follow4	] {CUJO_ai_follow (32);};
void()	CUJO_follow4	=[	$walk4  ,	CUJO_follow5	] {CUJO_ai_follow (20);};
void()	CUJO_follow5	=[	$walk5  ,	CUJO_follow6	] {CUJO_ai_follow (64);};
void()	CUJO_follow6	=[	$walk6  ,	CUJO_follow7	] {CUJO_ai_follow (32);};
void()	CUJO_follow7	=[	$walk7  ,	CUJO_follow8	] {CUJO_ai_follow (16);};
void()	CUJO_follow8	=[	$walk8  ,	CUJO_follow9	] {CUJO_ai_follow (32);};
void()  CUJO_follow9	=[	$walk9  ,	CUJO_follow10	] {CUJO_ai_follow(32);};
void()  CUJO_follow10	=[	$walk10  ,	CUJO_follow11	] {CUJO_ai_follow(20);};
void()  CUJO_follow11	=[	$walk11  ,	CUJO_follow12	] {CUJO_ai_follow(64);};
void()  CUJO_follow12	=[	$walk12  ,	CUJO_follow1	] {CUJO_ai_follow(32);};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_atta1                        บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_atta1	=[	$attack1,	CUJO_atta3	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta2	=[	$attack2,	CUJO_atta3	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta3	=[	$attack3,	CUJO_atta4	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta4	=[	$attack4,	CUJO_atta6	]
{
  sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);
  CUJO_bite();
  self.nextthink = time + 0.025;
};

void() CUJO_atta5	=[	$attack5,	CUJO_atta6	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta6	=[	$attack6,	CUJO_atta8	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta7	=[	$attack6,	CUJO_atta8	]
{
  ai_charge (3.2);
  self.nextthink = time + 0.025;
};
void() CUJO_atta8	=[	$attack6,	CUJO_run1       ]
{
  local   float   r;

  if (self.goalentity.classname == "dog_food")
  {
    // CUJO 1.3 - fix for BodyQue bug
    // don't remove a cujo or a player head, because they are in the
    // body que, simply change their classname to "head" and model to
    // "" and cujo will ignore them
    if ((self.goalentity.model == "progs/h_dog.mdl") ||
       (self.goalentity.model == "progs/player.mdl"))
    {
      self.goalentity.classname = "head";
      setmodel (self.goalentity, "");
    }
    else
      remove (self.goalentity);
    self.health = self.health + 15;

    if (self.health > 200)
      self.health = 200;

    r = random ();

    if (r < 0.25)
      sprint (self.owner, "P8 Likes his Gibby-chow!\n");
    else if (r < 0.5)
      sprint (self.owner, "P8 love a Gibby-Treat!\n");
    else if (r < 0.75)
      sprint (self.owner, "P8 ate some gibs.\n");
    else
      sprint (self.owner, "P8's eating his enemies again...\n");

  }
  else
    CUJO_ai_charge (10);

  self.nextthink = time + 0.025;

  CUJO_CheckRefire (CUJO_atta1);
};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_leap1                        บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_leap1	=[	$leap1,		CUJO_leap2	] {

	CUJO_ai_face();
	emsam_shoot();
	if (random()>0.1)
		self.think = CUJO_stand1;

};
void() CUJO_leap2	=[	$leap2,		CUJO_leap3	]
{
  CUJO_ai_face();
  self.touch = CUJO_JumpTouch;

  makevectors (self.angles);

  self.origin_z = self.origin_z + 1;
  self.velocity = v_forward * self.forward_jump_vel + v_up * self.upward_jump_vel;

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;
};

void() CUJO_leap3	=[	$leap3,		CUJO_leap4	] {};
void() CUJO_leap4	=[	$leap4,		CUJO_leap5	] {};
void() CUJO_leap5	=[	$leap5,		CUJO_leap6	] {};
void() CUJO_leap6	=[	$leap6,		CUJO_leap7	] {};
void() CUJO_leap7	=[	$leap7,		CUJO_leap7	] {};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_pain1                        บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_pain1	=[	$stand1 ,	CUJO_pain2	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_pain2	=[	$stand1 ,	CUJO_pain3	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_pain3	=[	$stand1 ,	CUJO_pain4	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_pain4	=[	$stand1 ,	CUJO_pain5	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_pain5	=[	$stand1 ,	CUJO_pain6	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_pain6	=[	$stand1 ,	CUJO_run1	]
{
  self.nextthink = time + 0.001;
};

void() CUJO_painb1	=[	$stand1 ,	CUJO_painb3	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb2	=[	$stand1 ,	CUJO_painb3	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb3	=[	$stand1 ,	CUJO_painb4     ]
{
  ai_pain (4);
  self.nextthink = time + 0.001;
};
void() CUJO_painb4	=[	$stand1 ,	CUJO_painb5	]
{
  ai_pain (12);
  self.nextthink = time + 0.001;
};
void() CUJO_painb5	=[	$stand1 ,	CUJO_painb6	]
{
  ai_pain (12);
  self.nextthink = time + 0.001;
};
void() CUJO_painb6	=[	$stand1 ,	CUJO_painb8	]
{
  ai_pain (2);
  self.nextthink = time + 0.001;
};
void() CUJO_painb7	=[	$stand1 ,	CUJO_painb8	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb8	=[	$stand1 ,	CUJO_painb10]
{
  ai_pain (4);
  self.nextthink = time + 0.001;
};
void() CUJO_painb9	=[	$stand1 ,	CUJO_painb10	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb10	=[	$stand1 ,	CUJO_painb12	]
{
  ai_pain (10);
  self.nextthink = time + 0.001;
};
void() CUJO_painb11	=[	$stand1 ,	CUJO_painb12	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb12	=[	$stand1 ,	CUJO_painb14	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb13	=[	$stand1 ,	CUJO_painb14	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb14	=[	$stand1 ,	CUJO_painb16	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb15	=[	$stand1 ,	CUJO_painb16	]
{
  self.nextthink = time + 0.001;
};
void() CUJO_painb16	=[	$stand1 ,	CUJO_run1	]
{
  self.nextthink = time + 0.001;
};

void() CUJO_pain =
{
  if (self.dmg_inflictor.classname == "fire")
  {
    if (random() > 0.5)
    {
      if (self.pain_finished > time)
        return;

      if (random () > 0.2)
      {
        CUJO_pain1 ();
        self.pain_finished = time + 0.6;
      }
      else
      {
        self.pain_finished = time + 1.6;
        CUJO_painb1 ();
      }

      sound (self, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);
    }
  }
  else
  {
    sound (self, CHAN_VOICE, "dog/dpain1.wav", 1, ATTN_NORM);

    if (random() > 0.5)
      CUJO_pain1 ();
    else
      CUJO_painb1 ();
  }
};

/*ษอออออออออออออออออออออออออออออออออออป
  บ                                   บ
  บ Cujo_die                          บ
  บ                                   บ
  บ Cujo deactivates self in last     บ
  บ frame                             บ
  บ                                   บ
  ศอออออออออออออออออออออออออออออออออออผ*/

void() CUJO_die1		=[	$stand1,	CUJO_die2	] {};
void() CUJO_die2		=[	$stand1,	CUJO_die3	] {};
void() CUJO_die3		=[	$stand1,	CUJO_die4	] {};
void() CUJO_die4		=[	$stand1,	CUJO_die5	] {};
void() CUJO_die5		=[	$stand1,	CUJO_die6	] {};
void() CUJO_die6		=[	$stand1,	CUJO_die7	] {};
void() CUJO_die7		=[	$stand1,	CUJO_die8	] {};
void() CUJO_die8		=[	$stand1,	CUJO_die9	] {};
void() CUJO_die9		=[	$stand1,	CUJO_die9	] {CUJO_SelfDeactivate ();};
/*
// used to set the dead-entity body to the correct final death frame
// then set up the next think to make the body disappear
void() CUJO_die10		=[	$death9,	CUJO_die10	]
{
  self.nextthink = time + 120;  // wait 2 minutes till body disappears
  self.think = SUB_Remove;
};
*/
void() CUJO_dieb1		=[	$stand1,	CUJO_dieb2	] {};
void() CUJO_dieb2		=[	$stand1,	CUJO_dieb3	] {};
void() CUJO_dieb3		=[	$stand1,	CUJO_dieb4	] {};
void() CUJO_dieb4		=[	$stand1,	CUJO_dieb5	] {};
void() CUJO_dieb5		=[	$stand1,	CUJO_dieb6	] {};
void() CUJO_dieb6		=[	$stand1,	CUJO_dieb7	] {};
void() CUJO_dieb7		=[	$stand1,	CUJO_dieb8	] {};
void() CUJO_dieb8		=[	$stand1,	CUJO_dieb9	] {};
void() CUJO_dieb9		=[	$stand1,	CUJO_dieb9	] {CUJO_SelfDeactivate ();};
/*
// used to set the dead-entity body to the correct final death frame
// then set up the next think to make the body disappear
void() CUJO_dieb10	        =[	$deathb9,	CUJO_dieb10	]
{
  self.nextthink = time + 120;  // wait 2 minutes till body disappears
  self.think = SUB_Remove;
};
*/

void() CUJO_die =
{
// check for gib
  if (self.health < -35)
  {
    sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
    ThrowGib ("progs/gib3.mdl", self.health);
    ThrowGib ("progs/gib3.mdl", self.health);
    ThrowGib ("progs/gib3.mdl", self.health);

    ThrowHead ("progs/fx_enginefire2.mdl", self.health);

    // Cujo heads only lay around for 2 minutes, then POOF!
//    self.nextthink = time + 120;
//    self.think = SUB_Remove;

    CUJO_SelfDeactivate ();

    return;
  }

// regular death
  sound (self, CHAN_VOICE, "dog/ddeath.wav", 1, ATTN_NORM);
  self.solid = SOLID_NOT;

  self.deadflag = DEAD_DYING;

  if (random() > 0.5)
    CUJO_die1 ();
  else
    CUJO_dieb1 ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_checkmelee                                                       บ
  บ                                                                       บ
  บ Returns TRUE if a melee attack would hit right now                    บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float()	CUJO_CheckMelee =
{
  local   float   dist;

  dist = vlen (self.goalentity.origin - self.origin);

  if ( ((self.goalentity.classname == "dog_food") && (dist < 1000)) ||
      ((self.goalentity.classname != "dog_food") && (dist < 500)) )
//  if (goal_range == RANGE_MELEE)
  {
    self.attack_state = AS_MELEE;

    return TRUE;
  }

  return FALSE;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_checkjump                                                        บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float()	CUJO_CheckJump =
{
  local	vector	dist;
  local	float	d;

  if (self.origin_z + self.mins_z > self.goalentity.origin_z + self.goalentity.mins_z
  + 0.75 * self.goalentity.size_z)
    return FALSE;

  if (self.origin_z + self.maxs_z < self.goalentity.origin_z + self.goalentity.mins_z
  + 0.25 * self.goalentity.size_z)
    return FALSE;

  dist = self.goalentity.origin - self.origin;
  dist_z = 0;

  d = vlen(dist);

  if (d < 800) return FALSE;

  if (d > 1500) return FALSE;

  return TRUE;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_SpawnMarker                                                      บ
  บ                                                                       บ
  บ For debugging:  spawns a temporary marker at the passed location      บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void (vector org, string mdl_name) CUJO_SpawnMarker =
{
  local   entity  marker;

  marker = spawn ();

  marker.solid = SOLID_NOT;
  marker.movetype = MOVETYPE_NONE;
  marker.think = SUB_Remove;
  marker.nextthink = time + 10;
  marker.takedamage = DAMAGE_NO;
  marker.classname = "debug_marker";

  setsize (marker, '0 0 0', '0 0 0');
  setorigin (marker, org);
  setmodel (marker, mdl_name);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_FindLedge                                                        บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float (float start_dist) CUJO_FindLedge =

{
  local   float   i;
  local   vector  org, end, above_org;
  local   float   highest, pc;
  local   float   found_ledge;
  local   float   ledge_height;

  local   float   max_mul;

  if (start_dist > 440)
    return 0;

  makevectors (self.angles);
  // start origin is 48 units above Cujo's origin
  above_org = self.origin + (v_up * 48);

  ledge_height = 0.096;
  found_ledge = FALSE;
  i = start_dist + 30;

  while ((i <= 440) && (!found_ledge))
  {
    // check the four corners of a 30x30 unit square i units in front of cujo
    // upper right corner
    org = above_org + (v_forward * (i + 30)) + (v_right * 15);
    end = org - (v_up * 1000);
    traceline (org, end, FALSE, self);
    highest = trace_fraction;

    // upper left corner
    if (trace_fraction <= ledge_height)
    {
      org = above_org + (v_forward * (i + 30)) - (v_right * 15);
      end = org - (v_up * 1000);
      traceline (org, end, FALSE, self);
      if (trace_fraction < highest) highest = trace_fraction;

      if (trace_fraction <= ledge_height)
      {
        // lower right corner
        org = above_org + (v_forward * i) + (v_right * 15);
        end = org - (v_up * 1000);
        traceline (org, end, FALSE, self);
        if (trace_fraction < highest) highest = trace_fraction;

        if (trace_fraction <= ledge_height)
        {
          // lower corner
          org = above_org + (v_forward * i) - (v_right * 15);
          end = org - (v_up * 1000);
          traceline (org, end, FALSE, self);
          if (trace_fraction < highest) highest = trace_fraction;

          if (trace_fraction <= ledge_height)
          {
            // center
            org = above_org + (v_forward * (i + 15));
            end = org - (v_up * 1000);
            traceline (org, end, FALSE, self);
            if (trace_fraction < highest) highest = trace_fraction;

            if (trace_fraction <= ledge_height)
            {
              // half way between center and left back corner
              org = above_org + (v_forward * (i + 7.5)) - (v_right * 7.5);
              end = org - (v_up * 1000);
              traceline (org, end, FALSE, self);
              if (trace_fraction < highest) highest = trace_fraction;

              if (trace_fraction <= ledge_height)
              {
                // half way between center and right back corner
                org = above_org + (v_forward * (i + 7.5)) + (v_right * 7.5);
                end = org - (v_up * 1000);
                traceline (org, end, FALSE, self);
                if (trace_fraction < highest) highest = trace_fraction;

                if (trace_fraction <= ledge_height) found_ledge = TRUE;
              }
            }
          }
        }
      }
    }
    i = i + 30;
  }

  if (found_ledge)
  {
    //FIXME: predict velocities based on server gravity

    max_mul = 2.2;

    highest = highest * 1000;
    // is ledge above Cujo's origin?
    if (highest < 48)
    {
      self.upward_jump_vel = 270;
      self.forward_jump_vel = i * 1.5 + 50;
    }
    else
    {
      self.upward_jump_vel = 270;
      self.forward_jump_vel = i * 1.5 + 50;
      return i;
    }
  }
  else
    return 0;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_JumpObstructed                                                   บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float (float dist) CUJO_JumpObstructed =

{
  local   vector  org, end;
  local   float   pc;

  // CALL MAKEVECTORS BEFORE CALLING THIS ROUTINE!!!!
//  makevectors (self.angles);
  org = self.origin;
  end = self.origin + (v_forward * dist);

  traceline (org, end, FALSE, self);

  if (trace_fraction < 1.0)
  {
    CUJO_allstop ();
    return TRUE;
  }
  else
    return FALSE;
};
/*
float (float dist) CUJO_JumpObstructed =

{
  local   vector  org, end;
  local   float   pc;

  makevectors (self.angles);
  org = self.origin;
  end = self.origin + (v_forward * dist);

  traceline (org, end, FALSE, self);
  pc = pointcontents (trace_endpos);

  if ((trace_fraction < 1.0) || (pc == CONTENT_SOLID))
    return TRUE;
  else
    return FALSE;
};
*/

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_JumpAI                                                           บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float () CUJO_JumpAI =
{
  local   vector  dir, org, end, yaw;
  local   float   dist, pc, i, yaw_add;

  if (!(self.flags & FL_ONGROUND)) return FALSE;

  // get vectors!
  makevectors (self.angles);

  // check to make sure there's no wall in front, or we could be
  // tracing for a jump outside the map!
  traceline (self.origin, self.origin + v_forward * 32, TRUE, self);
  if (trace_fraction != 1.0)
    return FALSE;

  // make sure there's not a small barrier at the feet preventing a jump from going
  // forward
  org = self.origin + v_forward * 32;
  traceline (org, org - '0 0 24', TRUE, self);
  if (trace_fraction != 1.0) return FALSE;

  org = self.origin;
  end = self.goalentity.origin;

  if (self.dmg_inflictor.classname == "fire")
  {
    i = 32;
    dist = pc = 0;
    while ((i < 256) && (dist == 0) && (pc != CONTENT_WATER) && (pc != CONTENT_SLIME))
    {
      dist = CUJO_CheckWater (i);
      traceline (self.origin + v_forward * i, self.origin + v_forward * i - '0 0 1000', TRUE, self);
      pc = pointcontents (trace_endpos + '0 0 2');
      if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME))
        dist = i;

      i = i + 32;
    }

    if (!dist)
    {
      yaw_add = 22.5;
      pc = CONTENT_SOLID;
      i = 0;

      while ((i < 16) && (dist == 0))
      {
        traceline (self.origin + v_forward * 128, self.origin + v_forward * 128 - '0 0 1000', TRUE, self);
        pc = pointcontents (trace_endpos + '0 0 2');
        if ((pc == CONTENT_WATER) || (pc == CONTENT_SLIME))
        {
          dist = 128;
          yaw = vectoangles (v_forward);
          self.ZEUS_stuck = TRUE;
          self.ZEUS_stuck_dir = 0;
          self.angles_y = yaw_y;
          self.ideal_yaw = yaw_y;
        }
        else
        {
          yaw = vectoangles (v_forward);
          yaw_y = yaw_y + yaw_add;
          makevectors (yaw);
        }

        i = i + 1;
      }
    }

    if (dist)
    {
      self.upward_jump_vel = 270;
      end = self.goalentity.origin - self.origin;
      end_z = 0;
      dist = vlen (end);
//      if (dist > 300) dist = 300;
      self.forward_jump_vel = dist * 1.6 + 50;

      if (self.deadflag == DEAD_NO) CUJO_leap1 ();

      return TRUE;
    }
  }
  else if (org_z - end_z > 24)
  {
    dist = CUJO_CheckWater (32);
    if (!dist)
      dist = CUJO_CheckGap (32);

    pc = pointcontents (self.goalentity.origin);

    if ((dist) && (pc != CONTENT_LAVA) && (pc != CONTENT_SLIME))
    {
      self.upward_jump_vel = 270;
      end = self.goalentity.origin - self.origin;
      end_z = 0;
      dist = vlen (end);
//      if (dist > 300) dist = 300;
      self.forward_jump_vel = dist * 1.5 + 100;

      if (self.deadflag == DEAD_NO) CUJO_leap1 ();

      return TRUE;
    }
  }
/*
  else
  {
    // turn ZEUS to _exactly_ the direction of his goal entity
    dir = self.goalentity.origin - self.origin;
    dir = normalize (dir);

    dist = CUJO_CheckWater (64);

    if (dist <= 0)
    {
        dist = CUJO_CheckGap (64);
    }

    if ((dist > 0) && (dist < 150) && (vlen (self.goalentity.origin - self.origin) >= dist))
    {
      dist = CUJO_FindLedge (64);

      if ((!CUJO_JumpObstructed (dist)) && (dist > 0) && (dist < 320))
      {
        if (self.deadflag == DEAD_NO) CUJO_leap1 ();

        return TRUE;
      }
    }
  }
*/
  return FALSE;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_checkattack                                                      บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// this checks the attack against self.goalentity not self.enemy!

float()	CUJO_CheckAttack =
{
  local	vector	vec;

  if ((((self.goalentity == self.owner) || (self.goalentity.classname == "monster_zombie"))
      || (self.Cujo_attack == FALSE)) && (self.goalentity.classname != "dog_food"))
  {
    CUJO_ResetGoalEntity ();

    self.think = self.th_stand;
    self.nextthink = time + nextthinktime;

    return FALSE;
  }

  if (CUJO_CheckMelee ())
  {
    self.attack_state = AS_MELEE;
    return TRUE;
  }

  if (self.goalentity.classname != "dog_food")
  {
    if (CUJO_CheckJump ())
    {
      self.attack_state = AS_MISSILE;
      return TRUE;
    }
  }

  return FALSE;

};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_ai_run_melee                                                     บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_ai_run_melee =
{
  CUJO_ai_face ();

  if (FacingIdeal())
  {
    self.th_melee ();
    self.attack_state = AS_STRAIGHT;
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_ai_run_missile                                                   บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_ai_run_missile =
{
  CUJO_ai_face ();

  if (FacingIdeal())
  {
    self.upward_jump_vel = 270;
    self.forward_jump_vel = 360;
    self.th_missile ();
    self.attack_state = AS_STRAIGHT;
  }
};

/*
======================
CUJO_CheckWaterJump

Total hack, I'm tired
======================
*/

void() CUJO_CheckWaterJump =
{
  local   vector  start, end;
  local   vector  dir, org;
  local   float   pc;

  //determine if there is an open space at head height
  org = self.origin + v_up * 56;
  traceline (org, org + v_forward * 32, TRUE, self);
  if (trace_fraction < 1.0)
    return;

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 32 + v_up * 32;
  traceline (org, org - v_up * 32, TRUE, self);

  // was 0.8
  if ((trace_fraction < 1.0))
  {
    self.velocity_z = 150 + (1.0 - trace_fraction) * 300;
    if (self.flags & FL_ONGROUND) setorigin (self, self.origin + '0 0 1');
    self.flags = self.flags | FL_WATERJUMP;
  }
};

/*
void() CUJO_CheckWaterJump =
{
  local   vector  start, end;
  local   vector  dir, org;
  local   float   pc;

  CUJO_ai_face ();
  makevectors (self.angles);

  // use trace_line to find obstacles on floor
  org = self.origin + v_forward * 32 + v_up * 64;
  pc = pointcontents (org);
  traceline (org, org - '0 0 64', TRUE, self);

  // was 0.8
  if ((trace_fraction < 1.0) & (pc == CONTENT_EMPTY))
  {
    self.velocity_z = 150 + (1.0 - trace_fraction) * 300;
    self.flags = self.flags | FL_WATERJUMP;
  }
};
*/
/*
======================
CUJO_ai_swim
======================
*/

void () CUJO_ai_swim =
{
  local   vector  org, end, dir, ang;
  local   float   dist;

//  CUJO_Msgln (ftos (CUJO_WaterLevel (self)));
  CUJO_ai_face ();

  if (self.flags & FL_ONGROUND)
    self.flags = self.flags - FL_ONGROUND;

  org = self.origin;
  end = self.goalentity.origin;
  dir = normalize (end - org);
  ang = vectoangles (dir);
  makevectors (ang);

  if ((self.goalentity != world))
  {
    self.velocity = dir * 320;
  }
  else
  {
   // go for air
   CUJO_Msgln ("Going for surface.");
  }

  CUJO_CheckWaterJump ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_ai_run                                                           บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void(float dist) CUJO_ai_run =
{
  local	vector	delta;
  local	float	axis;
  local	float	direct, ang_rint, ang_floor, ang_ceil, f_temp;
  local string  str_temp;

//  sprint (self.owner, "-- enter ai_run --\n");

  movedist = dist;//Tei

//  sprint (self.owner, "Enemy is ");
//  sprint (self.owner, self.enemy.classname);
//  sprint (self.owner, "\n");
//  sprint (self.owner, "Goalentity is ");
//  sprint (self.owner, self.goalentity.classname);
//  sprint (self.owner, "\n");

  if ((self.goalentity.classname != "dog_food") && (self.goalentity.health <= 0))
  {
    CUJO_ResetGoalEntity ();

    //sprint (self.owner, "CUJO_ai_run: reset goalentity\n");

    if (self.oldenemy.health > 0)
    {
      self.enemy = self.oldenemy;
      self.goalentity = self.oldenemy;

      CUJO_HuntTarget ();
    }
    else
    {
      if (CUJO_FindTarget()) return;
      else
      {
        CUJO_ResetGoalEntity ();

        //sprint (self.owner, "CUJO_ai_run #2: reset goalentity\n");

        self.th_walk ();

//        sprint (self.owner, "-- Left ai_run at return 1 --\n");
        return;
      }
    }

//    sprint (self.owner, "-- Left ai_run at return 2 --\n");
    return;
  }

  if (self.goalentity.classname != "dog_food")
    self.show_hostile = time + 1;		// wake up other monsters

  goal_vis = visible(self.goalentity);
  if (goal_vis) self.search_time = time + 5;

  goal_infront = infront (self.goalentity);
  goal_range = range (self.goalentity);
  goal_yaw = vectoyaw (self.goalentity.origin - self.origin);

  if ((self.attack_state == AS_MISSILE) && (self.goalentity.classname != "dog_food"))
  {
    CUJO_ai_run_missile ();
    return;
  }
  if (self.attack_state == AS_MELEE)
  {

// for debugging
//    f_temp = vlen (self.origin - self.goalentity.origin);
//    str_temp = ftos (f_temp);

//    sprint (self.owner, "Cujo is ");
//    sprint (self.owner, str_temp);
//    sprint (self.owner, " units from ");
//    sprint (self.owner, self.goalentity.classname);
//    sprint (self.owner, ".\n");

    CUJO_ai_run_melee ();

    return;
  }

  if (CUJO_JumpAI ()) return;           // needs to jump to goal
  if (CUJO_CheckAttack ()) return;	// beginning an attack

  if (CUJO_WaterLevel (self) > 1)
    CUJO_ai_swim ();
  else
    CUJO_movetogoal (dist);		// done in C code...

//  sprint (self.owner, "-- exit ai_run --\n");
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_SightSound                                                       บ
  บ                                                                       บ
  บ dog stands in place until target acquired or paustime is exceeded     บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_SightSound =
{
  sound (self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_HuntTarget                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_HuntTarget =
{
// for debugging
  //sprint (self.owner, "CUJO_HuntTarget: ");
  //sprint (self.owner, self.goalentity.classname);
  //sprint (self.owner, "\n");

  self.think = self.th_run;
  self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
  self.nextthink = time + nextthinktime;

  SUB_AttackFinished (0.1);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_FoundTarget                                                      บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_FoundTarget =
{
  local float   f_dist;
  local string  s_dist;
  local float   r;

  f_dist = vlen (self.goalentity.origin - self.origin);
  s_dist = ftos (f_dist);

  self.show_hostile = time + 1;		// wake up other monsters

  r = random ();

  if (r < 0.5)
    sprint (self.owner, "CONTACT!\n");
  else
    sprint (self.owner, "CHARLY!\n");

// for debugging
  //sprint (self.owner, "Cujo seeking target");
  //sprint (self.owner, self.goalentity.classname);
  //sprint (self.owner, "\n");

  CUJO_SightSound ();

  CUJO_HuntTarget ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_FindTarget                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float() CUJO_FindTarget =
{
  local entity   head, selected;
  local entity   food;
  local float    dist, lastd;
  local float    food_dist, food_lastd;

  // check for any enemies visible to Cujo
  dist = 600;
  food_dist = 600;
  selected = world;
  food = world;

  head = findradius(self.origin, dist);

  // CUJO 1.3 - trace_plane_dist was always equal to zero for some
  // unknown reason, so the code that used it was replaced
  while(head)
  {
    // search for food
    if ((head.classname == "dog_food") && (visible (head)))
    {
      if ((head != self) && (head != self.owner))
      {
        food_lastd = vlen (self.origin - head.origin);
        if (food_lastd < food_dist)
        // for efficiency's sake, go after the closest gib
        {
          food = head;
          food_dist = food_lastd;
        }
      }
    }

    // search for enemy
    if(!(head.flags & FL_NOTARGET) && ((head.flags & FL_CLIENT) || (head.flags & FL_MONSTER) ||
        (head.classname == "cujo")))
      if (((teamplay) &&  (head.team != self.owner.team)) || (!teamplay))
	if ( self.ts != self.owner.ts )//Tei for airquake
        if ((head.health > 0) && (head != self) && (head != self.owner))
          if ((visible(head)) && (head.classname != "monster_zombie"))
          {
            lastd = vlen (self.origin - head.origin);
            if (lastd < dist)
            {
              selected = head;
              dist = lastd;
            }
          }
    head = head.chain;
  }

  self.enemy = selected;

  if ((food != world) && (food != self.owner) && (self.Cujo_attack)
    && ((self.health < 50) || ((deathmatch) && (self.health < 25))))
  {
    self.goalentity = food;
    self.enemy = food;

    CUJO_FoundTarget ();

    return TRUE;
  }
  else if ((self.enemy == world) || (self.enemy == self.owner))
  {
    if ((food != world) && (food != self.owner) && ((self.health < 191) &&
        (self.Cujo_attack)))
    {
      self.goalentity = food;
      self.enemy = food;

      CUJO_FoundTarget ();

      return TRUE;
    }

    return FALSE;
  }
  else  // an enemy target has been sighted
  {
    if (!(self.Cujo_attack) || (self.enemy.classname == "dog_food"))
    // if not supposed to attack, just growl
    {
      if (random () < 0.10)
      {
        // make Cujo bark or growl
        if (random () < 0.5)
          sound (self, CHAN_VOICE, "dog/dsight.wav", 1, ATTN_NORM);
        else
          sound (self, CHAN_VOICE, "dog/dattack1.wav", 1, ATTN_NORM);
      }

      CUJO_ResetGoalEntity ();

      return FALSE;
    }

    // if Cujo is staying, make him attack!
    self.Cujo_stay = FALSE;

    self.goalentity = self.enemy;

    CUJO_FoundTarget();

    return TRUE;
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_ai_face                                                          บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_ai_face =
{
  if (self.ZEUS_stuck)
    self.ideal_yaw = self.ideal_yaw + self.ZEUS_stuck_dir;
  else
    self.ideal_yaw = vectoyaw (self.goalentity.origin - self.origin);

  CUJO_ChangeYaw ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_ai_charge                                                        บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void (float d) CUJO_ai_charge =
{
  CUJO_ai_face ();

  CUJO_movetogoal (d);		// done in C code...
};

/*
  บ Cujo_ai_stand                                                         บ
  บ dog stands in place until target acquired or paustime is exceeded     บ
*/

void() CUJO_ai_stand =
{
  if (CUJO_FindTarget ()) return;

 //etank_stand();

  if (vlen (self.origin - self.owner.origin) > teleport_dist)
  {
    CUJO_TeleportToOwner ();
  }
  else if (vlen (self.origin - self.owner.origin) > 100)
  {
    // if Cujo is staying, then he shouldn't run in place!
    if (self.Cujo_stay == TRUE) return;

    CUJO_follow1 ();

    return;
  }

  if (CUJO_JumpAI ()) return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_ai_walk                                                          บ
  บ                                                                       บ
  บ Cujo is walking and searching for targets                             บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void(float dist) CUJO_ai_walk =
{
  if (CUJO_FindTarget ()) return;

  if (vlen (self.origin - self.owner.origin) > 100)
  {
    CUJO_follow1();

    return;
  }
  else if (vlen (self.origin - self.owner.origin) > teleport_dist)
  {
    CUJO_TeleportToOwner ();
  }

  if (CUJO_WaterLevel (self) > 1)
    CUJO_ai_swim ();
  else
  {
    if (CUJO_JumpAI ()) return;

    CUJO_movetogoal (dist);  // this is done in C code
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_ai_follow                                                        บ
  บ                                                                       บ
  บ Cujo is following player and searching for targets                    บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void(float dist) CUJO_ai_follow =
{
  if (CUJO_FindTarget ()) return;

  //sprint (self.owner, "Following owner.\n");
  //sprint (self.owner, "Goalentity is ");
  //sprint (self.owner, self.goalentity.classname);
  //sprint (self.owner, "\n");
  //sprint (self.owner, "Enemy is ");
  //sprint (self.owner, self.enemy.classname);
  //sprint (self.owner, "\n");
  //sprint (self.owner, "Movetarget is ");
  //sprint (self.owner, self.movetarget.classname);
  //sprint (self.owner, "\n");

  // if Cujo is in STAY mode then do not follow the player!

  if ((vlen (self.origin - self.owner.origin) <= 100) || (self.Cujo_stay))
  {
    self.pausetime = time + 2;

    self.th_stand ();

    return;
  }
  else if ((vlen (self.origin - self.owner.origin) > teleport_dist) &&
          (!intermission_running))
  {
    CUJO_TeleportToOwner ();
  }

  if (CUJO_WaterLevel (self) > 1)
    CUJO_ai_swim ();
  else
  {
    if (CUJO_JumpAI ()) return;

    CUJO_movetogoal (dist);  // done in C code
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_ai_turn                                                          บ
  บ                                                                       บ
  บ Turn Cujo towards ideal_yaw if no enemies were sighted                บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void() CUJO_ai_turn =
{
  if (CUJO_FindTarget ()) return;

  CUJO_ChangeYaw ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_CheckRefire                                                      บ
  บ                                                                       บ
  บ Determine if the enemy is still visible for attack                    บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void (void () thinkst) CUJO_CheckRefire =
{
  if (!visible (self.goalentity) || (self.goalentity.health <= 0))
  {
    CUJO_ResetGoalEntity ();

    self.think = self.th_stand;
    self.nextthink = time + nextthinktime;

    return;
  }

//  self.think = thinkst;  // was thinkst
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_CorpsePain                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_CorpsePain =
{
 SpawnMeatSpray (self.origin, crandom() * 100 * v_right);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ CUJO_CorpseDie;                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_CorpseDie =
{
  local   float   i;
  local   float   j;

  sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

  // throw the head -- can be a player head or a cujo head only in this version!
  ThrowHead (self.weaponmodel, self.health);

  i = 0;

  while(i<3)
  {
    j = random();

    if(j > 0.6)
      ThrowGib ("progs/gib1.mdl", self.health);
    else if(j > 0.3)
      ThrowGib ("progs/gib2.mdl", self.health);
    else
      ThrowGib ("progs/gib3.mdl", self.health);

    i = i + 1;
  }

// Cujo's head only stays around for 2 minutes...
//  self.nextthink = time + 120;
//  self.think = SUB_Remove;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_SelfDeactivate                                                   บ
  บ                                                                       บ
  บ Cujo deactivates himself (when he is killed, basically)               บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_SelfDeactivate =
{
  local   entity  temp_self;
  local   string  deathstr, tempstr;

  temp_self = self;
  self = self.owner;

  if (self.Cujo_view)
    CUJO_SetPlayerView ();

  self = temp_self;

  // create a dummy Cujo body... this alleviates the problem of the
  // original Cujo entity becoming lost if the player reactivates Cujo
  // before the body has disappeared

//  self.classname = "cujo_body";

  // create a body in the que which is solid
  self.weaponmodel = "progs/fx_enginefire2.mdl";
  CopyToBodyQue (self);

  if (self.enemy == self.owner)
  {
    if (self.health < -35)
    {
      sprint (self.owner, "You just turned Cujo into puppy chow.\n");
    }
    else
    {
      sprint (self.owner, "You buried your dog.\n");
    }
  }
  else if (self.enemy.classname == "player")
  {
    deathstr = self.enemy.netname;
    if (self.health < -35)
    {
      tempstr = " just chunked your dog.\n";
    }
    else
    {
      if (random () < 0.5)
      {
        tempstr = " taught Cujo to play dead.\n";
      }
      else
      {
        tempstr = " took Cujo to the pound.\n";
      }
    }

    sprint (self.owner, deathstr);
    sprint (self.owner, tempstr);
  }
  else
  {
    if (self.health < -35)
    {
      sprint (self.owner, "Cujo is kibbles and bits.\n");
    }
    else
    {
      sprint (self.owner, "Cujo went to dog heaven.\n");
    }
  }

  self.owner.Cujo_flag = FALSE;
  remove (self);
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_TeleportPos                                                      บ
  บ                                                                       บ
  บ Determines the best position for Cujo to spawn in                     บ
  บ This procedure is to be called from Cujo's routines, not the player's บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

vector () CUJO_TeleportPos =
{
  local vector  org, temp, right, front;

  org = self.owner.origin;

  makevectors (self.owner.angles);

  // make front equal 50 units in front of the player
  front = 50 * normalize (v_forward);
  // and right equal fifty units to the right
  right = 50 * normalize (v_right);


  // right of player

  temp = org + right;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // left of player

  temp = org - right;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // in front of player

  temp = org + front;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // behind player

  temp = org - front;
  if (CUJO_CheckSpawnPos (temp)) return temp;

};


/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_TeleportToOwner                                                  บ
  บ                                                                       บ
  บ Cujo teleports to his owner, the player                               บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_TeleportToOwner =
{
  local vector org;

  // exit if in intermission or if Cujo is staying
  if ((intermission_running) || (self.Cujo_stay)) return;

  // Check to see if there is room to teleport Cujo here, if not, say so and
  // exit.
  org = CUJO_TeleportPos ();
  if (org == '0 0 0')
    return;

  sprint (self.owner, "Whoof!\n");
  sound (self, CHAN_BODY, "dog/dsight.wav", 1, ATTN_NORM);

  spawn_tfog (self.origin);

  self.angles = '0 0 0';
  self.ideal_yaw = self.angles * '0 1 0';
  self.pausetime = time + 5;
  self.nextthink = time + nextthinktime;
  self.think = self.Cujo.th_stand;

  setorigin(self, org);

  spawn_tfog (self.origin);
  self.nextthink = time + nextthinktime;
  self.think = self.th_stand;

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ                 Routines called by player, self=player                บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Precache                                                         บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_Precache =
{
  // Precache Cujo's sounds
  //precache_model2 ("progs/h_cujo.mdl");
  //precache_model2 ("progs/cujo.mdl");

  precache_sound2 ("dog/dattack1.wav");
  precache_sound2 ("dog/ddeath.wav");
  precache_sound2 ("dog/dpain1.wav");
  precache_sound2 ("dog/dsight.wav");
  precache_sound2 ("dog/idle.wav");
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_CheckSpawnPos                                                    บ
  บ                                                                       บ
  บ Returns true if Cujo's bounding box area around SpawnPos is free of   บ
  บ solid objects                                                         บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

float (vector SpawnPos) CUJO_CheckSpawnPos =
{
  local  vector  XVector, YVector, ZPosVec, ZNegVec;
  local  vector  HalfYVec, HalfXVec, HalfZPosVec, HalfZNegVec;
  local  float   pc;

  // These vector offsets match Cujo's current size, but do not match
  // the exact size of the Dog model (which was too big to follow the
  // player some places), so the dog may at times look like his head
  // is in a wall, but he shouldn't get stuck (we hope).

  XVector = '16 0 0';
  HalfXVec = '8 0 0';

  YVector = '0 16 0';
  HalfYVec = '0 16 0';

  ZPosVec = '0 0 16';
  HalfZPosVec = '0 0 8';
  ZNegVec = '0 0 -24';
  HalfZNegVec = '0 0 -12';

  // check the very center of the box, just in case something is floating
  // there (for example, the moving "key cubes" at the end of e1m2)

  pc = pointcontents (SpawnPos);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  // check half the distance to each face of the box.  Again, this is
  // for floating or thin objects which might fit in between the face
  // edge and the center of the face

  pc = pointcontents (SpawnPos + HalfXVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - HalfXVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + HalfYVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - HalfYVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + HalfZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + HalfZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;


  // this checks the six faces of each side of Cujo's bounding box

  pc = pointcontents (SpawnPos + XVector);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - XVector);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + YVector);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - YVector);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + ZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + ZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;


  // Check the eight vertices of Cujo's bounding box

  pc = pointcontents (SpawnPos + XVector + YVector + ZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + XVector + YVector + ZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + XVector - YVector + ZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + XVector - YVector + ZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - XVector + YVector + ZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - XVector + YVector + ZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - XVector - YVector + ZPosVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - XVector - YVector + ZNegVec);
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;


  // check the center of each edge of the box for content type
  // first check the center of the top 4 edges of the bounding box

  pc = pointcontents (SpawnPos + (YVector + ZPosVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - (YVector + ZPosVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + (XVector + ZPosVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - (XVector + ZPosVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  // now check the center of the middle 4 edges of the bounding box

  pc = pointcontents (SpawnPos - (XVector + YVector));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - (XVector - YVector));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + (XVector + YVector));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + (XVector - YVector));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  // now check the center of the bottom 4 edges of the bounding box

  pc = pointcontents (SpawnPos + (YVector + ZNegVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - (YVector + ZNegVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos + (XVector + ZNegVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  pc = pointcontents (SpawnPos - (XVector + ZNegVec));
  if (pc != CONTENT_EMPTY && pc != CONTENT_WATER) return FALSE;

  // if that doesn't check enough spots, then that's just too bad.

  return TRUE;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_SpawnPos                                                         บ
  บ                                                                       บ
  บ Determines the best position for Cujo to spawn in                     บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

vector () CUJO_SpawnPos =
{
  local vector  org, temp, right, front;

  org = self.origin;

  makevectors (self.angles);

  // make front equal 50 units in front of the player
  front = 50 * normalize (v_forward);
  // and right equal fifty units to the right
  right = 50 * normalize (v_right);


  // right of player

  temp = org + right;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // left of player

  temp = org - right;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // in front of player

  temp = org + front;
  if (CUJO_CheckSpawnPos (temp)) return temp;

  // behind player

  temp = org - front;
  if (CUJO_CheckSpawnPos (temp)) return temp;

};


/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Activate                                                         บ
  บ                                                                       บ
  บ Called by player, self = player                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_Activate =
{
  local entity  dogbot;
  local vector  org;
  local float   bit;

  // Check to see if there is room to spawn Cujo here, if not, say so and
  // exit.

  if (deathmatch)
    org = cujo_org + '0 0 24';
  else
  {
    org = CUJO_SpawnPos ();
    if (org == '0 0 0')
    {
      sprint (self, "There is no room for P8 here.\n");
      return;
    }
  }

  // Spawn Cujo

  dogbot = spawn();
  dogbot.solid = SOLID_BBOX;
  dogbot.movetype = MOVETYPE_STEP;
  dogbot.CUJO_verbose = TRUE;

  dogbot.angles = self.angles;
  dogbot.classname = "cujo";
  dogbot.owner=self;
  self.Cujo=dogbot;
  self.Cujo_flag = TRUE;
  self.Cujo_view = FALSE;
  self.Cujo.Cujo_attack = TRUE;
  self.Cujo.Cujo_stay = FALSE;

  dogbot.takedamage = DAMAGE_AIM;
  dogbot.goalentity = self;
  dogbot.movetarget = self;
  dogbot.pausetime = time + 5;
  dogbot.ideal_yaw = dogbot.angles * '0 1 0';
  dogbot.yaw_speed = 8;//90; // was 30 for a normal dog, looks really odd from Cujo's view

  // lowered Cujo's view offset to 15 above the center of it's bounding box
  // (I have no idea if this is exactly right...)

  dogbot.view_ofs = '0 0 15';

  // this dog has some badass armor

  dogbot.health = 200;
  bit = IT_ARMOR3;
  dogbot.armortype = 0.8;
  dogbot.armorvalue = 200;
  dogbot.items = other.items - (other.items & (IT_ARMOR1 | IT_ARMOR2 | IT_ARMOR3)) + bit;
    dogbot.ammo_rockets = 4;//Tei

  // Set to automatic mode sequences at startup

  dogbot.th_stand = CUJO_stand1;
  dogbot.th_walk = CUJO_walk1;
  dogbot.th_run = CUJO_run1;
  dogbot.th_pain = CUJO_pain;
  dogbot.th_die = CUJO_die;
  dogbot.th_melee = CUJO_atta1;
  dogbot.th_missile = CUJO_leap1;
  dogbot.deadflag = DEAD_NO;

  dogbot.team = self.team;		// Tei
  dogbot.ts 	= self.ts;		// Tei

  
  setmodel (dogbot, "progs/p8.mdl");

  // Cujo's size was made the same as the player, (except for his height)
  // because he was having trouble getting though some narrow doorways
  // and halls.

  //setsize (dogbot, '-16 -16 -24', '16 16 16');
  setsize (dogbot, '-16 -16 -16', '16 16 16');

  setorigin(dogbot, org);

  spawn_tfog (dogbot.origin);

  sound (self, CHAN_BODY, "dog/dattack1.wav", 1, ATTN_NORM);
  sprint(self, "P8 is here.\n");

  dogbot.nextthink = time + nextthinktime;
  dogbot.think = dogbot.th_stand;

  // remove powerup status from player
  self.Cujo_avail = 0;

  // used to determine if Cujo's think is a jumping frame
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Deactivate                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_Deactivate =
{
  spawn_tfog (self.Cujo.origin);

  if (self.Cujo_view)
    CUJO_SetPlayerView ();

  // prevents fire from continuing on the next cujo spawned if he
  // was burning but not dead when he was deactivated
  blaze_extinguishentity (self.Cujo);

  self.Cujo.nextthink = time + nextthinktime;
  self.Cujo.think = SUB_Remove;
  self.Cujo_flag = FALSE;

  sprint (self, "P8 went back to his doghouse.\n");
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Toggle                                                           บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// ver 1.2 -  Changed spawning rule for deathmatch
// ver 1.2 -  uhhh... fixed spawning rules for deathmatch :)

void () CUJO_Toggle =
{
  if ((self.Cujo_flag) && (self.Cujo.deadflag == DEAD_DYING)) return;

  if (deathmatch)
  {
    if (self.Cujo_flag)
    {
      if ((self.deadflag == DEAD_DYING) || (self.deadflag == DEAD_DEAD))
      {
        CUJO_Deactivate ();
      }
      else
        sprint (self, "P8 can't be sent away in deathmatch.\n");
    }
    else if (self.Cujo_avail)
    {
      CUJO_Activate ();
    }
    else
      sprint (self, "P8 is not available.\n");
  }
  else
  {
    if (!(self.Cujo_flag))
      CUJO_Activate();
    else
      CUJO_Deactivate();
  }
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_AttackToggle                                                     บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_AttackToggle =
{
  if (!(self.Cujo_flag))
  {
    CUJO_PrintCujoStatus ();

    return;
  }

  if (self.Cujo.Cujo_attack == TRUE)
  {
    self.Cujo.Cujo_attack = FALSE;
    sprint (self, "Cujo will not attack.\n");

    // reset Cujo's enemy so he doesn't whine even when the enemy goes
    // out of view.

    self.Cujo.enemy = world;
    self.Cujo.oldenemy = world;
    self.Cujo.goalentity = self;
    self.Cujo.movetarget = self;

    self.Cujo.think = self.Cujo.th_stand;
    self.Cujo.nextthink = time + nextthinktime;
  }
  else
  {
    self.Cujo.Cujo_attack = TRUE;
    sprint (self, "Cujo wants blood!\n");
  }

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Attack                                                           บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/
/*
void () CUJO_Attack =
{
  local entity oldself;
  local vector org;

  if (!(self.Cujo_flag))
  {
    CUJO_PrintCujoStatus ();

    return;
  }

  oldself = self;
  self = self.Cujo;

  if (self.owner.Cujo_auto && self.enemy != world && self.enemy.health > 1
  && !(self.enemy.items & IT_INVISIBILITY) && visible(self.enemy))
  {
  }
  else
  {
  }

  self = oldself;

  return;
};
*/
/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_TeleportHome                                                     บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

void () CUJO_TeleportHome =
{
  local vector org;

  if (!(self.Cujo_flag))
  {
    CUJO_PrintCujoStatus ();

    return;
  }
  if (self.Cujo_flag)
    if (self.Cujo.deadflag == DEAD_DYING) return;

  spawn_tfog (self.Cujo.origin);
  self.Cujo.ideal_yaw = self.angles * '0 1 0';
  self.Cujo.angles = '0 0 0';
  self.Cujo.pausetime = time + 2;
  self.Cujo.nextthink = time + nextthinktime;
  self.Cujo.think = self.Cujo.th_stand;

  org = self.origin + '0 0 0';
  setorigin(self.Cujo, org);

  spawn_tfog (self.Cujo.origin);
  self.Cujo.nextthink = time + nextthinktime;
  self.Cujo.think = self.Cujo.th_stand;

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_LightToggle                                                      บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/


// This will always be called from the players code, so self is always
// expected to be the player

void () CUJO_LightToggle =
{
  local   float   effect;
  local   float   bitmask;

  if (self.Cujo_flag)
  {
    effect = EF_DIMLIGHT;

    bitmask = (effect) & self.Cujo.effects;

    if (bitmask == 0)
    {
      self.Cujo.effects = self.Cujo.effects | effect;
    }
    else
    {
      bitmask = !(bitmask);
      self.Cujo.effects = (self.Cujo.effects) & bitmask;
    }
  }
  else
    CUJO_PrintCujoStatus ();

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_SetDogView                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// This will always be called from the players code, so self is always
// expected to be the player

void () CUJO_SetDogView =
{
  if (self.Cujo_flag)
  {
    // Set view point
    msg_entity = self;
    WriteByte (MSG_ONE, 5);                 // SVC, set the viewport
    WriteEntity (MSG_ONE, self.Cujo);

    // set the view angles to Cujo's view angles
//    WriteByte (MSG_ONE, 10);               // SVC, set view angles
//    WriteAngle(MSG_ONE, self.Cujo.angles_x);
//    WriteAngle(MSG_ONE, self.Cujo.angles_y);
//    WriteAngle(MSG_ONE, self.Cujo.angles_z);

    self.weaponmodel = "";
    self.weaponframe = 0;

    self.Cujo_view = TRUE;

    old_player_angles = self.angles;

    // turn to Cujo's angles...  I guess
    self.angles = self.Cujo.angles;
    self.fixangle = TRUE;		// turn this way immediately

  }
  else
    CUJO_PrintCujoStatus ();

  return;

};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_SetPlayerView                                                    บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/


// This will always be called from the players code, so self is always
// expected to be the player

void () CUJO_SetPlayerView =
{
  if (self.Cujo_flag)
  {
    // Set view point
    msg_entity = self;
    WriteByte (MSG_ONE, 5);                 // service, set the viewport
    WriteEntity (MSG_ONE, self);

//    WriteByte (MSG_ONE, 10);               // SVC, set view angles
//    WriteAngle(MSG_ONE, self.angles_x);    // tilt
//    WriteAngle(MSG_ONE, self.angles_y);    // yaw
//    WriteAngle(MSG_ONE, self.angles_z);    // flip

    // reset the players weapon model
    self.Cujo_view = FALSE;
    W_SetCurrentAmmo ();

    self.angles = old_player_angles;
    self.fixangle = TRUE;		// turn this way immediately
  }
  else
    CUJO_PrintCujoStatus ();

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_Stay                                                             บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// always called from player code.  Toggles self.Cujo.Cujo_stay which
// is used in follow routines to determine if Cujo should stay or follow

void () CUJO_Stay =
{
  if (self.Cujo_flag)
  {
    // toggle Cujo's stay flag
    if (self.Cujo.Cujo_stay == TRUE)
    {
      self.Cujo.Cujo_stay = FALSE;
      sprint (self, "Cujo is following.\n");
    }
    else
    {
      self.Cujo.Cujo_stay = TRUE;
      sprint (self, "Cujo is staying.\n");
    }

  }
  else
    CUJO_PrintCujoStatus ();

  return;
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_GiveStatus                                                       บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// called from player code, ie. self = player

void () CUJO_GiveStatus =
{
  local   string  str_temp;
  local   float   ftemp;

  if (self.Cujo_flag)
  {
    if (visible (self.Cujo))
    {
      sprint (self, "Cujo's health is ");

      ftemp = self.Cujo.health / 2;

      str_temp = ftos (ftemp);
      sprint (self, str_temp);
      sprint (self, "%.\n");

      sprint (self, "His armor is ");

      ftemp = self.Cujo.armorvalue / 2;

      str_temp = ftos (ftemp);
      sprint (self, str_temp);
      sprint (self, "%.\n");
    }
    else
    {
      sprint (self, "You must be able to see Cujo to determine his status.\n");
    }
  }
  else
    CUJO_PrintCujoStatus ();

  return;
};

/*
======================
CUJO_ShowSkin
======================
*/

void () CUJO_ShowSkin =
{
  sprint (self, "Skin #");
  temp_text = ftos (self.Cujo.skin);
  sprint (self, temp_text);
  sprint (self, " selected.\n");
};

/*
======================
CUJO_SkinUp
======================
*/
void () CUJO_SkinUp =
{
  self.Cujo.skin = self.Cujo.skin + 1;
  if (self.Cujo.skin > 15)
    self.Cujo.skin = 0;

  CUJO_ShowSkin ();
};

/*
======================
CUJO_SkinDown
======================
*/
void () CUJO_SkinDown =
{
  self.Cujo.skin = self.Cujo.skin - 1;
  if (self.Cujo.skin < 0)
    self.Cujo.skin = 15;

  CUJO_ShowSkin ();
};

/*ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
  บ                                                                       บ
  บ Cujo_KillAllMonsters                                                  บ
  บ                                                                       บ
  ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ*/

// to make debugging maps easier -- no having to fight stuff

void () CUJO_KillAllMonsters =
{
  local   entity  head;

  head = nextent (world);

  while (head)
  {
    if ((head.classname == "monster_army")
    || (head.classname == "monster_demon1")
    || (head.classname == "monster_dog")
    || (head.classname == "monster_dragon")
    || (head.classname == "monster_enforcer")
    || (head.classname == "monster_fish")
    || (head.classname == "monster_hell_knight")
    || (head.classname == "monster_knight")
    || (head.classname == "monster_ogre")
    || (head.classname == "monster_oldone")
    || (head.classname == "monster_shalrath")
    || (head.classname == "monster_shambler")
    || (head.classname == "monster_tarbaby")
    || (head.classname == "monster_vomit")
    || (head.classname == "monster_wizard"))
    {
      if (random () < 0.2)
        T_Damage (head, self, self, head.health + 100);
      else
        T_Damage (head, self, self, head.health + 1);
      bprint ("kill ");
    }
    else if (head.classname == "monster_zombie")
      T_Damage (head, self, self, head.health + 50);

    head = nextent (head);
   }
   bprint ("Everything is dead.\n");
};
