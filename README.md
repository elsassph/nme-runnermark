nme-RunnerMark
==============

**Performance demonstration**

First goal was to do a haxe NME port of [esDotDev's RunnerMark][1] for fair comparison of a realistic game scene. 

Minor twists: 
- shows 3 enemies even if it can't reach 58fps,
- for older Android devices you should not target 60fps; my HTC Desire (Nexus One) does a good job with lower targets.

Here are the scores (FPS*10 + ennemies count):
 - Nexus One (2.2): 460 (target 58fps), 487 (target 30fps)
 - Nexus One (2.3.7): 460 (target 58fps), 490 (target 45fps), 523 (target 30fps)
 - Samsung Galaxy S: 584 (target 58fps), 1000 (40fps), 1073 (30fps)
 - HTC Desire Z (2.3): 869
 - Samsung Galaxy S2 (ICS): 1944
 - Galaxy Tab 10.1 (3.1, 1.4GHz): 689
 - iPad 1: 823
 - iPod Touch 4: 881
 - iPad 2: 1547
 - [see AIR results][2]

Other point of comparison:
 - APK is 2.4Mb
 - IPA is 1.1Mb


**Introducing the TileLayer**

Second goal was to create a simple wrapper on haxe NME's Tilesheet which is rather low-level and native-targets orientated. 

 - provides a basic display-list and spritesheet animations,
 - includes a Sparrow spritesheet parser, supporting trimming,
 - uses Bitmaps for Flash target rendering (WIP) instead of the limited, and a bit slow, drawTriangles fallback.

[1]:https://github.com/esDotDev/RunnerMark
[2]:https://github.com/esDotDev/RunnerMark/blob/master/results/Results-04-24-2012.txt