;
; Wild Guns MSU-1 PATCH
; rev 1.0
;
; CODER: PepilloPEV
; PCM: Relikk
; DATE: 2018.07.28

lorom

; game notes go here
; --------------------------------------------------------------------
; game tracks
; 00c278 lda $0002,x   [09802a] A:0000 X:8028 Y:0002 S:0fee D:0000 DB:09 Nvmxdizc V: 13 H:259 F: 1
; 00c27b sta $2140     [092140] A:0000 X:8028 Y:0002 S:0fee D:0000 DB:09 nvmxdiZc V: 13 H:271 F: 1
;
; game fade
; 01af86 stz $041a     [01041a] A:fffd X:0006 Y:009e S:0ff7 D:0000 DB:01 nvmxdizC V:  1 H:231 F:44
; 01af89 jsl $00934d   [00934d] A:fffd X:0006 Y:009e S:0ff7 D:0000 DB:01 nvmxdizC V:  1 H:241 F:44
;
; fade nmi
; 0083b7 lda $c0       [0000c0] A:f88f X:0000 Y:000e S:0fd9 D:0000 DB:00 NvMxdIzc V:225 H:311 F:16 2B
; 0083b9 sta $4200     [004200] A:f8b1 X:0000 Y:000e S:0fd9 D:0000 DB:00 NvMxdIzc V:225 H:317 F:16 3B
;
; final boss dies mute
; 00c247 and #$00ff             A:b042 X:0000 Y:0022 S:0ffb D:0000 DB:00 Nvmxdizc V:240 H: 29 F:28 3B
; 00c24a sta $2142     [002142] A:0042 X:0000 Y:0022 S:0ffb D:0000 DB:00 nvmxdizc V:240 H: 35 F:28 3B
;
; resume game hook
; 048b0b ora #$0400             A:3000 X:0008 Y:000e S:0fe9 D:0000 DB:04 nvmxdizC V:247 H:110 F: 9 3B
; 048b0e sta $1202,x   [04120a] A:3400 X:0008 Y:000e S:0fe9 D:0000 DB:04 nvmxdizC V:247 H:116 F: 9 3B
;
; pause game hook
; 009ef1 sta $70       [000070] A:0008 X:0000 Y:0022 S:0ff4 D:0000 DB:00 nvmxdizc V: 65 H:125 F:15 2B
; 009ef3 ldy #$0010             A:0008 X:0000 Y:0022 S:0ff4 D:0000 DB:00 nvmxdizc V: 65 H:133 F:15 3B


; hook area: hook addresses go here
; --------------------------------------------------------------------
org $098951 ; hard mute
db $2F

org $048B0B ; resume game hook
JSL gameResumeStage
	NOP
	NOP

org $009EF1 ; pause game hook
JSL gamePause
	NOP

org $0083B7 ; fading volume when flag is set hook
JSL fadeCounter
	NOP

org $01AF86 ; set fade flag good luck screen hook
JSL gameFadeGL
	NOP
	NOP
	NOP

org $00C247 ; final boss dies scream and mute music
JSL bossMute
	NOP
	NOP

org $00C278 ; track hook
JSL trackTriggers
	NOP
	NOP


; code area: patch code goes here
; --------------------------------------------------------------------
org $208000
; tracks located on X register
trackTriggers:
	PHA
	PHX
	PHY
	PHP
	SEP #$30
	PHX
	PHA
	LDA $208100,X
	STA $7E1FFF ; store loop value to use later in msu routine
	TXA
	JSR msuPlay
goBack:
	PLA
	PLX
	PLP
	PLY
	PLX
	PLA
	LDA $0002,X ; native code
	STA $2140 ; native code
	RTL

; when fade flag set, msu volume will fade per NMI
fadeCounter:
	PHA
	LDA $7E1FFC ; load store flag value, 1-active/0-inactive
	CMP #$01 ; if flag set, start fading the msu volume
	BEQ doFadeOut
	PLA
	JMP volEnd ; return to native code
doFadeOut: ; start fading msu volume until zero
	LDA $7E1FFD ; load current volume level
	DEC ; reduce volume by one
	DEC ; reduce volume by one
	STA $7E1FFD ; store currenlty reduced volume value to RAM
	STA $2006 ; write current volume level to MSU-1
	CMP #$10 ; stop decrementing volume at equal or less than hex 01
	BCC leaveFadeOut
	PLA
	JMP volEnd ; return to native code
leaveFadeOut:
	LDA #$00 ; load lowest volume level
	STA $2006 ; write final volume (should be zero at this point, no volume)
	STA $7E1FFC ; clear msu fade flag, 0-inactive
	PLA
volEnd:
	LDA $C0 ; native code
	STA $4200 ; native code
	RTL

; restore volume when resumed
gameResumeStage:
	PHP
	SEP #$20 ; set 8-bit A
	PHA
	LDA #$FF ; load max voume level
	STA $7E1FFD ; write current volume level to RAM
	STA $2006 ; write max voluem level
	PLA
	PLP
	ORA #$0400 ; native code
	STA $1202,X ; native code
	RTL

; lower volume when paused
gamePause:
	STA $70 ; native code
	LDY #$0010 ; native code
	CMP #$0008 ; is this pause?
	BEQ yesPause
	RTL
yesPause:
	PHP
	SEP #$20 ; set 8-bit A
	PHA
	LDA #$40 ; load lower volume level
	STA $2006 ; write loaded volume level
	STA $7E1FFD ; write current volume level to RAM
	PLA
	PLP
	RTL

; mute music when final boss dies
bossMute:
	AND #$00FF ; native code
	CMP #$0042
	BEQ bossDie
bBack:
	STA $2142 ; native code
	RTL
bossDie:
	PHP
	SEP #$20 ; set 8-bit A
	PHA
	LDA #$01 ; load no loop value
	STA $7E1FFF ; store it in RAM for later use by MSU routine
	LDA #$5D ; load final boss death scream value
	JSR msuPlay
	PLA
	PLP
	JMP bBack

; set fade flag, start fading volume
gameFadeGL:
	STZ $041A ; native code
	JSL $00934D ; native code
	PHP
	SEP #$20 ; 8-bit A set
	PHA
	LDA #$01
	STA $7E1FFC ; set fade flag
	PLA
	PLP
	RTL

; msu1 routine
msuPlay:
	PHA
	CMP $7E1FFE
	BEQ skipMsu ; is same track already playing?
	PLA
	PHA
	STZ $2006
	STA $2004
	STA $7E1FFE ; used to prevent double playback
	STZ $2005
msuReady:
	BIT $2000
	BVS msuReady ; is msu ready?
	LDA #$FF ; max msu volume
	STA $7E1FFD ; store max volume
	STA $2006
	PHA
	LDA $7E1FFF ; load stored loop value
	STA $2007
	PLA
skipMsu:
	PLA
	RTS

; loop table
org $208100
;   0   1   2   3   4   5   6   7   8   9   A   B   C   D   E   F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 00-0F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 10-1F
db $00,$00,$00,$00,$00,$00,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00 ; 20-2F
db $03,$00,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$03,$00,$00,$00 ; 30-3F
db $03,$00,$00,$00,$03,$00,$00,$00,$03,$00,$00,$00,$03,$00,$00,$00 ; 40-4F
db $03,$00,$00,$00,$03,$00,$00,$00,$03,$00,$00,$00,$01,$01,$00,$00 ; 50-5F
db $01,$00,$00,$00,$01,$00,$00,$00,$03,$00,$00,$00,$01,$00,$00,$00 ; 60-6F
db $03,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; 70-7F