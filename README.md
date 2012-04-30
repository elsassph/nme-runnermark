nme-RunnerMark
==============

**Performance demonstration**

First goal was to do a haxe NME port of [esDotDev's RunnerMark][1]

Here are the scores:
 - iPad 1: 823
 - iPod Touch 4: 875
 - [see AIR results][2]


**Introducing the TileLayer**

Second goal was to create a simple wrapper on haxe NME's Tilesheet which is rather low-level and native-targets orientated. 

 - provides a basic display-list and spritesheet animations,
 - includes a Sparrow spritesheet parser, supporting trimming.
 - uses Bitmaps for Flash target rendering (WIP) instead of the limited, and a bit slow, drawTriangles fallback.

[1]:https://github.com/esDotDev/RunnerMark
[2]:https://github.com/esDotDev/RunnerMark/blob/master/results/Results-04-24-2012.txt