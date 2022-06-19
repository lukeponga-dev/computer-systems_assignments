# ##############
# Multitasking Kernel - kernel_q3.s
#
# Luke Ponga
###############

.global main
.text
main: 
# CPU Control Register
	movsg $2, $cctrl	        # Copy the current value of $cctrl into $2 
	andi $2, $2, 0x000F	# Mask (disable) all interrupts 
	ori $2, $2, 0x4F	        # Enable IRQ2,  IE (global interrupt enable)
	movgs $cctrl, $2	        # Copy the new CPU control value back to $cctrl
	
# Interrupt handler
	movsg $2, $evec 		# Copy the old handler's address to $2
	sw $2, old_vector($0)	# Save it to memory
	la $2, handler 			# Get the addres of handler
	movgs $evec, $2		# Copy the new address of the handler into $evec
	
# Timer Instructions
	sw $0, timerInterrupt_reg($0)	# Acknowledge any outstanding interrupts
	addui $2, $0, 24        			# put out count value into the timer load reg
	sw $2, timerLoad_reg($0)		# save it to memory
	addui $2, $0, 0x3				# Enable the timer and set auto-restard mode
	sw $2, timerControl_reg($0)		# Save it to the timer control register
	
        jal serial_main         # jump to serial main
        
handler:
	movsg $13, $estat		# get the cause of interrupt
	andi $13, $13, 0x40		# Check if interrupt was caused by the timer IRQ2
	bnez $13, handle_irq2		# No other interrupt happened, the timer caused it
	lw $13, old_vector($0)		# load default handler, that we saved earlier 
	jr $13					# stop counting
	
handle_irq2:
	sw $0, timerInterrupt_reg($0)	        # Acknowledge the IRQ2 interrupt
	lw $13, counter($0)	               		# Load counter from memory
	addui $13, $13, 1					# Increment counter by 1
	sw $13, counter($0)		        	# Save new counter value to memory
	rfe			                                  	# return from interrupt

.bss
old_vector: .word
###################
# Declare program constants #
###################
# timer # 
.equ timerControl_reg,	0x72000   
.equ timerLoad_reg,	0x72001   
.equ timerCount_reg,	0x72002   
.equ timerInterrupt_reg, 0x72003  

