.686

.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
include \masm32\include\msvcrt.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib

include \masm32\macros\macros.asm


.data
    fileNameMessage db "Input file name (.bmp): ", 0H
    fileName db 50 dup(0) ; 100 bytes = 800 bits
    fileNameLength dd 0

    outputFileNameMessage db "Output file name (.bmp): ", 0H
    outputFileName db 50 dup(0) ; 100 bytes = 800 bits
    outputFileNameLength dd 0

    outputHandle dd 0
    inputHandle dd 0

    readFileHandle dd 0
    writeFileHandle dd 0

    fileHeight dd 0

    fileHeaderBuffer db 32 dup(0)
    fileImageBuffer db 6480 dup(0)

    readCount dd 0
    writeCount dd 0
    consoleCount dd 0


.code
    remove_CR_LF:
        push ebp
        mov ebp, esp
        ; sub esp, 8

        ; remove ASCII CR from input file name
        mov esi, [ebp+8] ; Armazenar apontador da string em esi

        next:
            mov al, BYTE PTR [esi] ; Mover caractere atual para al
            inc esi ; Apontar para o proximo caractere
            cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
            jne next

        dec esi ; Apontar para caractere anterior
        xor al, al ; ASCII 0
        mov BYTE PTR [esi], al ; Inserir ASCII 0 no lugar do ASCII CR

        mov esp, ebp
        pop ebp
        ret 4

    start:

        ; ===== USER INPUT =====

        ; -- get input/output handle
        push STD_INPUT_HANDLE
        call GetStdHandle
        mov inputHandle, eax

        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax

        ; ---- input file ----

        ; write input message name
        push NULL
        push offset consoleCount
        push sizeof fileNameMessage
        push offset fileNameMessage
        push outputHandle
        call WriteConsole

        ; read input file name
        push NULL
        push offset consoleCount
        push sizeof fileName
        push offset fileName
        push inputHandle
        call ReadConsole


        push offset fileName
        call remove_CR_LF        

        ; mov esi, offset fileName ; Armazenar apontador da string em esi

        ; next:
        ;     mov al, [esi] ; Mover caracter e atual para al
        ;     inc esi ; Apontar para o proximo caracter e
        ;     cmp al, 13 ; Verificar se eh o caractere ASCII CR FINALIZAR
        ;     jne next

        ; dec esi ; Apontar para caracter e anterior
        ; xor al, al ; ASCII 0
        ; mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR


        ; get file name string length
        push offset fileName
        call StrLen
        mov fileNameLength, eax

        ; ---- output file ----

        ; write output file name message
        push NULL
        push offset consoleCount
        push sizeof outputFileNameMessage
        push offset outputFileNameMessage
        push outputHandle
        call WriteConsole

        ; read output file name
        push NULL
        push offset consoleCount
        push sizeof outputFileName
        push offset outputFileName
        push inputHandle
        call ReadConsole

        ; remove ASCII CR from input file name
        push offset outputFileName ; Armazenar apontador da string em esi
        call remove_CR_LF

        ; ===== FILES SETUP =====

        ; --- open input file ---
        push NULL
        push FILE_ATTRIBUTE_NORMAL
        push OPEN_EXISTING
        push NULL
        push 0
        push GENERIC_READ
        push offset fileName
        call CreateFile

        mov readFileHandle, eax

        ; -- create output file ---
        push NULL
        push FILE_ATTRIBUTE_NORMAL
        push CREATE_ALWAYS
        push NULL
        push 0
        push GENERIC_WRITE
        push offset outputFileName
        call CreateFile

        mov writeFileHandle, eax



        ; ===== COPY HEADER (14 bytes) =====

        ; --- read header (14 bytes) from input file ---
        push NULL
        push offset readCount
        push 22
        push offset fileHeaderBuffer
        push readFileHandle
        call ReadFile

        ; --- write header (14 bytes) to the output file ---
        push NULL
        push offset writeCount
        push 22
        push offset fileHeaderBuffer
        push writeFileHandle
        call WriteFile
        


        ; ===== COPY HEIGHT (4 bytes) =====

        ; --- read height (4 bytes) from input file ---
        push NULL
        push offset readCount
        push 4
        push offset fileHeaderBuffer
        push readFileHandle
        call ReadFile

        ; --- write height (4 bytes) to the output file ---
        push NULL
        push offset writeCount
        push 4
        push offset fileHeaderBuffer
        push writeFileHandle
        call WriteFile

        ; --- save the file height in memory ---
        
        ; convert ASCII to number
        push offset fileHeaderBuffer
        call atodw
        mov fileHeight, eax



        ; ===== COPY WIDTH (4 bytes) =====

        ; --- read width (4 bytes) from input file ---
        push NULL
        push offset readCount
        push 4
        push offset fileHeaderBuffer
        push readFileHandle
        call ReadFile

        ; --- write width (4 bytes) to the output file ---
        push NULL
        push offset writeCount
        push 4
        push offset fileHeaderBuffer
        push writeFileHandle
        call WriteFile


        ; ===== COPY REMAINING HEADER DATA (32 bytes) =====

        ; --- read 32 bytes from input file ---
        push NULL
        push offset readCount
        push 32
        push offset fileHeaderBuffer
        push readFileHandle
        call ReadFile

        ; --- write 32 bytes to the output file ---
        push NULL
        push offset writeCount
        push 32
        push offset fileHeaderBuffer
        push writeFileHandle
        call WriteFile



        ; ===== COPY IMAGE =====

        ; LOGIC: 
        ;   lineIndex = 0
        ;   do
        ;       read line from input file
        ;       write line to the output file
        ;       lineIndex++
        ;   while (lineIndex < fileHeight)

        xor edi, edi

        image_loop:
            push edi

            ; --- read "image line" from input file ---
            push NULL
            push offset readCount
            push 6480 ; image width = 2160 pixels * 3 bytes
            push offset fileImageBuffer
            push readFileHandle
            call ReadFile

            ; --- write "image line" to the output file ---
            push NULL
            push offset writeCount
            push 6480 ; image width = 2160 pixels * 3 bytes
            push offset fileImageBuffer
            push writeFileHandle
            call WriteFile

            pop edi

            inc edi
            cmp edi, fileHeight ; verify if image was fully copied
            jl image_loop

        finish:
            push 0
            call ExitProcess

    end start