/////////////////////
//  
//  fx_engine
//  
/////////////////////


// Tei decals

float STAT_EDITS = 0;
float STAT_ACTIVE = 1;
float STAT_MODELS = 2;
float STAT_SOLID = 3;
float STAT_STEP = 4;


float (float type_of_STAT ) statcount = #91; // Tei extra pfunctions
float (string str, string key ) kytest = #92; // Tei extra pfunctions
vector (string str, string format ) sscanf = #93; // Tei extra pfunctions
vector () rvector = #90; // Tei extra pfunctions
string (string s) hvstring = #94; // Tei extra pfunctions



float  TE_CUSTOMFX	 =	  18;
float TE_EXPLOSIONSMALL =	  19;
float TE_EXPLOSIONSMALL2	= 20;
float TE_EXPLOSIONSMALL3	= 21;


float EF_DECAL  	= 16;	//Tei decals 
float EF_BLUEFIRE   = 32;	//Tei fx effect
float EF_FIRE		= 64;  // Tei fire
float EF_DOWFIRE		= 128;  // Tei fire

float 	EF2_VOORTRAIL		= 1;
float	EF2_BIGFIRE 		= 2;
float	EF2_FOGSPLASH 	= 4;
float	EF2_WATERFALL 	= 8;
float EF2_FOGSPLASHLITE 	= 16;
float EF2_SPARKSHOWER 	= 32;
float EF2_DARKFIELD	 	= 64;
float EF2_ROTATEBIT	 	= 128;

float EF3_ROTATE1		= 1;
float EF3_ROTATE2		= 2;
float EF3_ROTATE0		= 3;
float EF3_ROTATE012		= 4;
float EF3_ROTATEZ		= 5;
float EF3_AUTOSNOW		= 6;
float EF3_TEMPUSVIVENDI	= 7;
float EF3_TEMPUSFIRE	= 8;
float EF3_TEMPUSSMOKE	= 9;
float EF3_SHADOWSHIELD	= 10;
float EF3_FLUXFIRE2		= 11;
float EF3_ROTATEZ10		= 12;
float EF3_ROTATEZ5		= 13;
float EF3_MAGICFIRE		= 14;
float EF3_DARKSMOKE		= 15;
float EF3_DARKTRAIL		= 16;
float EF3_DARKTRAIL2	= 17;
float EF3_FLUXFIRESMALL	= 18;
float EF3_CIRCLETRAIL	= 19;
float EF3_NODRAW 		= 20;//Never draw
float 	EF3_CLASSICDOWNFIRE = 21;
float EF3_NONET		= 22;//For waypoins, data holding, etc...
float EF3_AUTOVANISH	= 23;//Work!
float EF3_EBEAM		= 24;//?
float EF3_HIPERTRANS		= 25;
float EF3_HIPERTRANS2	= 26;
float  EF3_Q3AUTOGUN		= 27;
float EF3_GRAYBITS = 28;

.float	 scale;
.float	 glow_size;
.float	 glow_red;
.float	 glow_green;
.float	 glow_blue;
.float	 drops;
.float	 flakes;
.float alpha;
.entity drawonlytoclient;

float	MOVETYPE_FOLLOW	= 12; // Tomaz

/* Fx ents */

float FX_FIRE = 0 ;
float FX_BLUE = 1 ;
float FX_RED  = 2 ;
float FX_SMOKE = 3 ;
float FX_SPARK = 4 ;
float FX_VORE = 5 ;
float FX_WIZ = 6 ;
float FX_GIB = 7 ;
float FX_BOLT = 8 ;
float FX_BIGFIRE = 9;
float FX_SPARKSHOWER = 10;
float FX_FIREBLUE = 11;
float FX_FOGMAKER = 12;
float FX_FOGMAKERLITE = 12;
float FX_FOGENGINE = 13;
float FX_ENGINE = 14;
float FX_WATERFALL = 15;
float FX_MAGIC = 16;
float FX_AUTOSNOW = 17;
float FX_TEMPUSVIVENDI = 18;
float FX_TEMPUSFIRE = 19;
float FX_TEMPUSSMOKE = 20;
float FX_SHADOWSHIELD = 21;
float FX_FLUXFIRE2 = 22; 
float FX_MAGICFIRE = 23;
float FX_DARKSMOKE = 24;
float FX_DARKTRAIL = 25;
float FX_DARKTRAIL2 = 26;
float FX_FLUXFIRESMALL = 27;
float FX_CIRCLETRAIL = 28;
float FX_FLARE = 29;
float FX_BIGFLARE = 30;
float FX_FLAREFIRE = 30;
float FX_FLAREMINI = 31;// equal as flare :(
float FX_MUZ = 32;
float FX_GRAYBITS = 33;
float FX_AUTOGUN = 34;


entity (float fxt) SpawnFX =
{
	local entity ne;

	ne = spawn();

	setorigin(ne, self.origin);
	setsize (ne, '-0.1 -0.1 -0.1', '0.1 0.1 0.1');

	ne.solid = SOLID_NOT;
	ne.effects = ne.effects | EF_DECAL;
	ne.think = SUB_Remove;
	ne.nextthink = time + 0.1;
	ne.velocity = self.velocity;
	ne.avelocity = '600 600 600';

	ne.classname= "spike";

	if (fxt == FX_FIRE)
		{
			ne.glow_size = 30 ;
			ne.glow_red = 255;
			ne.glow_green = 0 ;
			ne.glow_blue =  0;
		setmodel (ne, "progs/flame2.mdl");
		return ne;
		}
	else

	if (fxt == FX_RED)
		{
			ne.glow_size = 30 ;
			ne.glow_red = 255;
			ne.glow_green = 0 ;
			ne.glow_blue =  0;
		setmodel (ne, "progs/bolt.mdl");
		return ne;
		}
	else

	if (fxt == FX_BLUE)
		{
			ne.glow_size = 30 ;
			ne.glow_red = 0;
			ne.glow_green = 0 ;
			ne.glow_blue = 255;
		setmodel (ne, "progs/bolt2.mdl");
		return ne;
		}
	else

	if (fxt == FX_SPARK)
		{
		setmodel (ne, "progs/fx_spark.mdl");
		return ne;
		}
	else

	if (fxt == FX_SMOKE)
		{
		setmodel (ne, "progs/fx_smoke.mdl");
		return ne;
		}
	else

	if (fxt == FX_VORE)
		{
		setmodel (ne, "progs/fx_voresmoke.mdl");
		return ne;
		}
	else

	if (fxt == FX_WIZ)
		{
		setmodel (ne, "progs/fx_wizsmoke.mdl");
		return ne;
		}
	else

	if (fxt == FX_GIB)
		{
		setmodel (ne, "progs/fx_gibsmoke.mdl");
		return ne;
		}
	else

	if (fxt == FX_BOLT)
		{
		setmodel (ne, "progs/bolt.mdl");
		return ne;
		}
	else

	if (fxt == FX_BIGFIRE)
		{
		setmodel (ne, "progs/fx_bigfire.mdl");
		return ne;
		}
	else

	if (fxt == FX_SPARKSHOWER)
		{
		setmodel (ne, "progs/fx_sparkshower.mdl");
		return ne;
		}
	else

	if (fxt == FX_FIREBLUE){		
		setmodel (ne, "progs/fx_fireblue.mdl");
		return ne;
		}
	else

	if (fxt == FX_FOGMAKER){		
		setmodel (ne, "progs/fx_fogmaker.mdl");
		return ne;
		}
	else

	if (fxt == FX_FOGMAKERLITE){		
		setmodel (ne, "progs/fx_fogmakerlite.mdl");
		return ne;
		}
	else

	if (fxt == FX_FOGENGINE){		
		setmodel (ne, "progs/fx_enginefire.mdl");
		return ne;
		}
	else

	if (fxt == FX_ENGINE){		
		setmodel (ne, "progs/fx_enginefire2.mdl");
		return ne;
		}
	else

	if (fxt == FX_WATERFALL){		
		setmodel (ne, "progs/fx_waterfall.mdl");
		return ne;
		}
	else

	if (fxt == FX_MAGIC){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_MAGICFIRE;
		return ne;
		}
	else

	if (fxt == FX_AUTOSNOW){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_AUTOSNOW;
		return ne;
		}
	else

	if (fxt == FX_TEMPUSVIVENDI){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_TEMPUSVIVENDI;
		return ne;
		}
	else

	if (fxt == FX_TEMPUSFIRE){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_TEMPUSFIRE;
		return ne;
		}
	else

	if (fxt == FX_TEMPUSSMOKE){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_TEMPUSSMOKE;
		return ne;
		}
	else

	if (fxt == FX_SHADOWSHIELD){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_SHADOWSHIELD;
		return ne;
		}
	else
	if (fxt == FX_FLUXFIRE2){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_FLUXFIRE2;
		return ne;
		}
	else
	if (fxt == FX_MAGICFIRE){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_MAGICFIRE;
		return ne;
		}
	else
	if (fxt == FX_DARKSMOKE){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_DARKSMOKE;
		return ne;
		}
	else
	if (fxt == FX_DARKTRAIL){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_DARKTRAIL;
		return ne;
		}
	else
	if (fxt == FX_DARKTRAIL2){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_DARKTRAIL2;
		return ne;
		}
	else
	if (fxt == FX_FLUXFIRESMALL){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_FLUXFIRESMALL;
		return ne;
		}
	else
	if (fxt == FX_CIRCLETRAIL){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_CIRCLETRAIL;
		return ne;
		}
	else
	if (fxt == FX_FLARE){		
		setmodel (ne, "progs/flare.spr");
		//ne.effects3 = EF3_FLUXFIRESMALL;

		ne.glow_size 		= 40 ;
		ne.glow_red 		= 255;
		ne.glow_green 	= 255;
		ne.glow_blue 		= 255;
		return ne;
		}
	else
	if (fxt == FX_BIGFLARE){		
		setmodel (ne, "progs/bigflare.spr");
		//ne.effects3 = EF3_CIRCLETRAIL;
		return ne;
		}
	else
	if (fxt == FX_FLAREFIRE){		
		//FIXME: NOT WORK?????
		setmodel (ne, "progs/flare.spr");
		ne.effects3 = EF3_FLUXFIRESMALL;
		ne.glow_size 		= 90;
		ne.glow_red 		= 250;
		ne.glow_green 	= 250;
		ne.glow_blue 		= 250;
		return ne;
	}
	else
	if (fxt == FX_MUZ){		
		if (random()<0.9) 
		{
			setmodel (ne, "progs/muz.spr");
		}
		else
			setmodel (ne, "progs/muz2.spr");

		if (random()<0.1)
				ne.skin = 1;
		else
				ne.skin = 0;

		ne.alpha = random() * 0.7;

		ne.movetype = MOVETYPE_NONE;
		ne.think = SUB_Remove;
		ne.nextthink = time + 0.1;
		ne.velocity = '0 0 0';
		return ne;
	}
	else
	if (fxt == FX_GRAYBITS){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_GRAYBITS;
		return ne;
		}
	else
	if (fxt == FX_AUTOGUN){		
		setmodel (ne, "progs/fx_void.mdl");
		ne.effects3 = EF3_Q3AUTOGUN;
		return ne;
		}
	
	return ne;
};



void () tfire =
{

	if (!self.weapon)
		self.think = SUB_Remove;

	self.weapon = self.weapon - 1;
	self.nextthink = time + 0.1;

	if( !self.weapon)	{ self.think = SUB_Remove;	}

	if (!self.aiment)	    remove(self);

	if (!self.aiment.model) remove(self);

	if (self.aiment)
	if(self.aiment.classname == "player")
	if( (self.aiment.health * random()) > 50)
		remove(self);

	//	if (decalcount > (MAX_DECALS * 0.5))
	//	self.think = SUB_Remove;
}

void (float counter, entity ent, float FXT) InFxEnt =
{
	local entity f;
	//bprint("hello\n");
	
	

	f = SpawnFX(FXT); 
	f.think = tfire;
	f.nextthink = time + 0.1; 
	f.owner  = ent;
	f.aiment = ent;


	f.weapon = counter;
	f.classname = "spike";
	f.solid = SOLID_NOT;
	setsize (f, '0 0 0', '0 0 0');

	// < FORCE AIMENT
	f.aiment = ent;
	f.movetype = MOVETYPE_FOLLOW;
	f.aiment = ent;
	// FORCE AIMENT >

};





void (vector pos, string decalname) PlaceDecal = 
{
    
    local entity new;
    local vector norm;
    
    new = spawn ();
    new.owner = new;
    new.alpha = 0.99;
    new.movetype = MOVETYPE_NONE;
    new.solid = SOLID_NOT;
    new.classname = "decal";
    setmodel (new, decalname);
    setsize (new,VEC_ORIGIN,VEC_ORIGIN);
    norm = trace_plane_normal;
    norm_x = (FALSE - norm_x);
    norm_y = (FALSE - norm_y);
    //norm_z = random() * 360;
    new.angles = vectoangles (norm);
    makevectors (self.angles);
    setorigin (new,(pos - (v_forward * 0.2) + (v_up * 0.2)));
    if (pointcontents(new.origin) == CONTENT_SKY)    {
	    remove(new);
	    return;
    }
    new.think = SUB_Remove;
    new.nextthink = -1;
    new.alpha = 1;
    new.effects3 = 23;
    new.effects = new.effects | EF_DECAL; // Help engine limits	
    //WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    //WriteByte (MSG_BROADCAST,  20);//21
    //WriteVec ( self.origin);

};	


void (vector pos, string decalname) PlaceDecal2 = 
{
    
    local entity new;
    local vector norm;
    
    new = spawn ();
    new.owner = new;
    new.alpha = 0.99;
    new.movetype = MOVETYPE_NONE;
    new.solid = SOLID_NOT;
    new.classname = "decal";
    setmodel (new, decalname);
    setsize (new,VEC_ORIGIN,VEC_ORIGIN);
    norm = trace_plane_normal;
    norm_x = (FALSE - norm_x);
    norm_y = (FALSE - norm_y);
    //norm_z = random() * 360;
    new.angles = vectoangles (norm);
    makevectors (self.angles);
    setorigin (new,(pos - (v_forward * 0.2) + (v_up * 0.2)));
    if (pointcontents(new.origin) == CONTENT_SKY)    {
	    remove(new);
	    return;
    }
    new.think = SUB_Remove;
    new.nextthink = -1;
    new.alpha = 1;
    new.effects3 = 23;
    new.effects = new.effects | EF_DECAL; // Help engine limits	
};

void () FX_Scorch =
{
	traceline(self.origin, self.origin + '0 0 -10', FALSE, self);
	if(trace_fraction != 1)
	    PlaceDecal(trace_endpos+'0 0 1', "progs/scorch.spr");
};


void () FX_Trail =
{
	traceline(self.origin+'0 0 5', self.origin + '0 0 -20', FALSE, self);
	bprint("trail?");	
       PlaceDecal2(trace_endpos+'0 0 1', "progs/trail.spr");

	/*	if(trace_fraction != 1)
	{
	    PlaceDecal(trace_endpos+'0 0 1', "newmedia/trail.spr");
		bprint(" yes\n");

	}	
	else
		bprint(" no\n");
	*/
};

void (vector pos, string decalname) PlaceDecalFinal = 
{
    
    local entity new;
    local vector norm;
    
    new = spawn ();
    new.owner = new;
    new.alpha = 0.99;
    new.movetype = MOVETYPE_NONE;
    new.solid = SOLID_NOT;
    new.classname = "decal";
    setmodel (new, decalname);
    setsize (new,VEC_ORIGIN,VEC_ORIGIN);
    norm = trace_plane_normal;
    norm_x = (FALSE - norm_x);
    norm_y = (FALSE - norm_y);
    //norm_z = random() * 360;
    new.angles = vectoangles (norm);
    makevectors (self.angles);
    setorigin (new,(pos - (v_forward * 0.2) + (v_up * 0.2)));
    if (pointcontents(new.origin) == CONTENT_SKY)    {
	    remove(new);
	    return;
    }
    new.think = SUB_Remove;
    new.nextthink = -1;
    new.alpha = 1;
    //new.effects3 = 23;
    //new.effects = new.effects | EF_DECAL; // Help engine limits	
	/*
    WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
    WriteByte (MSG_BROADCAST,  20);//21
    WriteVec ( self.origin);
	*/

};

void (vector org) FX_ScorchFinal =
{
	traceline(self.origin,org + '0 0 -20', FALSE, self);
	if(trace_fraction != 1)
	    PlaceDecal(trace_endpos+'0 0 1', "progs/scorch.spr");
};

void (vector org, vector end, float type, float typelife, float dead, float fxscale, float key ) StaticFX =
{
	/*
	start[0] = MSG_ReadCoord (); // Origin
	start[1] = MSG_ReadCoord ();
	start[2] = MSG_ReadCoord ();
	
	end[0] = MSG_ReadCoord ();	 // Origin2...	
	end[1] = MSG_ReadCoord ();
	end[2] = MSG_ReadCoord ();

	type		= MSG_ReadByte ();  // Fire, smoke, magic, rays.. etc..
	typelife	= MSG_ReadByte ();  // Temporal, static, etc..
	dead		= MSG_ReadCoord ();	// cl.time + deadclock dead (if type need)
	scale		= MSG_ReadCoord (); // 0.1 -- 4
	key			= MSG_ReadByte ();	// Key for delete and change
	*/
	
	if (cvar("no_staticfx"))
		return;


	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);	
	WriteByte ( MSG_BROADCAST,  49 ); 			
	WriteByte ( MSG_BROADCAST,  1 ); 	// Static TempEntity protocol 1.0
	WriteVec  ( org );				
	WriteVec  ( end );	
	WriteByte ( MSG_BROADCAST,  type ); 			
	WriteByte ( MSG_BROADCAST,  typelife ); 			
	WriteByte ( MSG_BROADCAST,  dead ); 			
	WriteByte ( MSG_BROADCAST, fxscale * 100 ); 			
	WriteByte ( MSG_BROADCAST,  key ); 			
};

// Tei - decals


//void (float handle) close = #87;
void (float handle) close = #111;
//float (string file, float mode) open = #86; // 0 read 1 append , 3 def write
float (string file, float mode) open = #110; // 0 read 1 append , 3 def write

//string (float handle) read = #88;
string (float handle) read = #112;
//void ( float handle , string print) write = #89;
void ( float handle , string print) write = #113;

//string(string s1, string s2) strcat = #82;
//float ( string fstring) stof = #84;
//vector ( string vecstring) stov = #85;
//string (string src, float from, float len) substring = #83;
//float (string str) strlen = #81;

//float (string mys) zone = #79 ;
//void (float pmys) unzone = #80 ;
string (string cvar) cvarstring = #97;
void () CheatCommand;

float FILE_WRITE = 2;
float FILE_APPEND = 1;
float FILE_READ = 0;

void () plant =
{
	local float pc;

	pc =pointcontents(self.origin);

	if (pc == CONTENT_EMPTY) 
	{
		self.nextthink = time + 0.1;
		setorigin(self, self.origin + '0 0 -1');
	}
	else
		self.nextthink = time + 110;

	self.weapon = self.weapon - 1;

	if ( !self.weapon ) {
		self.nextthink = -1;
	}
};

void (vector org, string tipe) GenDetal =
{
	local entity detal;

	detal = spawn();

	setmodel(detal, tipe );
	setorigin(detal, org );
	if (tipe == "progs/12pinos.mdl")
	{
		setorigin(detal, detal.origin +'0 0 -16' * random());
		self.scale = self.scale = 1 + random() * 0.5;
	}
	else
	if (tipe == "progs/city.mdl")
	{
		self.scale = 8;
		setorigin(detal, detal.origin +'0 0 -22');
	}
	else
	if (tipe == "newmedia/oiltank.md2")
	{
		setorigin(detal, detal.origin +'0 0 -22');
	}
	else
	if (tipe == "progs/tree.mdl")
	{
		self.scale = self.scale = 1 + random() * 0.5;
		setorigin(detal, detal.origin +'0 0 -10');
	}

	detal.angles_y = random()*360;
};

void () NewPalm =
{
	local vector pos;
	//pos = stov(cvarstring("palm"));	
	//GenDetal(pos);
	//bprint("HERE ", vtos(pos), " palm\n");
	//localcmd("echo hello\n");
	//dprint("no flores\n");
	//CheatCommand();
};


void () test =
{
	return;
 /*
  localcmd("exec maps/cfgs/palms.cfg\n");
  bprint("hello startframe\n");
  dprint("hello startframe\n");
	*/
};


void (string file) TouchFile = 
{
	//HACK HACK HACK
	local float f;
	f = fopen(file, FILE_APPEND);
	//write(f,"\n"); 
	write(f,""); 

	close(f);
	//HACK HACK HACK
};


void () ReadSkymax =
{
	dprint("readsky\n");
	return;

	if (cvarstring("skymap") != mapname ) 	
		return;

	dprint( "skymax\n");

	localcmd("temp1 33");
	sky_z = cvar("skymax");
};





void() SnowCopy = //BIG AND DIRTY HACK for SNOW maps.
{
	dprint("---- SnowCopy ----\n");
	return;
	local	entity new;
	local float snowoff;

	if (cvarstring("snowcopy_map") != mapname ) 	
		return;
	
	snowoff = cvar("snow_offset");

	if (!snowoff)
		snowoff = 3;	//default snowcopy

	new = spawn();
	

	setorigin(new, world.origin + '0 0 1' * snowoff); 
	setmodel (new, world.model);
	new.alpha = 1;
};


void () FileDetal =
{
	local float f, hs;
	local string str2, str3;
	local vector v;
	local string typedetal;
	local string str2, str3 , str;
	local string base;

	

	// Initializing world defaults per map
	ReadSkymax(); //FIXME!! does not work!
	SnowCopy(); // FIXME dirty hack
	//

	base = "maps/cfgs/";

	str2 = strcat( base , mapname );

	//hs = zone( str2 );

	//str3 = strcat( hs , ".ini");
	str3 = strcat(str2, ".ini");

	TouchFile(str3);//HACK HACK HACK!!!

	f = fopen( str3 , FILE_READ);


	typedetal = "newmedia/palm1.md2"; //Default
	str = read(f);

	while ( str != "$END" && str != "")
	{
		v = stov(str);
		if (v == '0 0 0')
		{
			if (str == "PALMS")
				typedetal = "newmedia/palm3.md2";
			else
			if (str == "TREES")
				typedetal = "progs/12pinos.mdl";
			else
			if (str == "OUTPOST")
				typedetal = "progs/city.mdl";
			else
			if (str == "OIL")
				typedetal = "newmedia/oiltank.md2";
			else
			if (str == "STREE")
				typedetal = "progs/tree.mdl";//FIXME, high poly count
		}
		else
			GenDetal(v, typedetal);	
		
		str = read(f);
	}

	close( f );
	//unzone( hs );
};


void () AddLocation =
{
	local float f, hs;
	local float nm;
	local string str2, str3;
	local string base;

	base = "maps/cfgs/";

	str2 = strcat( base , mapname );

	//hs = zone(str2);

	//str3 = strcat( hs , ".ini");
	str3 = strcat(str2, ".ini");

	bprint( str3 , " adding data\n");
	
	f = fopen(str3, FILE_APPEND);
	write(f,vtos(self.origin)); 
	write(f,"\n");
	close(f);

	//unzone(hs);
}


void() item_mdl =
{

	if (self.message == "progs/enginefire.mdl")
		self.message = "progs/fx_enginefire.mdl";

	if (self.message == "progs/waterfall.mdl")
		self.message = "progs/fx_waterfall.mdl";


	precache_model (self.message);
	setmodel (self, self.message);
	
	self.frame = self.angles_z;

	StaticFX( self.origin + '0 0 -20', self.origin,2,1,10,1,1,4);
	

	makestatic(self);
};


void() item_dropmdl =
{
	precache_model (self.message);
	setmodel (self, self.message);
	
	self.frame = self.angles_z;
	//( org, end, type, typelife, dead, fxscale, key ) 
	droptofloor(0,0);
	traceline (self.origin,self.origin + ' 0 0 -1000' , FALSE, self);
	setorigin(self, self.origin + '0 0 -1000' * trace_fraction );
	StaticFX( self.origin + '0 0 -20', self.origin,2,1,10,1,1,4);

	makestatic(self);
};


string bsp_origin1;
string bsp_origin2;


void () func_rotatemaster =
{
	setmodel (self, self.model);
	bsp_origin2 = self.model;	
	self.alpha = 0.01;
	makestatic(self);
};

void () func_clonemaster =
{
	setmodel (self, self.model);
	bsp_origin1 = self.model;	
	self.alpha = 0.01;
	makestatic(self);
};

void () bsp_clone =
{
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, bsp_origin1);
	//makestatic(self);
};


void () bsp_rotate =
{
	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, bsp_origin2);
	self.effects3 = 8;
	//self.effects2 = EF2_DARKFIELD | EF2_FOGSPLASH;
};



void () tempus_fire =
{
	setmodel (self, "progs/fx_enginefire2.mdl");
	self.effects3 = 8;
};

void () tempus_smoke =
{
	setmodel (self, "progs/fx_enginefire2.mdl");
	self.effects3 = 9;
};


void() func_tfgoal =
{
	//self.angles = '0 0 0';
	precache_model(self.mdl);
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_NOT;
	setmodel (self, self.mdl);
	//makestatic ();
};

void () event_cmd =
{
	localcmd(self.message);
	self.nextthink = time + 1;
	self.think = SUB_Remove;
};


void(vector org) HumoHere =
{
	local	entity new;

	new = spawn();
	
	new.effects = EF_DECAL;
	
	setorigin(new, org);
	//setmodel (new, "progs/fx_smoke.mdl");
	setmodel (new, "progs/fx_void.mdl");

	setsize (new, '0 0 0', '0 0 0');

	new.effects3 = 28;//EF3_GRAYBITS
	new.think = SUB_Remove; //SUB_Remove;
	new.nextthink = time + 0.1;
};

void(entity s) CopterSparks =
{
	local vector rvec;

	//bprint( "hello-cs\n");
	if (random()<0.5) 
	{
	traceline (s.origin, s.origin + '0 0 -80', TRUE, s);
	if (trace_fraction < 1){
		rvec = rvector();
              rvec_z = 0;
		//s.velocity_z = s.velocity_z + 4 * random() ;
		HumoHere( trace_endpos + '0 0 0.1' + rvec * 10 * (2 - trace_fraction) );
		}
	}
};

string f117 = "newmedia/f117.md2";



float TE_EXPLOSION2 = 12;
float TE_BEAM		= 13;
float TE_SNOW		= 14;
float TE_RAIN		= 15;
float TE_PLASMA		= 16;
float TE_RAILTRAIL	= 	17;

void () HackLux =
{
		lightstyle(0, cvarstring("lux"));
};


string () RandomMoron =
{
	local float f,r;
	local string str;
	
	f = 0;
	r = rint(random ()*44 * 2);
	
	//bprint ( ftos(r) , " line\n");
	f = fopen ( "dead.txt", FILE_READ );

	if (!f)
 		bprint("File dead.txt is lost!\n");

	while ( r>0 ) 
	{
		str = read( f) ;				
		//bprint ( str, "read\n");
		r = r - 2;
	}
	close (f);

	return str;
};


void () active =
{
	self.weapon = 231;
	self.movedir = '10 23 45';
};


void () Swap =
{
	local vector tmp;

	tmp = self.Cujo.origin;
	setorigin(self.Cujo, self.enemy.origin);
	setorigin(self.enemy, tmp);
	setorigin(self, tmp +'0 0 10');

	if (self.enemy.flags & FL_ONGROUND )
		self.enemy.flags = self.enemy.flags - FL_ONGROUND;

	if (self.Cujo.flags & FL_ONGROUND )
		self.Cujo.flags = self.Cujo.flags - FL_ONGROUND;
};





void () Command_Console =
{
	bprint(cvarstring("callvar"));
	bprint ("hola mundo\n");
};





