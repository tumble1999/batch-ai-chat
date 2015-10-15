@echo off
setlocal enabledelayedexpansion
cd %~dp0
set home=_chat
set aiHome=ai
set aiMsgSave=%aiHome%\msg.txt
if not exist %home% mkdir %home%
cd %home%
title Chat
if exist chat.txt call :archive chat.txt
set userName=user
set /p userName=username:
set aiName=ai

title %aiName% - Chat
cls
call :run
goto :eof

:run
	:loop
		call :userMsg
		call :aiMsg
		call :render
	goto loop
goto :eof

:userMsg
	set userMsg=
	set /p userMsg=%userName%: 
	call :send %userName% %userMsg%
goto :eof

:aiMsg
	if not exist %aiHome% mkdir %aiHome%
	if not exist %aiHome%\responses mkdir %aiHome%\responses
	
	call :addAiSave "%aiMsgSave%" "%userMsg%"
	if defined aiMsg call :addAiSave "%aiHome%\responses\%aiMsg%.txt" "%userMsg%"
	
	set aiMsg=

	if exist "%aiHome%\responses\%userMsg%.txt" call :aiGetMessage "%aiHome%\responses\%userMsg%.txt"
	
	if not defined aiMsg call :aiGetMessage %aiMsgSave%
	
	if not defined aiMsg set aiMsg=...
	set msgPointer=
	call :send %aiName% %aiMsg%
goto :eof

:addAiSave
	if not exist "%~1" (
		(echo 0)>"%~1"
	)

	set /p msgNum=<%1
	for /f "tokens=* skip=1" %%a in (%~1) do (
		if %%a==%~2 (
			goto stop-addAiSave
		)
	)
	copy %1 "%~1.tmp">nul
	set /a msgNum+=1
	(echo %msgNum%)>"%~1"
	for /f "tokens=* skip=1" %%a in (%~1.tmp) do (
		(echo %%a)>>"%~1"
	)
	del "%~1.tmp"
	(echo %~2)>>%1
	:stop-addAiSave
goto :eof

:aiGetMessage
	set /p msgNum=<"%*"
	set msgPointer=%random%
	set /a msgPointer%%=msgNum
	set /a msgPointer+=1
	
	if not %msgNum%==0 (
		for /f "tokens=* skip=1" %%a in (%*) do (
			set /a msgPointer-=1
			if !msgPointer! leq 0 (
				set aiMsg=%%a
				goto :eof
			)
		)
	)
goto :eof

:render
	cls
	if exist chat.txt type chat.txt
goto :eof

:send
set msg=%*
	(echo %1: !msg:%1 =!)>>chat.txt
goto :eof

:archive
set name=%~n1 %~t1%~x1
set name=%name::=-%
set name=%name:/=-%
rename %1 %name: =_%
if not exist archives mkdir archives
move %name: =_% archives>nul
goto :eof