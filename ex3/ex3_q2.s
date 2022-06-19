.text
.global main
	
# Programs entry point
main:
			lw $13, 0x70003($0)		# get the 1st serial port status
			andi $13, $13, 0x1		# check if the RDR bit is set
			beqz $13, main			# If not, loop try again
			lw $3, 0x70001($0)		# Get the character into $3
check:
			slei $4, $3, 0x60		# Check if less then or equals character 'a'  
			sgei $5, $3, 0x7B		# Check if the character >= 'A' 
			xor $6, $4, $5			# check which is true
			beqz $6, transmit		# If character is lowercase, transmit it
			addi $3, $0, 42 		# Get the character '*' if its anything else
transmit:
			lw $13, 0x70003($0)	
			andi $13, $13, 0x2		# check if the TDS bit is set
			beqz $13, transmit		# If not, loop and try again
			sw $3, 0x70000($0)		# send character to 1st serial port
			j main					# loop back and send another character
