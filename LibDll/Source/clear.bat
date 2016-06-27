@echo off
if exist *.~* del *.~*
if exist *.dcu del *.dcu

cd ./BackRestore
if exist *.~* del *.~*
if exist *.dcu del *.dcu

cd ../DlgMsg
if exist *.~* del *.~*
if exist *.dcu del *.dcu

cd ../ZipStream
if exist *.~* del *.~*
if exist *.dcu del *.dcu