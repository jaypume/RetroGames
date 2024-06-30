;
; FINAL FIGHT MSU-1 PATCH
; rev 1.0
;
; CODER: PepilloPEV
; DATE: 2017.10.20
;
; * tracks pulled from Sega CD version of game
; Music Composers: Sega

; bugs:
; played through whole game and notice nothing out of the ordinary so far (pepillopev)

lorom

; empty rom space to use
; 00B5F3 -> 00B606
; 00B633 -> 00B646
; 00FBC0 -> 00FD1E, padding is weird?
; 00FD41 -> 00FFBE, padding is weird too, FF's and 00's alternating, can I use?

; audio themes (side and top stages)
; F0=silence
; F3=pause
; F4=unpause
; 0D=game intro
; 0E=player select screen
; 0B=stage intro
; 0F=stage cleared
; 01=stage1 (outside 1)
; 02=stage1 (basement)
; 03=stage1 (outside 2)
; 10=bonus stage
; 11=beat last boss
; 12=game ending
; 45=fall death scream

; hook area deals with theme and game-sfx samples
; hook area is in these lines of code
; $00/83F3 BD C2 03    LDA $03C2,x[$00:03C2]   A:0000 X:0000 Y:0080 P:envMXdIZC -> hook here?
; $00/83F6 8D 40 21    STA $2140  [$00:2140]   A:000D X:0000 Y:0080 P:envMXdIzC

org $0083F3	; hook for game audio, jump to msuGo (keep byte usage the same using JSR)
JSR msuGo

org $00B5F3
msuGo:
	JSL checkMsu
	RTS
	
;
; Detect MSU-1 and check for track changes
;
org $00FD41
checkMsu:
	LDA $03C2,x ; track and sfx load point
	PHA ; push to preserve track value, need A to test for MSU-1 presence
	LDA $2002 ; load MSU-1 presence bit
	CMP #$53
	BEQ msuFound ; MSU-1 found if equal to #$53 (string S)
playSpc: ; otherwise, fallback to spc audio
	PLA ; restore pushed value, otherwise, the SPC will not play it (or crash game)
	RTL
msuFound:
	PLA ; restore spc A track value to compare current track to play
	CMP #$0D ; game intro (msu track 1)
	BNE next2
	JSR gameIntro
	JMP exit
next2:
	CMP #$0E ; player select (msu track 2)
	BNE next3
	JSR playerSelect
	JMP exit
next3:
	CMP #$0F ; stage cleared (msu track 4)
	BNE next4
	JSR stageCleared
	JMP exit
next4:
	CMP #$F0 ; spc silence 1 after defeating stage 1 boss
	BNE next5
	JSR msuStop
	JMP exit
next5:
	CMP #$F1 ; spc silence 2 after defeating stage 2 boss
	BNE next6
	JSR msuStop
	JMP exit
next6:
	CMP #$F3 ; paused
	BNE next7
	JSR pauseYes
	JMP exit
next7:
	CMP #$F4 ; unpaused
	BNE next8
	JSR pauseNo
	JMP exit
next8:
	CMP #$0B ; stage start (msu track 3)
	BNE next9
	JSR stageStart
	JMP exit
next9:
	CMP #$01 ; stage 1 outside (msu track 5)
	BNE next10
	JSR stage1
	JMP exit
next10:
	CMP #$02 ; stage 1 basement (msu track 6)
	BNE next11
	JSR stage1b
	JMP exit
next11:
	CMP #$03
	BNE next12
	JSR stage2 ; outside and inside train (msu track 7)
	JMP exit
next12:
	CMP #$04
	BNE next13
	JSR stage2b ; end of train tracks (msu track 8)
	JMP exit
next13:
	CMP #$10
	BNE next14
	JSR bonusStage
	JMP exit
next14:
	CMP #$05 ; fighting cage (msu track 10)
	BNE next15
	JSR stage3b
	JMP exit
next15:
	CMP #$06 ; bay area (msu track 11)
	BNE next16
	JSR stage4
	JMP exit
next16:
	CMP #$07
	BNE next17
	JSR stage4b
	JMP exit
next17:
	CMP #$08
	BNE next18
	JSR stage4c
	JMP exit
next18:
	CMP #$09
	BNE next19
	JSR stage5b ; stage 5 uses same track as stage 10
	JMP exit
next19:
	CMP #$11
	BNE next20
	JSR beatBoss
next20:
	CMP #$12
	BNE next21
	JSR gameEnding
next21:
	CMP #$0C
	BNE next22
	JSR gameOver
next22:
	CMP #$13
	BNE exit
	JSR gameContinue
exit:
	STA $2140 ; play sfx sample
	RTL

;
; Select Game Track to Play Routines
;
gameIntro:
	LDA #$3D ; restore phone ring sfx, otherwise, the sfx will mute during MSU-1 playback
	PHA
	LDA #$01
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
playerSelect:
	LDA #$F0
	PHA
	LDA #$02
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
stageCleared:
	LDA #$F0
	PHA
	LDA #$04
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
msuStop:
	LDA #$F0
	PHA
	STZ $2007
	PLA
	RTS
pauseYes:
	LDA #$46 ; preserve pause sfx
	PHA
	LDA #$50 ; low volume (game paused)
	STA $2006
	PLA
	RTS
pauseNo:
	PHA
	LDA #$FF ; max volume (game unpaused)
	STA $2006
	PLA
	RTS
stageStart:
	LDA #$F0
	PHA
	LDA #$03 ; play track3, stage start
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage1:
	LDA #$F0
	PHA
	LDA $050109
	CMP #$03 ; check bit for stage3 to boss transition (native code uses stage1 track, affects msu-1 playback)
	BNE playStage1
	BRA endStage1
playStage1:
	LDA #$05
	JSR play
	LDA #$03
	JSR msuLoop
endStage1:
	PLA
	RTS
stage1b:
	LDA #$F0
	PHA
	LDA #$06
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage2:
	LDA #$F0
	PHA
	LDA #$07
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage2b:
	LDA #$F1
	PHA
	LDA #$08
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
bonusStage:
	LDA #$F0
	PHA
	LDA #$09
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
;stage3 uses same track as stage 1
stage3b:
	LDA #$F0
	PHA
	LDA #$0A
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage4:
	LDA #$F0
	PHA
	LDA #$0B
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage4b: ; bathroom area transition
	LDA #$F1
	PHA
	LDA #$0C
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
stage4c: ; bathroom transition to abigail boss area
	LDA #$F1
	PHA
	LDA #$0D
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
; stage 5 uses same track as stage 10
stage5b:
	LDA #$F1
	PHA
	LDA #$0E
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS
beatBoss:
	LDA #$F1
	PHA
	LDA #$0F
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
gameEnding:
	LDA #$F1
	PHA
	LDA #$10
	JSR play
	LDA #$03
	JSR msuLoop
	PLA
	RTS

gameOver:
	LDA #$F1
	PHA
	LDA #$11
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
	
gameContinue:
	LDA #$F1
	PHA
	LDA #$12
	JSR play
	LDA #$01
	JSR msuLoop
	PLA
	RTS
;
; MSU-1 Play Routine
;
play:
	STA $2004
	STZ $2005
	STZ $2006
loopTitle:
	BIT $2000
	BVS loopTitle ; track not ready
	LDA #$FF ; max volume
	STA $2006
	RTS
msuLoop:
	STA $2007
	RTS