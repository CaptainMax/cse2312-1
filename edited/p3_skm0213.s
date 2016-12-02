/******************************************************************************
 * @file rand_array.s
 \_num:
 PUSH {LR}
 LDR R1, =
 LDR R0, =minVal
 MOV R1,
 BL _printVals
 LDR R0, =maxVal
 BL _printVals
 CMP R0, #0
 BEQ _setMinMax
 BL _changeMinMax
 _printValsD. McMurrough
 ******************************************************************************/

.global main
.func main

main:
    BL _seedrand
    BL _arrayMake

_setMinMax:
    MOV R5, R2
    MOV R6, R2
    MOV PC, LR

_changeMax:
    MOV R6, R2
    MOV PC, LR

_changeMin:
    MOV R5, R2
    MOV PC, LR

_changeMinMax:
    CMP R2, R5
    BLT _changeMin
    CMP R2, R6
    BGT _changeMax
    MOV PC, LR

_arrayMake:
    PUSH {LR}
    MOV R0, #0              @ initialze index variable
writeloop:

    CMP R0, #10             @ check to see if we are done iterating
    BEQ writedone           @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    PUSH {R0}               @ backup iterator before procedure call
    PUSH {R2}               @ backup element address before procedure call
    BL _getrand             @ get a random number


    POP {R2}                @ restore element address
    STR R0, [R2]            @ write the address of a[i] to a[i]
    POP {R0}                @ restore iterator
    ADD R0, R0, #1          @ increment index
    B   writeloop           @ branch to next loop iteration
writedone:
    MOV R0, #0              @ initialze index variable
readloop:
    CMP R0, #10             @ check to see if we are done iterating
    BEQ readdone            @ exit loop if done
    LDR R1, =a              @ get address of a
    LSL R2, R0, #2          @ multiply index*4 to get array offset
    ADD R2, R1, R2          @ R2 now has the element address
    LDR R1, [R2]            @ read the array at address
    PUSH {R0}               @ backup register before printf
    PUSH {R1}               @ backup register before printf
    PUSH {R2}               @ backup register before printf
    MOV R2, R1              @ move array value to R2 for printf
    MOV R1, R0              @ move array index to R1 for printf

    BL  _printf             @ branch to print procedure with return
    POP {R2}                @ restore register
    POP {R1}                @ restore register
    POP {R0}                @ restore register
    ADD R0, R0, #1          @ increment index
    B   readloop            @ branch to next loop iteration
readdone:
    BL _minMax
    B _exit                 @ exit if done

_minMax:
    PUSH {LR}
    LDR R0, =minVal
    MOV R1, R5
    BL printf
    MOV R1, R6
    LDR R0, =maxVal
    BL printf
    POP {PC}

_exit:
    MOV R7, #4              @ write syscall, 4
    MOV R0, #1              @ output stream to monitor, 1
    MOV R2, #21             @ print string length
    LDR R1, =exit_str       @ string at label exit_str:
    SWI 0                   @ execute syscall
    MOV R7, #1              @ terminate syscall, 1
    SWI 0                   @ execute syscall

_printf:
    PUSH {LR}               @ store the return address
    LDR R0, =printf_str     @ R0 contains formatted string address
    BL printf               @ call printf
    POP {PC}                @ restore the stack pointer and return

_seedrand:
    PUSH {LR}               @ backup return address
    MOV R0, #0              @ pass 0 as argument to time call
    BL time                 @ get system time
    MOV R1, R0              @ pass sytem time as argument to srand
    BL srand                @ seed the random number generator
    POP {PC}                @ return

_getrand:
    PUSH {LR}               @ backup return address
    BL rand                 @ get a random number
    POP {PC}                @ return

_mod_unsigned:
    cmp R2, R1          @ check to see if R1 >= R2
    MOVHS R0, R1        @ swap R1 and R2 if R2 > R1
    MOVHS R1, R2        @ swap R1 and R2 if R2 > R1
    MOVHS R2, R0        @ swap R1 and R2 if R2 > R1
    MOV R0, #0          @ initialize return value
    B _modloopcheck     @ check to see if
    _modloop:
    ADD R0, R0, #1  @ increment R0
    SUB R1, R1, R2  @ subtract R2 from R1
    _modloopcheck:
    CMP R1, R2      @ check for loop termination
    BHS _modloop    @ continue loop if R1 >= R2
    MOV R0, R1          @ move remainder to R0
    MOV PC, LR          @ return

.data

.balign 4
a:              .skip       100
printf_str:     .asciz      "a[%d] = %d\n"
prompt_str:     .asciz      "ENTER SEARCH VALUE: "
minVal:         .asciz      "MINIMUM VALUE = %d\n"
maxVal:         .asciz      "MAXIMUM VALUE = %d\n"
exit_str:       .ascii      "Terminating program.\n"
