@ECHO off
SET LookForFile="%localappdata%\COMPUTREX\2run.txt"

:CheckForFile
IF EXIST "%LookForFile%" (
GOTO FileFound
) ELSE (
GOTO RunClearJob
)

:RunClearJob
ECHO File not found. Running NK2Edit
start "" "\\192.168.30.24\Computrex\nk2\nk2script.bat"
ECHO Creating First Run File
If not exist "%localappdata%\COMPUTREX\" mkdir "%localappdata%\COMPUTREX\"
echo "First run complete" >> "%localappdata%\COMPUTREX\1run.txt"
ECHO Launching Outlook
start "" "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
Timeout 5
ECHO Running NK2Edit again
Start "" "\\192.168.30.24\Computrex\nk2\nk2script.bat"
ECHO Killing Outlook
taskkill /IM OUTLOOK.EXE /f
ECHO Creating Second Run File
echo "Second run complete" >>"%localappdata%\COMPUTREX\2run.txt"
EXIT


:FileFound
ECHO Found: %LookForFile%
EXIT
