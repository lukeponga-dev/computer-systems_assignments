.text
.global main
main:
	subui $sp, $sp, 3 	# setup stack frame
	sw $ra, 2($sp) 	# save return address	
	jal readswitches	# jump and link readswitches	
	andi $5, $1, 0xFF	# get least significant bits
	sw $5, 0($sp)		# initialize end	
	srli $4, $1, 8 	# shift right to get the most significant bits
	sw $4, 1($sp)		# initialize start	
	jal count
	
# return registers	
end:
	lw $5, 0($sp)
    	lw $4, 1($sp)
    	lw $ra, 2($sp) 
	addui $sp, $sp, 3   # destroy stack frame
   	jr $ra              # return
	
	

