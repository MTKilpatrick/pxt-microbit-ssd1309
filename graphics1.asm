; routines for graphics and SPI

; vertical line plot
vLineAsm:
; r0 = x
; r1 = y0
; r2 = y1
	push {r4,r5,r6,r7,lr}	
	cmp r0, #0				; if (x < 0) return
	bmi .vLinereturn
    cmp r0, #127
    bhi .vLinereturn
	mov r4, r1				; r4 = y = y0
	cmp r1, r2				
	bmi .vLine1
	mov r4, r2				; if (y0 > y1) {y = y1, y1 = y0}
	mov r2, r1
; r0 = x
; r2 = y1 (highest y)
; r4 = y (lowest y)	
.vLine1:
	cmp r2, #0				; if (y1 < 0) return
	bmi .vLinereturn	
	cmp r4, #0				; if (y < 0) y = 0;
	bpl .vLine2
	movs r4, #0				
.vLine2:
	movs r3, #63			; if (y1 > 63) y1 = 63;
	cmp r2, r3
	bls .vLine3
	mov r2, r3
.vLine3:
    mov r7, r4
	lsrs r7, r7, #3			; r7 = (y >> 3)
	cmp r7, #7				; if (y > 63) return
	bhi .vLinereturn
    mov r3, r7
	lsls r3, r3, #7			; r3 = 128 * (y>>3)
	adds r5, r3, r0			; r5 = x + 128 * (y>>3)
	
	movs r3, #7
	ands r3, r4				; r3 = (y & 7)
	movs r6, #0xff
	lsls r6, r3				; r6 = 0xff << (y & 7) bitmask
	
	bl ssd1309::getMyBufferData
	adds r5, r5, r0
	mov r1, r2
	lsrs r1, r1, #3			; r1 = (y1 >> 3)
	cmp r1, r7 				; if (y>>3) == (y1>>3)
	bne .vLineelse
	movs r3, #0xfe
	movs r0, #7
	ands r0, r2
	lsls r3, r0			; r3 = 0xfe << (y1 & 7)
	eors r6, r3				; bitmask r6 = r6 EOR r3
	bl ssd1309::getPlotState
    b .vLineendstore
.vLineelse:
	subs r1, r1, r7			; r1 = j
	bl ssd1309::getPlotState
	ldrb r3, [r5, #0]
	cmp r0, #1
	bne .vLinefalse2
	movs r4, #0xff
	orrs r3, r6
	strb r3, [r5, #0]
	b .vLine4
.vLinefalse2:
	movs r4, #0
	bics r3, r6
	strb r3, [r5, #0]
.vLine4:
	adds r5, #128
	cmp r1, #1
	beq .vLineloopout
	subs r1, #1
	strb r4, [r5, #0]
	b .vLine4	
.vLineloopout:
	movs r3, #7
	ands r3, r2         ; y1 & 7
	movs r6, #2
	lsls r6, r3	
	subs r6, #1			; bitmask = (2 << (y1 & 7)) - 1;
.vLineendstore:
	ldrb r3, [r5, #0]
	cmp r0, #1
	bne .vLinefalse3
	orrs r3, r6
	b .vLinereturnstrb
.vLinefalse3:
	bics r3, r6
.vLinereturnstrb:
	strb r3, [r5, #0]
.vLinereturn:
	pop {r4, r5, r6, r7, pc}





; horizontal line plot
hLineAsm:
	push {r4,r5,lr}
	mov r4, r0				; r4 = r0
	cmp r0, r1				
	bmi .hLine1
	mov r4, r1				; if (r0 > r1) {r4 = r1, r1 = r0}
	mov r1, r0
.hLine1:
	cmp r1, #0				; if (r1 < 0) return
	bmi .hLinereturn	
	cmp r4, #0				; if (r4 < 0) r4 = 0;
	bpl .hLine2
	movs r4, #0	
.hLine2:
	movs r3, #127			; if (r1 > 127) r1 = 127;
	cmp r1, r3
	bls .hLine3
	mov r1, r3
    cmp r4, r3			    ; if (r4 > 127) return;
    bhi .hLinereturn
.hLine3:
	lsrs r3, r2, #3			; r3 = r2 >> 3
	cmp r3, #7				; if ((r2 < 0) || (r2 > 63)) return;
	bhi .hLinereturn
	lsls r3, r3, #7			; r3 = 128 * (r2>>3)
	adds r5, r4, r3			; r5 = r4 + 128 * (r2>>3)	****
	subs r1, r1, r4
	movs r3, #7             ; set up the bit mask
	ands r3, r2
	movs r2, #1
	lsls r2, r3				; r2 = 1 << (r2 & 7)	
	bl ssd1309::getMyBufferData
	adds r5, r5, r0     ; r6 is the start offset
	bl ssd1309::getPlotState		; returns 0 or 1 ??
	;r0 - plot state
	;r1 - offset 
	;r2 - bit mask
	;r4 -
	;r5 -  buffer start position (128*7%8) + lowest x
	cmp r0, #1
	bne .hLinefalse
.hLinetrue:
	ldrb r3, [r5, r1] 
    orrs r3, r2
    strb r3, [r5, r1]
	subs r1, #1
	bpl .hLinetrue
    b .hLinereturn
.hLinefalse:
	ldrb r3, [r5, r1] 
    bics r3, r2
    strb r3, [r5, r1]
	subs r1, #1
	bpl .hLinefalse
.hLinereturn:	
	pop {r4,r5,pc}

; pixel plot

writePixelAsm:
    push {r4,lr}
    cmp r0, #127        ;  if (x >127) or (x < 0), extit
    bhi .wpreturn
    lsrs r4, r1, #3     ; r4 = y >> 3
    cmp r4, #7          ;   if r4 > 7, exit (y > 63) or (y<0)
    bhi .wpreturn
    lsls r4, r4, #7     ; r4 = 128 * (y>>3)
    adds r4, r4, r0     ; r4 = 128 * (y >>3) + x

    movs r3, #7         ; r3 = 7
    ands r3, r1         ; r1 = y & 7
    movs r1, #1         ; r2 = 1
    lsls r1, r3         ; r2 = 1 << (y & 7)
    bl ssd1309::getMyBufferData ; r0 points to data
    ; the above affects r0,r3 but not r1, r2 or r4
    ; r0 - buffer address
    ; r1 - data mask
    ; r2 - state
    ; r4 - offset
    ldrb r3, [r0, r4]
    cmp r2, #5
    beq .wpfalse
    orrs r3, r1
    strb r3, [r0, r4]
.wpreturn:
    pop {r4, pc}
.wpfalse:
    bics r3, r1
    strb r3, [r0, r4]
    b .wpreturn