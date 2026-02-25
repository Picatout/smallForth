;--------------------------------
;; IAP unlocking is different 
;; from STM8S* MCU 
;--------------------------------

;-----------------------
; UNLOCK_IAP ( -- )
; unlock FLASH for 
; IAP programming 
;-----------------------
;	_HEADER unlock_iap,10,"UNLOCK-IAP"
unlock_iap: 
    sim 
	btjt FLASH_IAPSR,#FLASH_IAPSR_PUL,1$
	mov FLASH_PUKR,#FLASH_PUKR_KEY1
    mov FLASH_PUKR,#FLASH_PUKR_KEY2
1$:	btjt FLASH_IAPSR,#FLASH_IAPSR_DUL,2$
	mov FLASH_DUKR,#FLASH_DUKR_KEY1 
    mov FLASH_DUKR,#FLASH_DUKR_KEY2 
2$:	rim 
	ret 

.IF 0 ;*********************

;------------------------
; LOCK_IAP ( -- )
; lock  IAP 
; programming 
;------------------------
	_HEADER lock_iap,8,"LOCK-IAP"
	clr FLASH_IAPSR 
	ret 

.ENDIF ;*********************

