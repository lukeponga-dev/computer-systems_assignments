# ######################
# Multitasking Kernel - kernel_q6.s
#
# Luke Ponga
######################

.global main
.text
main: 
#Setting up Serial Task
	la $1, serial_pcb	        #load serial task pcb 
	la $2, parallel_pcb		#link parallel task
	sw $2, pcb_link($1)
	
	la $2, serial_stack		#set $sp to top of stack
	sw $2, pcb_sp($1)
	
	la $2, serial_main	        # setup serial task main
	sw $2, pcb_ear($1)	        # into ear
	sw $5, pcb_cctrl($1)	# set the $cctrl
	
# Settting up parallel task
	la $1, parallel_pcb             #load parallel task
	la $2, games_pcb              #link to games
	sw $2, pcb_link($1)
	
	la $2, parallel_stack        # set $sp to top of stack
	sw $2, pcb_sp($1)
	
	la $2, parallel_main		#setup parallel task main
	sw $2, pcb_ear($1)		#into ear
	sw $5, pcb_cctrl($1)	#set the $cctrl
	
#Setting up Games Task
	la $1, games_pcb	        #load parallel task
	la $2, serial_pcb	        #link to serial
	sw $2, pcb_link($1)
	
	la $2, games_stack	        #set $sp to top of stack	
	sw $2, pcb_sp($1)
	
	la $2, gameSelect_main     #set game select main
	sw $2, pcb_ear($1)		#into ear
	sw $5, pcb_cctrl($1)	 #set cctrl	
	
	la $1, serial_pcb		
	sw $1, current_task($0)	#load serial to current task
	
# Interrupt handler
	movsg $2, $evec 		# Copy the old handler's address to $2
	sw $2, old_vector($0)	# Save it to memory
	la $2, handler 			# Get the addres of handler
	movgs $evec, $2		# Copy the new address of the handler into $evec
	
# Timer Instructions
	sw $0, timerInterrupt_reg($0)	        # Acknowledge any outstanding interrupts
	addui $4, $0, 24        			# put out count value into the timer load reg
	sw $4, timerLoad_reg($0)		# save it to memory
	addui $4, $0, 0x3				# Enable the timer and set auto-restard mode
	sw $4, timerControl_reg($0)		# Save it to the timer control register
	j load_context                                     # load current task
	
handler:
	movsg $13, $estat			# get the cause of interrupt
	andi $13, $13, 0x40		# Check if interrupt was caused by the timer IRQ2
	bnez $13, handle_timer		# No other interrupt happened, the timer caused it
	lw $13, old_vector($0)		# load default handler, that we saved earlier 
	jr $13				        # stop counting

handle_timer:
# Handle the timer interrupt
	sw $0, timerInterrupt_reg($0)	# Acknowledge the IRQ2 interrupt
	lw $13, counter($0)	        # Load counter from memory
	addui $13, $13, 1			# Increment counter by 1
	sw $13, counter($0)		# Save new counter value to memory
	lw $13, taskSlice($0)	        # load timeSlice
	subi $13, $13, 1			# decrement by 1
	sw $13, taskSlice($0)		# Save taskSlice
	lw $13, taskSlice($0)	        # task Slice has finshed
	beqz $13, dispatcher		# If 0 go to dispatcher
	rfe			                         # return from interrupt 
dispatcher:	
save_context:	
	
	lw $13, current_task($0)       # Get the base address of the current task
	
# Save the registers 
	sw $1, pcb_reg1($13)          
	sw $2, pcb_reg2($13)
	sw $3, pcb_reg3($13)
	sw $4, pcb_reg4($13)
	sw $5, pcb_reg5($13)
	sw $6, pcb_reg6($13)
	sw $7, pcb_reg7($13)
	sw $8, pcb_reg8($13)
	sw $9, pcb_reg9($13)        
	sw $10, pcb_reg10($13)
	sw $11, pcb_reg11($13)        
	sw $12, pcb_reg12($13)
	sw $sp, pcb_sp($13)      
	sw $ra, pcb_ra($13)
	
	movsg $1, $ers                  # Get the old value of $13                                              
	sw $1, pcb_reg13($13)       #  save it to the pcb
	movsg $1, $ear                  # Save $ear
	sw $1, pcb_ear($13)           # save it to pcb
	movsg $1, $cctrl                # Save $cctrl
	sw $1, pcb_cctrl($13)         # save it to pcb

schedule:
	lw $13, current_task($0)	        #load current task
	lw $13, pcb_link($13)	        #get the link address
	sw $13, current_task($0)	#make the link the new current
	
load_context:
	lw $13, current_task($0)	        #load current task
	
	lw $1, pcb_reg13($13)	        #load the ers from it's pcb
	movgs $ers, $1
	
	lw $1, pcb_ear($13)	        #load it's old location
	movgs $ear, $1		        #(to start where it left off)
	
	lw $1, pcb_cctrl($13)	        #load $cctrl
	movgs $cctrl, $1		        #to for it's needed exceptions
	
	#load the current context (ALL REGISTERS)
	lw $1, pcb_reg1($13)
	lw $2, pcb_reg2($13)
	lw $3, pcb_reg3($13)
	lw $4, pcb_reg4($13)
	lw $5, pcb_reg5($13)
	lw $6, pcb_reg6($13)
	lw $7, pcb_reg7($13)
	lw $8, pcb_reg8($13)
	lw $9, pcb_reg9($13)
	lw $10, pcb_reg10($13)
	lw $11, pcb_reg11($13)
	lw $12, pcb_reg12($13)
	lw $sp, pcb_sp($13)
	lw $ra, pcb_ra($13)
	
timeSlice:
	addui $13, $0, 100		#set timeslice to 100 ticks
	sw $13, taskSlice($0)	#store it
	rfe					#return from exception
	
.data
taskSlice:               .word 0

.bss
old_vector:              .word
serial_pcb:     
                .space 18
	        .space 200        
serial_stack:
parallel_pcb:
                .space 18
                .space 200          
parallel_stack:
games_pcb:
	        .space 18
	        .space 200	        
games_stack:	
current_task:           .word


###################
# Declare program constants #
###################

#####
# pcb  #
#####
.equ	pcb_link,  0
.equ	pcb_reg1,  1 
.equ	pcb_reg2,  2
.equ	pcb_reg3,  3
.equ	pcb_reg4,  4
.equ	pcb_reg5,  5
.equ	pcb_reg6,  6 
.equ	pcb_reg7,  7
.equ	pcb_reg8,  8
.equ	pcb_reg9,  9
.equ	pcb_reg10, 10
.equ	pcb_reg11, 11
.equ	pcb_reg12, 12
.equ	pcb_reg13, 13
.equ	pcb_sp,    14
.equ	pcb_ra,    15
.equ	pcb_ear,   16
.equ	pcb_cctrl, 17
######
# timer #
###### 
.equ timerControl_reg,  0x72000   
.equ timerLoad_reg,     0x72001   
.equ timerCount_reg,    0x72002   
.equ timerInterrupt_reg,        0x72003  
