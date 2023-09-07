/////////////////////
//  
//  PRECACHE
//  
/////////////////////

void () CUJO_Precache;

void () EnginePrecache =
{
	// Tei engine

	precache_model ("progs/multimisil.mdl");//Use engine hardcoded fx

	precache_model ("progs/fx_smoke.mdl");
	precache_model ("progs/fx_spark.mdl");
	precache_model ("progs/bolt.mdl");
	precache_model ("progs/bolt2.mdl");
	precache_model ("progs/bolt3.mdl");
	precache_model ("progs/fx_wizsmoke.mdl");
	precache_model ("progs/fx_voresmoke.mdl");
	precache_model ("progs/beam.mdl");
	precache_model ("progs/fx_gibsmoke.mdl");
	precache_model ("progs/fire2.mdl");
	precache_model ("progs/scorch.spr");
	precache_model ("progs/splatsmall.spr");
	precache_model ("progs/splat.spr");
	precache_model ("progs/bullethole.spr");
	precache_model ("progs/beam.mdl");
	precache_model ("progs/fx_bigfire.mdl");
	precache_model ("progs/fx_sparkshower.mdl");
	precache_model ("progs/fx_fireblue.mdl");
	precache_model ("progs/fx_fogmaker.mdl");
	precache_model ("progs/fx_fogmakerlite.mdl");
	precache_model ("progs/fx_enginefire.mdl");
	precache_model ("progs/fx_enginefire2.mdl");
	precache_model ("progs/fx_waterfall.mdl");
	precache_model ("progs/fx_void.mdl");
	precache_model ("progs/star2.mdl");
	precache_model ("progs/bigflare.spr");
	precache_model ("progs/flare.spr");
	precache_model ("progs/muz.spr");
	precache_model ("progs/muz2.spr");
	// Tei engine



  precache_model ("newmedia/f16.md2");
  precache_model ("newmedia/f18.md2");

  precache_model ("newmedia/helo.md2");
  precache_model ("newmedia/rotors.md2");

  precache_model ("newmedia/tankm1.md2");
  precache_model ("newmedia/turretm1.md2");

  precache_model ("newmedia/gunm1.md2");

  precache_model ("newmedia/f117.md2");

  precache_model ("newmedia/apache.md2");
  precache_model ("newmedia/aparotors.md2");

  precache_model ("newmedia/msam.md2");
  precache_model ("newmedia/msamturret.md2");
  precache_model ("newmedia/msamgun.md2");

  precache_model ("newmedia/a10.md2");

  precache_model ("newmedia/f22.md2");

	/*
	precache_model ("progs/humba.mdl");
	precache_model ("progs/humtb.mdl");
	precache_model ("progs/humtr.mdl");
	*/

  precache_model ("newmedia/palm1.md2");
  precache_model ("newmedia/palm3.md2");

  precache_model ("newmedia/brd.md2");
  precache_model ("newmedia/brdgun.md2");
  precache_model ("newmedia/brdturret.md2");

  precache_model ("progs/obus.mdl");

  precache_model ("progs/tree.mdl");
  precache_model ("progs/12pinos.mdl");
  precache_model ("progs/humba.mdl");
  precache_model ("progs/city.mdl");

  precache_model ("newmedia/oiltank.md2");

  precache_model ("newmedia/sampak.md2");
  precache_model ("progs/trail.spr");

  precache_model ("newmedia/comanche.md2");
  precache_model ("newmedia/comrotors.md2");

  precache_model ("progs/p8head.mdl");
  precache_model ("progs/p8walk.mdl");

  precache_model ("progs/p8.mdl");

  precache_model ("newmedia/orca.md2");

  precache_sound ("claw.wav");

  precache_model ("newmedia/a20.md2");
  precache_model ("newmedia/a40.md2");

  precache_model ("newmedia/su25.md2");

	CUJO_Precache();
};