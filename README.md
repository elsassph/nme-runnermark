nme-RunnerMark
==============

**Performance demonstration**

First goal was to do a haxe NME port of [esDotDev's RunnerMark][1] for fair comparison of a realistic game scene. 

Minor twists: 
- shows 3 enemies even if it can't reach 58fps,
- for older Android devices you should not target 60fps; my HTC Desire (Nexus One) does a good job with lower targets.

Here are the scores (FPSx10 + ennemies count, **in bold after engine update**):
 - iPad 1: 823
 - iPod Touch 4: **970**
 - iPad 2: **1454**
 - iPad 3: **1454**
 - Nexus One (2.2): 460 (target 58fps), 487 (30fps)
 - Nexus One (2.3.7): **470** (target 58fps), **577** (30fps)
 - Motorola Defy: 595 (target 30fps)
 - Samsung Galaxy Ace: 850 (target 30fps)
 - Samsung Galaxy S: 584 (target 58fps), 1000 (40fps), 1073 (30fps)
 - HTC Desire Z (2.3): 869
 - Galaxy Nexus: 909
 - Samsung Galaxy S2 (ICS): 1944
 - Galaxy Tab 10.1 (3.1, 1.4GHz): 689
 - [Compare with AIR RunnerMark results][2]
 - [Download the APKs][3]

Other point of comparison:
 - APK is 2.4Mb
 - IPA is 1.1Mb


**Introducing the TileLayer**

Second goal was to create a simple wrapper on haxe NME's Tilesheet which is rather low-level and native-targets orientated. 

 - provides a basic display-list, spritesheet animations, mirroring,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses Bitmaps for Flash & HTML5 target rendering (almost complete) instead of the limited, and a bit slow, drawTriangles fallback.

**HTML5 version**

Try NME's HTML5 output: http://philippe.elsass.me/lab/RunnerMark/

[1]:https://github.com/esDotDev/RunnerMark
[2]:https://github.com/esDotDev/RunnerMark/tree/master/results
[3]:https://github.com/elsassph/nme-runnermark/downloads