.text		# start of .text instructions 
.global main 	# global main entry point

main:
	addi $3, $0, 0	     	# Initialise the swtich count to 0
	jal readswitches    	# read value of switches
	andi $4, $1, 0xFF   	# AND operation, store result in $4
	jal loopcounter     	# jump and link loopcounter label
	
loopcounter:
	beqz $4, encryption   	# If finshed counting encrypt counter
	addi $3, $3, 1      	# Increment counter by 1
	subi $5, $4, 1      	# subtract 1 from binary number
	and $4, $4, $5  	# perform another AND
	j loopcounter   	# continue counting 
	
encryption:
	lw $2, output($3)	# load output with count as pointer
	jal writessd		# display result to SSD
	j main			# loop back to main
	
.data
output:		 # output for encrypted data
	.word 0xA3	 # 0
	.word 0x22	 # 1	
	.word 0x6B	 # 2
	.word 0x0D	 # 3	
	.word 0x49	 # 4
	.word 0xC0	 # 5
	.word 0x7F	 # 6
	.word 0xB8	 # 7
	.word 0x31	 # 8		
