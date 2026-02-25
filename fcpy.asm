;-----------------------------------------
;  FD! ( d a -- )
;  store a double in FLASH || eeprom
;  'a' must be aligned on 32 bits boundary  
;-----------------------------------------
       _HEADER FDSTOR,3,"FD!"
       ld a,FLASH_IAPSR 
       and a,#(1<<FLASH_IAPSR_DUL)|(1<<FLASH_IAPSR_PUL)
       cp a,#(1<<FLASH_IAPSR_DUL)|(1<<FLASH_IAPSR_PUL)
       jreq 1$
       jp iap_locked 
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
       ret  



;----------------------------
;  FCPY ( src dest cnt -- )
;  copies 'cnt' bytes to 
;  FLASH || EEPROM
;  in 4 bytes chunk
;  'cnt' is multiple of 4  
;  'dest' must be aligned to 
;  32 bits address.
;----------------------------
CHUNK=4 ; 4 bytes chunk 
SRC=1  ; source address 
DEST=3  ; dest address 
CNT=5  ; bytes count
VSIZE=6 ; local variables space on stack  
	_HEADER FCPY,4,"FCPY"
	CALL unlock_iap  
	ldw y,x
	ldw y,(y)
	pushw y ; CNT  
	ldw y,x 
	ldw y,(2,y)
	pushw y  ; DEST 
	ldw y,x 
	ldw y,(4,y)
	pushw y ; SRC
	addw x,#3*CELLL 
1$: ldw Y, (CNT,sp)
	jreq 9$ 
	ldw y,(SRC,SP)
	decw x 
	ld a,(y)
	ld (x),a 
	ld a,(1,y)
	decw x 
	ld (x),a 
	ld a,(2,y) 
	decw x 
	ld (x),a 
	ld a,(3,y)
	decw x
	ld (x),a 
	addw y,#CHUNK ; increment source 
	ldw (SRC,SP),Y 
	ldw y,(CNT,SP)
	subw y,#CHUNK   ; decrement cnt 
	ldw (CNT,SP),Y 
	ldw y,(DEST,SP)
	subw x,#CELLL 
	ldw (x),y  
	addw y,#CHUNK  ;increment dest
	ldw (DEST,SP),Y 
	call FDSTOR 
	jra 1$
9$:	
	addw sp,#VSIZE ; drop local variables 
	call lock_iap 
	ret 

