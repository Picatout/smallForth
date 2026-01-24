;;;;;;;;;;;;;;;;;;;;;;;;;
; stm8l151k6 flash and 
; eeprom programming 
;;;;;;;;;;;;;;;;;;;;;;;;;


;-----------------------
; UNLOCK_IAP ( -- )
; unlock FLASH for 
; IAP programming 
;-----------------------
	_HEADER unlock_iap,10,"UNLOCK-IAP"
    btjt FLASH_IAPSR,#FLASH_IAPSR_PUL,1$
	sim 
	mov FLASH_PUKR,#FLASH_PUKR_KEY1
    mov FLASH_PUKR,#FLASH_PUKR_KEY2
	mov FLASH_DUKR,#FLASH_DUKR_KEY1 
    mov FLASH_DUKR,#FLASH_DUKR_KEY2
	rim  
1$:	ret 

;------------------------
; LOCK_IAP ( -- )
; lock  IAP 
; programming 
;------------------------
	_HEADER lock_iap,8,"LOCK-IAP"
	clr FLASH_IAPSR 
	ret 

;---------------------------------
;   F!  ( w a -- )
;   store word in FLASH
;  IAP must be unlocked 
;----------------------------------
	_HEADER FSTOR,2,"F!"
	btjf FLASH_IAPSR,#FLASH_IAPSR_PUL,iap_locked 
write_word:
	ldw y,x 
	ldw y,(y)
	ld a,(2,x)
	ld (y),a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.  
	ld a,(3,x)
	ld (1,y),a 
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,. 
	addw x,#2*CELLL 
	ret 

;---------------------------------
;  FC! ( b a -- )
; write byte to FLASH 
;---------------------------------	 
	_HEADER FCSTOR,3,"FC!"
	btjf FLASH_IAPSR,#FLASH_IAPSR_PUL,iap_locked 
write_byte:
	ldw y,x 
	ldw y,(y)
	ld a,(3,x)
	ld (y),a 
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	addw x,#2*CELLL 
	ret 

;-------------------------
;  EE! ( w a -- )
;  store w in EEPROM 
;-------------------------
	_HEADER EESTOR,3,"EE!"
	btjf FLASH_IAPSR,#FLASH_IAPSR_DUL,iap_locked 
	jra write_word 

;------------------------
; EEC! ( b a -- )
;------------------------
	_HEADER EECSTOR,4,"EEC!"
	btjf FLASH_IAPSR,#FLASH_IAPSR_DUL,iap_locked 
	jra write_byte 

;-----------------------------------
; can't write to FLASH or EEPROM 
; In Application Programming locked 
;----------------------------------
iap_locked:
        call ABORQ
        .byte 19
        .ascii " failed! IAP locked"

;-----------------------------------
;  EEPROM  ( -- u )
; return EEPROM base address 
;-----------------------------------
	_HEADER EEPROM,6,"EEPROM"
    ldw y,#EEPROM_BASE
    subw x,#CELLL 
    ldw (x),y 
    ret

;---------------------------------
; EEP-CNTXT ( -- u )
; return EEP_CNTXT pointer
;---------------------------------
	_HEADER EPPCNTXT,9,"EEP-CNTXT"
	subw x,#CELLL 
	ldw y,#EEP_CNTXT  
	ldw (x),y 
	ret 

;----------------------------------
; EEP-RUN ( -- u )
; return EEP_RUN pointer
;-----------------------------------
	_HEADER EEPRUN,7,"EEP-RUN"
	subw x,#CELLL 
	ldw y,#EEP_RUN 
	ldw (x),y 
	ret 


;------------------------------------
; EEP-CP ( -- u )
; return EEP_CP pointer 
;------------------------------------
	_HEADER EEPCP,6,"EEP-CP"
	subw x,#CELLL 
	ldw y,#EEP_CP  
	ldw (x),y 
	ret 

;------------------------------------
; EEP-VP ( -- u )
; return EEP_VP pointer 
;-------------------------------------
	_HEADER EEPVP,6,"EEP-VP"
	subw x,#CELLL 
	ldw y,#EEP_VP  
	ldw (x),y 
	ret 

;---------------------------------
; UPDAT-RUN ( a -- )
; update EEP_RUN 
; store autorun code address in 
; EEPROM 
;---------------------------------
	_HEADER UPDATRUN,9,"UPDAT-RUN"
	call unlock_iap  
	call EEPRUN ; ( adr ee_adr -- )
	call EESTOR  
	call lock_iap 
	ret 

;----------------------------------
; UPDAT-CNTXT ( -- )
; update EEP_CNTXT with UCNTXT 
; store link address of dictionary head 
; in EEPROM. 
;----------------------------------
	_HEADER UPDATCNTXT,11,"UPDAT-CNTXT"
	call CNTXT 
	call AT      ; ( adr -- )
	call EPPCNTXT ; ( adr ee_adr -- )
	jp FSTOR 

;---------------------------------
; UPDAT-CP ( -- )
; update EEP_CP with CP 
; store top FLASH address 
; in EEPROM 
;---------------------------------
	_HEADER UPDATCP,8,"UPDAT-CP"
	call CPP 
	call AT     ; ( adr -- )
	call EEPCP  ; ( adr ee_adr -- )
	jp FSTOR 

;----------------------------------
; UPDAT-VP ( -- )
; update EEP_VP  
; store top variables address
; in EEPROM 
;----------------------------------
	_HEADER UPDATVP,8,"UPDAT-VP"
	call HERE    
	call EEPVP  ; ( adr ee_adr -- )
	jp FSTOR

;---------------------------------
;  UPDAT-EEPTR ( -- )
;  update system pointers saved 
;  in EEPROM 
;----------------------------------
	_HEADER UPDATPTR,11,"UPDAT-EEPTR"
	btjt FLASH_IAPSR,#FLASH_IAPSR_DUL,1$
	call unlock_iap  
1$:
	call UPDATCNTXT 
	call UPDATCP 
	call UPDATVP 
	call lock_iap   
	ret 
	
.IF 0 ;*********************

;----------------------------
;  FALLOT ( n -- )
;  allocate n byte to code space 
;---------------------------
	_HEADER FALLOT,6,"FALLOT"
	CALL CPP
	CALL AT   
	CALL PLUS 
	CALL CPP 
	CALL STORE 
	JP UPDATPTR 

;-----------------------------
; move interrupt sub-routine
; in flash memory
;----------------------------- 
    _HEADER IFMOVE,6,"IFMOVE"

    ret 

.ENDIF ;************************

;--------------------------
; FMOVE ( -- )
; 
; move new definition to FLASH 
; At this point the compiler as completed
; in RAM and pointers CP and CNTXT updated.
; CNTXT point to nfa of new word in RAM and  
; CP is after last compile word so 
; HERE-CNTXT+2=count to write 
;--------------------------
	_HEADER FMOVE,5,"FMOVE"
	CALL unlock_iap  
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
; update  CNTXT
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
	JP   UPDATPTR  

;------------------------------
; all interrupt vector with 
; an address >= a are resetted 
; to default
; CHKIVEC ( a -- )
;------------------------------
VECTOR_SIZE=4 
    _HEADER CHKIVEC,7,"CHKIVEC"
	call unlock_iap 
	ldw y,x 
	ldw y,(y)
	_stryz UTMP
	addw x,#CELLL ; drop a 
	pushw x 
	ldw x,#0x8000 
1$: 
	addw x,#VECTOR_SIZE  
    cpw x,#VECTOR_USART1_RX ; protected 
	jreq 1$ 
	cpw x,#VECTOR_TIM4 ; protected 
	jreq 1$  
	cpw x,#8080
	jreq 9$  ; done 
	ldw y,x   
	ldw y,(2,y) 
	cpw y,UTMP 
	jrmi 1$ 
	ldw  y,#NonHandledInterrupt
	ld (2,x),a 
	jra 1$
9$: popw x 
	call lock_iap 
	ret 

.IF 0 ;*******************

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

.ENDIF ;***********************
