/////////////////////
//  
//  GUI
//  
/////////////////////


float ORG_NW = 0;//Ok
float ORG_NE = 1;
float ORG_SW = 2;
float ORG_SE = 3;
float ORG_CC = 4;//Ok
float ORG_CN = 5;
float ORG_CS = 6;
float ORG_CW = 7;
float ORG_CE = 8;//Ok

float SVC_ITEMGUI 	 = 41;// Tomaz SHOWLMP hacked
float SVC_ITEMGUIX   = 42;// Tomaz SHOWLMP hacked2




void (string str, entity tag , string slot, float x, float y , float Zone ) g_show =
{
      local entity oldmy;

	// NegCodign
	if (Zone == ORG_CC ||   ORG_CW == Zone || ORG_CE == Zone )
		y = y + 8000;

	if (Zone == ORG_CC || ORG_CN == Zone || ORG_CS == Zone  )
		x = x + 8000;
	// NegCoding

      oldmy = msg_entity;
      msg_entity = tag;

      WriteByte  (MSG_ONE, SVC_ITEMGUI);
      WriteByte(MSG_ONE,Zone );

      WriteString(MSG_ONE,slot);
      WriteString(MSG_ONE,str);

      WriteShort(MSG_ONE, x);
      WriteShort(MSG_ONE, y);
	
      msg_entity = oldmy;
};



void (string str, entity tag ) g_weapon =
{
      local entity oldmy;

      oldmy = msg_entity;
      msg_entity = tag;

      WriteByte  (MSG_ONE, SVC_ITEMGUI);
      WriteByte(MSG_ONE,ORG_SE );

      WriteString(MSG_ONE,"gun1");
      WriteString(MSG_ONE,str);

      WriteShort(MSG_ONE, 56+1);
      WriteShort(MSG_ONE, 24+1);
	
      msg_entity = oldmy;
};


void (string str, entity tag) g_UnShow =
{
	return;
      local entity oldmy;

      oldmy = msg_entity;
      msg_entity = tag;

      WriteByte  (MSG_ONE, 36);//hide
      WriteString(MSG_ONE,str);

      msg_entity = oldmy;
};


void (string what) Geapon = //GUI weapon
{
	if (what == "hellfire")
		g_weapon("newmedia/hellfire.lmp",self);
	else
	if (what == "sider")
		g_weapon("newmedia/sider.lmp",self);
	else
	if (what == "sam")
		g_weapon("newmedia/sam.lmp",self);
	else
	if (what == "rockets")
		g_weapon("newmedia/rockets.lmp",self);
	else
	if (what == "rc")
		g_weapon("newmedia/rc.lmp",self);
	else
	if (what == "auto")
		g_weapon("newmedia/auto.lmp",self);
	else
	if (what == "plasma")
		g_weapon("newmedia/plasma.lmp",self);
	else
	if (what == "mine")
		g_weapon("newmedia/mine.lmp",self);
	else
	if (what == "maver")
		g_weapon("newmedia/maver.lmp",self);
	else
	if (what == "pave")
		g_weapon("newmedia/pave.lmp",self);
	else
	if (what == "amram")
		g_weapon("newmedia/amram.lmp",self);
	else
	if (what == "canon")
		g_weapon("newmedia/canon.lmp",self);
	else
	if (what == "bomb")
		g_weapon("newmedia/bomb.lmp",self);
	else
	if (what == "sting")
		g_weapon("newmedia/sting.lmp",self);
	else
		g_weapon("newmedia/slot.lmp",self);

};


//void (string str, entity tag , string slot, float x, float y , float Zone ) 


void () Markus =
{
	g_show( "pix/bord.lmp",self,"m1",0-(256),8,ORG_CN);
	g_show( "pix/bord.lmp",self,"m2",0-(256),16+8,ORG_CS);
};

void () UnShowCamo;
void () ShowNOVideo;


void (string g) G_SelectedShow =
{
		stuffcmd(self,"viewsize 200\n");
		Markus();
		g_show( "pix/hud.lmp",self,"hud",0-(320*0.5),0 - 30,ORG_CC);
		g_show( "pix/aqlogo.lmp",self,"logo",0-(320*0.5),16,ORG_CN);
		g_show( g,self,"selected",-64,16,ORG_CC);
		UnShowCamo();//FIXME??
};


void () UnShowSelected =
{
	stuffcmd(self,"viewsize 100\n");
	g_UnShow( "hud", self );
	g_UnShow( "selected", self );
	g_UnShow( "logo", self );
	g_UnShow( "m1", self );
	g_UnShow( "m2", self );
	ShowNOVideo();//FIXXME?
}



//36

void (string g) GSelected = //FIXME do this with zone/unzone
{
	if (g=="f4")
		G_SelectedShow("pix/f4.lmp");
	else
	if (g=="f18")
		G_SelectedShow("pix/f18.lmp");
	else
	if (g=="f14")
		G_SelectedShow("pix/f14.lmp");
	else
	if (g=="f16")
		G_SelectedShow("pix/f16.lmp");
	else
	if (g=="f22")
		G_SelectedShow("pix/f22.lmp");
	else
	if (g=="f117")
		G_SelectedShow("pix/f117.lmp");
	else
	if (g=="m1")
		G_SelectedShow("pix/m1.lmp");
	else
	if (g=="helo")
		G_SelectedShow("pix/havoc.lmp");
	else
	if (g=="a10")
		G_SelectedShow("pix/a10.lmp");
	else
	if (g=="msam")
		G_SelectedShow("pix/msam.lmp");
	else
	if (g=="brd")
		G_SelectedShow("pix/brd.lmp");
	else
	if (g=="hover")
		G_SelectedShow("pix/hover.lmp");
	else
	if (g=="apache")
		G_SelectedShow("pix/apache.lmp");
	else
	if (g=="comanche")
		G_SelectedShow("pix/comanche.lmp");
	else
	if (g=="orca")
		G_SelectedShow("pix/orca.lmp");
	else
	if (g=="mech")
		G_SelectedShow("pix/mech.lmp");
	else
	if (g=="a20")
		G_SelectedShow("pix/a20.lmp");
	else
	if (g=="a40")
		G_SelectedShow("pix/a40.lmp");
	else
	if (g=="su25")
		G_SelectedShow("pix/su25.lmp");
};


void (float num) g_updatesteer =
{
	if (num < 1)
		g_show( "pix/t1.lmp",self,"steer",1,48+1,ORG_SW);
	else
	if (num < 2)
		g_show( "pix/t2.lmp",self,"steer",1,48+1,ORG_SW);
	else
	if (num < 3)
		g_show( "pix/t3.lmp",self,"steer",1,48+1,ORG_SW);
	else
	if (num < 4)
		g_show( "pix/t4.lmp",self,"steer",1,48+1,ORG_SW);
	else
	if (num < 5)
		g_show( "pix/t5.lmp",self,"steer",1,48+1,ORG_SW);
	else
		g_show( "pix/t6.lmp",self,"steer",1,48+1,ORG_SW);
};

void () ShowVideo =
{
		g_show( "pix/vidi.lmp",self,"video",50+1,9,ORG_NE);
};

void () ShowNOVideo =
{
		g_show( "pix/vidino.lmp",self,"video",50+1,9,ORG_NE);
};


void () ShowCamo =
{
		g_show( "pix/camo1.lmp",self,"camode1",0,0,ORG_NW);
		g_show( "pix/camo2.lmp",self,"camode2",200,0,ORG_NE);
		g_show( "pix/camo3.lmp",self,"camode3",200,200,ORG_SE);
		g_show( "pix/camo4.lmp",self,"camode4",0,200,ORG_SW);
};

void () UnShowCamo =
{
	g_UnShow( "camode1",self);
	g_UnShow( "camode2",self);
	g_UnShow( "camode3",self);
	g_UnShow( "camode4",self);
};



void (float orgset, string name, string lmpfile, float dx, float dy, float num, float sx, float sy ) g_array =
{
      local entity oldmy;

      oldmy = msg_entity;
      msg_entity = self;

      WriteByte ( MSG_ONE, SVC_ITEMGUIX );
      WriteByte ( MSG_ONE,ORG_NW );

      WriteString ( MSG_ONE,name );
      WriteString ( MSG_ONE,lmpfile );

      WriteShort ( MSG_ONE, dx );
      WriteShort ( MSG_ONE, dy );

      WriteByte ( MSG_ONE, 1 );//CNT_ARRAY

      WriteShort ( MSG_ONE, num );//p1
      WriteShort ( MSG_ONE, sx );//p2
      WriteShort ( MSG_ONE, sy );//p3
	
      msg_entity = oldmy;
};


void (float curr) g_ammo =
{
	g_array(ORG_NW,"ammo","pix/amm1.lmp",8,32,curr,0,12);
	bprint("ammo set\n");
};

void () testgamo =
{
	//g_ammo(cvar("temp1"));
};


void () testlmpstring =
{
      local entity oldmy;

      oldmy = msg_entity;
      msg_entity = self;

      WriteByte  (MSG_ONE, SVC_ITEMGUIX);
      WriteByte(MSG_ONE,ORG_NW );

      WriteString(MSG_ONE,"xxx");
      WriteString(MSG_ONE,"hola mundo");

      WriteShort(MSG_ONE, 8);
      WriteShort(MSG_ONE, 8);

      WriteByte(MSG_ONE, 2);//String

      WriteShort(MSG_ONE, 0);//p1
      WriteShort(MSG_ONE, 0);//p2
      WriteShort(MSG_ONE, 0);//p3
	
      msg_entity = oldmy;
};

void () testalpha =
{
      local entity oldmy;
      local float v;

	v= cvar("temp1");


      oldmy = msg_entity;
      msg_entity = self;

      WriteByte  (MSG_ONE, SVC_ITEMGUIX);
      WriteByte(MSG_ONE,ORG_NW );

      WriteString(MSG_ONE,"xxx");
      WriteString(MSG_ONE,"pix/a10.lmp");

      WriteShort(MSG_ONE, 8);
      WriteShort(MSG_ONE, 8);

      WriteByte(MSG_ONE, 3);//alpha

      WriteShort(MSG_ONE, v );//p1
      WriteShort(MSG_ONE, 22);//p2
      WriteShort(MSG_ONE, 22);//p3
	
      msg_entity = oldmy;
};




