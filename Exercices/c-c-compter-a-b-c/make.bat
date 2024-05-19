@echo off
c:\masm32\bin\ml /c /Zd /coff VL2.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE VL2.obj
pause