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
.code

    start:
        invoke CreateFile, addr file, GENERIC_READ, 0, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0
        cmp eax, 0
        jg dimensionerSizeOfArq
        jmp finishPart

        dimensionerSizeOfArq:
            invoke GetFileSize, eax, 0
            push eax
            push offset fileSizeMessage
            printf( "Tamanho do arquivo: %d bytes", eax)
            add esp, 8

            invoke CloseHandle, eax

        finishPart:
            invoke ExitProcess, 0

    end start