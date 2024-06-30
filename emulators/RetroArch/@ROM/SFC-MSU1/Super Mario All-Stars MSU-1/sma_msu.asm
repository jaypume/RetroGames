; Patch by Conn
; apply on Super Mario Allstars (USA) without header - no Super Mario World!

; header ; remove selicon before "header" if your rom has a header

; $16A0: track number
; $16A2: msu busy flag (01- track to be played, 02 - fade)
; $16A4: volume 

lorom

;----------------title screen play tracks

;SMB1 title hook
org $039ec5
JSL SMB1titlehook
NOP

;Lost Levels title hook
org $0D9E4A
JSL LLevelstitlehook
NOP

;-----------------mute menu themes
;mute menu
org $009c2f
JSL mutemenu1
NOP

org $008A00
JSL mutemenu2
NOP
NOP

org $009cc4
JSL mutemenu3
NOP

;----------------------PLAY TRACKS

;menu hook
org $0087CC
JML menu
NOP

;SMB1 and Lost Levels
org $0481AB
JML SMB1
NOP

;SMB2
org $11962C
JML SMB2
NOP

;SMB3
org $22E6Bf
JML SMB3
NOP


org $1fecf0
menu:
LDA $0062
BEQ endMenu     ; no track change
LDA $2002
CMP #$53
BEQ $07
LDA $0062 ; no msu -> play spc
JML $0087D1  
LDA $0062
cmp #$80
BEQ fadeMenu
STZ $2006
CLC
ADC #$80   ;add new pcm index
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
BRA $05
fadeMenu:
LDA #$02
STA $16A2  ;store fade to msu busy
STZ $0062
endMenu:
lda $16A2      ; is a track about to play?
BEQ $03
JSR checkMSU
JML $008821

SMB1:
LDA $1602
BEQ endSMB1     ; no track change
LDA $2002
CMP #$53
BEQ $07
LDA $1602 ; no msu -> play spc
JML $0481B0  
LDA $1602
cmp #$80
BEQ fadeSMB1
CMP #$F1
BEQ fadehalfSMB1
CMP #$F2
BEQ fadefullSMB1
STZ $2006
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
BRA nofadeSMB1
fadeSMB1:
LDA #$02
STA $16A2  ;store fade to msu busy
bra nofadeSMB1
fadehalfSMB1:
LDA #$03
STA $16A2  ;store fade to msu busy
bra nofadeSMB1
fadefullSMB1:
LDA #$04
STA $16A2  ;store fade to msu busy
bra nofadeSMB1
nofadeSMB1:
STZ $1602
endSMB1:
lda $16A2      ; is a track about to play?
BEQ $03
JSR checkMSU
JML $048226

SMB2:
LDA $1DE2
BEQ endSMB2     ; no track change
LDA $2002
CMP #$53
BEQ $07
LDA $1DE2 ; no msu -> play spc
JML $119631  
LDA $1DE2
cmp #$80
BEQ fadeSMB2
CMP #$F1
BEQ fadehalfSMB2
CMP #$F2
BEQ fadefullSMB2
STZ $2006
CLC
ADC #$20   ;add new pcm index
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
BRA nofadeSMB2
fadeSMB2:
LDA #$02
STA $16A2  ;store fade to msu busy
BRA nofadeSMB2
fadehalfSMB2:
LDA #$03
STA $16A2  ;store fade to msu busy
bra nofadeSMB2
fadefullSMB2:
LDA #$04
STA $16A2  ;store fade to msu busy
bra nofadeSMB2
nofadeSMB2:
STZ $1DE2
endSMB2:
lda $16A2      ; is a track about to play?
BEQ $03
JSR checkMSU
JML $1196A7


SMB3:
LDA $1202
BEQ endSMB3     ; no track change
LDA $2002
CMP #$53
BEQ $07
LDA $1202 ; no msu -> play spc
JML $22E6C4  
LDA $1202
STA $1206
cmp #$80
BEQ fadeSMB3
CMP #$F1
BEQ fadehalfSMB3
CMP #$F2
BEQ fadefullSMB3
STZ $2006
PHA
LDA $1503
cmp #$00
BNE $06
PLA
CLC
ADC #$40   ;add new pcm index for Overworld
BRA $04
PLA
CLC
ADC #$60   ;add new pcm index for Level
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
BRA nofadeSMB3
fadeSMB3:
LDA #$02
STA $16A2  ;store fade to msu busy
BRA nofadeSMB3
fadehalfSMB3:
LDA #$03
STA $16A2  ;store fade to msu busy
bra nofadeSMB3
fadefullSMB3:
LDA #$04
STA $16A2  ;store fade to msu busy
bra nofadeSMB3
nofadeSMB3:
STZ $1202
endSMB3:
lda $16A2      ; is a track about to play?
BEQ $03
JSR checkMSU
JML $22E73A



checkMSU:
cmp #$02
BEQ fade
cmp #$03
BEQ fadehalf
cmp #$04
BEQ fadefull
BIT $2000
BVS endCheck
PHX
LDA $16A0
TAX
LDA $1ff800,x ;load loop value
STA $2007  ; also wenn ein theme endlos looped dann mach hier eine 03 auf 2007
PLX
STZ $16A2
LDA #$FF
STA $2006
STA $16A4
endCheck:
RTS

fade:
LDA $16A4
dec
dec
STA $16A4
STA $2006
cmp #$05
bcc mute
RTS
mute:
STZ $2006
STZ $16A4
STZ $16A2
RTS

fadehalf:
LDA $16A4
dec
dec
dec
STA $16A4
STA $2006
cmp #$60
bcc mutehalf
RTS
mutehalf:
LDA #$60
STA $2006
STA $16A4
STZ $16A2
RTS

fadefull:
LDA $16A4
inc
inc
inc
STA $16A4
STA $2006
cmp #$F8
bcs full
RTS
full:
LDA #$FF
STA $2006
STA $16A4
STZ $16A2
RTS


SMB1titlehook:
LDA $2002
CMP #$53
BEQ $06 
LDA #$14
STA $2142
RTL
LDA #$14
STZ $2006
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
RTL

LLevelstitlehook:
LDA $2002
CMP #$53
BEQ $06 
LDA #$15
STA $2142
RTL
LDA #$15
STZ $2006
STA $2004
STA $16A0 ; store track number
STZ $2005
LDA #$01
STA $16A2  ; store track change to msu busy
RTL


mutemenu1:
LDA #$11
STA $0060
LDA $2002
CMP #$53
BNE $03
STZ $2007
RTL

mutemenu2:
STZ $2140
STZ $2142
LDA $2002
CMP #$53
BNE $03
STZ $2007
RTL

mutemenu3:
LDA #$80 
STA $2100
LDA $2002
CMP #$53
BNE $03
STZ $2007
RTL

ORG $1ff800 ; loop table 03:loop, 01 non-loop
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$01,$01,$03,$03,$03 ; themes 00-0f SMB1 and Lost Levels 
db $03,$01,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 10-1f SMB1 and Lost Levels
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$01,$01,$01,$03,$03,$01 ; themes 20-2f SMB2
db $01,$01,$01,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 30-3f SMB2
db $03,$03,$03,$03,$03,$03,$03,$01,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 40-4f SMB3 Overworld
db $03,$01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 50-4f SMB3 Overworld
db $03,$03,$03,$03,$03,$03,$03,$01,$03,$01,$01,$01,$01,$03,$01,$03 ; themes 60-6f SMB3 Level
db $03,$03,$03,$01,$03,$03,$03,$01,$01,$03,$03,$03,$03,$03,$03,$03 ; themes 70-7f SMB3 Level
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 80-8f Menu

