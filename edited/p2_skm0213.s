/******************************************************************************
*
* @file procedure_call_parameters.s, factorial.s, mod.s
* @brief Code source
*
* Recursive algorithm to find the gcd of two numbers
*
* @author Christopher D. McMurrough
******************************************************************************/
 
.global main
.func main
   
main:
    BL  _getint             @ getting first number
    MOV R1, R0              @ copy return value of getting first number to R1
    BL  _getint             @ getting second number
    MOV R2, R0              @ copy return value of getting second number to R2
    PUSH {R1}               @ backup input argument value
    PUSH {R2}               @ backup input argument value
    BL _gcd                 @ going to gcd label
    POP {R2}                @ restore input argument
    POP {R1}                @ restore input argument
    MOV R3, R0              @ copy return value of gcd to R2
    BL  _print_val          @ print value stored in R1, R2, R3
    B   main                @ loop to main procedure with no return

_gcd:
    PUSH {LR}               @ store the return address
    CMP R2, #0              @ compare the input argument to 1
    MOVEQ R0, R1            @ set return value to 1 if equal
    POPEQ {PC}              @ restore stack pointer and return if equal
                            @ recursive check condition
    PUSH {R1}               @ backup input argument value
    PUSH {R2}               @ backup input argument value
    BL _mod_unsigned        @ finding modulus
    MOV R1, R2              @ setting n1 to n2
    MOV R2, R0              @ setting n2 to n1%n2
    BL _gcd                 @ compute gcd with new args
    POP {R2}                @ restore input argument
    POP {R1}                @ restore input argument
    POP {PC}                @ restore the stack pointer and return
_mod_unsigned:
    cmp R2, R1              @ check to see if R1 >= R2
    MOVHS R0, R1            @ swap R1 and R2 if R2 > R1
    MOVHS R1, R2            @ swap R1 and R2 if R2 > R1
    MOVHS R2, R0            @ swap R1 and R2 if R2 > R1
    MOV R0, #0              @ initialize return value
    B _modloopcheck         @ check to see if
    _modloop:
        ADD R0, R0, #1          @ increment R0
        SUB R1, R1, R2          @ subtract R2 from R1

    _modloopcheck:
        CMP R1, R2              @ check for loop termination
        BHS _modloop            @ continue loop if R1 >= R2
    MOV R0, R1              @ move remainder to R0
    MOV PC, LR              @ return

_getint:
    PUSH {LR}               @ store LR since scanf call overwrites
    PUSH {R1}
    PUSH {R2}
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =input          @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {R2}
    POP {R1}
    POP {PC}                @ return

_print_val:
	MOV R4, LR              @ store LR since printf call overwrites
	LDR R0,=result_str      @ string at label hello_str:
	BL printf               @ call printf, where R1 is the print argument
	MOV LR, R4              @ restore LR from R4
	MOV PC, LR              @ return
   
.data
result_str  :      .asciz      "The GCD of %d and %d is %d\n"
input       :      .asciz      "%d"
