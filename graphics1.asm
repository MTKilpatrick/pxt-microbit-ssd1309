; routines for graphics


pBoxAsm:
  push {r4,r5,r6,r7,lr}
  cmp r0, r2
  it pl
    mov r4, r0  ; then
    mov r0, r2  ; then
    mov r2, r4  ; then
  cmp r1, r3
  ittt pl
    mov r4, r1  ; then
    mov r1, r3  ; then
    mov r3, r4  ; then
  mov r4, r2
  orrs r4, r3
  bmi .pBoxReturn     ; if x1 or y1 are negative, exit
  cmp r2, #128
 it pl
    movs r2, #127       ; if x1 > 127, x1 = 127
  cmp r1, #0
  it mi
    movs r1, #0         ; if y0 < 0, y0 = 0
  cmp r3, #63
  IT HI
    movs r3, #63        ; if y1 > 63, y1 = 63
  cmp r0, #0
  IT MI
    movs r0, #0         ; if x0 < 0, x0 = 0
  movs r4, #7
  ands r4, r1				; r4 = (y0 & 7)
  movs r6, #0xff
  lsls r6, r4				; r6 = 0xff << (y0 & 7) bitmask
  lsrs r5, r1, #3			; r5 = (y0 >> 3)
  cmp r5, #7				; if (y0 > 63) return
  bhi .pBoxReturn
  lsls r4, r5, #7			; r4 = 128 * (y0>>3)
  adds r4, r4, r0			; r4 = x0 + 128 * (y0>>3)
  subs r7, r2, r0         ; r7 = x1 - x0
  lsrs r1, r3, #3         ; r1 = y1 >>3
  movs r2, #7
  ands r2, r3             ; r2 = y1 & 7
  bl ssd1309::getMyBufferData
  adds r4, r4, r0
  bl ssd1309::getPlotState    
  subs r1, r1, r5 		; r1 = j = (y1>>3) - (y0>>3)
  bne .pBoxElse
    ; r0 - state
    ; r1 - (y1 >>3) - (y0 >>3) 
    ; r2 - y1 & 7
    ; r3 - empty
    ; r4 - start offset
    ; r5 - 
    ; r6 - bit mask
    ; r7 - x1 - x0
    ; just one row of bits...
  movs r3, #0xfe
  lsls r3, r2			; r3 = 0xfe << (y1 & 7)
  eors r6, r3			; bitmask r6 = r6 EOR r3
  b .pBoxEndStore         ; do the row fill same as last row
.pBoxElse:
  bl pBoxRowFill
.pBoxLoop2:
  adds r4, #128
  subs r1, #1
  beq .pBoxLoopOut
  movs r3, #0x00
  subs r3, r3, r0
  mov r5, r7
.pBoxLoop1:
  strb r3, [r4, r5]
  subs r5, #1
  bpl .pBoxLoop1
  b .pBoxLoop2
.pBoxLoopOut:
  movs r6, #2
  lsls r6, r2	
  subs r6, #1			; bitmask = (2 << (y1 & 7)) - 1;
.pBoxEndStore:
  bl pBoxRowFill
.pBoxReturn:
  pop {r4,r5,r6,r7,pc}

pBoxRowFill:
  mov r5, r7
  cmp r0, #1
  bne .pBoxRFLF
.pBoxRFLT:
  ldrb r3, [r4, r5]
  orrs r3, r6
  strb r3, [r4, r5]
  subs r5, #1
  bpl .pBoxRFLT
  mov pc, lr
.pBoxRFLF:
  ldrb r3, [r4, r5]
  bics r3, r6
  strb r3, [r4, r5]
  subs r5, #1
  bpl .pBoxRFLF
  mov pc, lr



.vLineNeg:
  movs r1, #0		; if y0 < 0, y0 = 0
  cmp r2, #0		; if y1 < 0, exit
  bpl .vLine2
  b .vLineReturn	
.vLineStart:
  mov r2, r3
; vertical line plot
; r0 = x
; r1 = y0
; r2 = y1
vLineAsm:
  push {r4,r5,r6,lr}
  lsrs r3, r0, #7
  bne .vLineReturn        ; if x out of range, exit
  cmp r1, r2				
  IT PL
    mov r3, r2				; if (y0 > y1) {y = y1, y1 = y0}
    mov r2, r1
    mov r1, r3
.vLine1:
  cmp r1, #0
  bmi .vLineNeg
.vLine2:
  lsrs r3, r2, #6
  IT EQ
    movs r3, #63			; if (y1 > 63) y1 = 63;
.vLine3:
  lsrs r5, r1, #3			; r5 = (y0 >> 3)
  cmp r5, #7				; if (y0 > 63) return
  bhi .vLineReturn
  lsls r3, r5, #7			; r3 = 128 * (y>>3)
  adds r4, r3, r0			; r4 = x + 128 * (y>>3)
	
  movs r3, #7
  ands r3, r1				; r3 = (y & 7)
  movs r6, #0xff
  lsls r6, r3				; r6 = 0xff << (y & 7) bitmask
  lsrs r1, r2, #3			; r1 = (y1 >> 3)
  bl ssd1309::getMyBufferData
  adds r4, r4, r0
  bl ssd1309::getPlotState
  subs r1, r1, r5			; r1 = j
  bne .vLineElse          ; if more than one line got to Else
    ; r0 - state
    ; r1 - y1 >> 3 - y >>3
    ; r2 - y1
    ; r3 -
    ; r4 -  start offset
    ; r5 - 
    ; r6 - bit mask
	
  movs r5, #7
  ands r5, r2
  movs r3, #0xfe
  lsls r3, r5			; r3 = 0xfe << (y1 & 7)
  eors r6, r3				; bitmask r6 = r6 EOR r3
  b .vLineEndStore
.vLineElse:
  ldrb r3, [r4, #0]
  cmp r0, #1
  ITTEE EQ  
    movs r5, #0xff  ; then 
    orrs r3, r6  ; then
      movs r5, #0 ; else
      bics r3, r6 ; else
  strb r3, [r4, #0]
.vLine4:
  adds r4, #128
;	cmp r1, #1
;	beq .vLineLoopOut
  subs r1, #1
  beq .vLineLoopOut
  strb r5, [r4, #0]
  b .vLine4	
.vLineLoopOut:
  movs r3, #7
  ands r3, r2         ; y1 & 7
  movs r6, #2
  lsls r6, r3	
  subs r6, #1			; bitmask = (2 << (y1 & 7)) - 1;
.vLineEndStore:
  ldrb r3, [r4, #0]
  cmp r0, #1
  ITE EQ
    orrs r3, r6  ; then
    bics r3, r6  ; else
  strb r3, [r4, #0]
.vLineReturn:
  pop {r4, r5, r6, pc}


pLineAsm:
    cmp r0, r2
    beq .vLineStart
    cmp r1, r3
    beq .hLineStart
    push {r0,r3,r4,r5,r6,r7,lr}
    bl ssd1309::getPlotState
    mov r12, r0
    bl ssd1309::getMyBufferData
    mov r9, r0
    pop {r0,r3}
    subs r6, r0, r2
    bpl .pLine1
    subs r6, r2, r0
.pLine1:
    subs r5, r1, r3
    bpl .pLine2
    subs r5, r3, r1
.pLine2:            ; r4 = abs(dx), r5 = abs(dy)
    cmp r5, r6  
    bhi .pLineDyGtDx
.pLineDxGtDy:
    lsls r5, r5, #1     ; r5 = a
    mov r10, r5     ; r10 = a
    subs r7, r5, r6       ;   r7 = p = a - dx
    subs r6, r7, r6         ; r6 = b = p - dx
    adds r5, r2, r0
    lsrs r5, r5, #1     ; r5 = mid
    cmp r0, r2
    bmi .pLineNoSwap1
    mov r8, r0
    mov r0, r2
    mov r2, r8
    mov r8, r1
    mov r1, r3
    mov r3, r8
.pLineNoSwap1:      ; r0 = x, r1 = y, r2 = x1, r3 = y1, r5 = mid, r6 = b,  r7 = p, r9 = buffer, r10 = a, r12 = state
    movs r4, #1
    cmp r3, r1
    bpl .pLine3
    subs r4, #2
.pLine3:
    mov r8, r4
;  r0 = x, r1 = y, r2 = x1, r5 = mid, r6 = b, r7 = p, r8 = yc,  r9 = buffer, r10 = a, r12 = state
.pLineP1Start:
;  r0 = x, r1 = y, r2 = x1, r5 = mid, r6 = b, r7 = p, r8 = yc,  r9 = buffer, r10 = a, r12 = state
    bl writePixelQAsm        ; here
    cmp r0, r2          
    bpl .pLineReturn
    cmp r7, #0
    beq .pLineP12
    bpl .pLineP1Else
.pLineP1If:
    add r7, r10           ; if (p < 0) || ((p  == 0) && x >=mid),  p = p + a
    adds r0, #1
    b .pLineP1Start
 .pLineP12:
    cmp r0, r5
    bpl .pLineP1If
.pLineP1Else:
    add r7, r6
    add r1, r8
    adds r0, #1
    b .pLineP1Start

.pLineReturn:
    pop  {r4,r5,r6,r7,pc}


.pLineDyGtDx:
    lsls r4, r4, #1     ; r5 = a  = dx << 1
    mov r10, r4     ; r10 = a
    subs r7, r4, r5     ; r7 = p = a - dy
    subs r6, r7, r5     ; r6 = b = p - dy
    adds r5, r3, r1
    lsrs r5, r5, #1     ; r5 = mid = (y0 + y1) >> 1
    cmp r1, r3
    bmi .pLineNoSwap1D
    mov r4, r0
    mov r0, r2      ; r0 = x
    mov r2, r4      ; r2 = x1 
    mov r4, r1
    mov r1, r3      ; r1 = y
    mov r3, r4      ; r3 = y1
    ; r0 = x, r1 = y, r2 = x1, r3 = y1, r5 = mid, r6 = b, r7 = p, r8 = xc, r9 = buffer, r12 = state, r10 = a
.pLineNoSwap1D:     
    ; r0 = x, r1 = y, r2 = x1, r3 = y1, r5 = mid, r6 = b, r7 = p, r8 = xc, r9 = buffer, r12 = state, r10 = a
    movs r4, #1
    cmp r2, r0
    bpl .pLine3D
    subs r4, #2
.pLine3D:
    mov r8, r4
    mov r2, r3      ; discard x1 and keep y1
    ; r0 = x, r1 = y, r2 = y1, r5 = mid, r6 = b, r7 = p, r8 = xc, r9 = buffer, r12 = state, r10 = a
.pLineP1StartD:
    bl writePixelQAsm        ; here
    cmp r1, r2          
    bpl .pLineReturn
    cmp r7, #0
    beq .pLineP12D
    bpl .pLineP1ElseD
.pLineP1IfD:
    add r7, r10
    adds r1, #1
    b .pLineP1StartD
.pLineP12D:
    cmp r1, r5
    bpl .pLineP1IfD
.pLineP1ElseD:
    add r7, r6
    add r0, r8
    adds r1, #1
    b .pLineP1StartD



.hLineNeg:
    movs r0, #0				; if (r0 < 0) r0 = 0
    cmp r1, #0				; if (r1 < 0) return
    bmi .hLineReturn
    cmp r1, #128
    bmi .hLineC
.hLineNeg2:
    movs r1, #127		        ; if (r1 > 127) r1 = 127;
    cmp r0, #128
    bmi .hLineC
    b .hLineReturn

.hLineStart:
    mov r1, r2
    mov r2, r3
; horizontal line plot
; r0 - x0
; r1 - x1
; r2 - y
hLineAsm:
    push {r4,lr}
    cmp r0, r1
    bmi .hLineA1
    mov r3, r0				; if (r0 > r1) {r4 = r1, r1 = r0}
    mov r0, r1
    mov r1, r3
.hLineA1:
    cmp r0, #0              ; if r0 < 0
    bmi .hLineNeg
.hLineB1:
    cmp r1, #128
    bpl .hLineNeg2
.hLineC:
    lsrs r3, r2, #3
    cmp r3, #7
    bhi .hLineReturn        ; if y out of range, exit
    lsls r3, r3, #7
	subs r1, r1, r0         ; r1 = dx
	adds r4, r0, r3			; r4 = r0 + 128 * (r2>>3)	****
	movs r3, #7             ; set up the bit mask
	ands r3, r2
	movs r2, #1
	lsls r2, r3				; r2 = 1 << (r2 & 7)
	bl ssd1309::getMyBufferData
	adds r4, r4, r0     ; r6 is the start offset
	bl ssd1309::getPlotState		; returns 0 or 1 ??
	;r0 - plot state
	;r1 - offset (x1-x0 down to zero)
	;r2 - bit mask
    ;r3 -
	;r4 -  buffer  position (128*7%8) + lowest x
	cmp r0, #0
	beq .hLinefalse
.hLinetrue:
	ldrb r3, [r4, r1] 
    orrs r3, r2
    strb r3, [r4, r1]
	subs r1, #1
	bpl .hLinetrue
    b .hLineReturn
.hLinefalse:
	ldrb r3, [r4, r1] 
    bics r3, r2
    strb r3, [r4, r1]
	subs r1, #1
	bpl .hLinefalse
.hLineReturn:	
	pop {r4,pc}

writePixelQAsm:
; this routine doesn't load the plotState or the base buffer address
; r0 - x
; r1 - y
; r9 - buffer base
; r10 - plot plotState
    push {r1,r2,lr}
    cmp r0, #127        ;  if (x >127) or (x < 0), extit
    bhi .wpreturn4
    lsrs r2, r1, #3     ; r2 = y >> 3
    cmp r2, #7          ;   if r2 > 7, exit (y > 63) or (y<0)
    bhi .wpreturn4
    lsls r2, r2, #7     ; r2 = 128 * (y>>3)
    add r2, r9
    movs r4, #7
    ands r1, r4         ; r1 = y & 7
    movs r3, #1         
    lsls r3, r1         ; r3 = 1 << (y & 7)
    ldrb r4, [r2, r0]
    bics r4, r3
    mov r3, r12
    lsls r3, r1         ; r3 = state << (y & 7)
    orrs r4, r3
    strb r4, [r2, r0]    
.wpreturn4:
    pop {r1,r2,pc}
; r0 - preserved
; r1 - corrupted
; r2 - corrupted
; r3 - corrupted
; r4 - corrupted

; pixel plot

writePixelAsm:
    push {lr}
    cmp r0, #127        ;  if (x >127) or (x < 0), extit
    bhi .wpreturn2
    lsrs r2, r1, #3     ; r2 = y >> 3
    cmp r2, #7          ;   if r2 > 7, exit (y > 63) or (y<0)
    bhi .wpreturn2
    lsls r2, r2, #7     ; r2 = 128 * (y>>3)
    adds r2, r2, r0     ; r2 = 128 * (y >>3) + x
    movs r3, #7
    ands r1, r3
    bl ssd1309::getMyBufferData ; r0 points to data
    adds r2, r2, r0
    bl ssd1309::getPlotState
    movs r3, #1         ; r2 = 1
    lsls r3, r1         ; r3 = 1 << (y & 7)
    lsls r0, r1
    ; r0 - OR mask
    ; r1 - y & 7
    ; r2 - address
    ; r3 - BIC mask
    ldrb r1, [r2, #0]
    bics r1, r3
    orrs r1, r0
    strb r1, [r2, #0]
.wpreturn2:
    pop {pc}
