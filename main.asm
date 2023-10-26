.686

.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc ; nessa lib tem a leitura de arquivos 
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib

include \masm32\macros\macros.asm


.data
    inputFileName db "Input file name (.bmp): ", 0H

    fileName db 50 dup(0) ; 100 bytes = 800 bits
    fileNameLength dd 0
    outputFileName db "copiaFotoanonima.bmp"

    outputHandle dd 0
    inputHandle dd 0
    fileHandle dd 0

    fileInfoBuffer dw 18 dup(0)
    fileInfoToNextBuffer dw 28 dup(0)
    fileInfoString db 0

    fileWidth dd 0
    fileHeight dd 0

    readCount dd 0
    consoleCount dd 0

    output dd 0

    outputTeste db 32 dup(0)

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

        ; get file name string length
        push offset fileName
        call StrLen
        mov fileNameLength, eax

        mov esi, offset fileName ; Armazenar apontador da string em esi

        next:
            mov al, BYTE PTR [esi] ; Mover caractere atual para al
            inc esi ; Apontar para o proximo caractere
            cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
            jne next

        dec esi ; Apontar para caractere anterior
        xor al, al ; ASCII 0
        mov BYTE PTR [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        ; -- open access image file --
        push NULL
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_EXISTING
        push NULL
        push 0
        push GENERIC_READ
        push offset fileName
        call CreateFile

        ;code to create the output file
        ;push NULL
        ;push FILE_ATTRIBUTE_NORMAL
        ;push CREATE_ALWAYS
        ;push NULL
        ;push 0
        ;push GENERIC_WRITE
        ;push offset outputFileName
        ;call CreateFile

        mov fileHandle, eax

        ; -- read image file --
        push NULL
        push offset readCount
        push 18
        push offset fileInfoBuffer
        push fileHandle
        call ReadFile

        ; read the width
        push NULL
        push offset readCount
        push 4
        push offset fileWidth
        push fileHandle
        call ReadFile

        ; read the height
        push NULL
        push offset readCount
        push 4
        push offset fileHeight
        push fileHandle
        call ReadFile

        push NULL
        push offset readCount
        push 28
        push offset fileInfoToNextBuffer
        push fileHandle
        call ReadFile

        ;verify code to show values searched {
        ;push offset outputTeste
        ;push fileInfoToNextBuffer
        ;call dwtoa

        push NULL
        push offset consoleCount
        push 28
        push offset fileInfoToNextBuffer
        push outputHandle
        call WriteConsole
        ;}

        finish:
            invoke ExitProcess, 0

    end start