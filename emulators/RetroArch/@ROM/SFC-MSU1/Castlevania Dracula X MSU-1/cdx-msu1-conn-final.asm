;
; CASTLEVANIA DX MSU-1 PATCH
; rev 1.5 final
;
; CODER: Conn
; DATE: 2017.11.24
;
; Music: mix of Rondo of Blood (PCengine) and Dracula X Chronicles (PSP)

; fixed:
; - castlevania title logo buzzin sound on sd2snes, attempting to play a missing track
; - hopefully, fixed sd2snes issue attempting to play missing tracks on pcm set

lorom

org $A813
Jmp trackChange
NOP
returnTrack:

org $80e1
JSR msuBusy

org $A6ED
JSR pause
NOP

; empty space area
org $F678

trackChange:
ADC #$8FF9
TAX        ; repeat deleted code
PHA
LDA $2002
AND #$00ff
CMP #$0053    
BEQ $04
PLA
jmp returnTrack
PLA
php
SEP #$30
STZ $2006
STA $2004 ;(we have e.g., theme 23 from trace above for intro on stack, this you can use for the msu track list) ;execute the rest of msu ;.... like stz $2005
STA $7e1b82 ;store track
LDA #$0a
STA $7e1b80  ;sta msu busy flag
STZ $2005
plp
LDX #$9027   ;mute spc
PLA
LDA #$005c  ; this will push a mute code on the stack 
PHA
jmp returnTrack

msuBusy:
LDA $4210
LDA $7e1b80
Bne $01
endbusy:
RTS
cmp #$20
beq fadeBusy
BIT $2000
Bvs endbusy ; track not ready
lda $2000
AND #$08
BEQ noerror ; error bit set?
STZ $2006
STZ $2007
bra enderror
noerror:
LDA $7e1b82
PHX
TAX
LDA $80f800,x
STA $2007
PLX
LDA #$FF
STA $2006
STA $7e1b81
enderror:
LDA $7e1b80
dec
STA $7e1b80
bra endbusy

fadeBusy:
LDA $7e1b81
dec
dec
dec
;dec
STA $7e1b81
STA $2006
cmp #$07
bcc endfade
bra endbusy
endfade:
lda #$00
sta $2006
sta $7e1b81
STA $7e1b80
bra endbusy


pause:
cmp #$ea
beq fade
cmp #$eb
beq fade
cmp #$ec
beq fade
cmp #$e6
beq startpause
cmp #$e9
beq startpause
cmp #$e7
beq resumePause
endpause:
LDX $5a
cpx $5b
RTS

startpause:
STZ $2007
bra endpause

resumePause:
PHA 
LDA $2002
cmp #$53
bne continueResume
LDA $7e1b82
PHX
TAX
LDA $80f800,x
STA $2007
PLX
continueResume:
PLA
bra endpause

fade:
pha
LDA $2002
cmp #$53
bne continueFade
LDA #$20            ; set fadeflag
STA $7e1b80
continueFade:
PLA
bra endpause


org $F800 ; loop table 03:loop, 01 non-loop
db $03,$01,$03,$01,$03,$01,$03,$01,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 00-0f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$03,$03,$03,$03 ; themes 10-1f
db $03,$03,$03,$01,$03,$03,$03,$01,$03,$01,$03,$03,$03,$03,$03,$03 ; themes 20-2f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 30-3f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 40-4f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 50-5f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 60-6f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 70-7f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 80-8f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 90-9f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes A0-Af
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes B0-Bf
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes C0-Cf
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes D0-Df
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes E0-Ef
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$03,$01,$03,$01 ; themes F0-Ff