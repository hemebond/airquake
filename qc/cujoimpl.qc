/*
==============================================================================

CUJO Impulse Command Checker

==============================================================================
*/

void () CUJO_CheckImpulses=
{
  local   float   bitmask;

  if (self.impulse == CUJO_TOGGLE)
    CUJO_Toggle();

  if (self.impulse == CUJO_TELEPORT)
  {
    CUJO_TeleportHome();
  }

  if (self.impulse == CUJO_LIGHT_TOGGLE)
  {
    CUJO_LightToggle ();
  }

  if (self.impulse == CUJO_ATTACK_TOGGLE)
  {
    CUJO_AttackToggle ();
  }

// NOT WORKING YET!  View changes, but angles are not updated and mouse
// control of view remains.

  if (self.impulse == CUJO_VIEW_TOGGLE)
  {
    if (self.Cujo_view == FALSE)
    {
      CUJO_SetDogView ();
    }
    else
    {
      CUJO_SetPlayerView ();
    }
  }


  if (self.impulse == CUJO_STAY_TOGGLE)
  {
    CUJO_Stay ();
  }

  if (self.impulse == CUJO_GIVE_STATUS)
  {
    CUJO_GiveStatus ();
  }

  // debugging impulse

  if (self.impulse == 101)
  {
    CUJO_KillAllMonsters ();
  }

  return;
};
