DECIMAL 
FORGET LOAD_LINE 

\ load a single line 
\ from terminal 
\ b buffer 
\ c1 max count
\ c2 left  
: LOAD_LINE ( b c1 -- b++ c2 )
   CR
   DUP . ."  LEFT ? "
   QUERY 
   BEGIN  
      SWAP  \ c1 b 
      TOKEN NUMBER? WHILE  
      OVER C! 1+ 
      SWAP 1-
      DUP 0< IF ABORT THEN   
   REPEAT
   DROP SWAP  
; 

\ load buffer from data 
\ input on command line
\ b is buffer address 
\ c is byte count 
: LOAD_BUFF ( b c -- ) 
   BEGIN 
      LOAD_LINE 
      DUP
   WHILE
   REPEAT 
   2DROP 
; 

