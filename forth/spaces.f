\  print n spaces  
: SPACES ( n -- ) 
    BEGIN ?DUP WHILE SPC EMIT 1- REPEAT ; 
