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
    ret 

lock_ee:
	bres FLASH_IAPSR,#FLASH_IAPSR_DUL
	bres FLASH_IAPSR,#FLASH_IAPSR_PUL 
	ret 

.if 0
;--------------------------------
; P!  ( u -- )
; initialize PTRH 
;---------------------------------
	_HEADER PTRSTORE,2,"P!"
    ldw y,x
    ldw y,(y)
    _stryz PTRH 
    addw x,#CELLL 
    ret 
.endif 

;---------------------------------
;   F!  ( w a -- )
;   store word in FLASH || EEPROM 
;----------------------------------
	_HEADER FSTORE,2,"F!"
	ldw y,x 
	ldw y,(y)
	ld a,(2,x)
	ld (y),a 
	ld a,(3,x)
	ld (1,y),a 
	addw x,#2*CELLL 
	ret 

;-----------------------------------
;  EEPROM  ( -- u )
; return EEPROM base address 
; as a double 
;-----------------------------------
	_HEADER EEPROM,6,"EEPROM"
    ldw y,#EEPROM_BASE
    subw x,#CELLL 
    ldw (x),y 
    ret

;---------------------------------
; EEP-LAST ( -- u )
; return APP_LAST pointer
;---------------------------------
	_HEADER EEPLAST,8,"EEP-LAST"
	subw x,#CELLL 
	ldw y,#APP_LAST 
	ldw (x),y 
	ret 

;----------------------------------
; EEP-RUN ( -- u )
; return APP_RUN pointer
;-----------------------------------
	_HEADER EEPRUN,7,"EEP-RUN"
	subw x,#CELLL 
	ldw y,#APP_RUN 
	ldw (x),y 
	ret 

;------------------------------------
; EEP-CP ( -- u )
; return APP_CP pointer 
;------------------------------------
	_HEADER EEPCP,6,"EEP-CP"
	subw x,#CELLL 
	ldw y,#APP_CP  
	ldw (x),y 
	ret 

;------------------------------------
; EEP-VP ( -- u )
; return APP_VP pointer 
;-------------------------------------
	_HEADER EEPVP,6,"EEP-VP"
	subw x,#CELLL 
	ldw y,#APP_VP  
	ldw (x),y 
	ret 

;----------------------------------
; UPDAT-LAST ( -- )
; update APP_LAST with LAST 
; store link address of dictionary head 
; in EEPROM 
;----------------------------------
	_HEADER UPDATLAST,10,"UPDAT-LAST"
	call CNTXT 
	call AT      ; ( adr -- )
	call EEPLAST ; ( adr ee_adr -- )
	jp FSTORE 

;---------------------------------
; UPDAT-RUN ( a -- )
; update APP_RUN 
; store autorun code address in 
; EEPROM 
;---------------------------------
	_HEADER UPDATRUN,9,"UPDAT-RUN"
	call EEPRUN ; ( adr ee_adr -- )
	jp FSTORE 
	
;---------------------------------
; UPDAT-CP ( -- )
; update APP_CP with CP 
; store top FLASH address 
; in EEPROM 
;---------------------------------
	_HEADER UPDATCP,8,"UPDAT-CP"
	call CPP 
	call AT     ; ( adr -- )
	call EEPCP  ; ( adr ee_adr -- )
	jp FSTORE 

;----------------------------------
; UPDAT-VP ( -- )
; update APP_VP  
; store top variables address
; in EEPROM 
;----------------------------------
	_HEADER UPDATVP,8,"UPDAT-VP"
	call HERE    
	call EEPVP  ; ( adr ee_adr -- )
	jp FSTORE
	
;----------------------------
;  FHERE ( -- a )
;  get top of FLASH 
;---------------------------
	_HEADER FHERE,5,"FHERE"
	ldw y,#UCP 
	ldw y,(y)
	subw x,#CELLL 
	ldw (x),y 
	ret 

;----------------------------
;  FALLOT ( n -- )
;  allocate n byte to code space 
;---------------------------
	_HEADER FALLOT,6,"FALLOT"
	CALL FHERE  
	CALL PLUS 
	CALL CPP 
	CALL STORE 
	JP UPDATCP 

;----------------------------
;   F, ( w -- )
; compile 16 bits integer to 
; top of FLASH 
;-----------------------------
	_HEADER FCOMMA,2,^/"F,"/
	CALL     FHERE
	CALL     DUPP
	CALL     CELLP   ;cell boundary
	CALL     CPP
	CALL     STORE
	CALL     FSTORE
	JP       UPDATCP 

;----------------------------
;   FC, ( c -- )
; compile byt to  
; top of FLASH 
;-----------------------------
	_HEADER FCCOMMA,2,^/"FC,"/
	CALL     FHERE
	CALL     DUPP
	CALL     ONEP   
	CALL     CPP
	CALL     STORE
	CALL     STORE
	JP       UPDATCP 

.if 0
;------------------------------------------
; UPDAT-PTR 
; update pointers kept in EEPROM
;-------------------------------------------
    _HEADER UPDATPTR,9,"UPDAT-PTR"
;update CONTEXT and LAST 
	call LAST
	call AT 
	call STORE 
	call UPDATLAST 
;update CP 
	call CPP 
	call STORE
	call UPDATCP 
	ret 
.endif 

;-----------------------------
; move interrupt sub-routine
; in flash memory
;----------------------------- 
    _HEADER IFMOVE,6,"IFMOVE"

    ret 

;--------------------------
; FMOVE ( -- )
; 
; move new definition to FLASH 
; using WR-ROW for efficiency 
; preserving bytes already used 
; in the current block. 
; At this point the compiler as completed
; in RAM and pointers CP and CNTXT updated.
; CNTXT point to nfa of new word in RAM and  
; CP is after last compile word so 
; CP-CNTXT+2=count to write 
;--------------------------
	_HEADER FMOVE,5,"FMOVE"
	CALL unlock_ee 
	CALL CNTXT 
	CALL AT     ; nfa 
	CALL CELLM  ; source address 
	CALL DUPP 
	CALL TOR  ; R: src, save to reset UVP 
	CALL HERE  
	CALL OVER
	CALL SUBB  ; src cnt  
	CALL DUPP 
	CALL TOR  ; R: src cnt,  save cnt to update UCP later 
	CALL CPP 
	CALL AT    ; src cnt dest  
	CALL SWAPP ; src dest cnt
	CALL CMOVE ; stack empty 
; update  CNTXT and UCP 
	CALL RFROM ; cnt  R: src 
	CALL CPP 
	CALL AT   ; cnt adr  
; set CNTXT to last NFA 	
	CALL DUPP 
	CALL CELLP ; cnt adr nfa  
	CALL CNTXT 
	CALL STORE ; -- cnt adr  
; update UCP 	
	CALL PLUS
	CALL CPP 
	CALL STORE ; CP point after last definition
; reset UVP 
	CALL RFROM ; src 
	CALL VPP  
	CALL STORE  ; RAM pointer restored 
	CALL UPDATVP 
	CALL UPDATCP 
	CALL UPDATLAST 
	call lock_ee 
	RET 

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
