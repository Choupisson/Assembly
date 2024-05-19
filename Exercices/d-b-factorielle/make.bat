@echo off
c:\masm32\bin\ml /c /Zd /coff fact.asm
c:\\masm32\bin\Link /SUBSYSTEM:CONSOLE fact.obj
pause