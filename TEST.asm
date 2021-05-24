;**********************************************************************************
;creates 3 threads to present to running windmills with speeds that can be toggled
; two threads are dedicated to outputting the windmills spinning at varrying speeds
; the main thread changes the speeds and asks for userinput
;**********************************************************************************
;External Windows API Functions
include Win64API.inc

                    .DATA

LF                  equ     10                              ;New Line 
SHADOW_MEM          equ     32                              ;Shadow memory for 4 register parameters
STACK_ALIGN         equ     8                               ;Align stack to 16 byte boundary
WundmillPos         equ     3                               ;contains the max value in the windmill array

ThreadDec1          equ     31h                             ;the value for the 1 ascii
ThreadInc1          equ     32h                             ;the value for the 2 ascii
WindmillTo1         equ     124                             ;these contains the ascii
PrintInitial        byte    124
WindmillTo2         equ     47                              ;values of all
WindmillTo3         equ     45                              ;tokens representing
WindmillTo4         equ     92                              ;the windmill

ThreadDec2          equ     33h                             ;the value for 3 in ascii
ThreadInc2          equ     34h                             ;the value for 4 in ascii

ENT                 equ     13                              ;the value of the enter key

CharsRead           qword    0                              ;Returned by ReadConsole 
BytesWritten        qword    0                              ;Returned by WriteConsole
MutexHandle         qword    0                              ;this variable contains the mutex address
threadHandle1       qword    0                              ;this contains the address for the first created thread
threadHandle2       qword    0                              ;this contains the thread address for thread2
SpeedCounter1       byte     0                              ;this counts the speed for first thread
inSpeedCounter      byte    30h
SpeedCounter2       byte     0                              ;this contains the count for speed2
tokenSp1            byte     0                              ;this is used to move the value of the speedcounter to thread1
tokenSp2            byte     0                              ;this us used to move the value of speedcounter to thread2
WindmillToken1      qword    0                              ;
WindmillToken2      qword    0                              ;
SuspendCount        qword    0
message1            byte     "Press 1 to decrease and 2 to increase windmill 1. 3 to decrease and 4 to increase windmill 2"

hStdOut             qword    0                              ;Handle to the standard output
hStdIn              qword    0                              ;Handle to the standard input
Thread_ID1          qword    0                              ;thread id for thread1
Thread_ID2          qword    0                              ;thread id for thread2
UserInput           byte     0                              ;contains user input

COORDWindMill1      LABEL   DWORD
CursorXPosition1    word    0
CursorYPosition1    word    0
COORDWindMillSpeed1 LABEL   DWORD
CursorXPosition1s   word    0
CursorYPosition1s   word    5
COORDWindMill2      LABEL   DWORD
CursorXPosition2    word    9
CursorYPosition2    word    0
COORDWindMillSpeed2 LABEL   DWORD
CursorXPosition2s    word   9
CursorYPosition2s    word   5
COORDprompt         LABEL   DWORD
CursorXPositionprompt    word   0
CursorYPositionprompt    word   8


                    .CODE

Main                PROC

                    sub     rsp, SHADOW_MEM + STACK_ALIGN   ;Shadow memory and align stack
                                                            ;32 bytes for shadow memory
                                                            ;8 bytes to align stack
                    ;*********************************************
                    ;Get a handle to the standard input device
                    ;*********************************************
                    mov     rcx, STD_INPUT_HANDLE
                    call    GetStdHandle
                    mov     hStdIn, rax                     ;Save input handle

                    ;*********************************************
                    ; Get a handle to the standard output device
                    ;*********************************************
                    mov     ecx, STD_OUTPUT_HANDLE
                    call    GetStdHandle
                    mov     hStdOut, rax                    ;Save output handle

                    ;*********************************************
                    ; Set Console Mode for Line Input
                    ;*********************************************
                    mov     rcx, hStdIn                     ;1st parameter
                    mov     edx, ENABLE_NOTHING_INPUT
                    call    SetConsoleMode                  ;Call Windows API
                    ;*********************************************
                    ;Prints the prompt
                    ;**********************************************

                    ;*************************************************************************************
                    ; Set Cursor Position
                    ;the prompt is giving the instructions to how to interface with the program to user
                    ;*************************************************************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDprompt
                    call    SetConsoleCursorPosition
                    mov rcx,hStdOut
                    mov rdx,Offset message1
                    mov r8d,SIZEOF message1
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA  
                    ;**********************************************
                    ;Prints the original position for the windmill1
                    ;***********************************************

                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMill1
                    call    SetConsoleCursorPosition

                    mov rcx,hStdOut
                    mov rdx,Offset PrintInitial
                    mov r8d,SIZEOF PrintInitial
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA  
                    ;**********************************************
                    ;Prints the original position for the windmill2
                    ;***********************************************
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMill2
                    call    SetConsoleCursorPosition

                    mov rcx,hStdOut
                    mov rdx,Offset PrintInitial
                    mov r8d,SIZEOF PrintInitial
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA 
                    ;****************************************************
                    ;Prints the original position for the windmill1 speed
                    ;****************************************************
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMillSpeed1
                    call    SetConsoleCursorPosition

                    mov rcx,hStdOut
                    mov rdx,Offset inSpeedCounter
                    mov r8d,SIZEOF inSpeedCounter
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA  
                    ;*****************************************************
                    ;Prints the original position for the windmill1 speed2
                    ;*****************************************************                   
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMillSpeed2
                    call    SetConsoleCursorPosition

                    mov rcx,hStdOut
                    mov rdx,Offset inSpeedCounter
                    mov r8d,SIZEOF inSpeedCounter
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA                                           
                    ;************************************************
                    ; Create Mutex
                    ;************************************************
                    xor     r8d, r8d
                    xor     edx, edx
                    xor     ecx, ecx

                    call    CreateMutexA
                    mov     mutexHandle, rax                 ;Save Mutex Handle                    
                    ;********************************************************************
                    ;creating both threads with these blocks of codes
                    ;********************************************************************               

                    mov	rax,OFFSET Thread_ID1               ;sets up the 
                    mov	[rsp+28h],rax                       ;parameters for 
                    mov	dword ptr [rsp+20h],0               ;the windows api function
                    xor	r9d,r9d                             ;create thread
                    mov	r8,OFFSET ThreadProc1               ;to work effectively
                    xor	edx,edx                             ;zeores out edx
                    xor	ecx,ecx                             ;zeroes out ecx
                    call	CreateThread
                    mov	threadHandle1,rax                   ;moves the thread handle to the variable for future use
                    mov rcx,threadHandle1                   ;suspend the thread
                    call SuspendThread                      ;immediatly as speed is set to zero

                    mov	rax,OFFSET Thread_ID2               ;sets up the
                    mov	[rsp+28h],rax                       ;parameters for
                    mov	dword ptr [rsp+20h],0               ;the windows api function
                    xor	r9d,r9d                             ;create thread
                    mov	r8,OFFSET ThreadProc2               ;to work effectively
                    xor	edx,edx                             ;zeroes out edx
                    xor	ecx,ecx                             ;zeroes out ecx
                    call	CreateThread                    
                    mov	threadHandle2,rax                   ;keeps the address for the threadhandle in a variable
                    mov rcx,ThreadHandle2                   ;suspends the thread
                    call SuspendThread                      ;from the very beggining
                    ;***********************************************************************
                    ;creates the mutex for the threads to pass to each other
                    ;***********************************************************************
                    xor	r8d,r8d			  
                    xor	edx,edx	  
                    xor	ecx,ecx  
                    call	CreateMutexA
                    mov	mutexHandle,rax
                    mov r15,1
                    mov rbx,1
Beggining:
                    ;*********************************************
                    ;Get User Input
                    ;*********************************************
                     mov     rcx,hStdIn                          ;handle to standard input
                     mov     rdx, OFFSET UserInput               ;address where to store input data
                     push    rdx                                 ;saves the value so it isnt zeroed out 
                     mov     r8d,TYPE UserInput                  ;max number of bytes to store
                     mov     r9,OFFSET CharsRead                 ;Bytes stored is returned in this address
                     xor     rax,rax                             ;last parameter is 0 
                     mov     [rsp+SHADOW_MEM], rax               ;5th parameter is passed on the stack
                     call    ReadConsoleA      
                    ;************************************************
                    ; Get mutex
                    ;************************************************
                    mov     rdx, 0FFFFFFFFh                 
                    mov     rcx, mutexHandle
                    call    WaitForSingleObject              
                    pop r10
                    ;***************************************************
                    ;user input is compared with the 3 possible values
                    ;and jump accordingly
                    ;***************************************************
                    cmp UserInput,ThreadInc1                  ;checks if thread 1 fan is increased
                    je incrementSpeed1
                    cmp UserInput,ThreadInc2                 ;checks if thread 2 fan is increased
                    je incrementSpeed2
                    cmp UserInput,ThreadDec1                 ;checks if thread 1 fan is decreased
                    je decrementSpeed1
                    cmp UserInput,ThreadDec2                 ;checks if thread 2 fan is decreased
                    je decrementSpeed2
                    cmp UserInput,ENT                       ;if only enter is in input
                    je Terminate                            ;program terminates
                    jmp Beggining                           ;if the wrong input is input the input loops

SpeedChange1:
                    cmp r12b,0                              ;checks if the count is 0
                    je SusThread                            ;jumps to pause thread                        
                    cmp r12b,1                              ;checks if count is one
                    je ResuThread                           ;jumps to resume thread
                    jmp SetCursor                           ;jumps tp set cursor

SusThread:
                    inc r15
                    cmp r15,1
                    ja OneSuspend1
                    mov rcx,threadHandle1                  ;moves threadhandle tor egister
                    call SuspendThread                     ;suspends thread
                    jmp SetCursor
OneSuspend1:        
                    dec r15
                    jmp SetCursor
ResuThread:    
                    dec r15     
                    mov rcx,threadHandle1                  ; 
                    call ResumeThread                      ;resumes thread

SetCursor:
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMillSpeed1
                    call    SetConsoleCursorPosition
                    mov rcx,hStdOut
                    mov rdx, OFFSET SpeedCounter1
                    mov r8d,SIZEOF SpeedCounter1
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA
                    jmp ReleaseMainMutex

SpeedChange2:

                    cmp r13b,0                          ;checks if the count is 0
                    je SusThread2                       ;jumps to pause thread    
                    cmp r13b,1                          ;checks if count is one
                    je ResuThread2                      ;jumps to resume thread
                    jmp SetCursor2                      ;jumps tp set cursor

SusThread2:
                    mov rcx,threadHandle2               ;moves threadhandle tor register
                    inc rbx
                    cmp rbx,1
                    ja OneSuspend2
                    call SuspendThread                  ;suspends thread
                    jmp SetCursor2
OneSuspend2:
                    dec rbx
                    jmp SetCursor2
ResuThread2:  
                    dec rbx       
                    mov rcx,threadHandle2
                    call ResumeThread                   ;resumes thread

SetCursor2:
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMillSpeed2
                    call    SetConsoleCursorPosition

                    mov rcx,hStdOut
                    mov rdx, OFFSET SpeedCounter2
                    mov r8d,SIZEOF SpeedCounter2
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA
ReleaseMainMutex:
                    ;*********************************************
                    ; Release Mutex
                    ;********************************************* 
                    mov     rcx, mutexHandle
                    call    ReleaseMutex
                    jmp Beggining

incrementSpeed1:
                    add r12,1                   ;increments r12
                    cmp r12,6                   ;if r12 is higher than 5 then sets back to 5
                    je tooHigh1
Capped1:
                    mov tokenSp1,r12b          ;moves the register value into the variable tokenSp1   
                    add r12,30h                ;adds the ascii default for 0 into r12
                    mov SpeedCounter1,r12b     ;moves the ascii value into a variable
                    sub r12,30h                ;subtracts 30h out of r12 again

                    jmp SpeedChange1
tooHigh1:
                    dec r12                     ;sets r12 back to 5
                    jmp Capped1               
incrementSpeed2:
                    add r13,1                   ;increments r13
                    cmp r13,6                   ;checks if out of bounds with speeds
                    je tooHigh2         
Capped2:
                    mov tokenSp2,r13b           ;moves r13 into a variable
                    add r13,30h                 ;adds ascii value into r13
                    mov SpeedCounter2,r13b      ;moves ascii value into variable
                    sub r13,30h                 ;subtracts the ascii value from r13
                    jmp SpeedChange2
tooHigh2:            
                    dec r13                     ;sets the register back into its max value of 5
                    jmp Capped2
decrementSpeed1:
                    cmp r12,0                   ;checks if the value is already at the floor of 0
                    je NoSub1       
                    sub r12,1                   ;decrements the register by 1
NoSub1:
                    mov tokenSp1,r12b           ;moves the register value into a variable
                    add r12,30h                 ;adds the ascii value to register
                    mov SpeedCounter1,r12b      ;movces the register into a variab;e
                    sub r12,30h                 ;subtracts ascii value from register
                    jmp SpeedChange1
decrementSpeed2:
                    cmp r13,0                   ;checks if it is at the floor of 0
                    je NoSub2           
                    sub r13,1                   ;decrements register
NoSub2:
                    mov tokenSp2,r13b           ;moves the register into a variable
                    add r13,30h                 ;adds the ascii value
                    mov SpeedCounter2,r13b      ;moves the register value into a variable
                    sub r13,30h                 ;subtracts the ascii value
                    jmp SpeedChange2            
Terminate:
                    ;Terminate program
                    mov     ecx, 0
                    call    ExitProcess

Main                ENDP
ThreadProc1         PROC


                    xor r14,r14                 ;zeroes r14
                    ;************************************************************************
                    ;SETS UP THE SLEEP SPEED FOR THE THREAD
                    ;************************************************************************
ThisProjectSucks:
                    mov r12b, tokenSp1          ;moves the token for speed to r12
                    cmp r12b,1                  ;checks if value is one and jumps if equal
                    Je Pleaseresume
                    cmp r12b,2                  ;checks if value is two and jumps if equal
                    Je Stage2
                    cmp r12b,3                  ;checks if value is three and jumps if equal
                    Je Stage3
                    cmp r12b,4                  ;checks if value is four and jumps if equal
                    je Stage4
                    cmp r12b,5                  ;checks if value is five and jumps if equal
                    je Stage5
Pleaseresume:
                    mov r12,700                 ;moves the slowest speed into r12
                    jmp BegginingProc1
Stage2:
                    mov r12,325                 ;moves the second slowest speed into r12
                    jmp BegginingProc1
Stage3:
                    mov r12,150                 ;moves the third slowest speed into r12
                    jmp BegginingProc1
Stage4:
                    mov r12,70                  ;moves the second fastest speed into r12
                    jmp BegginingProc1
stage5:
                    mov r12,30                  ;moves the fastest speed into r12
                    jmp BegginingProc1


BegginingProc1:
                    ;*********************************************
                    ; Call Mutex
                    ;********************************************* 
                    mov     rdx, 0FFFFFFFFh
                    mov     rcx, mutexHandle
                    call    WaitForSingleObject

                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMill1
                    call    SetConsoleCursorPosition
                    ;********************************************
                    ;gets the token to print
                    ;*******************************************
                    cmp     r14,0           ;checks if r14 is 0 for token
                    je      FirstToken
                    cmp     r14,1           ;checks if r14 is 1for token
                    je      SecondToken
                    cmp     r14,2           ;checks if r14 is 2 for token
                    je      ThirdToken
                    cmp     r14,3           ;checks if r14 is 3 for token
                    je      FourthToken
PrintIt1:
                    mov rcx,hStdOut
                    mov rdx,Offset WindmillToken1
                    mov r8d,SIZEOF WindmillToken1
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA
                    ;*********************************************
                    ; Release Mutex
                    ;********************************************* 
                    mov     rcx, mutexHandle
                    call    ReleaseMutex

                    mov ecx,r12d          ;moves the value of r12 (sleep speed) into ecx
                    call Sleep            ;calls the sleep function

                    inc r14               ;increments r14
                    cmp r14,4             ;checks if it is the max value for tokens
                    je resetCount1        ;resets if it is

                    jmp ThisProjectSucks  ;loops the project


FirstToken:
                    mov r13,WindmillTo1           ;moves the token in the variable into r13
                    mov WindmillToken1,r13        ;moves the token into the variable
                    jmp PrintIt1
SecondToken:
                    mov r13,WindmillTo2           ;moves the token in the variable into r13
                    mov WindmillToken1,r13        ;moves the token into the variable
                    jmp PrintIt1
ThirdToken:         
                    mov r13,WindmillTo3           ;moves the token in the variable into r13
                    mov WindmillToken1,r13        ;moves the token into the variable
                    jmp PrintIt1
FourthToken:        
                    mov r13,WindmillTo4           ;moves the token in the variable into r13
                    mov WindmillToken1,r13        ;moves the token into the variable
                    jmp PrintIt1

                    

resetCount1:
                    xor r14,r14
                    jmp BegginingProc1

ThreadProc1         endp


ThreadProc2         PROC


                    xor r14,r14
ThisProjectSucks2:
                    mov r12b,tokenSp2
                    cmp r12b,1                  ;checks if value is one and jumps if equal
                    Je Pleaseresume2
                    cmp r12b,2                  ;checks if value is two and jumps if equal
                    Je Stage2Thread2
                    cmp r12b,3                  ;checks if value is three and jumps if equal
                    Je Stage3Thread2
                    cmp r12b,4                  ;checks if value is four and jumps if equal
                    je Stage4Thread2
                    cmp r12b,5                  ;checks if value is five and jumps if equal
                    je Stage5Thread2
Pleaseresume2:
                    mov r12,700                 ;moves the slowest speed into r12
                    jmp BegginingProc2
Stage2Thread2:
                    mov r12,325                 ;moves the second slowest speed into r12
                    jmp BegginingProc2
Stage3Thread2:
                    mov r12,150                 ;moves the third slowest speed into r12
                    jmp BegginingProc2
Stage4Thread2:
                    mov r12,70                  ;moves the second fast speed into r12
                    jmp BegginingProc2
stage5Thread2:
                    mov r12,30                  ;moves the fastest speed into r12
                    jmp BegginingProc2
                 
BegginingProc2: 

                    ;*********************************************
                    ; Call Mutex
                    ;********************************************* 
                    mov     rdx, 0FFFFFFFFh
                    mov     rcx, mutexHandle
                    call    WaitForSingleObject
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMill2
                    call    SetConsoleCursorPosition
                    cmp     r14,0           ;checks if r14 is 0 for token
                    je      FirstToken2
                    cmp     r14,1           ;checks if r14 is 1 for token
                    je      SecondToken2
                    cmp     r14,2           ;checks if r14 is 2 for token
                    je      ThirdToken2
                    cmp     r14,3           ;checks if r14 is 3 for token
                    je      FourthToken2
PrintIt2:
                    mov rcx,hStdOut
                    mov rdx,Offset WindmillToken2
                    mov r8d,SIZEOF WindmillToken2
                    mov r9,OFFSET BytesWritten
                    xor rax,rax
                    mov [rsp+SHADOW_MEM],rax
                    call WriteConsoleA
                    ;*********************************************
                    ; Set Cursor Position
                    ;*********************************************
                    mov     rcx, hStdOut
                    mov     edx, COORDWindMill2
                    call    SetConsoleCursorPosition
                    ;*********************************************
                    ; Release Mutex
                    ;********************************************* 
                    mov     rcx, mutexHandle
                    call    ReleaseMutex


                    mov ecx,r12d          ;moves the value of r12 (sleep speed) into ecx
                    call Sleep

                    inc r14               ;increments r14
                    cmp r14,4             ;checks if it is the max value for tokens
                    je resetCount2        ;resets if it is
                    jmp ThisProjectSucks2 ;loops the procedure


FirstToken2:
                    mov r13,WindmillTo1           ;moves the token in the variable into r13
                    mov WindmillToken2,r13        ;moves the token into the variable
                    jmp PrintIt2
SecondToken2:
                    mov r13,WindmillTo2           ;moves the token in the variable into r13
                    mov WindmillToken2,r13        ;moves the token into the variable
                    jmp PrintIt2
ThirdToken2:         
                    mov r13,WindmillTo3           ;moves the token in the variable into r13
                    mov WindmillToken2,r13        ;moves the token into the variable
                    jmp PrintIt2
FourthToken2:        
                    mov r13,WindmillTo4           ;moves the token in the variable into r13
                    mov WindmillToken2,r13        ;moves the token into the variable
                    jmp PrintIt2

                    

resetCount2:
                    xor r14,r14
                    jmp BegginingProc2
ThreadProc2         endp

                    END
