.686

.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc ; nessa lib tem a leitura de arquivos 
include \masm32\include\msvcrt.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\msvcrt.lib
include \masm32\macros\macros.asm

.data
    file db "fotoanonima.bmp", 0
    fileSizeMessage db "Tamanho do arquivo: %d bytes", 0
    bufferSize = 256
    buffer db bufferSize dup(?)
    prompt db "Digitar nome do arquivo: ", 0
    outputHandle dd 0
    output dd 0
    write_count dd 0

.data?
    hStdOut HANDLE ?

.code


    start:
     mov esi, offset file ; Armazenar apontador da string em esi
    proximo:
        mov al, [esi] ; Mover caractere atual para al
        inc esi ; Apontar para o proximo caractere
        cmp al, 13 ; Verificar se eh o caractere ASCII CR - FINALIZAR
        jne proximo
        dec esi ; Apontar para caractere anterior
        xor al, al ; ASCII 0
        mov [esi], al ; Inserir ASCII 0 no lugar do ASCII CR
        
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov hStdOut, eax
        invoke CreateFile, addr file, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        cmp eax, 0
        jg dimensionerSizeOfArq
        jmp finishPart

        dimensionerSizeOfArq:
            invoke GetFileSize, ebx, 0 
            invoke WriteConsole, hStdOut, addr output, sizeof output, addr write_count, NULL
            add esp, 8
            invoke CloseHandle, ebx

        finishPart:
            invoke ExitProcess, 0

    end start