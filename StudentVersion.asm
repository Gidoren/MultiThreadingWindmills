;External Windows API Functions
include Win64API.inc


                    .DATA

LF                  equ     10              ;new line
MAX_LENGTH          equ     30000
SHADOW_MEM          equ     32              ;shadow memory for 4 register parameters
STACK_ALIGN         equ     8               ;Align stack to 16 byte boundary

UserInput           byte     MAX_LENGTH dup(0)                        ;Variable to store user input name
msg1                byte    "ERROR INVALID TOKEN", LF               ;Message to prompt user for name

BytesWritten        dword    0                              ;returned by WriteConsole

hStdOut             dword    0                              ;handle to the standard output
                    ;Prints "Hello World!"
Program2            byte    "++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<"
                    byte    "+++++++++++++++.>.+++.------.--------.>+.>.",0

                    ;Prints ASCII Characters
Program3            byte    ".+[.+]",0

                     ;Prints "99 Bottles of Beer on the Wall"
Program4             byte    ">>>>>++++++++[<+++++++++>-]<+[>>[>]+[<]<-]>++++++++++[<+++++"
                     byte    "+++++>-]<[>>[+>]<[<]<-]<++++++++[>++++++++[>>->->->>>>>>>>>>"
                     byte    ">->>>->>>>>>->->->->>->>>->>>>->>>>>->->>>>>>->>>>->>>>>->->"
                     byte    ">>>>->>>->>>>>>>->-[<]<-]>>++>++>->>+>++>++>+>>>>++>>->+>>->"
                     byte    ">>>++>>+>+>+>--->>->+>+>->++>>>->++>>+>+>+>--->>-->>+>>->+>+"
                     byte    ">>->>+>++>+>+>->+>>++>++>->>++>->>++>+>++>+>>+>---[<]<<-]>>>"
                     byte    "++++>++++>+++>--->++>->->->>[-]>->-->[-]>+++>++>+>+++>--->>>"
                     byte    "--->[-]>+>+>+>--->[-]>+++>++>+>+++>->+++>>+++>++>---->->->+>"
                     byte    "--->[-]>->---->-->>+++>++>+>>+++>->++>++>+>->+++>+++>---->--"
                     byte    ">-->+++>++++>->+++>---->--->++>>+>->->---[[<]<]+++++++++[<+<"
                     byte    "+++++++++++>>-]<<[>>>>>[<]>[.>]>--[>.>]<[<<]>++>>>[.>]>[>]>["
                     byte    ".>]<[[<]<]>>[.>]>--[>.>]<[<<]>++>>>[.>]>[.>]>[>]>[.>]<[[<]<]"
                     byte    "<<[<]>>>+<[>-]>[>]<[+++++++++[<+<->>>>>+<<<-]+<<[>>-]>>>[<]<"
                     byte    "<<++++++++++>>[>>[-]+<<-]>>-<<]>>>-[>]>-<<[<]>[.>]>--[>.>]<["
                     byte    "<<]>++>>>[.>]>[>]>[.>]<.[[<]<]<<[<]>>-<-]",0



Plus                 equ    43                              ;this is the + character
Minus                equ    45                              ;this is the - character
MarchOn              equ    62                              ;>
Retreat              equ    60                              ;<
PrintIt              equ    46                              ;.
BegginingL           equ    91                              ;[
EndingL              equ    93                              ;]
                    .CODE

Main                Proc

                    sub     rsp,SHADOW_MEM + STACK_ALIGN    ;shadow memory and align stack
                                                            ;32 bytes for shadow memory
                                                            ; 8 bytes to align stack
                    ;*********************************************
                    ;In order to write to windows console screen
                    ;we need to get a handle to the screen
                    ;Refer to MSDN GetStdHandle for more info
                    ;*********************************************
                    mov     ecx,STD_OUTPUT_HANDLE
                    call    GetStdHandle
                    mov     hStdOut,eax                    ;Save output handle
                                
                    ;********************************
                    ;Setting the arrays to a register
                    ;*********************************
                    mov R10, offset Program3                ;this is the register pointing to the programs
                    mov R11, offset UserInput               ;this is the register used for the array
                    mov R12,0                               ;my counter for the program
L1:
                    mov bl,[R10+R12]                        ;moving the tokens into a byte register
                    
                    cmp bl,MarchOn                          ;comparing for a > token
                    je NextIndex                            ;jumps to the instructions involving the > token

                    cmp bl,Retreat                          ;comparing for a < token
                    je LastIndex                            ;jumps to the instructions involving the > toke

                    cmp bl,Plus                             ;comparing for a + token
                    je Increase                             ;jumps to the instructions involving the + toke

                    cmp bl,Minus                            ;comparing for a - token
                    je Decrease                             ;jumps to the instructions involving the - toke

                    cmp bl,PrintIt                          ;comparing for a . token
                    je Printer                              ;jumps to the instructions involving the . toke

                    cmp bl,BegginingL                       ;comparing for a [ token
                    je GroundHogsDay                        ;jumps to the instructions involving the [ toke

                    cmp bl,EndingL                          ;comparing for a ] token                    
                    je ItsOver                              ;jumps to the instructions involving the ] toke
                    jmp messgError                          ;jumps to display error if none of the tokens are in the register
NextIndex:
                    add R11,Type UserInput                  ;moving the pointer
                    inc R12                                 ;incrementing the offset
                    jmp L1                                  ;jumping back essentially creating a loop

LastIndex:
                    sub R11,Type UserInput                  ;moving the pointer
                    inc R12                                 ;incrementing the offset
                    jmp L1                                  ;jumping back to the comparisons

Increase:
                    mov r13b,[R11]                          ;moving the value in r11 into a register
                    inc r13b                                ;incrementing the register
                    mov [r11],r13b                          ;moving the value back into the register
                    inc R12                                 ;incrementing the offset
                    jmp L1
                    
Decrease:
                    mov r13b,[R11]
                    dec r13b
                    mov [r11],r13b
                    inc R12
                    jmp L1

Printer: 
                    jmp PlzPrint

GroundHogsDay: 
                    push R12                                ;pushes the value of r12 onto the stack for returning back later
                    inc  R12                                ;moving forward by incrementing the offset
                    jmp  L1
                
ItsOver:
                    mov r13b,[R11]                          ;moving the counters value into r13b
                    cmp r13b,0                              ;checks to see if the value is 0
                    je LEAVEMEALONE                         ;jumps if it is
                    pop R12                                 ;if it isnt then the stack is popped and the original value of the offset for[ is placed in r12
                    jmp L1                                  ;jumps back into the loop
LEAVEMEALONE:
                    inc R12                                 ;increments r12 and simply leaves the loop
                    jmp L1                                  ;continues feeding tokens

                    ;*********************************************
                    ;Prompt user to input a string
                    ;Refer to MSDN WriteConsole for more info
                    ;*********************************************
messgError:
                    mov     ecx,hStdOut                     ;handle to standard output
                    mov     rdx,OFFSET msg1                 ;address of message to display
                    mov     r8d,SIZEOF msg1                 ;number of bytes to display
                    mov     r9,OFFSET BytesWritten          ;bytes written to output returned in this address
                    xor     rax,rax                         ;last parameter is 0 
                    mov     [rsp+SHADOW_MEM], rax           ;5th parameter is passed on the stack
                    call    WriteConsoleA
                    jmp     Term
                    ;*********************************************
                    ;Prompt user to input a string
                    ;Refer to MSDN WriteConsole for more info
                    ;*********************************************
PlzPrint:
                    mov     ecx,hStdOut                     ;handle to standard output
                    mov     rdx, r11
                    mov     r8d,TYPE  UserInput             ;number of bytes to display
                    mov     r9,OFFSET BytesWritten          ;bytes written to output returned in this address
                    xor     rax,rax                         ;last parameter is 0 
                    mov     [rsp+SHADOW_MEM], rax           ;5th parameter is passed on the stack
                    call    WriteConsoleA
                    inc     R12
                    jmp     L1
                    ;*************************
                    ;Terminate Program
                    ;*************************
Term:
                    xor     ecx,ecx
                    call    ExitProcess

Main                endp

                    END