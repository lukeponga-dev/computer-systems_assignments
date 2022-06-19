.text
.global main
				
# program entry point	         
main:
			addi $3, $0, 0      # Initialise the loop counter
			jal readswitches    # read value of switches '0' or '1'
			andi $4, $1, 0xFF   # AND operation, store result in $4
			jal count     # jump and link count label
count:      
			beqz $4, write		# if binary equals 0, loop to write label
			addi $3, $3, 1		# increment the loop counter by 1
			subi $5, $4, 1 		# subtract 1 from binary number
			and $4, $4, $5  	# perform another AND
			j count			   	# continue loop counter
write:
			add $2,$3, $0 		# store count in $2
			jal writessd		# Displays count to the SSD 
			j main				# loop to main 
