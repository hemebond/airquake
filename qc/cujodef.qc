// CUJO ver 1.3

// Global Constants

// Defines for Effects that aren't already defined by name (see MODELS.QC)

float   EF_ROCKET               = 1;

float   CUJO_TOGGLE             = 230;
float	CUJO_TELEPORT             = 234;
float   CUJO_LIGHT_TOGGLE       = 235;
float   CUJO_GIVE_STATUS        = 236;
float   CUJO_ATTACK_TOGGLE      = 237;
float   CUJO_VIEW_TOGGLE        = 233;
float   CUJO_STAY_TOGGLE        = 232;
float   CUJO_KILL_ALL           = 240;

// Bot Prototypes - called by player

void () CUJO_Precache;
void () CUJO_Activate;		// Activate bot
void () CUJO_Deactivate;	// DeActivate bot
void () CUJO_Toggle;		// Toggle bot on and off
void () CUJO_AttackToggle;	// Toggle bot's auto-firing in auto mode
/*
void ()	CUJO_Attack;		// Have bot fire at its current target in auto mode
*/
void ()	CUJO_TeleportHome;	// Have bot teleport back to its owner
void ()	CUJO_LightToggle;	// Have bot teleport back to its owner
void () CUJO_CheckImpulses;     // check for commands to CUJO
void () CUJO_SetDogView;
void () CUJO_SetPlayerView;
void () CUJO_Stay;

// CUJO - begin new entity fields

.entity		Cujo;		// bot entity
.float		Cujo_flag;	// existence of bot (TRUE or FALSE)
//.float		Cujo_auto;	// flags auto mode of bot (TRUE or FALSE)
//.float		Cujo_moveflag;	// (STAND, WALK, OR RUN)
.float		Cujo_attack;    // (TRUE or FALSE)
.float          Cujo_view;      // (TRUE if seeing through Cujo, FALSE otherwise)
.float          Cujo_stay;      // (TRUE if Cujo is not following player)
.float          Cujo_avail;     // (TRUE if Cujo powerup taken during deathmatch)

// Fields for ZEUS movement routines
.float          ZEUS_stuck;
.float          ZEUS_stuck_dir;
.vector         ZEUS_own_lastorg;
.float          upward_jump_vel;
.float          forward_jump_vel;

.float          CUJO_verbose;
.float		motd_time;
.float		motd_count;
// CUJO - end new entity fields

float  old_weapon;
float  cujo_armorval;
vector cujo_org;

float   current_flames;

void (entity old_ent) blaze_extinguishentity =
{
  local   entity  head, temp;
  local   float   i;
  local   string  temp_text;

  head = nextent (world);

  while (head)
  {
    if ((head.classname == "fire") && //(vlen (head.origin - old_ent.origin) < 100))
        (head.enemy == old_ent))
    {
      temp = nextent (head);
      head.enemy.dmg_inflictor = world;
      current_flames = current_flames - 1;
      remove (head);
      head = temp;
    }
    else head = nextent (head);
  }
};



