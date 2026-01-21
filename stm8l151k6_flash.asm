;;;;;;;;;;;;;;;;;;;;;;;;;
; stm8l151k6 flash and 
; eeprom programming 
;;;;;;;;;;;;;;;;;;;;;;;;;



;----------------------
; unlock flash and 
; eeprom programming 
;----------------------
unlock_ee:
; unlock FLASH IAP 
    mov FLASH_PUKR,#FLASH_PUKR_KEY1
    mov FLASH_PUKR,#FLASH_PUKR_KEY2 
;unlock EEPROM IAP 
    mov FLASH_DUKR,#FLASH_DUKR_KEY1 
    mov FLASH_DUKR,#FLASH_DUKR_KEY2
;enable write to OPTION registers 
    bset FLASH_CR2,#FLASH_CR2_OPT 
    ret 


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
; store link address of dictionary head 
; in EEPROM 
; UPDAT-LAST ( -- )
;----------------------------------
	.word LINK 
	LINK=.
	.byte 10
	.ascii "UPDAT-LAST"
UPDATLAST:
	call LAST
	call AT      ; ( adr -- )
	call EEPLAST ; ( adr ee_adr -- )
	jp STORE 

;---------------------------------
; update APP_RUN 
; store autorun code address in 
; EEPROM 
; UPDAT-RUN ( a -- )
;---------------------------------
	.word LINK
	LINK=.
	.byte 9
	.ascii "UPDAT-RUN"
UPDATRUN:
	call EEPRUN ; ( adr ee_adr -- )
	jp STORE 
	
;---------------------------------
; update APP_CP with CP 
; store free code start address 
; in EEPROM 
; UPDAT-CP ( -- )
;---------------------------------
	.word LINK 
	LINK=.
	.byte 8 
	.ascii "UPDAT-CP"
UPDATCP:
	call CPP 
	call AT     ; ( adr -- )
	call EEPCP  ; ( adr ee_adr -- )
	jp STORE 

;----------------------------------
; update APP_VP with VP 
; store free variables start address
; in EEPROM 
; UPDAT-VP ( -- )
;----------------------------------
	.word LINK
	LINK=.
	.byte 8 
	.ascii "UPDAT-VP" 
UPDATVP:
	call VPP   
	call AT    ; ( adr -- )
	call EEPVP  ; ( adr ee_adr -- )
	jp STORE
	
;-----------------------------
; move interrupt sub-routine
; in flash memory
;----------------------------- 
    _HEADER IFMOVE,6,"IFMOVE"

    ret 

;------------------------------------------
; adjust pointers after **FMOVE** operetion.
; UPDAT-PTR ( cp+ -- )
; cp+ is new CP position after FMOVE 
;-------------------------------------------
    _HEADER UPDATPTR,9,"UPDAT-PTR"

    ret 

;--------------------------
; move new colon definition to FLASH 
; using WR-ROW for efficiency 
; preserving bytes already used 
; in the current block. 
; At this point the compiler as completed
; in RAM and pointers CP and CNTXT updated.
; CNTXT point to nfa of new word and  
; CP is after compiled word so CP-CNTXT+2=count to write 
; 
; FMOVE ( -- cp+ )
; 
;--------------------------
	_HEADER FMOVE,5,"FMOVE"

    ret

;------------------------------
; all interrupt vector with 
; an address >= a are resetted 
; to default
; CHKIVEC ( a -- )
;------------------------------
    _HEADER CHKIVEC,7,"CHKIVEC"

    ret 

.if 0
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

;-----------------------------------
; write integer in FLASH|EEPROM|OPT 
; EE! ( n u -- )
;----------------------------------
	_HEADER STORE,3,"EE!"

    ret 
.endif 
