@echo off
c:\masm32\bin\ml /c /Zd /coff Routine.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE Routine.obj
pause