.686
.model flat, stdcall
option casemap: none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\masm32.inc
includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\masm32.lib

.data
    inputString db 50 dup(0)
    inputHandle dd 0
    outputHandle dd 0
    console_count dd 0
    tamanho_string dd 0
    phraseToInput db "Digite algo: ", 0

.code
    start:
        invoke GetStdHandle, STD_INPUT_HANDLE
        mov inputHandle, eax
        invoke GetStdHandle, STD_OUTPUT_HANDLE
        mov outputHandle, eax
        invoke WriteConsole, outputHandle, addr phraseToInput, sizeof phraseToInput, addr console_count, NULL
        invoke ReadConsole, inputHandle, addr inputString, sizeof inputString, addr console_count, NULL
        invoke StrLen, addr inputString
        mov tamanho_string, eax
        invoke WriteConsole, outputHandle, addr inputString, tamanho_string, addr console_count, NULL
        invoke ExitProcess, 0
    end start