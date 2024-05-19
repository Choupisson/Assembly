@echo off
c:\masm32\bin\ml /c /Zd /coff d.d.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE d.d.obj
pause