.686

.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\masm32.inc
include \masm32\include\gdi32.inc
include \masm32\include\user32.inc
include \masm32\include\kernel32.inc
include \masm32\include\msvcrt.inc
include \masm32\macros\macros.asm

includelib \masm32\lib\msvcrt.lib
includelib \masm32\lib\masm32.lib
includelib \masm32\lib\gdi32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\kernel32.lib

.data
    fileNameMessage db "Input file name (.bmp): ", 0H
    fileName db 256 dup(0) ; 100 bytes = 800 bits
    fileNameLength dd 0

    outputFileNameMessage db "Output file name (.bmp): ", 0H
    outputFileName db 256 dup(0) ; 100 bytes = 800 bits
    outputFileNameLength dd 0

    pointXCensurerMenssage db "Point X to censure (natural): ", 0H
    pointXCensurer db 32 dup(0)
    pointX DWORD ?

    pointYCensurerMenssage db "Point Y to censure (natural): ", 0H
    pointYCensurer db 32 dup(0)
    pointY DWORD ?

    widthCensurerMenssage db "WIDTH of black square (natural): ", 0H
    widthCensurer db 32 dup(0)
    widthSquare DWORD ?

    heightCensurerMenssage db "HEIGHT of black square (natural): ", 0H
    heightCensurer db 32 dup(0)
    heightSquare DWORD ?

    outputHandle HANDLE ?
    inputHandle HANDLE ?

    readFileHandle HANDLE ?
    writeFileHandle HANDLE ?

    fileWidth DWORD ?
    fileHeight DWORD ?

    fileHeaderBuffer db 32 dup(0)
    fileImageBuffer db 6480 dup(0)

    readCount DWORD ?
    writeCount DWORD ?
    consoleCount DWORD ?
    lineCount dd 0
    imageWidth dd 0

    error db "ocorreu um erro.", 0H


.code
   
   remove_CR_LF:
        push ebp
        mov ebp, esp

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


        censure:
            push ebp
            mov ebp, esp
            

            ; Argumentos:
            mov edi, [ebp + 8]    ; Largura da censura
            mov eax, [ebp + 12]    ; Coordenada X inicial
            imul eax, 3
            mov ebx, [ebp + 16]     ; Endereço do array de bytes
            imul ebx, 3

            ; Preencha os pixels com a cor preta

            add ebx, eax            

            fillPixels:
                cmp eax, ebx 
                jg finish_fillPixels

                mov BYTE PTR [edi + eax], 0  ; Preencha os bytes da imagem com a cor preta
                mov BYTE PTR [edi + eax + 1], 0  
                mov BYTE PTR [edi + eax + 2], 0 ; Avance para o próximo pixel
                add eax, 3
                jmp fillPixels

            ; Libere a pilha e retorne
            finish_fillPixels:
                mov esp, ebp
                pop ebp
                ret 0

    start:

        ; ===== USER INPUT =====

        ; -- get input/output handle
        push STD_INPUT_HANDLE
        call GetStdHandle
        mov inputHandle, eax

        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov outputHandle, eax

        push STD_INPUT_HANDLE
        call GetStdHandle
        mov readFileHandle, eax

        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov writeFileHandle, eax

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

        push offset outputFileName
        call remove_CR_LF


        ;printf("valor altura %d", heightSquare)

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
        cmp readFileHandle, INVALID_HANDLE_VALUE
        je error_occurred

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
        push 18
        push offset fileHeaderBuffer
        push readFileHandle
        call ReadFile

        ; --- write header (14 bytes) to the output file ---
        push NULL
        push offset writeCount
        push 18
        push offset fileHeaderBuffer
        push writeFileHandle
        call WriteFile
        
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

        push offset fileHeaderBuffer
        call atodw
        mov fileWidth, eax



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

                ; --- position X ---

        ; write position X message
        push NULL
        push offset consoleCount
        push sizeof pointXCensurerMenssage
        push offset pointXCensurerMenssage
        push outputHandle
        call WriteConsole

        ; read position X
        push NULL
        push offset consoleCount
        push sizeof pointXCensurer
        push offset pointXCensurer
        push inputHandle
        call ReadConsole

        
        push offset pointXCensurer
        call remove_CR_LF

        push offset pointXCensurer
        call atodw

        mov pointX, eax

        ; --- position Y ---
        
        ; write position Y message
        push NULL
        push offset consoleCount
        push sizeof pointYCensurerMenssage
        push offset pointYCensurerMenssage
        push outputHandle
        call WriteConsole

        ; read position Y
        push NULL
        push offset consoleCount
        push sizeof pointYCensurer
        push offset pointYCensurer
        push inputHandle
        call ReadConsole

        
        push offset pointYCensurer
        call remove_CR_LF

        push offset pointYCensurer
        call atodw

        mov pointY, eax
        ; --- width ---
        
        ; write width message
        push NULL
        push offset consoleCount
        push sizeof widthCensurerMenssage
        push offset widthCensurerMenssage
        push outputHandle
        call WriteConsole

        ; read width
        push NULL
        push offset consoleCount
        push sizeof widthCensurer
        push offset widthCensurer
        push inputHandle
        call ReadConsole

        
        push offset widthCensurer
        call remove_CR_LF

        push offset widthCensurer
        call atodw

        mov widthSquare, eax

        ; --- height ---
        
        ; write width message
        push NULL
        push offset consoleCount
        push sizeof heightCensurerMenssage
        push offset heightCensurerMenssage
        push outputHandle
        call WriteConsole

        ; read width
        push NULL
        push offset consoleCount
        push sizeof heightCensurer
        push offset heightCensurer
        push inputHandle
        call ReadConsole

        
        push offset heightCensurer
        call remove_CR_LF

        push offset heightCensurer
        call atodw

        mov heightSquare, eax


        mov eax, fileWidth
    
        
        mov imageWidth, eax

        ; ===== COPY IMAGE =====

        ; LOGIC: 
        ;   lineIndex = 0
        ;   do
        ;       read line from input file
        ;       write line to the output file
        ;       lineIndex++
        ;   while (lineIndex < fileHeight)

         image_loop:

            ; --- read "image line" from input file ---
            push NULL
            push offset readCount
            push 2700
            push offset fileImageBuffer
            push readFileHandle
            call ReadFile

            cmp readCount, 0
            je image_exit
            
            mov esi, lineCount
        ; Verifique se estamos dentro da área a ser censurada
        ;xor ecx, ecx

                cmp esi, pointY
                jl not_censorY ; Se não estiver, vá para a próxima posição

                mov eax, pointY
                add eax, heightSquare


                cmp esi, eax
                jge not_censorY


                

        ; Se estiver dentro da área, aplique a censura
                push widthSquare
                push pointX
                push offset fileImageBuffer
                call censure
                
        ; Verifique se chegamos ao final da linha


        not_censorY:
            push NULL
            push offset writeCount
            push 2700; image width = 900 pixels * 3 bytes
            push offset fileImageBuffer
            push writeFileHandle
            call WriteFile

            inc lineCount
            
            jmp image_loop


        image_exit:
        push inputHandle
        call CloseHandle

        push outputHandle
        call CloseHandle
        
        finish:
            push 0
            call ExitProcess
            


        error_occurred: 
        push STD_OUTPUT_HANDLE
        call GetStdHandle
        mov ecx, eax
        push NULL
        push offset consoleCount
        push sizeof error
        push offset error
        push ecx
        call WriteConsole
        push -1
        call ExitProcess

    end start