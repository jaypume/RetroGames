Super Mario Allstars MSU-1 patch (bsnes, higan and sd2snes support) for Non Headered rom

Patch created by RedScorpion, Conn
    
This patch includes the possibility to hear cd-quality audio. Note: 
The easiest emulator is snes9x 1.55: https://dl.qwertymodo.com/snes9x_msu.zip
Also you can play it with bsnes+ 0.73: https://www.romhacking.net/utilities/1197/
Also higan is supported

Imprtant notes: 
- FOR NON-HEADER USA version ONLY. The native SMA, not the version that includes Super Mario World. If you do not know what a header is, or how to remove it (there are several tools), check http://forum.romulation.net/index.php?topic=17597.0
Ususally *.smc is with header, *.sfc without. 


Preparation:
1.
apply sma_msu.ips on your Non-Headered US version of Super Mario Allstars rom (Without super Mario World). Usual name is Super Mario All-Stars (U) [!].sfc). Alternatively, you can also use the sma_msu.asm.

2.
Rename your rom into sma_msu1.sfc (sma_msu1.sfc, not sma-msu.sfc or whatever).


Snes9x 1.55 (ff) and Bsnes tutorial: 
Bsnes until 0.68 play wav files which do not loop. Bsnes 0.69 and later versions support pcm files that can loop, so this is the music format and emulator of your choice since it is super easy:
-make a new folder (sma_msu or whatever)
- copy the  patched sma_msu1.sfc into this folder (from preparation Step 1 and 2)
- copy sma_msu1.msu and sma_msu1.xml into this folder (part of the zip file), use those from the individual subfolders as bsnes differs between ntsc and pal. Snes9x 1.55 does not need this xml, but it needs the sma_msu.msu.
- copy the PCM:s into this folder (from extern cloud) 
Then play the rom in bsnes 0.70 or snes9x 1.55(ff) and enjoy!

Sd2snes tutorial:
Actually this works the same way as bsnes: make a custom folder in the main directory called 'SMA_MSU” or whatever. In this folder, you'll need to have your patched sma_msu1.sfc. In this same directory, you'll need the " sma_msu1.msu" file. sma_msu1.xml' is not needed. Copy also all your pcm files (with the similar names as your msu and sfc file (e.g., sma_msu -1.pcm )) into this folder and enjoy! Also keep in mind that the audio volume changed in firmware 0.1.7, and it this patch is thus incompatible with prior version.
Firmware v0.1.7 ff: choose Configuration-> Chip Options and set the msu1 boost to +12dBFS
Important note:
Problems with saving is a known issue with MSU-1 enhanced games on the SD2SNES.The game saves only with this technique your progress: In order to save permanently, you'll need to save after you made progress, with either (1) pressing L+R+Select+X or (2) press and hold the reset button on your console long enough so that it resets to the SD2SNES main menu.

Step-by-step with video by Mattroid
1.	Firmware 0.1.7 and later be sure you adjusted Configuration-> Chip Options and set the msu1 boost to +12dBFS
2.	Put your patched patched sma_msu1.sfc ROM (from preparation step 1 and 2) on your SD card in a folder someplace (I named mine 'sma_msu')
3.	Also put the sma_msu1.msu into this folder
4.	Copy the PCM:s from the extern cloud into this folder


Higan:
- import your patched sma_msu1.sfc rom (from Preparation Step 1 and 2) in higan
- go into the folder  %USERPROFILE%\Emulation\Super Famicom\sma_msu1.sfc in Windows Explorer
- overwrite the existing manifest.bml with (until higan v0.95) or just copy (higan v0.96 and later) the manifest.bml from the patch package into this folder
- also copy sma_msu1.msu from the patch package into this folder
- copy the PCM:s from the extern cloud into this folder



