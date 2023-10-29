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

    output dd 0

    outputTeste db 32 dup(0)

    counterPrint dd 0

.code
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


        ; remove ASCII CR from input file name
        mov esi, offset fileName ; Armazenar apontador da string em esi

        next:
            mov al, BYTE PTR [esi] ; Mover caractere atual para al
            inc esi ; Apontar para o proximo caractere
            cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
            jne next

        dec esi ; Apontar para caractere anterior
        xor al, al ; ASCII 0
        mov BYTE PTR [esi], al ; Inserir ASCII 0 no lugar do ASCII CR


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
        mov esi, offset outputFileName ; Armazenar apontador da string em esi

        next_2:
            mov al, BYTE PTR [esi] ; Mover caractere atual para al
            inc esi ; Apontar para o proximo caractere
            cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
            jne next_2

        dec esi ; Apontar para caractere anterior
        xor al, al ; ASCII 0
        mov BYTE PTR [esi], al ; Inserir ASCII 0 no lugar do ASCII CR


        ; get file name string length
        push offset outputFileName
        call StrLen
        mov outputFileNameLength, eax



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

        ; XXXXXXXXXXXX CONVERTION BYTE TO DWORD NOT WORKING XXXXXXXXXXXXXXXXXXXXXXX

        mov esi, offset fileHeaderBuffer ; address of the first char
        
        ;next_convertion:
            movzx eax, BYTE PTR [fileHeaderBuffer] ; passing the value of the current char (ASCII)
            mov fileHeight, eax

            ;inc esi ; load the address of the next char

            ; check if the ASCII is not numerical (ASCII < 48)
            ;cmp al, 48
            ;jl finish_convertion

            ; check if the ASCII is numerical (ASCII < 58)
            ;cmp al, 58
            ;jl next

        ;finish_convertion:
            ;dec esi ; address of the not numerical ASCII

            ; set the ASCII to 0 (NULL, end of string)
            ;xor al, al 
            ;mov BYTE PTR [esi], al
    
        ;push eax

        ; convert string to integer
        ;push offset fileHeaderBuffer
        ;call atodw
        
        ;pop eax

        ;mov fileHeight, eax

        printf("%d\n",fileHeight)

        ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

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

        ; ===== COPY IMAGE ====

        ; XXXXXXXXXXXXXXXXXXXXXX NOT WORKING XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        xor edi, edi

        image_loop:
            push edi

            push NULL
            push offset readCount
            push 6480
            push offset fileImageBuffer
            push readFileHandle
            call ReadFile

            push NULL
            push offset writeCount
            push 6480
            push offset fileImageBuffer
            push writeFileHandle
            call WriteFile

            pop edi

            printf("%d\n",edi)

            inc edi
            cmp edi, fileHeight
            jl image_loop

            ; XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

        finish:
            push 0
            call ExitProcess

    end start