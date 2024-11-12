# Pocket openFPGA SLAP FIGHT / ALCON Core with support for Analogizer-FPGA adapter
* Analogizer V1.0.0 [12/11/2024]: Added initial support for Analogizer adapter (RGBS, RGsB, YPbPr, Y/C, SVGA Scandoubler) and SNAC.

Adapted to Analogizer by [@RndMnkIII](https://github.com/RndMnkIII) based on **Anton Gale** SLAP FIGHT / ALCON FPGA core for the Analogue Pocket platform.
The core can output RGBS, RGsB, YPbPr, Y/C and SVGA scandoubler(0%, 25%, 50% 75% scanlines and HQ2x) video signals.

| Video output | Status |
| :----------- | :----: |
| RGBS         |  ✅    |
| RGsB         |  ✅    |
| YPbPr        |  ✅    |
| Y/C NTSC     |  ✅    |
| Y/C PAL      |  ✅    |
| Scandoubler  |  ✅    |

The Analogizer interface allow to mix game inputs from compatible SNAC gamepads supported by Analogizer (DB15 Neogeo, NES, SNES, PCEngine) with Analogue Pocket built-in controls or from Dock USB or wireless supported controllers (Analogue support).

**Analogizer** is responsible for generating the correct encoded Y/C signals from RGB and outputs to R,G pins of VGA port. Also redirects the CSync to VGA HSync pin.
The required external Y/C adapter that connects to VGA port is responsible for output Svideo o composite video signal using his internal electronics. Oficially
only the Mike Simone Y/C adapters (active) designs will be supported by Analogizer and will be the ones to use.

Support native PCEngine/TurboGrafx-16 2btn, 6 btn gamepads and 5 player multitap using SNAC adapter
and PC Engine cable harness (specific for Analogizer). Many thanks to [Mike Simone](https://github.com/MikeS11/MiSTerFPGA_YC_Encoder) for his great Y/C Encoder project.

For output Y/C and composite video you need to select in Pocket's Menu: `Analogizer Video Out > Y/C NTSC` or `Analogizer Video Out > Y/C NTSC,Pocket OFF`.
For output Scandoubler SVGA video you need to select in Pocket's Menu: `Analogizer Video Out > Scandoubler RGBHV`.

You will need to connect an active VGA to Y/C adapter to the VGA port (the 5V power is provided by VGA pin 9). I'll recomend one of these (active):
* [MiSTerAddons - Active Y/C Adapter](https://misteraddons.com/collections/parts/products/yc-active-encoder-board/)
* [MikeS11 Active VGA to Composite / S-Video](https://ultimatemister.com/product/mikes11-active-composite-svideo/)
* [Active VGA->Composite/S-Video adapter](https://antoniovillena.com/product/mikes1-vga-composite-adapter/)

Using another type of Y/C adapter not tested to be used with Analogizer will not receive official support.
============================================================================================================

<h1># SLAP FIGHT / ALCON</H1>
FPGA core for the Analogue Pocket platform developed by Anton Gale.

A big thank you to Boogermann for providing a template and tools to help build this core.

Thank you to the following members of the community: Boogermann, misterretrowolf, Jotego, JimmyStones, atrac17 & BirdyBro.

Slap Fight was developed by Toaplan and released by Taito in 1986. Slap Fight was known as ALCON (Alien League Of Cosmic Nations)

<h2>Compatible Platforms</h2>
<li>Analogue Pocket</li>

<h2>Compatible Games</h2>
<blockquote>
<p dir="auto"><strong>ROMs NOT INCLUDED:</strong> By using this core you agree to provide your own roms.</p>
</blockquote>

<li>Slap Fight</li>
<li>Tiger Heli</li>
<li>Get Star</li>

<h2>Game Instructions:</h2>

	The year is 2059.  Aliens have overrun the planet.  The Allied League of Cosmic Nations, commonly called ALCON, have convened to combat this menace to the world.  ALCON has determined that a sole, experienced pilot, flying the experimental SW475 aircraft, must defend the world against certain destruction.

	YOU are the pilot that must fly the SW475 aircraft and defeat the aliens.

<h2>Maneuvers:</h2>

	Use the joystick to fly the SW475 over the terrain.
	Use 'Fire' button to shoot at enemies.
	Use 'Weapon Select' button to choose your weapons.
	The 'Weapon's Gauge' on the bottom of the screen shows which weapons can be used (the wording on the weapons turn yellow).
	Pick up starts to advance 'Weapon's Gauge'

<h2>Weapons available on the SW475:</h2>

	SPEED  - This will increase you flying speed
	SHOT   - Normal forward fire
	SIDE   - Right and Left fire
	WING   - Double, Triple and Quadruple fire power
	BOMB   - Wide range fire
	LASER  - Long range fire
	H. MIS - Homing missiles
	SHIELD - Indestructible against three hits

<h2>DIP Switch Settings:</h2>

	Cabinet Type       - Up-Right* ,Table
	Screen			   - Normal*, Invert
	Mode			   - Normal Game*, Screen Test Mode
	Demo Sounds		   - ON*, OFF 
	Coinage            - 1 Coin/1 Play*, 1 Coin/2 Play, 2 Coins/1 Play, 2 Coins/3 Play
	Difficulty         - A, B*, C, D
	Extend             - 30000 Every 100000*, 50000 Every 200000, 50000 Only, 100000 Only
	Fighter Count      - 1,2,3* & 5
	Dip Switch Display - OFF*, ON (show dip switch configuration) 

	*Factory Setting
