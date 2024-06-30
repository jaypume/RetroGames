; $7f9000: Kopie Track Nummer
; $7f9002: MSU1 busy

hirom

; NTSC crack
org $c0FFD9
db $01
org $c797ce
db $80

org $cd9542 ;hook 1 - intro und so
JSL $21E6A0 ; irgendein freier rom space(TO $E1E6A0)
Nop
nop
nop   ; wir wollen ja nicht dass der code irgendwie ausgef黨rt wird

org $c6904a ; hook 2, name select, town
JSL hook2

;809161 lda $04b2     [8104b2] A:00ff X:17c0 Y:17c0 S:01f1 D:0000 DB:81 nvmxdIZC V:248 H: 57 F:47
;809164 inc                    A:0000 X:17c0 Y:17c0 S:01f1 D:0000 DB:81 nvmxdIZC V:248 H: 66 F:47
;809165 sta $7f2014,x [7f37d4] A:0001 X:17c0 Y:17c0 S:01f1 D:0000 DB:81 nvmxdIzC V:248 H: 69 F:47
;809169 lda $0006,x   [8117c6] A:0001 X:17c0 Y:17c0 S:01f1 D:0000 DB:81 nvmxdIzC V:248 H: 79 F:47

org $c09161
JSL item

org $c5F9A5 ; hook direkt im nmi(原来为$c5FA3d)
JSL msubusy

org $E1E6A0 ; 原来是d7E6A0 freier rom space f黵 hook1, intro
LDA $7F2014,x
STA $04B8        ; IMMER den gel鰏chten code ausf黨ren!
CMP #$0000
BNE $01
RTL
DEC A
CMP $7f9000
BNE $03
jmp mutespc1
jmp msuroutine


hook2: ; freier rom space f黵 hook2, name select, town
Sta $04b4
INY
;CMP #$00
;BNE $01
;RTL
CMP $7f9000
BNE $03
jmp mutespc1
jmp msuroutine


mutespc1:
PHP
Rep #$30
LDA $04b8
BEQ $06
LDA #$0001
Sta $04b8 ; mute hook 1
LDA $04b4
BEQ $06
LDA #$0000
sta $04b4 ; mute hook2
PLP
RTL

msuroutine:
PHP                 ; store processor flags 
Rep #$30            ; je nach hook sind wir im 1 oder 2 byte modus, wir m黶sen unbedingt den 2 byte modus generell haben
PHX                 ; X auf Stack
PHY                ; Y auf Stack
PHA                ; Accumulator auf den Stack
Sep #$30      ; wechel zu 1 byte modus

LDA $2002      ;check if msu found
CMP #$53               
BEQ msufound   
rep #$30
PLA          ; Restore Accumulator
PLY
PLX
PLP             ; Restore processor flags
RTL        ; spc wird gespielt weil kein msu eingeschaltet

msufound:
STZ $2006    ; mache mute falls noch ein alter track l鋟ft
STZ $2000
Rep #$30 ; dummerweise ist ja die Track-Nr in 2 byte
LDA $7f9000
STA $04f1
LDA #$0001
STA $7F9002 ; freier ram flag f黵 msu busy
PLA  ; welchen Track haben wir auf dem Stack?
AND #$00FF ; lieber das erste byte isolieren
STA $2004   ; speicher das als msu-鋛uivalent
STA $7f9000 ; Kopie falls wir den Track schon haben
LDA $04b8
BEQ $06
LDA #$0001
Sta $04b8 ; mute hook 1
LDA $04b4
BEQ $06
LDA #$0000
sta $04b4 ; mute hook2
PLY
PLX
PLP ; restore Prozessorstatus
RTL



; bis hier ist der Erste Teil, der einfach nur den Track auf $2004 spielt
;
; jetzt kommt der zweite Teil, wo nur noch getestet wird ob der Track fertig ist, und wenn ja, dann mit 2007 gespielt wird

msubusy:
JSL $86A505 ; alter nativer code
LDA $7F9002 ; ist die msu flag gesetzt?
BNE $01
end:
RTL
Bit $2000
bvs end    ; track noch nicht bereit
LDA #$00
STA $7F9002  ; clear msu busy flag
LDA $7f9000  ; welcher track soll gespielt werden?
TAX
LDA $E1f000,x ;load loop value
sta $2007  ; also wenn ein theme endlos looped dann mach hier eine 03 auf 2007
lda #$FF   ; lautst鋜ke
sta $2006
RTL

item:
lda $04f1
inc
cmp #$0034
bne $03
lda #$0001
RTL

ORG $E1F000 ; loop table 03:loop, 01 non-loop
db $01,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$01,$03,$03,$03,$03 ; themes 00-0f
db $03,$03,$03,$03,$01,$03,$01,$03,$03,$01,$01,$03,$01,$01,$03,$03 ; themes 10-1f
db $01,$03,$01,$03,$03,$03,$01,$03,$01,$01,$03,$03,$03,$01,$01,$03 ; themes 20-2f
db $03,$03,$03,$01,$03,$01,$03,$03,$01,$03,$01,$03,$03,$03,$03,$03 ; themes 30-3f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 40-4f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 50-5f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 60-6f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 70-7f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 80-8f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes 90-9f
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes a0-af
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes b0-bf
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes c0-cf
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes d0-df
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes e0-ef
db $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03 ; themes f0-ff
