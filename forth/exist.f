

DECIMAL 
FORGET EXIST? 

\ check if a <name> is already in dictionary 
\ abort if already exist.
: EXIST? ( <name>  -- )
    >IN @ 
    TOKEN CONTEXT FIND IF
       ABORT" exist" 
    ELSE
        DROP 
        >IN !  
    THEN 
;
 
\ create a constant only if it doesn't already exist 
: CONST ( <name>  n -- )
    EXIST?
    CONSTANT 
; 

\ create a variable only if it doesn't already exist 
: VAR ( <name>  -- )
    EXIST?
    VARIABLE 
; 

\ enter compile mode only if <name> does not arleary exist.
: :? ( <name> -- )
    EXIST? 
    :  
;


