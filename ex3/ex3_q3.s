.text
.global main

main:
			lw $2, 0x73001($0) 		# Load the value for pushed buttons
			ori $2, $2, 0           # check if any buttons have been pressed
			beqz $2, main			# Checks to see if not 0, loop until not 0
			lw $3, 0x73000($0) 		# Read the switches value
	
check_buttons:
			andi $4, $2, 1			# rightmost button has been pressed
			bnez $4, leds			# If value is 1, break to leds
			andi $4, $2, 4			# leftmost button pushed set value 1
			bnez $4, end			# If value in register $4 is 1, jump to end
	
invert:
			xori $3, $3, 0xFFFF		# If middle buttion pressed, invert the swtich value
	
leds:                
			remui $5, $3, 4        # Checks if the switch value is a multiple of 4
			beqz $5, on_lights     # If true, break to the lights label 
			sw $0, 0x7300A($0)     # If not, keep them off
			j write

on_lights:  
			addi $6, $0, 0xFFFF		# Set all LED register bits to '1'     
			sw $6, 0x7300A($0)		# sends value to turn on lights
write:            
			sw $3, 0x73009($0)		# Write to lower right SSD
			srli $3, $3, 4			# Shift right				
			sw $3, 0x73008($0)		# Write to lower left SSD
			srli $3, $3, 4
			sw $3, 0x73007($0)		# Write to upper right SSD
			srli $3, $3, 4
			sw $3, 0x73006($0)		# Write to upper left SSD
			j main					# loop back to main
	
	
end:
			jr $ra                 # End program
