
; Patch By: Kurrono/PeV
; Date: July 14, 2018

; version 1.0 initial release


lorom

; HOOK SPACE, PeV
; ---------------
; PeV, start hard core mute code, 2018.07.13
org $2A8C3F
db $2F
; PeV, end hard core mute code

; pause/resume section
; --------------------
org $AA817A
JSL gamePause

org $81ED83
JSL gameResume
; --------------------
; pause/resume section

org $AA8181
JSL findMsu1

org $AA8315 ; for some tracks only
JSL findMsu2
	NOP

org $AA86BB
JSL findMsu3
	NOP

; PATCH CODE, PeV
; ---------------
org $EFF000 ; freespace for JSR, avoid black screen
gamePause:
	CMP #$FC
	BEQ gPs
gPsB:
	STA $2140
	NOP
	RTL
gPs:
	STZ $2007
	JMP gPsB

gameResume:
	CMP #$00FB
	BNE gRs
	PHA
	PHP
	SEP #$20
	LDA #$03
	STA $002007
	PLP
	PLA
gRs:
	STA $002142
	RTL
findMsu3:
	CMP #$FF
	BEQ stopMsu
pFM3:
	LDA #$E1 ; it this track 00 that mutes music in options menu?
	JMP resume
findMsu1:
	STA $2142
	CMP #$FA ; mute? 
	BEQ stopMsu
	CMP #$FE ; did player die? if so, stop msu music
	BEQ stopMsu
	CMP #$81 ; final boss form 2
    BEQ yesReload
    JMP resume
yesReload:
    PHA
    LDA $2142
    CMP #$38
    BEQ yesEscape
    LDA $00F0
    CMP #$4C
    BEQ yesContinue
    PLA
    RTL	
yesEscape:
    JSR playMsu
    PLA
    RTL
yesContinue:
    JSR playMsu
    PLA
    RTL	
stopMsu:
    STZ $2007
	JMP pFM3
	RTL
findMsu2:
	JSR playMsu
	LDA #$E0
resume:
	STA $2142 ; native code
	RTL

playMsu:
	PHA
	STZ $2006
	STA $2004
	STZ $2005
	LDA #$FF
	STA $2006
loop:
	bit $2000
	BVS loop
	LDA #$03
	STA $2007
	PLA
	RTS