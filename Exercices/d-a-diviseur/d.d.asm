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
format_int db "%d", 0
number dd 0 ; créer un endroit pour stocker le nombre
phrase_formatee db "%d|", 0

.CODE

divi PROC
    push ebp
    mov ebp, esp
    pushad

    mov eax, [ebp+8] ; obtenir le nombre à tester
    mov ecx, eax ; mettre le nombre dans ecx (pour les comparaison ds la boucle)
    mov ebx, 1 ; 
    loop_increment:
        ; vérifier si eax heurte la limite
        cmp ebx, ecx
        jg fin_increment ; si oui, sortir de la boucle
        
                                                ; diviser le nombre par ebx
        push eax                                ; on save la valeur de eax
        XOR EDX, EDX                            ; vide EDX (nécessaire car DIV divise le nombre 64 bits dans EDX:EAX par le diviseur -> voir note sur Notion)
        DIV ebx                                 ; divise EAX par EbX, le quotient est stocké dans EAX, le reste dans EDX

        
        cmp edx, 0                              ; vérifier si le reste est nul
        jnz non_divisible                       ; si le reste est non nul, le nombre n'est pas divisible
        
        push ebx
        push offset phrase_formatee
        call crt_printf
        add esp, 8                              ;sinon, le nombre est divisible

        pop eax                                 ; restauration de eax (le divie)
        inc ebx                                    ; incrémente du diviseur

        jmp loop_increment ; recommencer la boucle
    
    non_divisible:
        pop eax                                 ; restauration de eax (le divie)
        inc ebx                                 ; incrémente du diviseur

        jmp loop_increment                      ; recommencer la boucle

    fin_increment:
        popad
        mov esp, ebp
        pop ebp
        ret

divi ENDP

start: 
    lea eax, [number] ; obtenir l'adresse de 'number'               ; lire le nombre de l'utilisateur
    push eax                                                         ; push l'adresse de 'number'
    push offset format_int
    call crt_scanf      
    add esp, 8 ; nettoie la pile

    sub esp, 12                                     ; Crée 12 octets d'espace (3 variables de 4 octets)

    
    mov eax, [number]                                   ; obtenir le nombre stocké
    push eax                                            ; push le nombre
    call divi                                               
    add esp, 8 

    
    push 0
    call ExitProcess
end start