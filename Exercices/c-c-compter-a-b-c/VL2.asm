.386
.model flat, stdcall
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
MotA db "A = %d",10,0
MotB db "B = %d",10,0
MotC db "C = %d",10,0
Mot db "aaabbbccccc",10,0

.CODE
Count PROC
    push ebp
    mov ebp, esp
    sub esp, 12
    mov dword PTR [ebp-12], 0  ; compteur pour 'a'
    mov dword PTR [ebp-8], 0   ; compteur pour 'b'
    mov dword PTR [ebp-4], 0   ; compteur pour 'c'
    mov esi, [ebp+8]           ; charge l'adresse de la chaîne dans esi
    pushad                     ; Sauvegarde des registres

    loop_start:
        mov al, [esi]         
        cmp al,0           
        je end_loop          

        cmp al, 'a'           ; compare al à 'a'
        je increment_a
        cmp al, 'b'           ; compare al à 'b'
        je increment_b
        cmp al, 'c'           ; compare al à 'c'
        je increment_c

        inc esi               
        jmp loop_start       

    increment_a:
        inc dword ptr [ebp-12]
        jmp increment_next

    increment_b:
        inc dword ptr [ebp-8]
        jmp increment_next

    increment_c:                             
        inc dword ptr [ebp-4]
        jmp increment_next

    increment_next:
        inc esi               ; incrémente esi pour pointer au prochain caractère
        jmp loop_start        

    end_loop:
        popad                  ; Restaure les registres
        mov eax, [ebp-12]
        mov ebx, [ebp-8]
        mov ecx, [ebp-4]
        mov esp, ebp
        pop ebp
        ret
Count ENDP

start:
    push offset Mot
    call Count
    push ecx
    push ebx
    push eax
    push offset MotA
    call crt_printf
    add esp, 8            ;nettoie la pile après l'appel d'une foncttion

    ;push ebx
    push offset MotB
    call crt_printf
    add esp, 8

    ;push ecx
    push offset MotC
    call crt_printf
    add esp, 8

    mov eax, 0
    invoke ExitProcess,eax
end start
end
