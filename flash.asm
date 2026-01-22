;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright Jacques Deschênes 2019,2020,2021 
;; This file is part of stm32_eforth  
;;
;;     stm8_eforth is free software: you can redistribute it and/or modify
;;     it under the terms of the GNU General Public License as published by
;;     the Free Software Foundation, either version 3 of the License, or
;;     (at your option) any later version.
;;
;;     stm32_eforth is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY;; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public License
;;     along with stm32_eforth.  If not, see <http:;;www.gnu.org/licenses/>.
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  routines to write to FLASH, EEPROM 
;  and OPTION 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;--------------------------------
; initialize PTRH 
; P!  ( u -- )
;---------------------------------
    .word LINK 
    LINK=.
    .byte 2 
    .ascii "P!"
PTRSTOR:
    ldw y,x
    ldw y,(y)
    _stryz PTRH 
    addw x,#CELLL 
    ret 

;-----------------------------------
; return EEPROM base address 
; as a double 
;  EEPROM  ( -- u )
;-----------------------------------
    .word LINK 
	LINK=.
    .byte 6 
    .ascii "EEPROM"
EEPROM: 
    ldw y,#EEPROM_BASE
    subw x,#CELLL 
    ldw (x),y 
    ret

;---------------------------------
; return APP_LAST pointer
; EEP-LAST ( -- u )
;---------------------------------
	.word LINK 
	LINK=.
	.byte 8 
	.ascii "EEP-LAST"
EEPLAST:
	subw x,#CELLL 
	ldw y,#APP_LAST 
	ldw (x),y 
	ret 

;----------------------------------
; return APP_RUN pointer
; EEP-RUN ( -- u )
;-----------------------------------
	.word LINK 
	LINK=.
	.byte 7
	.ascii "EEP-RUN"
EEPRUN:
	subw x,#CELLL 
	ldw y,#APP_RUN 
	ldw (x),y 
	ret 

;------------------------------------
; return APP_CP pointer 
; EEP-CP ( -- u )
;------------------------------------
	.word LINK
	LINK=.
	.byte 6 
	.ascii "EEP-CP"
EEPCP:
	subw x,#CELLL 
	ldw y,#APP_CP  
	ldw (x),y 
	ret 

;------------------------------------
; return APP_VP pointer 
; EEP-VP ( -- ud )
;-------------------------------------
	.word LINK
	LINK=.
	.byte 6
	.ascii "EEP-VP"
EEPVP:
	subw x,#CELLL 
	ldw y,#APP_VP  
	ldw (x),y 
	ret 

;----------------------------------
; update APP_LAST with LAST 
; UPDAT-LAST ( -- )
;----------------------------------
	.word LINK 
	LINK=.
	.byte 10
	.ascii "UPDAT-LAST"
UPDATLAST:
	call LAST
	call AT  
	call EEPLAST
	jp EESTORE 

;---------------------------------
; update APP_RUN 
; UPDAT-RUN ( a -- )
;---------------------------------
	.word LINK
	LINK=.
	.byte 9
	.ascii "UPDAT-RUN"
UPDATRUN:
	call EEPRUN
	jp EESTORE 
	
;---------------------------------
; update APP_CP with CP 
; UPDAT-CP ( -- )
;---------------------------------
	.word LINK 
	LINK=.
	.byte 8 
	.ascii "UPDAT-CP"
UPDATCP:
	call CPP 
	call AT 
	call EEPCP 
	jp EESTORE 

;----------------------------------
; update APP_VP with VP 
; UPDAT-VP ( -- )
;----------------------------------
	.word LINK
	LINK=.
	.byte 8 
	.ascii "UPDAT-VP" 
UPDATVP:
	call VPP 
	call AT
	call EEPVP 
	jp EESTORE
	
;----------------------------------
; UNLOCK EEPROM/OPT for writing/erasing
; wait endlessly for FLASH_IAPSR_DUL bit.
;  UNLKEE   ( -- )
;----------------------------------
    .word LINK 
LINK=.
    .byte 6 
    .ascii "UNLKEE"
UNLKEE:
;	mov FLASH_CR2,#0 
;	mov FLASH_NCR2,#0xFF 
	mov FLASH_DUKR,#FLASH_DUKR_KEY1
    mov FLASH_DUKR,#FLASH_DUKR_KEY2
	btjf FLASH_IAPSR,#FLASH_IAPSR_DUL,.
	ret

;----------------------------------
; UNLOCK FLASH for writing/erasing
; wait endlessly for FLASH_IAPSR_PUL bit.
; UNLKFL  ( -- )
;----------------------------------
    .word LINK 
LINK=. 
    .byte 6 
    .ascii "UNLKFL"    
UNLKFL:
;	mov FLASH_CR2,#0 
;	mov FLASH_NCR2,#0xFF 
	mov FLASH_PUKR,#FLASH_PUKR_KEY1
	mov FLASH_PUKR,#FLASH_PUKR_KEY2
	btjf FLASH_IAPSR,#FLASH_IAPSR_PUL,.
	ret

;-----------------------------
; UNLOCK FLASH or EEPROM 
; according to PTRH address 
;  UNLOCK ( -- )
;-----------------------------
	.word LINK 
	LINK=.
	.byte 6
	.ascii "UNLOCK"
UNLOCK:
; put addr[15:0] in Y, for bounds check.
	ldw y,PTRH   ; Y=addr15:0
; check addr[23:16], if <> 0 then it is extened flash memory
	tnz PTRH 
	jrne 4$
    cpw y,#FLASH_BASE
    jruge 4$
	cpw y,#EEPROM_BASE  
    jrult 9$
	cpw y,#OPTION_END 
	jrugt 9$
	call UNLKEE
	ret 
4$: call UNLKFL
9$: ret 

;-------------------------
; LOCK write access to 
; FLASH and EEPROM 
; LOCK ( -- )
;-------------------------
	.word LINK 
	LINK=.
	.byte 4 
	.ascii "LOCK" 
LOCK: 
	bres FLASH_IAPSR,#FLASH_IAPSR_PUL
	bres FLASH_IAPSR,#FLASH_IAPSR_DUL
	ret 

;-------------------------
; increment PTR 
; INC-PTR ( -- )
;-------------------------
	.word LINK 
	LINK=. 
	.byte 8 
	.ascii "INC-PTR" 
INC_PTR:
	_ldyz PTRH 
	incw y 
	_stryz PTRH 
    ret 

;------------------------------
; add u to PTR 
; PTR+ ( u -- )
;------------------------------
	.word LINK 
	LINK=.
	.byte 4 
	.ascii "PTR+"
PTRPLUS:
	ldw y,x 
	addw x,#CELLL
	ldw y,(y) 
	addw y,PTRH  
	_stryz PTRH   
1$: ret 

;----------------------------
; write a byte at address pointed 
; by PTR and increment PTR.
; Expect pointer already initialized 
; and memory unlocked 
; WR-BYTE ( c -- )
;----------------------------
	.word LINK 
	LINK=. 
	.byte 7 
	.ascii "WR-BYTE" 
WR_BYTE:
	ld a,(1,x)
	addw x,#CELLL 
	ld [PTRH],a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	jp INC_PTR 

;---------------------------------------
; write a word at address pointed 
; by PTRH and increment PTRH 
; Expect pointer already initialzed 
; and memory unlocked 
; WR-WORD ( w -- )
;---------------------------------------
	.word LINK 
	LINK=.
	.byte 7 
	.ascii "WR-WORD" 
WR_WORD:
	ldw y,x
	ldw y,(y)
	addw x,#CELLL 
	ld a,yh 
	ld [PTRH],a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	call INC_PTR 
	ld a,yl 
	ld [PTRH],a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	jp INC_PTR 

;---------------------------------------
; write a byte to FLASH or EEPROM/OPTION  
; EEC!  (c u -- )
;---------------------------------------
    .word LINK 
	LINK=.
    .byte 4 
    .ascii "EEC!"
	; local variables 
	BTW = 1   ; byte to write offset on stack
    OPT = 2 
	VSIZE = 2
EECSTORE:
	sub sp,#VSIZE
    call PTRSTOR
	ld a,(1,x)
	cpl a 
	ld (BTW,sp),a ; byte to write 
	clr (OPT,sp)  ; OPTION flag
	call UNLOCK 
	; check if option
	tnz PTRH 
	jrne 2$
	ldw y,PTRH 
	cpw y,#OPTION_BASE
	jrmi 2$
	cpw y,#OPTION_END+1
	jrpl 2$
	cpl (OPT,sp)
	; OPTION WRITE require this UNLOCK 
    bset FLASH_CR2,#FLASH_CR2_OPT
;    bres FLASH_NCR2,#FLASH_CR2_OPT 
2$: 
	call WR_BYTE 	
	tnz (OPT,sp)
	jreq 3$ 
    ld a,(BTW,sp)
    clrw y
	ld yl,a 
	subw x,#CELLL 
	ldw (x),y 
	call WR_BYTE
3$: 
	call LOCK 
	addw sp,#VSIZE 
    ret

;------------------------------
; write integer in FLASH|EEPROM
; EE! ( n u -- )
;------------------------------
	.word LINK 
	LINK=.
	.byte 3 
	.ascii "EE!"
EESTORE:
	call PTRSTOR 
	call UNLOCK 
	ldw y,x 
	ldw y,(y)
	pushw y 
	swapw y 
	ldw (x),y 
	call WR_BYTE 
	popw y 
	subw x,#CELLL
	ldw (x),y 
	call WR_BYTE
	jp LOCK 


;----------------------------
; Erase flash memory row 
; stm8l151k6 as 128 bytes rows
; ROW-ERASE ( u -- )
;----------------------------
	.word LINK 
	LINK=. 
	.byte 9 
	.ascii "ROW-ERASE" 
row_erase:
	call PTRSTOR
;code must be execute from RAM 
;copy routine to PAD 
	subw x,#CELLL 
	ldw y,#row_erase_proc
	ldw (x),y 
	call PAD 
	ldw y,#row_erase_proc_end 
	subw y,#row_erase_proc
	subw x,#CELLL 
	ldw (x),y 
	call CMOVE 
block_erase:
	ldw y,PTRH
	cpw y,#app_space 
	jrpl erase_flash 
; erase EEPROM block
	cpw y,#EEPROM_BASE 
	jruge 1$
	ret ; bad address 
1$: cpw y,#EEPROM_END 
	jrule 2$ 
	ret ; bad address 
2$:	
	call UNLKEE 
	jra proceed_erase
; erase flash block:
erase_flash:
	call UNLKFL 
proceed_erase:
	call PAD 
	ldw y,x
	ldw y,(y)
	addw x,#CELLL  
	call (y) 
	bres FLASH_IAPSR,#FLASH_IAPSR_DUL
	ret 

; this routine is to be copied to PAD 
row_erase_proc:
	mov FLASH_CR2,#(1<<FLASH_CR2_ERASE) 
;	mov FLASH_NCR2,#~(1<<FLASH_CR2_ERASE)
	clr a 
	clrw y 
	ld ([PTRH],y),a
    incw y
	ld ([PTRH],y),a
    incw y
	ld ([PTRH],y),a
    incw y
	ld ([PTRH],y),a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	ret
row_erase_proc_end:

;-----------------------------------
; block programming must be 
; executed from RAM 
; initial contidions: 
; 		memory unlocked
;       PTRH initialized 
; input: 
;    x   buffer address 
;-----------------------------------
	BCNT=1 
copy_buffer:
	push #BLOCK_SIZE  
;enable block programming 
	bset FLASH_CR2,#FLASH_CR2_PRG 
;	bres FLASH_NCR2,#FLASH_CR2_PRG
	clrw y
1$:	ld a,(x)
	ld ([PTRH],y),a
	incw x 
	incw y 
	dec (BCNT,sp)
	jrne 1$
; wait EOP bit 
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,. 
	pop a ; remove BCNT from stack 
	ret 
copy_buffer_end:

;-------------------------
; move program_row to RAM 
; in TIB 
;------------------------
copy_prog_to_ram:
	subw x,#6
	ldw y,#copy_buffer 
	ldw (4,x),y 
	ldw y,#TIBBASE
	ldw (2,x),y 
	ldw y,#copy_buffer_end 
	subw y,#copy_buffer  
	ldw (x),y 
	call CMOVE 
	ret 


;-----------------------------
; write a row in FLASH/EEPROM 
; WR-ROW ( a u -- )
; a -> address 128 byte buffer to write 
; u ->  row address in FLASH|EEPROM 
;-----------------------------
	.word LINK 
	LINK=.
	.byte 6 
	.ascii "WR-ROW"
write_row:
	call PTRSTOR
; align to FLASH block 
	ld a,#0x80 
	and a,PTRL 
	ld PTRL,a  
	call copy_prog_to_ram
	call UNLOCK
	ldw y,x 
	ldw y,(y)
	addw x,#CELLL 
	pushw x 
	ldw x,y ; buffer address in x 
	call TIBBASE
	call LOCK
	popw x 
	ret 

;-------------------------------------
; change value of OPTION register 
; SET-OPT (c n -- ) 
; c new value.
; n OPT  number {1..7}
;--------------------------------------
		.word LINK 
		LINK=.
		.byte 7 
		.ascii "SET-OPT" 
set_option: 
		ldw y,x 
		ldw y,(y)
		jreq 1$
		cpw y,#7 
		jrule 2$ 
; invalid OPTION number 		
1$:		addw x,#2*CELLL
		ret
2$:		sllw y 
		addw y,#OPTION_BASE-1
		ldw (x),y 
		subw x,#CELLL 
		clrw y 
		ldw (x),y 
		call EECSTORE
		ret 

.if STM8L151K6
clear_l151k6_opt:
	
	ret 
.endif 

;--------------------------------------
; reset system to its original state 
; before any user modification
; PRISTINE ( -- )
;-------------------------------------
	.word LINK  
	LINK=.
	.byte 8 
	.ascii "PRISTINE"
pristine:
;;; erase EEPROM
	call EEPROM 
1$:	call DUPP  
	call row_erase
	ldw y,x 
	ldw y,(y)
	addw y,#BLOCK_SIZE
	ldw (x),y
	cpw y,#EEPROM_END 
	jrult 1$
	addw x,#CELLL 
;;; reset OPTION to default values
.if STM8L151K6
	callr clear_l151k6_opt
.endif 
;;; erase first row of app_space 		
	subw x,#CELLL 
	ldw y,#app_space
	ldw (x),y  
	call row_erase 
; reset interrupt vectors 0..29 for stm8l151k6  
	subw x,#CELLL 
	clrw y  
4$:	ldw (x),y  ; ( n -- ) int# 
	call DUPP  
	call reset_vector
	ldw y,x 
	ldw y,(y)
	incw y   ; next vector 
	cpw y,#30
	jrult 4$
	jp NonHandledInterrupt ; reset MCU

;------------------------------
; reset an interrupt vector 
; to its initial value 
; i.e. NonHandledInterrupt
; RST-IVEC ( n -- )
;-----------------------------
	.word LINK 
	LINK=. 
	.byte 8 
	.ascii "RST-IVEC"
reset_vector:
	ldw y,x
	addw x,#CELLL 
	ldw y,(y)
	cpw y,#25 ; timer4 preserved 
	jreq 9$
	cpw y,#27 ; usart1 rx preserved 
	jreq 9$ 
	cpw y,#29 ; last vector
	jrugt 9$  
	sllw y 
	sllw y 
	addw y,#0x8008 ; irq0 address 
	ldw YTEMP,y
	subw x,#2*CELLL 
	ldw (x),y 
	ldw y,#0x8200 
	ldw (2,x),y
	call EESTORE
	subw x,#2*CELLL
	ldw y,YTEMP 
	addw y,#2 
	ldw (x),y
	ldw y,#NonHandledInterrupt
	ldw (2,x),y 
	call EESTORE
9$:	ret 


;------------------------------
; all interrupt vector with 
; an address >= a are resetted 
; to default
; CHKIVEC ( a -- )
;------------------------------
	.word LINK 
	LINK=.
	.byte 7
	.ascii "CHKIVEC"
;local variables 
	SSP=1
	CADR=3
	OFS=5
	VSIZE=6  
CHKIVEC:
	sub sp,#VSIZE ;alloc local variables 
	ldw y,x 
	ldw y,(y)
	ldw (CADR,sp),y ; ca 
	ldw (SSP,sp),x 
	ldw x,#0x800a ; irq0 address 
	ldw PTRH,X
	ldw x,#-4 
1$:	addw x,#4
	cpw x,#30*4 ; irq0-29 
	jreq 9$
	ldw y,x  
	ld a,([PTRH],y)
	cp a,(CADR,sp)
	jrult 1$
	incw y 
	ld a,([PTRH],y)
	cp a,(CADR+1,sp) 
	jrult 1$ 
	ldw (OFS,sp),x 
	srlw x
	srlw x 
	ldw y,x 
	ldw x,(SSP,sp)
	ldw (x),y
	call reset_vector
	ldw x,(OFS,sp) 
	jra 1$
9$:	ldw x,(SSP,sp) 
	addw x,#CELLL 
	addw sp,#VSIZE ; drop local variables  
	ret 

;------------------------------
; set interrupt vector 
; SET-IVEC ( u n -- )
;  u  Handler address
;  n  vector # 0 .. 29 
;-----------------------------
	.word LINK
	LINK=.
	.byte 8 
	.ascii "SET-IVEC" 
set_vector:
    ldw y,x 
	addw x,#CELLL 
	ldw y,(y) ; vector #
	cpw y,#29 ; last vector
	jrule 2$
	addw x,#2*CELLL 
	ret
2$:	sllw y 
	sllw y 
	addw y,#0X8008 ; IRQ0 vector address 
	ldw YTEMP,y ; vector address 
	ld a,#0x82 
	ld yh,a 
	ld a,(1,x) ; isr address bits 23..16 
	ld yl,a 
;  write 0x82 + most significant byte of int address	
	subw x,#3*CELLL 
	ldw (4,x),y 
	ldw y,YTEMP
	ldw (2,x),y ; vector address 
	clrw y 
	ldw (x),y   ; as a double 
	call EESTORE 
	ldw y,x 
	ldw y,(2,y) ; bits 15..0 int vector 
	subw x,#3*CELLL 
	ldw (4,x),y 
	ldw y,YTEMP 
	addw y,#2 
	ldw (2,x),y 
	clrw y 
	ldw (x),y 
	call EESTORE
	addw x,#2*CELLL  
9$: ret 


;------------------------
; Compile word to flash
; EE, (w -- )
;-----------------------
	.word LINK
	LINK=.
	.byte 3
	.ascii "EE,"
EE_COMMA:
	subw x,#2*CELLL 
	ldw y,UCP
	pushw y 
	ldw (2,x),y 
	clrw y 
	ldw (x),y
	call EESTORE
	popw y 
	addw y,#2
	ldw UCP,y
	ret 


;-------------------------
; Compile byte to flash 
; EEC, ( c -- )	
;-------------------------
	.word LINK 
	LINK=.
	.byte 4 
	.ascii "EEC,"
EE_CCOMMA:
	subw x,#2*CELLL 
	ldw y,UCP
	pushw y 
	ldw (2,x),y 
	clrw y 
	ldw (x),y
	call EECSTORE
	popw y 
	incw y 
	ldw UCP,y
	ret 


;--------------------------
; copy FLASH block to ROWBUF
; ROW>BUF ( ud -- )
;--------------------------
	.word LINK 
	LINK=.
	.byte 7 
	.ascii "ROW>BUF"
ROW2BUF: 
	call PTRSTOR 
	ld a,#BLOCK_SIZE
	push a 
	and a,PTRL ; block align 
	ld PTRL,a
	ldw y,#ROWBUFF 
1$: ldf a,[PTRH]
	ld (y),a
	call INC_PTR
	incw y 
	dec (1,sp)
	jrne 1$ 
	pop a 
	ret 


;---------------------------
; copy ROWBUFF to flash 
; BUF>ROW ( ud -- )
; ud is row address as double 
;---------------------------
	.word LINK 
	LINK=.
	.byte 7 
	.ascii "BUF>ROW" 
BUF2ROW:
	call TBUF ; ( ud rb -- )
	call ROT 
	call ROT  ; ( rb ud -- )
	call write_row 
	ret 

;---------------------------------
; how many byte free in that row 
; RFREE ( a -- n )
; a is least byte of target address
;----------------------------------
	.word LINK 
	LINK=.
	.byte 5 
	.ascii "RFREE"
RFREE:
	ld a,(1,x)
	and a,#BLOCK_SIZE-1 
	ld YTEMP,a 
	ld a,#BLOCK_SIZE 
	sub a,YTEMP 
	clrw y 
	ld yl,a
	ldw (x),y 
	ret 

;---------------------------------
; write u bytes to flash/EEPROM 
; constraint to row limit 
; RAM>EE ( ud a u -- u2 )
; ud flash address 
; a ram address 
; u bytes count
; return u2 bytes written  
;-------------------------------
	.word LINK 
	LINK=. 
	.byte 6
	.ascii "RAM>EE"
	
RAM2EE:
; copy ud on top 
	ldw y,x 
	ldw y,(6,y) ; LSW of ud  
	ldw YTEMP,y 
	ldw y,x 
	ldw y,(4,y)  ; MSW of ud 
	subw x,#2*CELLL 
	ldw (x),y 
	ldw y,YTEMP 
	ldw (2,x),y 
	call ROW2BUF 
	ldw y,x 
	ldw y,(6,y)
	pushw y ; udl 
	ld a,yl
	and a,#BLOCK_SIZE-1 
	clrw y 
	ld yl,a 
	addw y,#ROWBUFF 
	subw x,#CELLL 
	ldw (x),y  
	call SWAPP ;  ( ud a ra u -- )
	call RFROM  
	call RFREE 
	call MIN
	call DUPP 
	call TOR  
	call CMOVE
	call BUF2ROW 
	call RFROM 
	ret 


;--------------------------
; expand 16 bit address 
; to 32 bit address 
; FADDR ( a -- ud )
;--------------------------
	.word LINK 
	LINK=. 
	.byte 5 
	.ascii "FADDR"
FADDR:
	jp ZERO 


;--------------------------
; FMOVE ( -- cp+ )
; 
; move new colon definition to FLASH 
; using WR-ROW for efficiency 
; preserving bytes already used 
; in the current block. 
; At this point the compiler as completed
; in RAM and pointers CP and CNTXT updated.
; CNTXT point to nfa of new word and  
; CP is after last compiled word so 
; CP-CNTXT+2=count to write 
;--------------------------
	_HEADER FMOVE,5,"FMOVE"
	call CPP
	call AT  
	call DUPP ; ( udl udl -- )
	call CNTXT 
	call AT 
	call DOLIT 
	.word 2 
	call SUBB ; ( udl udl a -- )
	call SWAPP 
	call ROT  ; ( udl ud a -- )
	call DUPP 
	call TOR    ; R: a 
FMOVE2: 
	call HERE 
	call RAT 
	call SUBB ; (udl ud a wl -- )
next_row:
	call DUPP 
	call TOR  ; ( udl ud a wl -- ) R: a wl
	call RAM2EE ; ( udl a u -- udl u2 ) u2 is byte written to FLASH 
	call DUPP 
	call TOR
	call PLUS  ; ( udl+ ) 
	call DUPP 
	call ZERO   ; ( udl+ ud -- )
	call RFROM  ; ( udl+ ud u2  R: a wl ) 
	call RFROM  ; ( udl+ ud u2 wl R: a ) 
	call OVER   ; ( udl+ ud u2 wl u2 -- )
	call SUBB  ; ( udl+ ud u2 wl- R: a )
	call DUPP 
	call QBRAN
	.word fmove_done 
	call SWAPP  ; ( udl+ ud wl- u2 R: a )
	call RFROM ; ( udl+ ud wl- u2 a -- ) 
	call PLUS  ; ( udl+2 ud wl- a+ )
	call DUPP 
	call TOR   ; ( udl+2 ud wl- a+ ) R: a+
	call SWAPP 
	call BRAN
	.word next_row  
fmove_done:	
	call RFROM  ; ( -- udl+ ud u2 wl- a  )
	addw x,#5*CELLL ; (  -- cp+ ) new CP 
 	ret  

;------------------------------------------
; adjust pointers after **FMOVE** operetion.
; UPDAT-PTR ( cp+ -- )
; cp+ is new CP position after FMOVE 
;-------------------------------------------
	.word LINK 
	LINK=.
	.byte 9
	.ascii "UPDAT-PTR" 
UPDATPTR:
;reset VP to previous position  
	call EEPVP 
	_DROP 
	call AT
	call VPP 
	call STORE
;update CONTEXT and LAST 
	call EEPCP 
	_DROP
	call AT
	call DOLIT 
	.word 2 
	call PLUS 
	call DUPP 
	call CNTXT 
	call STORE
	call LAST
	call STORE 
	call UPDATLAST 
;update CP 
	call CPP 
	call STORE
	call UPDATCP 
	ret 

;-----------------------------
; move interrupt sub-routine
; in flash memory
;----------------------------- 
	.word LINK 
	LINK=. 
	.byte 6
	.ascii "IFMOVE" 
IFMOVE:
	call TFLASH 
	CALL AT 
	CALL QBRAN 
	.word no_move 
	call CPP 
	call AT 
	call DUPP ; ( udl udl -- )
	call EEPVP 
	_DROP
	call AT  ; ( udl udl a )
	call TOR 
	call FADDR
	call RAT ; ( udl ud a -- ) R: a 
	jp FMOVE2 


