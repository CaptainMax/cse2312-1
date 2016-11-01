/******************************************************************************
* @file procedure_call_parameters.s
* @brief procedure call and return example with passed parameters
*
* Simple example of executing a procedure call and returning upon completion.
* The procedure call expects 3 input parameters, and returns a value.
*
* @author Christopher D. McMurrough
******************************************************************************/
 
.global main
.func main
   
main:
    BL  _getint
    MOV R4, R0
    BL  _getchar            @ branch to scanf procedure with return
    MOV R5, R0
    BL  _getint
    MOV R6, R0
    BL  _check_char
	MOV R1, R0              @ copy return value to R1
	BL  _print_val          @ print value stored in R1
	B   main                @ loop to main procedure with no return

_exit:  
	MOV R7, #4              @ write syscall, 4
	MOV R0, #1              @ output stream to monitor, 1
	MOV R2, #21             @ print string length
	LDR R1,=exit_str        @ string at label exit_str:
	SWI 0                   @ execute syscall
	MOV R7, #1              @ terminate syscall, 1
	SWI 0                   @ execute syscall

_invalid_char:
	LDR R0,=result_str      @ string at label hello_str:
	BL printf               @ call printf, where R1 is the print argument
    MOV PC, R7

_check_char:
    MOV R7, LR
    CMP R5, #'+'
    BEQ _sum
    CMP R5, #'-'
    BEQ _diff
    CMP R5, #'*'
    BEQ _mul
    CMP R5, #'M'
    BEQ _max
    BNE _invalid_char
    MOV PC, LR

_sum:
	MOV R0, R1              @ copy input register R1 to return register R0
	ADD R0, R2              @ add input register R2 to return register R0
	MOV PC, R7              @ return

_diff:
    MOV R0, R1
    SUB R0, R2
    MOV PC, R7

_mul:
    MOV R0, R1
    MUL R0, R2
    MOV PC, R7

_left_is_bigger:
    MOV R4, LR
    LDR R0, =val_str
    BL printf
    MOV PC, R4

_right_is_bigger:
    MOV R4, LR
    LDR R0, =val_str
    MOV R1, R8
    BL printf
    MOV PC, R4

_max:
    CMP R1, R8
    BGT _left_is_bigger
    BLT _right_is_bigger
    BEQ _left_is_bigger
    MOV PC, R7

_getchar:
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    MOV PC, LR              @ return

_getint:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =input          @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return
   
_print_val:
	MOV R4, LR              @ store LR since printf call overwrites
	LDR R0,=result_str      @ string at label hello_str:
	BL printf               @ call printf, where R1 is the print argument
	MOV LR, R4              @ restore LR from R4
	MOV PC, LR              @ return

_prompt:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #23             @ print string length
    LDR R1, =prompt_str     @ string at label prompt_str:
    SWI 0                   @ execute syscall
    MOV PC, LR              @ return
   
.data
read_char   :      .ascii      " "
prompt_str  :      .ascii      "Enter first operand: "
add_str     :      .ascii      "Adding numbers...\n"
val_str     :      .ascii      "%d\n"
result_str  :      .asciz      "Sum = %d\n"
exit_str    :      .ascii      "Terminating program.\n"
input       :      .asciz      "%d"
