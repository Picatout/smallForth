;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2026 
;; This file is part of smallForth  
;;
;;     smallForth is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;;
;;     smallForth is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY;; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with smallForth.  If not, see <http:;;www.gnu.org/licenses/>.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;-------------------------
; hardware initialization 
; and BASIC INPUT/OUTPUT 
;-------------------------


RAMBASE = 0x0000	        ;ram base
STACK_SIZE = 128 
DSTACK_SIZE = 128 
TIB_SIZE= 128 
STACK   =	RAM_END                 ;R: stack  
DATSTK  =	RAM_SIZE-DSTACK_SIZE 	;S: stack  
TIBBASE =       DATSTK-TIB_SIZE         ; transaction input buffer addr. 128 bytes


;**********************************************************
        .area DATA (ABS)
        .org RAMBASE 
;**********************************************************

;**********************************************************
        .area SSEG (ABS) ; STACK
        .org RAM_SIZE-STACK_SIZE-DSTACK_SIZE-TIB_SIZE
        .ds STACK_SIZE+DSTACK_SIZE+TIB_SIZE
;   space for DATSTK,TIB and STACK         
;**********************************************************


;**********************************************************
        .area CODE
;**********************************************************

;--------------------------------
; non handled interrupt reset MCU
; do nothing 
;--------------------------------
NotHandledInterrupt:
       iret 

;--------------------------------
; used for milliseconds counter 
; MS is 16 bits counter 
;--------------------------------
Timer4Handler:
	clr TIM4_SR 
        ldw x,MS 
        incw x 
        ldw MS,x
        iret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; UART intterrupt handler 
;;; on receive character 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;--------------------------
; UART receive character
; in a FIFO buffer 
; CTRL+X reboot MCU  
;--------------------------
UartRxHandler: ; console receive char 
        btjf UART_SR,#UART_SR_RXNE,5$ 
	ld a,UART_DR 
	cp a,#CTRL_X  
	jrne 2$
        clr FLASH_IAPSR
	_swreset 	
2$:
        cp a,#CTRL_C
        jrne 3$
        LDW X,#ABORT 
        LDW (8,SP),X 
        IRET 
3$:
	push a 
	ld a,#RX_QUEUE
	add a,RX_TAIL 
	clrw x 
	ld xl,a 
	pop a 
	ld (x),a 
	ld a,RX_TAIL 
	inc a 
	and a,#RX_QUEUE_SIZE-1
	ld RX_TAIL,a 
5$:	iret 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; power up entry points and COLD start data
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
reset:

; clear all RAM
	ldw X,#RAM_END
1$:
	clr (X)
	decw x 
        jrne 1$
; set SEEDY to $0101
        LDW  Y,CHIPID+5 ; LOT 
        LDW   SEEDY,Y        

; initialize stacks 
        LDW     X,#STACK  ;initialize return stack
        LDW     SP,X
        LDW     RP0,X
        LDW     X,#DATSTK ;initialize data stack
        LDW     SP0,X

; initialize clock to HSI
; no divisor 16Mhz 
clock_init:
        clr CLK_CKDIVR

; set pullup on all input 
        LD      A,#255 
        LD      PA_CR1,A 
        LD      PB_CR1,A 
        LD      PC_CR1,A 
        LD      PD_CR1,A 
        
; initialize UART, 115200 8N1
uart_init:
	bset CLK_PCKENR1,#UART_PCKEN
; baud rate 115200 Fmaster=16Mhz  16000000/115200=139=0x8b
	mov UART_BRR2,#0x0b ; must be loaded first
	mov UART_BRR1,#0x08
        clr UART_DR
	mov UART_CR2,#((1<<UART_CR2_TEN)|(1<<UART_CR2_REN)|(1<<UART_CR2_RIEN));
        call clr_scr

; initialize timer4, used for millisecond interrupt  
	bset CLK_PCKENR1,#CLK_PCKENR1_TIM4 
        mov TIM4_PSCR,#7  ; prescale 128  
	mov TIM4_ARR,#124 ; set for 1msec. 125Khz/1Khz-1 
	mov TIM4_CR1,#((1<<TIM4_CR1_CEN)|(1<<TIM4_CR1_URS))
	bset TIM4_IER,#TIM4_IER_UIE 
        rim 
; 100 msec delay to protect EEPROM update 
; from power fluctuations
        clr MS 
        clr MS+1 
1$:
        ldw X,MS 
        cpw X,#1000 
        jrmi 1$

        jp  COLD   ;default=MN1


;;;;;;;;;;;;;;;;;;
;; Basic UART I/O
;;;;;;;;;;;;;;;;;;

;----------------------
; clear terminal screen
;----------------------
clr_scr:
        ld a,#27 
        call putc 
        ld a,#'c 
        jra putc 

;-----------------------
; cehck if char in queue
; output:
;    A    0 no char
;-----------------------
qchar: 
        ld a,RX_HEAD 
        sub a,RX_TAIL 
        ret 

;------------------------
; extract char from queue
;  output:
;    A     c  
;------------------------
getc:
        pushw y 
        _ldaz RX_HEAD 
1$:     cp a,RX_TAIL 
        jreq 1$ 
        clrw y 
        _ldaz RX_HEAD 
        add a,#RX_QUEUE 
        ld yl,a 
        ld a,(y)
        push a 
        _ldaz RX_HEAD 
        inc a 
        and a,#RX_QUEUE_SIZE-1 
        _straz RX_HEAD 
        pop a
; uppercase letters 
        cp a,#'a 
        jrult 9$ 
        cp a,#'z+1 
        jrpl 9$ 
        and a,#0xDF          
9$:     popw y 
        ret 

;---------------------------------
; send character to UART 
;  input: 
;     A     c 
;---------------------------------
putc:
        BTJF UART_SR,#UART_SR_TXE,.  ;loop until tx empty 
        LD    UART_DR,A   ;send A
        RET        

;-----------------------------
; move cursor left 
; 1 character 
;-----------------------------
delback:
    ld a,#BKSPP 
    callr putc  
    ld a,#SPC  
    callr putc 
    ld a,#BKSPP 
    jra putc 


;-----------------------------------
; accept line from terminal 
; input:
;    A   max length 
;    Y   input buffer 
; output:
;    A   actual len 
;----------------------------------
LEN=1 
LIMIT=2
CHAR=3  
VSIZE=3
getline:
    sub sp,#VSIZE 
    ld (LIMIT,SP),a  
    clr (LEN,SP)   
1$:
    callr getc
    ld (CHAR,sp),a 
    cp a,#CRR 
    jreq 9$ 
    cp a,#BKSPP  
    jrne 2$
    tnz (LEN,SP)
    jreq 1$ 
    callr delback 
    dec (LEN,SP)
    decw y 
    jra 1$ 
2$:     
    cp a,#SPC  
    jrmi 1$  ; ignore others control char 
    ld a,(LEN,SP)
    cp a,(LIMIT,SP)
    jreq 1$ 
    ld a,(CHAR,SP)    
    callr putc
    ld (y),a 
    incw y 
    inc (LEN,SP)
    jra 1$
9$:  
    ld a,(LEN,SP)
    addw sp,#VSIZE 
    ret 

;--------------------------------
; convert unsigned integer to 
; string  
; input:
;   A    base 
;   Y    uint16 
; output:
;   A    string length 
;   Y    *string 
;---------------------------------
slen=2 
div=1
utoa:
        pushw  x   ; save DP 
        push   #0  ; slen 
        push a     ; div 
        ldw  x,UVP  
        addw x,#80  ; string pointer
1$:     ld   a,(div,sp)
        div y,a 
        cp a,#10
        jrmi 4$ 
        add a,#7 
4$:     add a,#'0 
        ld   (x),a
        inc  (slen,sp) 
        decw  x 
        tnzw  y 
        jrne 1$
        incw x
        ldw   y,x   ; *string 
        ld   a,(slen,sp) ; string length 
        addw  sp,#2  ; drop slen and div 
        popw  x      ; restore DP 
        ret 
