@ECHO off
SET LookForFile="%localappdata%\NK2\2run.txt"

:CheckForFile
IF EXIST "%LookForFile%" (
GOTO FileFound
) ELSE (
GOTO RunClearJob
)

:RunClearJob
ECHO File not found. Running NK2Edit
start "" "\\ENTERDIRECTORY\nk2\nk2script.bat"
ECHO Creating First Run File
If not exist "%localappdata%\NK2\" mkdir "%localappdata%\NK2\"
echo "First run complete" >> "%localappdata%\NK2\1run.txt"
ECHO Launching Outlook
start "" "C:\Program Files (x86)\Microsoft Office\root\Office16\OUTLOOK.EXE"
Timeout 5
ECHO Running NK2Edit again
Start "" "\\ENTERDIRECTORYnk2\nk2script.bat"
ECHO Killing Outlook
taskkill /IM OUTLOOK.EXE /f
ECHO Creating Second Run File
echo "Second run complete" >>"%localappdata%\NK2\2run.txt"
EXIT


:FileFound
ECHO Found: %LookForFile%
EXIT
