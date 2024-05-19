c

.DATA
; variables initialisees
format_int db "%d", 0
number dd 0 ; créer un endroit pour stocker le nombre
Fact     db    "Fact(%d) = %d",10,0

.CODE
Facto PROC
	push ebp
	mov ebp, esp
	mov esi, [esp+8]
	cmp esi, 1
	je end_fact
	dec esi
	push esi
	call Facto
	mov edi, eax
	pop esi
	sub esp, 4
	mov dword PTR [ebp-4],edi
	loop_mul:
		cmp esi, 0
		je end_loop_mul
		add edi, [ebp-4]
		dec esi
		jmp loop_mul
	end_loop_mul:
		mov esp, ebp
		pop ebp
		mov eax, edi
		ret
	end_fact:
		pop ebp
		mov eax, 1
		ret
Facto ENDP
start:
    ; lire le nombre de l'utilisateur
    lea eax, [number] ; obtenir l'adresse de 'number'
    push eax ; push l'adresse de 'number'
    push offset format_int
    call crt_scanf ; appelle scanf
    add esp, 8 ; nettoie la pile
    
    mov eax, [number] ; obtenir le nombre stocké
    push eax ; push le nombre

	;push 5
	call Facto
	push eax

    mov eax, [number] ; obtenir le nombre stocké
    push eax ; push le nombre

	push offset Fact
	call crt_printf
	add ebp, 16
	mov eax, 0
	  	invoke	ExitProcess,eax
end start
