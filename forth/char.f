\ compile first character of token 
: CHAR  ( <string> ) 
    TOKEN COUNT DROP COUNT SWAP DROP ;

\ compile version 
: [CHAR] CHAR ; COMPILE-ONLY IMMEDIATE 
