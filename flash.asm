;;;;;;;;;;;;;;;;;;;;;;;;;
; flash and 
; eeprom programming 
;;;;;;;;;;;;;;;;;;;;;;;;;


;-----------------------------------------
;  FD! ( d a -- )
;  store a double in FLASH || eeprom
;  'a' must be aligned on 32 bits boundary  
;-----------------------------------------
       _HEADER FDSTOR,3,"FD!"
       call unlock_iap  
1$:    bset FLASH_CR2,#FLASH_CR2_WPRG
       ldw y,x 
       ldw y,(y) ; write address 
       addw x,#CELLL 
       ld a,(x)
       ld (y),a 
       ld a,(1,x)
       ld (1,y),a 
       ld a,(2,x)
       ld (2,y),a 
       ld a,(3,x)
       ld (3,y),a 
       btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,. 
       addw x,#2*CELLL ; drop double 
       _lock_iap 
	   ret  

;---------------------------------
;   F!  ( w a -- )
;   store word in FLASH
;  IAP must be unlocked 
;----------------------------------
	_HEADER FSTOR,2,"F!"
	call unlock_iap 
	ldw y,x 
	ldw y,(y)
	ld a,(2,x)
	ld (y),a
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.  
	ld a,(3,x)
	ld (1,y),a 
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,. 
	addw x,#2*CELLL 
	_lock_iap 
	ret 

;---------------------------------
;  FC! ( b a -- )
; write byte to FLASH 
;---------------------------------	 
	_HEADER FCSTOR,3,"FC!"
	call unlock_iap  
	ldw y,x 
	ldw y,(y)
	ld a,(3,x)
	ld (y),a 
	btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,.
	addw x,#2*CELLL 
	_lock_iap 
	ret 

.IF 0 ;**************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ERASE   ( n -- )
; Erase EEPROM, FLASH memory BLOCK 
; if 1 <= n < 7  erase EEPROM block 
; if 64 <= n < 256 erase FLASH block 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        _HEADER ERASE,5,"ERASE"
		ldw y,x 
		ldw y,(y)
		_DROP
		ld  a,#FLASH_BLOCK 
		mul y,a  
		cpw y,#8*FLASH_BLOCK  
		jrmi 1$  
		addw y,#FLASH_BASE
		cpw y,#app_space
		jrmi 9$ ; protected   
		jra 2$
1$:     addw y,#EEPROM_BASE  
		cpw y,#128 
		jrmi 9$ ; EEROM block zero protected 
2$:     
		call unlock_iap 
		bset FLASH_CR2,#FLASH_CR2_ERASE
		clr (y)
		clr (1,y)
		clr (2,y)
		clr (3,y)
		btjf FLASH_IAPSR,#FLASH_IAPSR_EOP,. 
		_lock_iap 
9$:		
		RET 

.ENDIF ;**************************

.IF 0 ;****************************

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

.ENDIF ;***********************

;-----------------------------------
;  EEPROM  ( -- u )
; return EEPROM base address 
;-----------------------------------
	_HEADER EEPROM,6,"EEPROM"
    ldw y,#EEPROM_BASE
    JP	DPUSH 

;---------------------------------
; EEP-CNTXT ( -- u )
; return EEP_CNTXT pointer
;---------------------------------
;	_HEADER EEPCNTXT,9,"EEP-CNTXT"
EEPCNTXT:
	ldw y,#EEP_CNTXT  
	JP	DPUSH 

;----------------------------------
; EEP-RUN ( -- u )
; return EEP_RUN pointer
;-----------------------------------
;	_HEADER EEPRUN,7,"EEP-RUN"
EEPRUN:
	ldw y,#EEP_RUN 
	JP	DPUSH 

;------------------------------------
; EEP-CP ( -- u )
; return EEP_CP pointer 
;------------------------------------
;	_HEADER EEPCP,6,"EEP-CP"
EEPCP:
	ldw y,#EEP_CP  
	JP	DPUSH 

;------------------------------------
; EEP-VP ( -- u )
; return EEP_VP pointer 
;-------------------------------------
;	_HEADER EEPVP,6,"EEP-VP"
EEPVP:
	ldw y,#EEP_VP  
	JP	DPUSH 
	
;---------------------------------
; UPDAT-RUN ( a -- )
; update EEP_RUN 
; store autorun code address in 
; EEPROM 
;---------------------------------
;	_HEADER UPDATRUN,9,"UPDAT-RUN"
UPDATRUN: 
	ldw y, EEP_RUN
	cpw y,(x)
	jreq 9$ 
	call EEPRUN ; ( adr ee_adr -- )
	call FSTOR  
9$:	 
	ret 

;----------------------------------
; UPDAT-CNTXT ( -- )
; update EEP_CNTXT with UCNTXT 
; store link address of dictionary head 
; in EEPROM. 
;----------------------------------
;	_HEADER UPDATCNTXT,11,"UPDAT-CNTXT"
UPDATCNTXT:
	_ldyz UCNTXT 
	cpw y,EEP_CNTXT 
	jreq 9$ 
	call CNTXT 
	call AT      ; ( adr -- )
	call EEPCNTXT ; ( adr ee_adr -- )
	jp FSTOR 
9$: ret 

;---------------------------------
; UPDAT-CP ( -- )
; update EEP_CP with CP 
; store top FLASH address 
; in EEPROM 
;---------------------------------
;	_HEADER UPDATCP,8,"UPDAT-CP"
UPDATCP:
	_ldyz UCP 
	cpw y,EEP_CP
	jreq 9$
	call CPP 
	call AT     ; ( adr -- )
	call EEPCP  ; ( adr ee_adr -- )
	jp FSTOR 
9$: ret 

;----------------------------------
; UPDAT-VP ( -- )
; update EEP_VP  
; store top variables address
; in EEPROM 
;----------------------------------
;	_HEADER UPDATVP,8,"UPDAT-VP"
UPDATVP:
	_ldyz UVP 
	cpw y,#EEP_VP 
	jreq 9$ 
	call HERE    
	call EEPVP  ; ( adr ee_adr -- )
	jp FSTOR
9$: ret 

;---------------------------------
;  UPDAT-EEPTR ( -- )
;  update system pointers saved 
;  in EEPROM 
;----------------------------------
	_HEADER UPDATPTR,11,"UPDAT-EEPTR"
	call UPDATCNTXT 
	call UPDATCP 
	call UPDATVP 
	ret 

;----------------------------
;  FCPY ( src dest cnt -- )
;  copies 'cnt' bytes to 
;  FLASH || EEPROM
;----------------------------
SRC=1  ; source address 
DEST=3  ; destination address 
CNT=5  ; bytes count
VSIZE=6 ; local variables space on stack  
	_HEADER FCPY,4,"FCPY"
	ldw y,x
	ldw y,(y) ; CNT 
	jrne 0$
; CNT==0 drop and leave 
	addw x,#3*CELLL 
	jp 10$ 
0$: ; push arguments on R: SRC DEST CNT  
	pushw y ; R: CNT  
	ldw y,x 
	ldw y,(2,y)
	pushw y  ; R: CNT DEST 
	ldw y,x 
	ldw y,(4,y) 
	pushw y ; R: CNT DEST SRC
	addw x,#3*CELLL ; drop parameters now on R:   
1$: ; copy loop 
	ldw Y, (CNT,sp)
	jreq 9$  ; nothing left, done 
	cpw y,#4
	jrmi 3$ 
; CNT>=4 
	ld a,(DEST+1,SP)
	and a,#3 
	jrne 3$
	subw x,#3*CELLL 
; push a double from SRC 
	ldw y,(SRC,SP) ; addr 
	ldw y,(y) ; high word  
	ldw (2,x),y 
	ldw y,(SRC,SP)
	ldw y,(2,Y) ; low word 
	ldw (4,x),y
; push DEST 	
	ldw y,(DEST,sp)
	ldw (x),y 
	call FDSTOR 
; increment SRC,DEST	
	ldw y,(SRC,SP)
	addw y,#4 
	ldw (SRC,SP),Y 
	ldw Y,(DEST,SP)
	addw y,#4 
	ldw (DEST,SP),Y 
; decrement CNT 	
	ldw y,(CNT,SP) 
	subw y,#4 
	ldw (CNT,SP),Y 
	jra 1$
3$: ; DEST not aligned or less than 4 bytes left  
	subw x,#2*CELLL 
	ldw y,(SRC,SP)
	ld a,(y)
	clrw y 
	ld yl,a 
	ldw (2,x),y  
	ldw y,(DEST,sp) 
	ldw (x),y 
	call FCSTOR 
	ldw y,(SRC,SP)
	incw y 
	ldw (SRC,SP),Y 
	ldw y,(DEST,SP)
	incw y 
	ldw (DEST,SP),Y 
	ldw y,(CNT,SP)
	decw y 
	ldw (CNT,SP),Y 
	jra 1$
9$:	
	addw sp,#VSIZE ; drop local variables 
10$:
	ret 
