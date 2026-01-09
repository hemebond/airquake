// ADMIN funcs for AirQuake, based on what's said below.

//---------------------------------------------------------------------------
//Quake
//
//Copyright (c) 1995-96 by Dave Kirsch
//---------------------------------------------------------------------------
//admin - remove server admin functions
//---------------------------------------------------------------------------

// NOTE:  THE FOLLOWING VALUES ARE THE PASSWORD USED TO ENABLE
// REMOTE ACCESS.
//
// The have the following properties and requirements:
// a. Must not be an existing impulse
// b. Must be entered in the specified order
// c. Must be in the range 1 to 255 excluding previously used impulses
//
// They must be entered in the correct order which gives 256*256*256 or
// 16777216 possible passwords.  If a specified order wasn't given, it
// would only be 768 possibilities.
//
// BY DEFAULT, REMOTE ADMIN ACCESS IS DISABLED
// This is done by setting the admin passwords all to -1.
//
// If you wanted to enable it, pick three random numbers (that aren't
// existing impulses) and put 'em here, for example:
//
//		float	ADMIN_PWD_1	= 179;
//		float	ADMIN_PWD_2	= 131;
//		float	ADMIN_PWD_3	= 157;
//
// which would give you a password of 179, 131 and 157.  To send this from
// a Quake client, do a bind like this:
//
// bind p "impulse 179;wait;impulse 131;wait;impulse 157"
//
// When you hit p, you'll be granted remote admin functionality.
//
// Currently the only admin functions available right now are kick
// team change, and level change.  They are bound to impulse 151, 
// impulse 152 and impuluse 153 respectively.
//
// The way it works is after you enter the admin password, do an
// impulse 151/152/153.  You'll get a list of players on the server with their
// numbers.  Send the next impulse with the number of the player
// to act the command on.

// CHANGE THE FOLLOWING THREE -1 NUMBERS TO YOUR ADMIN PASSWD
/*  // moved to non-constants admin_p_*
float	ADMIN_PWD_1	= -1;  // change me to first number of the passwd
float	ADMIN_PWD_2	= -1;  // change me to second number of the passwd
float	ADMIN_PWD_3	= -1;  // change me to third number of the passwd

float	ADMIN_KICK = 151;
float ADMIN_CHANGEMAP = 152;
float ADMIN_TIMELIMIT = 153;
float ADMIN_FRAGLIMIT = 154;
*/

void() Adminmenu =
{
  sprint(self, "Admin Commands:\n");
  sprint(self, "1: kick\n");
  sprint(self, "2: change map\n");
  sprint(self, "3: set timelimit\n");
  sprint(self, "4: set fraglimit\n");
  sprint(self, "5: set temp1\n");
  sprint(self, "9: exit menu\n");
};

void() CheckAdminCmd =
{
  local float n, n2;
	local entity p;
	local string st;

  if (admin_p < 0)
		return; // disabled


  if (self.impulse == 99)
  {
    if (self.accesslvl == 4)
    {
      self.accesslvl = 3;

      bprint(self.netname);
      bprint(" has become a sysop\n");

      Adminmenu();

      self.accessparm = 0;  // In which "menu"
      self.gettingnum = 1;
      self.numcurspos = 1;
      self.twonumbers = 0;
      return;
    }
    else if (self.accesslvl < 3)
    {
      sprint(self, "Type your admin password (6 digits).\n");
      self.gettingnum = 1;
      self.twonumbers = 0;
      self.numcurspos = 6;
      self.accessparm = 0;
    }
  }

  if (self.gettingnum)  // number input via impulses 1-10
  {
    if (self.impulse > 0 && self.impulse < 11)
    {
      self.twonumbers = self.twonumbers * 10;
      if (self.impulse < 10)
        self.twonumbers = self.twonumbers + self.impulse;
      self.impulse = 0;
      self.numcurspos = self.numcurspos - 1;
      if (self.numcurspos < 1)
      {
        self.gettingnum = 0;
        if (self.twonumbers == admin_p)
        {
          self.accesslvl = 3;
          bprint(self.netname);
          bprint(" has become a sysop\n");

          Adminmenu();

          self.accessparm = 0;  // In which "menu"
          self.gettingnum = 1;
          self.numcurspos = 1;
          self.twonumbers = 0;
          return;
        }
      }
    }
  }

  if (self.accesslvl != 3)
  {
    if (self.impulse > 0 && self.accesslvl < 3) 
      self.accesslvl = 0;

		self.accessparm = 0;
		return; // must be a sysop beyond this point
	}

  if (self.gettingnum)   // input'ing a number for cmd, don't execute stf yet
  {
    return;
  }

  if (self.accessparm == 0)  // main menu cmd
  {
    self.accessparm = self.twonumbers;
    self.twonumbers = 0;
    self.gettingnum = 1;
    if (self.accessparm == 1) // kick
    {
      sprint(self, "Kick (00 - 99):\n");
      p = find(world, classname, "player");
      n = 1;
      while (p != world) {
        st = ftos(n);
        if (n < 10)
          sprint(self, " ");
        sprint(self, st);
        sprint(self, " ");
        sprint(self, p.netname);
        sprint(self, "\n");
        p = find(p, classname, "player");
        n = n + 1;
      }
      self.numcurspos = 2;
    }
    else if (self.accessparm == 2) // Change map
    {
      sprint(self, "Run map(00-99).cfg file.\n");
      self.numcurspos = 2;
    }
    else if (self.accessparm == 3) // Set timelimit
    {
      sprint(self, "Set timelimit (00-99).\n");
      self.numcurspos = 2;
    }
    else if (self.accessparm == 4) // Set fraglimit
    {
      sprint(self, "Set fraglimit (000-999).\n");
      self.numcurspos = 3;
    }
    else if (self.accessparm == 5) // Set temp1
    {
      sprint(self, "Set temp1 (000-999).\n");
      self.numcurspos = 3;
    }
    else if (self.accessparm == 9) // quit admin menu
    {
      sprint(self, "Goodbye. Press impulse 99 to get back to menu.\n");
      self.gettingnum = 0;
      self.numcurspos = 0;
      self.twonumbers = 0;
      self.accessparm = 0;
      self.accesslvl = 4;
    }
    return;
  }

  if (self.accessparm == 1) { // kick cmd

    n = self.twonumbers - 1;
		p = find(world, classname, "player");
		while (p != world && n > 0) {
			p = find(p, classname, "player");
			n = n - 1;
		}

		if (p != world) {
			sprint(p, "\n\nYou have been kicked.\nGo abuse somewhere else.\n");
			stuffcmd(p, "disconnect\n");
			bprint(p.netname);
			bprint(" was kicked by ");
			bprint(self.netname);
			bprint("\n");
		} else {
			sprint(self, "Can't kick #");
      st = ftos(self.twonumbers);
			sprint(self, st);
			sprint(self, "\n");
		}
	}
  else if (self.accessparm == 2)  // Change map.cfg
  {
    n2 = self.twonumbers;
    serverflags = serverflags - (serverflags & 255) + n2;
    sprint(self, "running map cfg file..\n");
    if (n2 >= cvar("noexit"))
    {
      n2 = 0;
    }
    localcmd("exec map");
    n = floor(n2 * 0.1);
    st = ftos(n);
    localcmd(st);
    n = n2 - (n * 10);
    st = ftos(n);
    localcmd(st);
    localcmd(".cfg\n");
  }
  else if (self.accessparm == 3)  // Change timelimit
  {
    st = ftos (self.twonumbers);
		localcmd("timelimit ");
		localcmd(st);
		localcmd("\n");
    sprint(self, "Timelimit set\n");
  }
  else if (self.accessparm == 4)  // Change fraglimit
  {
    st = ftos (self.twonumbers);
    localcmd("fraglimit ");
		localcmd(st);
		localcmd("\n");
    sprint(self, "Fraglimit set\n");
  }
  else if (self.accessparm == 5)  // Change temp1
  {
    st = ftos (self.twonumbers);
    localcmd("temp1 ");
		localcmd(st);
		localcmd("\n");
    sprint(self, "Fraglimit changed.\n");
  }

  Adminmenu();

  self.twonumbers = 0;
	self.accessparm = 0;

	self.impulse = 0;
	return;
};


