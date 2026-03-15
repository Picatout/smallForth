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

