.386
.model flat,stdcall
option casemap:none

include c:\masm32\include\windows.inc
include c:\masm32\include\user32.inc
include c:\masm32\include\kernel32.inc
include c:\masm32\include\msvcrt.inc

includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
includelib c:\masm32\lib\msvcrt.lib

WinMain proto :DWORD

.DATA
ClassName       db "SimpleWinClass",0
AppName         db "File Explorer",0
pathBuffer      db 256 dup(?)
ButtonClassName db "button",0
EditClassName   db "edit",0

.DATA?
hInstance HINSTANCE ?
hButton   HWND ?
hEdit     HWND ?

; Définition des variables pour la navigation
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

start:
    invoke  GetModuleHandle, NULL
    mov     hInstance, eax
    invoke  WinMain, hInstance, NULL, NULL, SW_SHOWDEFAULT
    invoke  ExitProcess, eax

; Fonction principale
WinMain proc hInst:HINSTANCE, hPrevInst:HINSTANCE, CmdLine:LPSTR, CmdShow:DWORD
    LOCAL wc:WNDCLASSEX
    LOCAL msg:MSG
    LOCAL hwnd:HWND

    mov     wc.cbSize, SIZEOF WNDCLASSEX
    mov     wc.style, CS_HREDRAW or CS_VREDRAW
    mov     wc.lpfnWndProc, OFFSET WndProc
    mov     wc.cbClsExtra, NULL
    mov     wc.cbWndExtra, NULL
    mov     wc.hInstance, hInst
    mov     wc.hbrBackground, COLOR_WINDOW+1
    mov     wc.lpszMenuName, NULL
    mov     wc.lpszClassName, OFFSET ClassName
    invoke  LoadIcon, NULL, IDI_APPLICATION
    mov     wc.hIcon, eax
    mov     wc.hIconSm, eax
    invoke  LoadCursor, NULL, IDC_ARROW
    mov     wc.hCursor, eax
    invoke  RegisterClassEx, addr wc

    invoke  CreateWindowEx, NULL, ADDR ClassName, ADDR AppName, WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 500, 300, NULL, NULL, hInst, NULL
    mov     hwnd, eax
    invoke  ShowWindow, hwnd, SW_SHOWNORMAL
    invoke  UpdateWindow, hwnd

    ; Création du bouton et de la zone de texte
    invoke  CreateWindowEx, 0, ADDR EditClassName, NULL, WS_CHILD or WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL, 10, 10, 470, 20, hwnd, 1001, hInst, NULL
    mov     hEdit, eax
    invoke  CreateWindowEx, 0, ADDR ButtonClassName, "Explore", WS_CHILD or WS_VISIBLE or BS_PUSHBUTTON, 400, 40, 80, 30, hwnd, 1002, hInst, NULL
    mov     hButton, eax

main_loop:
    invoke  GetMessage, ADDR msg, NULL, 0, 0
    test    eax, eax
    jz      end_loop
    invoke  TranslateMessage, ADDR msg
    invoke  DispatchMessage, ADDR msg
    jmp     main_loop

end_loop:
    mov     eax, msg.wParam
    ret

WinMain endp

; Fonction de traitement des messages
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
    LOCAL ps:PAINTSTRUCT
    LOCAL rect:RECT
    LOCAL hdc:HDC

    mov     eax, uMsg
    cmp     eax, WM_DESTROY
    je      destroy_window
    cmp     eax, WM_COMMAND
    je      command_received

default_proc:
    invoke  DefWindowProc, hWnd, uMsg, wParam, lParam
    ret

destroy_window:
    invoke  PostQuitMessage, NULL
    ret

command_received:
    mov     eax, wParam
    cmp     eax, 1002
    jne     default_proc
    invoke  GetWindowText, hEdit, ADDR pathBuffer, 256
    invoke  naviguerRepertoire, ADDR pathBuffer ; Adapter cette fonction selon vos besoins
    ret

WndProc endp

; Procédures pour la navigation 

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
        sub ebx, 842   ;calcule l'adresse de destination pour sprintf
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

end start
