;options mode asm.. this will make it work all songs
lorom

org $aa86e0 ; msu1 music change!
JSL $AAFC91

org $AAFC91 ;freespace
PHA
TYA
PHP ;save processor status
SEP #$20
lda $2002
CMP #$53
BEQ $07
PLP ;restore processor status
PLA ;native code if no msu
CLC
ADC $0166
RTL
PLP ;restore processor status
PLA ;get track number from stack
PHA
TYA
PHP ;save processor status again
SEP #$20
CMP #$0c
BNE $04
JSL escape
CMP #$0e
BNE $04
JSL continue
JSL msuRoutine
PLP ;restore processor status
PLA
CLC 
ADC $0166
RTL

escape:
ADC $0166
cmp #$0C; this need value on ram
Bne $03
LDA #$0C
RTL
LDA #$38
RTL

continue:
ADC $0166
cmp #$0E; this need value on ram
Bne $03
LDA #$0E
RTL
LDA #$4C
RTL

msuRoutine:
STZ $2006
STA $2004
STZ $2005
loop:
bit $2000
BVS loop
LDA #$03
STA $2007
LDA #$ff
STA $2006
RTL


