/******************************************************************************************************
 * @file final_skm0213.s
 * @author Satej Mhatre
 * Code snippets are taken from: Christopher D. McMurrough from http://github.com/cmcmurrough/cse2312
 *
 *
 * **NOTE**: I have not returned back to the main function using PUSH {LR} and POP {PC}, which is the conventional way,
 *      because when I try to do that, the program prints 0.0 as the output in alternate runs.
        For example,
        With PUSH {LR} and POP {PC}:
        9
        i
        0.111111
        9
        i
        0.000000
        9
        i
        0.111111
        
        But, without PUSH {LR} and POP {PC},
         9
         i
         0.111111
         9
         i
         0.111111
         9
         i
         0.111111
         9
         i
         0.111111
        
        I have tried debugging it and added extra Pushes and Pops for R1 and R2, but it gives me the same result.
        I have made sure that this program will not cause a stack overflow because of incorrect pushing and popping.
 ******************************************************************************************************/

.global main
.func main

main:
    BL  _getFloat           @ get the float value from the user
    MOV R4, R0              @ store recieved value in R4
    BL  _getchar            @ get the character value from the user
    MOV R5, R0              @ store recieved value in R5
    MOV R1, R4              @ Prepare the input argument 1 for passing to _check_char
    MOV R2, R5              @ Prepare the input argument 2 for passing to _check_char
    BL _check_char          @ Go to _check_char
    VMOV S1, S0
    BL _printf
    BL  _printf_result      @ print the result
    B main

_printf:
    PUSH {LR}
    VCVT.F64.F32 D1, S1     @ covert the result to double precision for printing
    VMOV R1, R2, D1         @ split the double VFP register into two ARM registers
    BL _printf_result
    POP {PC}

_printf_result:
    PUSH {LR}
    LDR R0, =result_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}

_getFloat:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return


_getchar:
    PUSH {LR}
    MOV R7, #3              @ write syscall, 3
    MOV R0, #0              @ input stream from monitor, 0
    MOV R2, #1              @ read a single character
    LDR R1, =read_char      @ store the character in data memory
    SWI 0                   @ execute the system call
    LDR R0, [R1]            @ move the character to the return register
    AND R0, #0xFF           @ mask out all but the lowest 8 bits
    POP {PC}


_scanf:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =format_str     @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return


_invalid_char:
    PUSH {LR}
    LDR R0,=invalid_str     @ string at label hello_str:
    BL printf               @ call printf, where R1 is the print argument
    POP {LR}

_getInt:
    PUSH {LR}               @ store LR since scanf call overwrites
    SUB SP, SP, #4          @ make room on stack
    LDR R0, =formatint_str  @ R0 contains address of format string
    MOV R1, SP              @ move SP to R1 to store entry on stack
    BL scanf                @ call scanf
    LDR R0, [SP]            @ load value at SP into R0
    ADD SP, SP, #4          @ restore the stack pointer
    POP {PC}                @ return

_abs:
    PUSH {LR}
    MOV R1, R1              @ redundant Mov
    VMOV S0, R1             @ move the value to floating point register
    VABS.F32 S2, S0         @ compute S2 = |S0|
    VMOV S0, S2
    POP {PC}

_square_root:
    PUSH {LR}
    VMOV S0, R1             @ move the numerator to floating point register
    VSQRT.F32 S2, S0        @ compute S2 = sqrt(S0)
    VMOV S0, S2
    POP {PC}

_find_pow:
    VMUL.F32 S4, S4, S1     @ multiply s4 by itself.
    ADD R3, R3, #1          @ increase the while loop counter by 1
    B _pow_start            @ branch to _pow_start
_pow:
    PUSH {LR}
    MOV R1, R1              @ getting the user float value input
    BL  _getInt             @ getting the user integer input for the pow function
    VMOV S1, R4             @ moving user float value input to S1
    MOV R1, R0              @ moving the returned value from user input integer to R1
    MOV R2, #1              @ initializing R2, which will be to store the pow value
    MOV R3, #0              @ initializing R3, which will the counter for the while loop
    VMOV S4, R2             @ moving the R2 value to S4
    VCVT.F32.U32 S4, S4     @ convert unsigned bit representation to single float
_pow_start:
    CMP R3, R1              @ check if counter < input integer
    BLT _find_pow           @ if less than, then multiply by float value
    BEQ _pow_finish         @ otherwise finish
_pow_finish:
    VMOV S0, S4
    POP {PC}

_inverse:
    PUSH {LR}
    MOV R0, #1              @ initialize numerator
    VMOV S0, R0             @ move the numerator to floating point register
    VMOV S1, R1             @ move the denominator to floating point register
    VCVT.F32.U32 S0, S0     @ convert unsigned bit representation to single float
    VDIV.F32 S2, S0, S1     @ compute S2 = S0 / S1
    POP {PC}


_check_char:
    PUSH {LR}
    CMP R2, #'a'            @ check if char value is a
    BEQ _abs                @ find absolute value if equal
    CMP R2, #'s'            @ check if char value is s
    BEQ _square_root        @ find sqrt value if equal
    CMP R2, #'p'            @ check if char value is p
    BEQ _pow                @ find power value if equal
    CMP R2, #'i'            @ check if char value is i
    BEQ _inverse            @ find inverse value if equal
    BNE _invalid_char       @ if an invalid character is entered
    POP {PC}


.data
read_char:      .ascii      " "
@%.7g is to print the floating point number without trailing zeros
result_str:     .asciz      "%.7g\n"
invalid_str:    .asciz      "Invalid input\n"
exit_str:       .ascii      "Terminating program.\n"
format_str:     .asciz      "%f"
formatint_str:  .asciz      "%d"
printf_str:     .ascii      "%f\n"
val1:           .float      1.000
