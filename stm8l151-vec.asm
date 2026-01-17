;;--------------------------------------
    .area HOME 
;; STM8L151    
;; interrupt vector table at 0x8000
;;--------------------------------------

    int reset  			    ; RESET vector 
	int NonHandledInterrupt ; trap instruction 
	int NonHandledInterrupt ;int0 reserved 
	int NonHandledInterrupt ;int1 FLASH    auto wake up from halt
	int NonHandledInterrupt ;int2 DMA1 0/1
	int NonHandledInterrupt ;int3 DMA1 2/3
	int NonHandledInterrupt ;int4 RTC 
	int NonHandledInterrupt ;int5 EXTI E/F/PVD
	int NonHandledInterrupt ;int6 EXTIB/G external interrupt B/G
	int NonHandledInterrupt ;int7 EXTID/H external interrupt D/H 
	int NonHandledInterrupt ;int8 EXTI0 extenal interrupt 0
	int NonHandledInterrupt ;int9 EXTI1 extenal interrupt 1
	int NonHandledInterrupt ;int10 EXTI2 
	int NonHandledInterrupt ;int11 EXTI3
	int NonHandledInterrupt ;int12 EXTI4
	int NonHandledInterrupt ;int13 EXTI5 
	int NonHandledInterrupt ;int14 EXTI6
	int NonHandledInterrupt ;int15 EXTI7
	int NonHandledInterrupt ;int16 LCD 
	int NonHandledInterrupt ;int17 CLK/TIM1/DAC 
	int NonHandledInterrupt ;int18 COMP1/COMP2/ADC1 
	int NonHandledInterrupt ;int19 TIM2 udpade/overflow/trigger/break 
	int NonHandledInterrupt ;int20 TIM2 capture/compare 
	int NonHandledInterrupt ;int21 TIM3 update/overflow/trigger/break 
	int NonHandledInterrupt ;int22 TIM3 capture/compare 
	int NonHandledInterrupt	;int23 TIM1 update/overflow/trigger/COM  
	int NonHandledInterrupt ;int24 TIM1 capture/compare 
	int NonHandledInterrupt ;int25 TIM4 update/overflow/trigger
	int NonHandledInterrupt ;int26 SPI1 TX buffer empty/RX buffer not empty/error/wakeup
	int NonHandledInterrupt ;int27 USART1 TX register empty/transmit completed 
	int UartRxHandler       ;int28 USART1 RX ready/error 
	int NonHandledInterrupt ;int29 I2C1 


