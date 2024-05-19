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
string db "Ceci est un test.",0 ; Chaîne d'entrée



.CODE
; Fonction pour convertir une chaîne en majuscules
; Paramètre : ESI pointe sur la chaîne
ToUpper:
    mov esi, [esp+4] ; Obtenir l'adresse de la chaîne depuis la pile sans altérer ESP
loop_start:
    mov al, [esi]    ; Charger le caractère courant dans AL
    test al, al      ; Tester si la fin de la chaîne est atteinte (caractère nul)
    jz loop_end      ; Si AL est 0, fin de la chaîne, donc sortir de la boucle
    cmp al, 'a'      ; Comparer AL avec 'a'
    jl next_char     ; Si AL < 'a', aller au prochain caractère
    cmp al, 'z'      ; Comparer AL avec 'z'
    jg next_char     ; Si AL > 'z', aller au prochain caractère
    sub al, 32       ; Convertir en majuscule (soustraire 32 de la valeur ASCII)
    mov [esi], al    ; Stocker le caractère converti
next_char:
    inc esi          ; Passer au prochain caractère
    jmp loop_start   ; Répéter la boucle
loop_end:
    ret              ; Retourner

start:
    ; Afficher la chaîne avant la conversion
    push offset string
    call crt_printf
    ; Convertir la chaîne en majuscules
    push offset string
    call ToUpper
    ; Afficher la chaîne après la conversion
    push offset string
    call crt_printf

    ; Appel système pour arrêter correctement un programme
    invoke ExitProcess, 0

end start