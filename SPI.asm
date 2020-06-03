sendSPIBufferAsm:

 	; arguments are: r0 - buffer, r1 - data pin, r2 - clock pin
    push {r4,r5,r6,r7,lr}
    
    mov r6, r1 ; save datapin in r6
    mov r7, r2 ; save clock pin in r7
    mov r8, r3 ; save chip select in r8

    mov r4, r0 ; save buff
    mov r0, r4
    bl BufferMethods::length
    mov r5, r0          ; r5 contains buffer length
    
    mov r0, r4
    bl BufferMethods::getBytes
    mov r4, r0          ; r4 points to the data
    

    mov r0, r8  ; get CE pin
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r0, [r0, #4] ; r1-mask for this pin
    mov r8, r0    ; save CE mask

    ; load data pin address
    mov r0, r6
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r6, [r0, #4] ; r1-mask for this pin    

    ; load clock pin address into r0 and get addrs/mask
    mov r0, r7
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r1, [r0, #4] ; r1-mask for this pin
    ldr r2, [r0, #16] ; r2-clraddr
    ldr r3, [r0, #12] ; r3-setaddr

    ; set CE low
    mov r0, r8
    str r0, [r2, #0]


    ; r0    to bloaded with buffer data
    ; r1    mask byte for clock pin
    ; r2    address for set pins low
    ; r3    address for set pins high
    ; r4    buffer address
    ; r5    counter
    ; r6    mask byte for data pin
    ; r7    bitmask for bit testing

    b .start
.dohigh:                                    ; C6
    str r6, [r3, #0]    ; set data pin  hi  ; C8
    lsrs r7, r7, #1     ; r6 >>= 1          ; C9
    str r1, [r3, #0]    ; clock -> high     ; C11
    beq .nextbyte                           ; C12
    tst r7, r0                              ; C13
    str r1, [r2, #0]    ; clock pin := lo   ; C15
    beq .dolow  ; r3 is high set so...      ; C16
    ; data pin is already high
    lsrs r7, r7, #1     ; r6 >>= 1          ; C17
    str r1, [r3, #0]    ; clock -> high     ; C19
    beq .nextbyte                           ; C22

.common:                                    ; C0
    tst r7, r0                              ; C1
    str r1, [r2, #0]    ; clock pin := lo   ; C3
    bne .dohigh  ; r3 is high set so...     ; C4
.dolow:
    str r6, [r2, #0]  ; set data pin low    ; C6
    lsrs r7, r7, #1     ; r6 >>= 1          ; C7
    str r1, [r3, #0]    ; clock -> high     ; C9
    beq .nextbyte                           ; C10
    tst r7, r0                              ; C11
    str r1, [r2, #0]    ; clock pin := lo   ; C13
    bne .dohigh  ; r3 is high set so...     ; C14
    ; data pin is already low
    lsrs r7, r7, #1     ; r6 >>= 1          ; C15
    str r1, [r3, #0]    ; clock -> high     ; C17
    bne .common                             ; C20
.nextbyte:
    adds r4, #1        ; r4++       C9
    subs r5, #1         ; r5--       C10
    beq .stop          ; if (r5=0) 
.start:                                     ; C0
    movs r7, #0x80      ; reset mask        ; C1
    ldrb r0, [r4, #0]  ; r0 := *r4          ; C3
    b .common    
.stop:
    str r1, [r2, #0]    ; clock pin := lo
    ; set CE high
    mov r0, r8
    str r0, [r3, #0]
    pop {r4,r5,r6,r7,pc}


sendSPIByteAsm:
 	; arguments are: r0 - buffer, r1 - data pin, r2 - clock pin
    push {r4,r5,r6,r7,lr}
   
    mov r5, r0  ; save the byte
    mov r6, r1 ; save datapin in r6
    mov r7, r2 ; save clock pin in r7
    mov r8, r3 ; save chip select in r8

    mov r0, r8  ; get CE pin
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r0, [r0, #4] ; r1-mask for this pin
    mov r8, r0    ; save CE mask


    ; load data pin address
    mov r0, r6
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r6, [r0, #4] ; r1-mask for this pin    

    ; load clock pin address into r0 and get addrs/mask
    mov r0, r7
    bl pins::getPinAddress
    ldr r0, [r0, #8] ; get mbed DigitalOut from MicroBitPin
    ldr r1, [r0, #4] ; r1-mask for this pin
    ldr r2, [r0, #16] ; r2-clraddr
    ldr r3, [r0, #12] ; r3-setaddr

    ; set CE low
    mov r0, r8
    str r0, [r2, #0]

    ; r0    not used
    ; r1    mask byte for clock pin
    ; r2    address for set pins low
    ; r3    address for set pins high
    ; r4    not used
    ; r5    the data byte
    ; r6    mask byte for data pin
    ; r7    bitmask for bit testing

    movs r7, #0x80      ; reset mask        ; C1
    b .bcommon
.bdohigh:                                   ; C6
    str r6, [r3, #0]    ; set data pin  hi  ; C8
    lsrs r7, r7, #1     ; r6 >>= 1          ; C9
    str r1, [r3, #0]    ; clock -> high     ; C11    
    beq .bstop                              ; C12           
.bcommon:                                   ; C0
    tst r7, r5                              ; C1
    str r1, [r2, #0]    ; clock pin := lo   ; C3
    bne .bdohigh  ; r3 is high set so...    ; C4
    str r6, [r2, #0]  ; set data pin low    ; C6
    lsrs r7, r7, #1     ; r6 >>= 1          ; C7
    str r1, [r3, #0]    ; clock -> high     ; C9
    bne .bcommon                            ; C12   
.bstop:
    str r1, [r2, #0]    ; clock pin := lo
    ; set CE high
    mov r0, r8
    str r0, [r3, #0]
    pop {r4,r5,r6,r7,pc}