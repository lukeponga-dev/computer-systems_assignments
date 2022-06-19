.text
.global main

#  main entry instructions
main:
	# Stack Frame
	subui $sp, $sp, 1		# Create stack frame
	sw $ra, 0($sp)			# Save $ra
	
	# CPU Control instructions
	movsg $2, $cctrl		# Copy the current value of $cctrl into $2
	andi $2, $2, 0x000F		# Mask (disable) all interrupts
	ori $2, $2, 0xCD		# Enable IRQ2, IRQ3 and IE (global interrupt enable)
	movgs $cctrl, $2		# Copy the new CPU control value back to $cctrl
	
	# Interrupt handler instructions
	movsg $2, $evec 			# Copy the old handler's address to $2
	sw $2, old_vector($0)		# Save it to memory
	la $2, handler 				# Get the addres of handler
	movgs $evec, $2	 			# Copy the new address of the handler into $evec
	
	# Programmable Timer Instructions 
	sw $0, timerInterrupt_reg($0)	# Acknowledge any outstanding interrupts
	addui $2, $0, 2400				# put out count value into the timer load reg
	sw $2, timerLoad_reg($0)		# Save it to the timer load register 
	addui $2, $0, 0x2				# Enable the timer and set auto-restart mode
	sw  $2, timerControl_reg($0)	# Save it to the timer control register
	
	# Parrallel Instructions
	sw $0, parallel_interrupt($0)	# Acknowledge any outstanding interrupts
	addui $2, $0, 0x3				# Enable the parrallel control interrupt
	sw $2, parallel_control($0)		# Save it to the parrallel control register
	
loop:
	lw $7,   terminate($0)	# Check if termination flag is set
	beqz $7, exit			# If so, exit
	lw $3, counter($0) 		# Load counters value into $3
		
# write counter to SSD
	remui $5, $3, 10		# lower right SSD
	sw $5, writessd_lr($0)	# Save value
	divui $3, $3, 10		# Go to next digit
	remui $5, $3, 10		# lower left SSD
	sw $5, writessd_ll($0)	# Save value 
	divui $3, $3, 10		# go to next digit		
	remui $5, $3, 10		# upper right SSD
	sw $5, writessd_ur($0)	# Save value
	divui $3, $3, 10		# go to next digit
	remui $5, $3, 10		# upper left SSD
	sw $5, writessd_ul($0)	# Save value
		
	j loop		# loop
exit:
	lw $ra, 0($sp)		#  Load the $ra
	addui $sp, $sp, 1	# Destroy Stack frame
	jr $ra				# return

####################################	
# Interrupts and Exception Handler #
####################################
handler:
	# IRQ2 Interrupt
	movsg $13, $estat		# Get the cause of interrupt
	andi $13, $13, 0x40		# Check if interrupt was caused by the timer IRQ2
	bnez $13, handle_irq2	# No other interrupt happened, the timer caused it
	# IRQ3 Interrupt
	movsg $13, $estat		# Get the cause of interrupt
	andi $13, $13, 0x80		# Check if the interrupt is because of the parallel IO
	bnez $13, handle_irq3	# No other interrupt happened, the parallel IO caused it
	lw $13, old_vector($0)	# load default handler, that we saved earlier 
	jr $13				# stop counting
handle_irq2:
	sw $0, timerInterrupt_reg($0)	# Acknowledge the IRQ2 interrupt
	lw $13, counter($0)				# Load counter from memory
	addui $13, $13, 1				# Increment counter by 1
	sw $13, counter($0)				# Save new counter value to memory
	rfe				# return from interrupt
handle_irq3:
	sw $0, parallel_interrupt($0)	# Acknowledge the IRQ3 interrupt
	lw $13, parallel_btn($0)		# Check if buttons pushed
	beqz $13, irq3_return			# If not, return 
	
	lw  $13, parallel_btn($0)   # Load the value of the push button
	seqi $13, $13, 0x2			# middle button pushed 
	bnez $13, irq3_resume 		# If so, start/pause the counter
	lw $13, parallel_btn($0)	# Load the value of the push button
	seqi $13, $13, 0x1  		# rightmost button pushed 
	bnez $13, irq3_reset   		# If so, reset the counter
	lw $13, parallel_btn($0)    # Load the value of the push button
	seqi $13, $13, 0x4			# Leftmost button pushed 
	bnez $13, irq3_terminate 	# If so, terminate the counter
	
irq3_resume:
# Toggle the timer
	lw $13, timerControl_reg($0)	# Load the current value of the programmable timer control
	xori $13, $13, 0x1		# Use exclusive OR to toggle the interrupt enable
	sw $13, timerControl_reg($0)   # Save it to the timer control
	
	rfe                        	# Return from exception
	
irq3_reset:
# Reset the counter to 0
	lw $13, timerControl_reg($0)	# Load the value of the timer control
	seqi $13, $13, 0x3         	# Check if the bits are set
	bnez $13, irq3_return   	# If so, counter is incrementing
	sw $0, counter($0)   		# If not, reset the counter
	
irq3_return:
	rfe				# Return from exception
	
irq3_terminate:
	sw $0, terminate($0)		# Initialize termination flag
	rfe
###########################################################################

.data
# Programs counter value
counter: .word 0

.bss
old_vector: .word
terminate: .word
#############################
# Declare program constants #
#############################

# timer # 
.equ timerControl_reg,	0x72000   
.equ timerLoad_reg,	0x72001   
.equ timerCount_reg,	0x72002   
.equ timerInterrupt_reg, 0x72003  

# Parallel # 
.equ parallel_btn, 	0x73001
.equ parallel_control,	0x73004
.equ writessd_ul,	0x73006
.equ writessd_ur,	0x73007
.equ writessd_ll,	0x73008
.equ writessd_lr,	0x73009
.equ parallel_interrupt, 0x73005
