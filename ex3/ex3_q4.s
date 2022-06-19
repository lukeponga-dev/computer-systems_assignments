.global main
.text
main:
			jal serial_job
			jal parallel_job
    		bnez $1, close          # Check if parallel_job returns a value greater than 0
    		j main                  # If not, keep program running
close:	
			syscall					# End program

##-------------serial_job----------------##
serial_job:
			subui $sp, $sp, 1		# create stack frame
			sw $ra, 0($sp)			# save return address
			lw $13, 0x70003($0)		# get the 1st serial port status
			andi $13, $13, 0x1		# check if the RDR bit is set
			beqz $13, end_serial	# If not, loop and try again
			lw $11, 0x70001($0)		# Get the character into $9
check:
			slei $10, $11, 0x60		# Check if the character <= 'a' 
			sgei $12, $11, 0x7B		# Check if the character >= 'A' 
			xor $12, $10, $12		# check which is true
			beqz $12, transmit		# If character is lowercase, transmit it
			addi $11, $0, 42 		# Get the character '*' if its anything else
transmit:
			lw $13, 0x70003($0)	
			andi $13, $13, 0x2		# check if the TDS bit is set
			beqz $13, end_serial	# If not, loop and try again
			sw $11, 0x70000($0)		# send character to 1st serial port
end_serial:
			lw $ra, 0($sp)          # Restore the return address
			addui $sp, $sp, 1       # Destroy the stack frame
			jr $ra                  # Return to main

##-------------parallel_job-----------------##
parallel_job:
			subui $sp, $sp, 1       # Create the stack frame
			sw $ra, 0($sp)          # save return address to the stack
			add $1, $0, $0          # Set return value to 0
			lw $2, 0x73001($0)		# Load the value for pushed buttons
			ori $2, $2, 0           # check if any buttons have been pressed
			beqz $2, end_parallel	# Checks to see if not 0, loop until not 0
			lw $3, 0x73000($0)		# Read the switches value
	
check_buttons:
			andi $4, $2, 0x1		# rightmost button has been pressed
			bnez $4, leds			# If value is 1, break to leds
			andi $4, $2, 0x4		# leftmost button pushed set value 1
			bnez $4, set_close		# If value in register $4 is 1, jump to end
invert:
			xori $3, $3, 0xFFFF		# If middle buttion pressed, invert the swtich value
leds:                
			remui $5, $3, 4        # Checks if the switch value is a multiple of 4
			beqz $5, on_lights     # If true, break to the lights label 
			sw $0, 0x7300A($0)     # If not, keep them off
			j write
on_lights:  
			addi $6, $0, 0xFFFF    # Set all LED register bits to '1'     
			sw $6, 0x7300A($0)     # sends value to turn on lights
write:            
			sw $3, 0x73009($0)		# Write to lower right SSD
			srli $3, $3, 4			# Shift right				
			sw $3, 0x73008($0)		# Write to lower left SSD
			srli $3, $3, 4
			sw $3, 0x73007($0)		# Write to upper right SSD
			srli $3, $3, 4
			sw $3, 0x73006($0)		# Write to upper left SSD
end_parallel:
			lw $ra, 0($sp)          # Restore return address
			addui $sp, $sp, 1       # Destroy stack frame
			jr $ra                  # Return to main
set_close:
			addui $1, $0, 1         # Set return value to 1
			j end_parallel          # End Task
