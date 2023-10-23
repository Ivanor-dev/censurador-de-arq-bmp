.686

.model flat,stdcall

option casemap:none

include \masm32\include\windows.inc ; constants
include \masm32\include\kernel32.inc ; input/output
include \masm32\include\masm32.inc ; 

includelib \masm32\lib\kernel32.lib 
includelib \masm32\lib\masm32.lib

.data
    inputFileName db "Input file name (.bmp): ", 0H
    outputHandle dd 0

    fileName db 50 dup(0) ; 100 bytes = 800 bits
    fileNameLength dd 0
    inputHandle dd 0

    consoleCount dd 0

.code 
    start:
        ; -- get input/output handle
        push STD_INPUT_HANDLE
        call GetStdHandle
        mov inputHandle, eax

        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax

        ; write input message (file name)
        push NULL
        push offset consoleCount
        push sizeof inputFileName
        push offset inputFileName
        push outputHandle
        call WriteConsole

        ; read file name
        push NULL
        push offset consoleCount
        push sizeof fileName
        push offset fileName
        push inputHandle
        call ReadConsole

        finish:
            invoke ExitProcess, 0
            
    end start


