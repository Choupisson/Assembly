@echo off
c:\masm32\bin\ml /c /Zd /coff Variableslocales.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE Variableslocales.obj
pause