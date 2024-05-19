.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\gdi32.inc
include c:\masm32\include\gdiplus.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\gdi32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\msvcrt.lib

.DATA
; variables initialisees
MsgTitle     db    "Fenetre",0
Phrase     db    "Hello World : 42",10,0

.DATA?
; variables non-initialisees (bss)

.CODE
MakeUpperCase PROC
     mov esi, [esp+4] ; Obtenir l'adresse de la chaîne depuis la pile sans altérer ESP
loop_start:
    mov al, [esi]    ; Charger le caractère courant dans AL
    test al, al    
    jz loop_end      
    cmp al, 'a'     
    jl next_char     
    cmp al, 'z'      
    jg next_char     
    sub al, 32       ; Convertir en majuscule (soustraire 32 de la valeur ASCII)
    mov [esi], al    ; Stocker le caractère converti
next_char:
    inc esi          ; Passer au prochain caractère
    jmp loop_start  
loop_end:
    ret             
MakeUpperCase ENDP
start:
    push 0
    push offset MsgTitle
    ;push offset Phrase
    call MakeUpperCase
    push offset Phrase
    push 0
    call MessageBox
        
        mov eax, 0
        invoke    ExitProcess,eax

end start