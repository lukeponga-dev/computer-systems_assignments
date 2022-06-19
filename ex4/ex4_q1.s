.text
.global main

# Programs main entry
main:
	# CPU Control Register
	movsg $2, $cctrl	# Copy the current value of $cctrl into $2
	andi $2, $2, 0x000F	# Mask (disable) all interrupts
	ori $2, $2, 0xAD	# Enable IRQ1, IRQ3 and IE (global interrupt enable)
	movgs $cctrl, $2	# Copy the new CPU control value back to $cctrl
		
	# Interrupt handler
	movsg $2, $evec 		# Copy the old handler's address to $2
	sw $2, old_vector($0)	# Save it to memory
	la $2, handler 			# Get the addres of handler
	movgs $evec, $2			# Copy the new address of the handler into $evec
		
	# Parrallel interrupt	
	addui $13, $0, 0x3				# Enable parrallel control interrupt
	sw $13, parallel_control($0)	# Save it to the parrallel control register

loop:
	lw $3, counter($0) 	# Load counters value into $3
		
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
		
	j loop			# loop
handler:
# IRQ1
	movsg $13, $estat		# get the cause of interrupt
	andi  $13, $13, 0x20	# Check if interrupt was caused by the user interrupt button
	bnez  $13, handle_irq1	# No other interrupt happened, the user interrupt button caused it
#IRQ3	
	movsg $13, $estat		# Get the cause of the interrupt
	andi $13, $13, 0x80		# Check if the interrupt was caused by the parallel push buttons
	bnez $13, handle_irq3	# No other interrupt happened, the parallel push button caused it
	lw $13, old_vector($0)	# Otherwise, jump to the default handler, that we saved earlier 
	
	jr $13	# return
	
handle_irq1:
	sw $0, 0x7F000($0) 		# Acknowledge the user interrupt	
	lw $13, counter($0)   	# load the value from counter
	addi $13, $13, 1		# Increment counter by 1
	sw $13, counter($0)		# store counter value into $13
	rfe						# return from exception
handle_irq3:
	sw $0, parallel_interrupt($0)	# Acknowledge the Parallel interrupt			
	lw $13, parallel_btn($0)		# Load value from push buttons 
	beqz $13, exit_handle			# If no buttons pressed, exit interrupt
	lw $13, counter($0)				# Else load counters value
	addi $13, $13, 1				# Increment counter by 1
	sw $13, counter($0)				# store value of counter into $13
	
exit_handle:   
	rfe			# Return to the main program
#########################################################
.data
# Programs counter value
counter: .word 0

.bss
old_vector: .word 

#############################
# Declare program constants #
#############################
# Parallel # 
.equ parallel_interrupt,	0x73005
.equ parallel_btn, 		0x73001
.equ parallel_control,	0x73004
.equ writessd_ul,	0x73006
.equ writessd_ur,	0x73007
.equ writessd_ll,	0x73008
.equ writessd_lr,	0x73009
