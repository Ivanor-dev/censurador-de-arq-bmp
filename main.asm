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

    pointXCensurerMenssage db "point X to censure (natural): ", 0H
    pointXCensurer db 3 dup(0)
    pointX dd 0

    pointYCensurerMenssage db "point Y to censure (natural): ", 0H
    pointYCensurer db 3 dup(0)
    pointY dd 0

    widthCensurerMenssage db "width of black square (natural): ", 0H
    widthCensurer db 3 dup(0)
    widthSquare dd 0

    heightCensurerMenssage db "height of black square (natural): ", 0H
    heightCensurer db 3 dup(0)
    heightSquare dd 0

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

    integerString db "1234", 0
    integer dd 0



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

    dbtodd:
        push ebp
        mov ebp, esp
        sub esp, 8
        
    

        mov esi, [ebp + 8] ; passa o primeiro parametro para esi
        next_position:
            mov al, [esi] ; passa o caraciter da posição para al
            inc esi ; incrementa esi para acessar a proxima posição
            cmp al, 48 ; compara o valor dos caracteres
            jl finish_convertion ; sendo menor acaba a converção
            cmp al, 58 ; compara o valor dos caracteres
            jl next_position ; vai par a proxima posição
        finish_convertion:
            dec esi ; decrece o esi
            xor al, al ; zera al
            mov [esi], al ; põe o caracter nulo na posição de esi
        
        push [ebp + 8]
        call atodw ; chamada para função de tradução
        mov esi, [ebp + 12] ; passagem do parametro 2 para esi

        mov DWORD PTR [esi], eax ; atribuição de eax para o parametro 2

        mov esp, ebp
        pop ebp
        ret 4

    start:

        ; ===== USER INPUT =====
        push offset integer
        push offset integerString
        call dbtodd

        printf("%d\n", integer)


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

        push offset pointX
        push offset pointXCensurer
        call dbtodd

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

        push offset pointY
        push offset pointYCensurer
        call dbtodd

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

        push offset widthSquare
        push offset widthCensurer
        call dbtodd

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

        push offset heightSquare
        push offset heightCensurer
        call dbtodd

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