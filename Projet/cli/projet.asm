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
path db "\*",0
element db "ElementsDuDossier:",0
folder db "Dossier:",0
niveauRecursion DWORD 0
pointSimple db ".",0
formatAffichage db "%s %s",13,10,0
fileHandle HANDLE ?
pointDouble db "..",0
pathFormat db "%s\%s",0
delete db "cls",13,10,0
formatSaisie db "%s",0
prompt db "Saisir le chemin:",13,10,": ",0
exitFormat db "dir /s %s",13,10,0
espaceIndent db "-",0

.CODE

; Concaténation
concatene PROC
    push ebp
    mov ebp, esp
    mov esi, [ebp+8] ; pointer vers la destination string
    mov edi, [ebp+12] ; pointer vers la source string

    ; Trouve la fin de la chaîne de destination
    find_end:
        mov al, [esi]
        inc esi
        test al, al
        jnz find_end
    dec esi

    ; Ajoute la chaîne source à la destination
    append_loop:
        mov al, [edi]
        inc edi
        mov [esi], al
        inc esi
        test al, al
        jnz append_loop

    pop ebp
    ret 8
concatene ENDP




; Parcourir les répertoires et traiter chaque élément
naviguerRepertoire PROC
    push ebp              
    mov ebp, esp          
    sub esp, 1024   ;Réserve 1024 octets sur la pile pour les variables locales

    inc niveauRecursion   ;Incrémente pour la profondeur des appels récursifs
    push MAX_PATH         ;(longueur maximale d'un chemin)
    push [ebp + 8]        ; push premier paramètre de la fonction (chemin du répertoire)
    mov ebx, ebp          
    sub ebx, 578          ; Calcule un offset dans la pile pour une variable temporaire
    push ebx              ; push adresse de cette var (pour utilisation après)

    call crt_strncpy ; Copie le chemin initial dans un buffer local

    push MAX_PATH ;longueur max chemin
    push offset path
    push ebx
    call concatene ; Concatène le chemin avec le masque de recherche "*"

    mov ebx, ebp
    sub ebx, WIN32_FIND_DATA ;permet de pointer au début de la pile
    push ebx
    sub ebx, MAX_PATH
    push ebx
    call FindFirstFile ; Commence la recherche dans le répertoire (https://learn.microsoft.com/fr-fr/windows/win32/api/fileapi/nf-fileapi-findfirstfilea?redirectedfrom=MSDN)
    mov [ebp - 582], eax

    do:
        push ecx 

        mov ebx, ebp
        sub ebx, WIN32_FIND_DATA
        add ebx, 44 

        push ebx
        push offset pointSimple   ;Compare l'élément actuel à "."
        call crt_strcmp
        add esp, 8   ;Nettoie la pile
        cmp eax, NULL   ;Vérifie si les chaînes sont égales
        je suivant   ;Saute si c'est un point (.)

        push ebx
        push offset pointDouble   ;Compare l'élément actuel à ".."
        call crt_strcmp
        add esp, 8   ;Nettoie la pile
        cmp eax, NULL  
        je suivant   ;Saute si c'est deux points (..)

        push [ebp-WIN32_FIND_DATA]
        mov ebx, ebp
        sub ebx, WIN32_FIND_DATA
        add ebx, 44   ;Ajuste ebx pour pointer à nouveau sur l'élément spécifique
        push ebx
        call visu ; Affiche les informations de l'élément courant
        add esp, 8   ;Nettoie 

        mov ebx, ebp
        sub ebx, WIN32_FIND_DATA
        cmp DWORD PTR [ebx], FILE_ATTRIBUTE_DIRECTORY   ;vérifie si c'est un dossier
        jne pasDossier   ;continue si ce n'est pas un dossier

        mov ebx, ebp
        sub ebx, WIN32_FIND_DATA
        add ebx, 44
        push ebx
        push [ebp + 8]   ;push l'adresse de base
        push offset pathFormat   ;Format pour sprintf
        mov ebx, ebp
        sub ebx, 852   ;calcule l'adresse de destination pour sprintf
        push ebx
        call crt_sprintf   ;formate le chemin complet
        add esp, 16   ;Nettoie la pile

        push ebx
        call naviguerRepertoire   ; récursivité pour explorer le sous-dossier
        pasDossier:   ;continuer si ce n'est pas un dossier /!\


    suivant:
        mov ebx, ebp
        sub ebx, WIN32_FIND_DATA
        push ebx
        push [ebp - 582]
        call FindNextFile

        pop ecx
        cmp eax, NULL
    jne do

    dec niveauRecursion
    mov esp, ebp
    pop ebp
    ret
naviguerRepertoire ENDP



; Affiche les informations sur le fichier ou dossier
visu PROC
    push ebp
    mov ebp, esp

    mov ecx, niveauRecursion
    boucleVisualisation:
        push ecx

        push offset espaceIndent
        call crt_printf ; Affiche les indentations selon niveau de récursion

        add esp, 4
        pop ecx
        loop boucleVisualisation

    mov edx, offset element
    cmp DWORD PTR [ebp + 12], FILE_ATTRIBUTE_DIRECTORY
    jne afficheFichier
    mov edx, offset folder
    afficheFichier:

    push [ebp + 8]
    push edx
    push offset formatAffichage
    call crt_printf ; Affiche le nom du fichier ou dossier 

    mov esp, ebp
    pop ebp
    ret
visu ENDP




start:
    sub esp, MAX_PATH
    mov niveauRecursion, 0

    push offset prompt
    call crt_printf

    mov ebx, ebp
    sub ebx, MAX_PATH
    push ebx
    push offset formatSaisie
    call crt_scanf
    add esp, 8

    invoke crt_system, offset delete

    push ebx
    push offset exitFormat
    call crt_printf

    push ebx
    call naviguerRepertoire

    mov eax, 0
    invoke ExitProcess, eax
end start
