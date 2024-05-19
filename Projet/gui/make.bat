@echo off
c:\masm32\bin\ml /c /Zd /coff projetGui.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE projetGui.obj
pause