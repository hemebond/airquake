# AIRQUAKE

by Iikka Ker�nen (ikeranen@raita.oulu.fi)

This is a "total conversion" with players replaced by fighter planes and
other military vehicles, and monsters replaced by similar vehicles or ground
artillery. Since this also means all the maps need to be done specifically
for AirQuake, it is a very total conversion indeed.

This is not trying to be a hard-core realistic simulator, rather than a 3d
action game with some simulator-like features. The controls etc are very
simple, as you'll see. This doesn't mean the enemies are easy to kill though.
They have as good weapons as you...

## Installing & Running

1. Extract the archive to `airquake` within your Quake program directory.
2. Run Quake by typing "quake -game airquake". Then type into console: "map air1", "map air2", "map air3" or "map aircity" to get into the levels. I have included 3 demos. Just run Quake with "-game airquake" and wait till the demos start...
3. To play in Internet, run "q95 -game airquake" or "winquake -game airquake" (or whatever you have in Linux etc). Then in the main menu, select Multiplayer/Join Game/TCP-IP, and type the server address in the box below. If the port of the server is not 26000, type the port number in the other box (in the upper part of the screen).

See [Rules](#rules) section below for DM settings etc.

## Playing

This section tells you how to play with the included autoexec.cfg, that has all the necessary controls bound to mouse and keyboard.

### Quick Start

Here is a simple example of a flight in AirQuake. By following these instructions, you can bomb the enemy radar base in Air3. The third demo shows this flight in action, so sit down and watch it if you didn't understand something...

After running Quake -game airquake, type "map air3" into console to start the level. Press 3 to select the stealth fighter, then press mouse button to start.

Now you find yourself in a stealth fighter parked on the front deck of an aircraft carrier. Take-off clearance is asked automatically.

Press 8 to start your engines. Drive to the start of the runway and turnright. Press 8 repeatedly to speed up, and look a little upward to take offat the end of the runway. Feel the amazing freedom of flight. ;-)

Keep climbing up till you hit the ceiling. Turn around while climbing to remain inside friendly area. You can ignore the few incoming enemies, your carrier has enough defenses to take them out.

When you are at high altitude enough, turn towards the enemy radar base (You see three white objects atop a hill near the coast). Press 3 to select the Paveway bomb. Press and hold right mouse button to see the bomb sight, and hold W key pressed to fly straight while aiming. Look with the mouse so that the red box is exactly centered to the radar base, and press left mouse button to release the bomb.

Release the right mouse button (to get back to stealth mode) and W, and turn away. If you want, you can now press and hold W again, and press 9 to see where your bomb goes. If it doesn't hit, try again.

When the radar base has been destroyed, or if you run out of ammo, you have to land. Press 7 to reduce throttle to 75%, dive to low altitude and circle around until your speed slows down. Approach the carrier's rear aligned to the runway, and come down in about 10 degrees angle. Right before the touch- down, reduce throttle to zero by pressing 7 repeatedly. If it seems you won't stop quickly enough, speed up with key 8 and take off (to try again).

When stopped on the runway, set about 25% throttle and drive to the repair spot under the bridge to rearm.

### Controls

- Steer your vehicle with mouse, or turning keys and look up/down. Vehicles don't turn instantly, but at speed depending on the vehicle type. Basically you tell the pilot or driver where to go by looking somewhere, and he just follows these orders.
- Tilting a helicopter up or down makes it move backward or forward.
- Press right mouse button (+jump) to use the special ability of your vehicle. This may for example turn on afterburner, or open stealth fighter's weapon bay doors. Helicopters and ground vehicles move to where you are looking, when you press special. For example, if you look back and press this button, your tank reverses. Hovercraft only goes forwards.
- All vehicles have throttle settings. Press 7 to decrease, and 8 to increase throttle. With helicopters and hover, this is used for moving up and down.
- Aircraft have additional left/right movement keys. Press:

  A (+extraleft)   to strafe/roll left. (helicopter/plane)
  D (+extraright)  to strafe/roll right.
- Change views by pressing:

  W (bound to +freelook) to freely look around with mouse. The vehicle's
    direction is "locked" and it goes straight while you press this key.
    Helicopter stops moving unless you press special key to move it.
    Release the key to return the controls. Freelook is good for locking
    missiles to targets in any direction with some planes, as well as for
    turning tank's turret while going straight, and landing with a chopper.
    (+lookleft) to look left. Release to return to the normal front view.

  S (+lookback) to look back.
    (+lookright) to look right.

  Z (+cczoomin) to zoom in.

  X (+cczoomout) to zoom out.

  Q (liftcam) to move camera up. Cycles through 5 positions. I added this as
    the hummer is hard to see in the default camera position. :)

  E (lockturret) is not actually a camera option, but somewhat related, as
    it's mostly used for taking screenshots. :) Basically it locks the turret
    to the current direction and then you can see it from front... I've found
    a practical use for this too: In AIRCITY, lock your tank guns upward, then
    use freelook and a lot of zoom out to watch where your cannon shells
    land. This way you can guard those bridges from your own base... Also,
    if you are using a ground vehicle, you can press E to lock your turret
    into an enemy (if you have a missile lock into it). It then follows the
    enemy automatically if possible.

  9 (impulse 9) toggles missile view. Usable for the hummer's bomb...

- Press number keys to select weapons. More about them in Vehicles section.
- Commands "cycleweapon" and "cycleweapon2" work like the cycle command in normal Quake... I'm not using them so they aren't bound to any keys. Bind them yourself.
- Number 5 drops a flare (or shoots upward if a ground vehicle), that has 50% chance to get missiles out of your tail.
- Press number 6 to set weapon model (big/small/none). The small version is mostly for high resolutions and GLquake, it's too small in 320x200.
- Before each respawn (while dead), you can select vehicles with the numbers.
- You can also switch your skin by typing "impulse 15" into console between respawns. Currently there's an alternate skin for dogfighter only.
- When you are stopped at rearm/repair spot with 100% health, you can re-select your vehicle by pressing 0 (impulse 10), and then vehicle number.
- When you're dead, you can switch teams in teamplay DM by selecting a new colour. Type into console "color 2" for blue, and "color 7" for red team. Don't do this when you're alive, or the game doesn't recognize the team change. (It should force the colours back to that of your team, but it has problems on dedicated servers)
- All the weapons except bombs auto-aim into ground targets, and homing missiles can be locked into planes as well. Slow missiles like mavericks aren't too good in shooting planes though.
- The red targeting box shows the direction where you are flying/shooting, except in the stealth mode.
- When the targeting box changes to different shape and moves on a target, you have gained a weapon lock.
- The drone planes fly around following their routes. At first, they don't use afterburner, but if they take some damage, they start to use it... They have no AI yet, but I'm going to make some.
- The enemy helicopters have (almost) finished AI, they can really hunt you down and kill. They have a bit limited aiming skills for now though.
- You can land on a special runway brush. Simply fly above it and reduce throttle, if you're in a helicopter... With planes, come down as slowly as possible, and don't turn at the moment when you touch the ground. Landing or taxiing outside a runway kills you. (Ground vehicles can of course travel anywhere on the ground)
- Ground vehicles can travel in shallow water without any problems. If they become (almost) completely submerged, they start to get heavy damage. The tank may survive for 10 seconds... Humvee can now drive underwater for about 10 seconds without getting any damage, but then it dies quickly... Only use this ability to cross rivers and such. (The friction between tires and sea floor is sometimes zero, and you get bad problems if you drive too long submerged..)

### Radio Communications

There are many radio messages in the airsay.rc. They are only sent to the players of your team in teamplay DM, so you can communicate relatively safe. Read the airsay.txt and examine airsay.rc to find more info about impulses etc... Basically, everything is bound to keys F1-F8, and pressing F1 shows you what the others do.

### Rules

This section contains descriptions for different game modes of AirQuake.

- Single player and Co-op game modes work like usual. (Except there are no many co-op starts in the levels, so you may get "telefrag" problems. Move away after starting)
- All monsters are now removed from deathmatch mode, EXCEPT if you have teamplay on, and the monsters belong in either team. (Defense turrets)
- Teamplay 1 turns on the team rules:
  * When a new player connects, he joins the team with least players.
  * Players always respawn at their own base.
  * Before respawns, you can change your team if you want. Please don't use this excessively, other players might not like it. Simply change your color to join another team. ("color 2" in console for blue, 7 for red)
  * Killing a teammate lowers your frag count.
  * Certain maps may contain people ("enemy officers") you can pick up. Bring them to an officer of your team to gain 10 frags, and 5 frags to other players in your team. (In aircity, the officers are at the bases)
  * Maps may also contain enemy buildings to be destroyed for frags in a similar way. Destroying your own buildings reduces your frags. There are buildings like this in Air2 and Air3.
- Almost forgot to tell... You do get 3 frag points for each kill. I did this because in AirQuake it's very easy to kill yourself. Now people sometimes have positive frags...

### Server

Here are some server options that are set by console variables.

Variable "temp1": Type "temp1 \<number\>" to set these options. Add numbers together to use many options. "temp1 15" would turn on all the options below.

  1. Double weapons.
  2. Remove targeting box.
  4. Remove bright light effect from afterburners. RECOMMENDED FOR GL USERS!
  8. Prevent locking weapons into friendly targets.

Variable "noexit": This is no more used to prevent exiting from level, but for level cycling on servers. Set noexit to the number of levels, and put config files map00.cfg - mapNN.cfg in the airquake directory. These cfg files contain line "changelevel mapname".

If you want to enable remote server options, get a password number with 6 digits, multiple it by 256 and add to the noexit. In the game, type "impulse 99" and then type the password by number keys (impulse 1-10). It must be 6 digits, for example "000245"... This brings you to the admin menu which is controlled by numbers in the same way. For example, press 1 for kick command, then 07 to kick 7th player. Some commands take 3 digits (frag/timelimit). Press 9 to quit from admin menu. Once you have been there, you can always get back by impulse 99 without the password. (Warning: you can get strange results with passwords above 131071, apparently Quake uses 25-bit numbers..)

An example command line:

```
Quake -dedicated 16
      -game airquake
      +deathmatch 1
      +noexit 28444420       [ 256*111111 + 4 ]
      +timelimit 30
      +map air1
```

This uses files map00.cfg to map03.cfg to set up a regular deathmatch game that cycles through 4 levels, playing for 30 minutes in each. These .cfg files are included, they cycle all the four levels. The .cfg files may also contain commands to switch on/off teamplay, change timelimits etc. The admin password in this example is 111111.

## Vehicles

There are SIX different aircraft and FOUR ground vehicles. When the game starts, you can select which one to use, unless set otherwise in the map file. The vehicles have many different features, and they have different roles in the game in team play... Now, to the specs:

### Vehicle 1: Dogfighter

This plane is an air superiority fighter, with weapons for little more than air-to-air battles. Relatively fast, and can outturn almost anything.

Speed: 0.9 mach, with afterburner: 1.5 mach.
Weapons:
1. Vulcan cannon (AA). Ammo: 200
2. 37mm Rockets (AA/AS). Rapid fire. Ammo: 10
3. Sidewinder missiles (AA), speed 2.4 mach. Moderate damage. Ammo: 4
4. AMRAAM missiles (AA), speed 3 mach. Long range, Good damage. Ammo: 4
Health: 200
Armour: 0

### Vehicle 2: Fighter Bomber

This is a ground assault fighter, with weapons for both air-to-air and air-to-surface missions. As it's a lot heavier than the dogfighter, its turning ability and speed are not as good. To compensate this problem, the plane is equipped with a high-tech look-it-shoot-it helm sight... However, it doesn't help that much if the enemy is behind you. Try to shoot from distance and avoid real dogfights.

Speed: 0.85 mach, with afterburner: 1.35 mach.
Weapons:
1. Autocannon (AA). Ammo: 50
2. Sidewinder missiles (AA). Ammo: 4
3. Bombs (AS). Ammo: 4
4. Maverick missiles (AS). speed 1.5 mach, heavy damage. Ammo: 4
Health: 250
Armour: 0

### Vehicle 3: Stealth Fighter

This is a flying piece of state of the art technology. Unfortunately, it can't take as big payload as A-10. While it's a bit easier to fly than the A-10 plane, it has no afterburner. Instead, the special key opens up weapon bays to make you able to shoot. When the bays are closed, the plane is nearly invisible to radars and incoming missiles. This is also indicated by darker texture, and the targeting box disappears (as you can't shoot). This plane is ideal against small, important targets (ie. radar bases, or single buildings). The paveway bomb can be locked to anything you can see, but it's not very useful against moving targets as it glides so slowly. However, the enemy gets no "incoming missile" warning from this bomb, and it's hard to see as it doesn't have a visible glowing rocket engine...

Speed: 0.9 mach.
Weapons:
1. Autocannon (AA). Ammo: 50
2. Sidewinder missile (AA). Ammo: 4
3. Paveway laser guided bomb (AS). Ammo: 4
4. Maverick missiles (AS). Ammo: 4
Health: 200
Armour: 0

### Vehicle 4: A-10 Ground attack plane

This is what the name says. The nightmare of any ground forces, A-10 has tough armor enough to survive all but the most extreme anti-aircraft fire, and huge load of hard-hitting weapons. Just the 5-barreled 30mm long range autocannon with exploding shells is enough for most of the targets. If it's not, you have all the heavy stuff like hellfires and bombs. It's not really recommended to try this plane out in deathmatch as it doesn't have dogfight abilities, but it can take incredible amounts of punishment, and in the hands of a skillful pilot, the said autocannon tears planes apart...

Speed: 0.75 mach, with afterburner: 1.05 mach.
Weapons:
1. Autocannon (AA/AS). Ammo: 50
2. Sidewinder missile (AA). Ammo: 2
3. Free fall bombs (AS). Heavy damage. Ammo: 6 (spends 2 per 4 bombs)
4. Maverick missile (AS). Speed 1.5 mach, heavy damage. Ammo: 6
Health: 350
Armour: 15

(A-10 model made by Matt "Mix" Fox, skinned by Iikka Ker�nen)

### Vehicle 5: X-29 experimental fighter     

This is something that will make today's dogfight planes obsolote in the near future. It turns faster than any other plane, and it has some high tech weaponry. But, since this is an experimental prototype of a future fighter, it has its flaws. The most important are light weapon load and fragile electronics that make this plane vulnerable.

Speed: 0.9 mach, with afterburner: 1.5 mach.
Weapons:
1. Autocannon (AA). Ammo: 100
2. Plasma cannons (AA). Ammo: 40
3. Mini missiles (AA/AS). Rapid fire homing rockets. Ammo: 8
4. Sidewinder missiles (AA). Uses "helm sight". Ammo: 4
Health: 170
Armour: 0

(X-29 model made by Matt "Mix" Fox, skin modified by Iikka Ker�nen)

### Vehicle 6: Attack Helicopter

This is a very fast and powerful helicopter, that relies on its huge load of rockets when fighting against ground targets. It's also capable of self- defense against fighter planes... not least because of the different way it moves. You can get into places where jets can't shoot you, and the chopper turns really fast. Also, the helicopter is ideal for picking up stuff.

Speed: depends on the pitch angle... slow compared to the jet fighters.
Weapons:
1. Autocannon (AA). Ammo: 50
2. 37mm Rockets (AA/AS). Ammo: 16
3. Sidewinder missile (AA). Ammo: 4
4. Hellfire missile (AA/AS). Faster than Maverick, less damage. Ammo: 4
Health: 200
Armour: 0

### Vehicle 7: Mobile SAM vehicle

Although this vehicle travels at the speed of 200mph in the AirQuake scale, It doesn't look like that. Basically, it's very slow compared to anything that flies. However, it has the double-barreled rapid-fire SAM launcher on its side, and lots of armour. If you run out of missiles, you have an auto- cannon as a backup weapon. There are a few things you'll learn soon in the game: First, don't fall from heights! Second, don't shoot down a helicopter when it's hovering above you! :)  In DM, you have to make good use of the terrain, keep close to places where you can hopefully hide. If you're caught in the middle of an open field, you're going to know what "sitting duck" means.

Weapons:
1. Autocannon (SA/SS). Ammo: 200
2. SAM missiles (SA/SS). Ammo: 16
Health: 400
Armour: 15
  
Notice that, while you can use the weapons against ground targets, they're not very powerful. Tanks are better for ground fights.

### Vehicle 8: Battle Tank

This is what many people have asked me to do. It's slow of course, but it actually does have armour, and very powerful weapons for ground fights. Now you can do a map completely on ground. :)  This is pretty good against enemy helicopters too, but there are only a few homing missiles... and since you can't dodge their rockets, you might want to leave them to others if possible. Again, make use of the terrain... In Air2, attack from tunnels and behind corners, so that the enemy looks elsewhere when you shoot your missiles. And finally, learn to use your Big Gun. Its range is very long, and you can shoot to/from behind obstacles. (I have even killed planes with it. ;)

Weapons:
1. Autocannon (SA/SS). Ammo: 100
2. Plasma Cannons (SA/SS). Ammo: 30
3. 110mm Cannons (SS). Ballistic projectiles, extreme damage. Ammo: 60
4. SAM missile (SA/SS). Ammo: 6
Health: 600
Armour: 20

### Vehicle 9: Armoured Car

Yes, it is a Humvee all right. I just don't call it so. :)  This car is a bit faster than the heavy vehicles, but it has almost no hope in any real battle. The top-mounted turret is basically there for self defense. Your main weapons are the mines and the huge bomb. You can kill anything by laying 6 mines together, and adding a bomb next to them... Then wait till somebody gets too close and BOOM. Of course, if you drop your explosives on open ground they'll see them and shoot them. In AirCity it's a good idea to place this stuff behind a corner, so that the enemy can't see it until it's too late. And yes, one maverick or hellfire kills the car.

Weapons:
1. Machine gun (SA/SS). Ammo: 100
2. Stinger missile (SA). Light, quick missiles. Ammo: 8
3. Land mines (SS). Ammo: 6
4. Remote-Controlled Bomb (SS). Ammo: 2. Press fire again to detonate.
Health: 150
Armour: 5

Note that mines and remote bombs explode after 2 minutes. This is needed to reduce the lag. For the same reason I have limited number of mines per player to 10. Your mine launcher jams when you have 10 mines laying around. You can use it again when some of your older mines are destroyed.

### Vehicle 10: Hovercraft

I don't know if hovers are used in military anywhere, but I added it as it's a cool idea and somewhat useful if there's water in the level. It's a bit like the tank in the way it has mostly ground weapons, and it has a turret. But it has less armour, and is a LOT faster except when climbing uphill. (Like real hovers, it sucks on sloped surfaces... Though downhill is pretty fun)  It also slides quite a bit in turns, and can get over obstacles on full throttle. (The altitude depends on throttle, shutting down the engines above water is not recommended :)  Lower throttle to get through doors, of course...

Weapons:
1. Machine gun (SA/SS). Ammo: 100
2. Plasma cannons (SA/SS). Ammo: 40
3. Rockets (SA/SS). Ammo: 10
4. Hellfire missile (SS). Ammo: 6
Health: 300
Armour: 10

## Legal Stuff

You may freely distribute AirQuake in non-commercial electronic formats. This includes public ftp- and www-sites and BBS systems, which don't charge money for downloading files.

For cover-CD's on computer magazines (or other "free" disks or similar media that accompanies other products), I require a free copy of the magazine and the CD to everybody who has contributed to AirQuake.

For other commercial CD's, I require more money than you have. Forget it. :)

AirQuake TC is copyright 1997, Iikka Ker�nen.

Quake is copyright 1996, Id software.
