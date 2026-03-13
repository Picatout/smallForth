\ push the first character of next stream token
: CHAR ( <string> -- c )
    TOKEN 1+ C@ 
; 

\ version to be used in ':' definition 
: [CHAR] ( <string> -- c )
    CHAR 
; IMMEDIATE COMPILE-ONLY 
