.text
.global main

# main entry instructions
main:
# CPU Control
	movsg $2, $cctrl		# Copy the current value of $cctrl into $2
	andi $2, $2, 0x000F		# Mask (disable) all interrupts
	ori $2, $2, 0xCF		# Enable IRQ2 and IE (global interrupt enable)
	movgs $cctrl, $2		# Copy the new CPU control value back to $cctrl
		
# Interrupt handler
	movsg $2, $evec 		# Copy the old handler's address to $2
	sw $2, old_vector($0)	# Save it to memory
	la $2, handler 			# Get the addres of handler
	movgs $evec, $2			# Copy the new address of the handler into $evec
	
# Timer Instructions
	sw $0, timerInterrupt_reg($0)	# Acknowledge any outstanding interrupts
	addui $2, $0, 2400				# put out count value into the timer load reg
	sw $2, timerLoad_reg($0)		# save it to memory
	addui $2, $0, 0x3				# Enable the timer and set auto-restard mode
	sw $2, timerControl_reg($0)		# Save it to the timer control register
	
loop:
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
	
handler:
#IRQ2
	movsg $13, $estat		# get the cause of interrupt
	andi $13, $13, 0x40		# Check if interrupt was caused by the timer IRQ2
	bnez $13, handle_irq2	# No other interrupt happened, the timer caused it
	lw $13, old_vector($0)	# load default handler, that we saved earlier 
	
	jr $13		# stop counting
handle_irq2:
	sw $0, timerInterrupt_reg($0)	# Acknowledge the IRQ2 interrupt
	lw $13, counter($0)				# Load counter from memory
	addui $13, $13, 1				# Increment counter by 1
	sw $13, counter($0)				# Save new counter value to memory
	rfe			# return from interrupt
#########################################################
.data
# Programs counter value
counter: .word 0

.bss
old_vector: .word 
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
