nme-RunnerMark
==============

Performance demonstration
-------------------------

First goal was to do a haxe NME port of [esDotDev's RunnerMark][1] for fair comparison of a realistic game scene. 

Minor twists: 
- shows 3 enemies even if it can't reach 58fps,
- runner is rotating, enemies are randomly scaled & flipped,
- for older Android devices you should not target 60fps; my HTC Desire (Nexus One) does a good job with lower targets.

Here are the scores (FPSx10 + ennemies count, **in bold after engine update**):
 - iPhone 3GS: **668**
 - iPod Touch 4: **978**
 - iPhone 4: 888
 - iPad 1: **916**
 - iPad 2: **3121**
 - iPad 3: **1454** (debug build)
 - Nexus One (2.2): 460 (target 58fps), 487 (30fps)
 - Nexus One (2.3.7): **470** (target 58fps), **577** (30fps)
 - Motorola Defy: 595 (target 30fps)
 - Samsung Galaxy Ace: 850 (target 30fps)
 - Samsung Galaxy S: 584 (target 58fps), 1073 (30fps)
 - HTC Desire Z (2.3): 869
 - Galaxy Nexus: **1081**
 - Samsung Galaxy S2 (ICS): **1972**
 - Samsung Galaxy S3: **2119**
 - Galaxy Tab 10.1 (3.1, 1.4GHz): 689
 - Xoom (3.1): **923**
 - TouchPad (ICS): **916**
 - [Compare with AIR RunnerMark results][2]
 - [Download the APKs][3]

Other point of comparison:
 - APK is 2.4Mb
 - IPA is 1.1Mb

Introducing the TileLayer
-------------------------

Second goal was to create a simple wrapper on haxe NME's Tilesheet which is rather low-level and native-targets orientated. 

 - provides a basic display-list, spritesheet animations, mirroring,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses Bitmaps for Flash & HTML5 target rendering (almost complete) instead of the limited, and a bit slow, drawTriangles fallback.

**TileLayer is now in haxelib**: 
- [source (and some doc) on github][4]
- install the library: `haxelib install tilelayer` in your terminal
- add `<haxelib name="tilelayer" />` in your nmml

HTML5 version
-------------

Try NME's HTML5 output: http://philippe.elsass.me/lab/RunnerMark/

[1]:https://github.com/esDotDev/RunnerMark
[2]:https://github.com/esDotDev/RunnerMark/tree/master/results
[3]:https://github.com/elsassph/nme-runnermark/downloads
[4]:https://github.com/elsassph/nme-tilelayer
