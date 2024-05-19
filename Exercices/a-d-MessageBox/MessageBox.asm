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
start:
    push 0
    push offset MsgTitle
    push offset Phrase
    push 0
    call MessageBox

end start