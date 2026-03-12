\ check if a name is already in dictionary 
: EXIST? 
    TOKEN CONTEXT FIND ;
 
\ create a constant only if it doesn't already exist 
: CONST ( <name>  n -- )
    >IN
    @  
    EXIST?
    IF 
        ABORT" exist"  
    ELSE 
        DROP  
        >IN ! 
        CONSTANT 
    THEN 
; 

\ create a variable only if it doesn't already exist 
: VAR ( <name>  -- )
    >IN @ 
    EXIST?
    IF 
        ABORT" exist" 
    ELSE 
        DROP 
        >IN ! 
        VARIABLE 
    THEN 
; 

