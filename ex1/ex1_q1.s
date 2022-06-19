.text		# start Instructions
.global main	         

main:		          
    jal readswitches    # reads current value represented switches  
    add $2, $1, $0      # adds the value of readswitches and stores it in $2
    jal writessd        # write the value of $2 to SSD 
    j main              # loop again
