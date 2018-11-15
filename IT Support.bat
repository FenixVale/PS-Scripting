@ECHO off
MODE CON: LINES=35 COLS=100

:again
ECHO.
ECHO                                           Master Utility Script
ECHO.
ECHO              __________________________________________________________________________
ECHO             [                                                                          ]
ECHO             [                                                                          ]
ECHO             [   [1] Reset Local Admin Password                                         ]
ECHO             [                                                                          ] 
ECHO             [   [2] Refresh IP Configuration                                           ]
ECHO             [       Release, Renew, and Flush IP Configuration                         ] 
ECHO             [                                                                          ]   
ECHO             [   [3] Ping Google DNS                                                    ]
ECHO             [       Pings both the primary and secondary DNS servers                   ] 
ECHO             [                                                                          ] 
ECHO             [   [4] Ping Active Directory                                              ]
ECHO             [       Pings Active Directory and provides IP/PC names                    ] 
ECHO             [                                                                          ] 
ECHO             [   [5] Ping A Website/IP Address                                          ] 
ECHO             [                                                                          ] 
ECHO             [   [6] Trace A Website/IP Address                                         ] 
ECHO             [                                                                          ] 
ECHO             [   [7] Clear Print Spooler                                                ]
ECHO             [                                                                          ] 
ECHO             [   [8] Remap S: Drive                                                     ]
ECHO             [       Removes and remaps the share drive                                 ] 
ECHO             [                                                                          ] 
ECHO             [   [9] PC Cleanup Utility                                                 ] 
ECHO             [       Clear Cookies/Temp Files/Defrag Disk/Cleanup Disk                  ] 
ECHO             [                                                                          ] 
ECHO             [   [0] Quit                                                               ]
ECHO             [                                                                          ]
ECHO             [__________________________________________________________________________]  
ECHO.            
ECHO.
set /p mastch=Please select an option:  
ECHO.
if [%mastch%]==[0] goto quit
if [%mastch%]==[ ] goto again
if [%mastch%]==[1] goto admin
if [%mastch%]==[2] goto refresh
if [%mastch%]==[3] goto pingdns
if [%mastch%]==[4] goto active
if [%mastch%]==[5] goto pingweb
if [%mastch%]==[6] goto tracert
if [%mastch%]==[7] goto print
if [%mastch%]==[8] goto remap
if [%mastch%]==[9] goto clean
ECHO.
CLS
ECHO INCORRECT CHOICE, CHOOSE AGAIN
goto again
ECHO.

:admin
CLS
ECHO.
ECHO              __________________________________________________________________________
ECHO             [                                                                          ]
ECHO             [                                                                          ]
ECHO             [   [1] Set Default USTN Admin Password                                    ]
ECHO             [                                                                          ]   
ECHO             [   [2] Set Custom Admin Password                                          ]
ECHO             [                                                                          ]   
ECHO             [   [0] Return To Main Menu                                                ]
ECHO             [                                                                          ]  
ECHO             [__________________________________________________________________________] 
ECHO.
set /p adch=Please select an option:
ECHO.
if [%adch%]==[0] goto ret
if [%adch%]==[ ] goto admin
if [%adch%]==[1] goto admindef
if [%adch%]==[2] goto admincus
ECHO.
CLS
goto admin
ECHO.

:admindef
echo Updating Admin Account
net user administrator 8786@dmiN /active:yes
ECHO.
ECHO Local Admin Account Enabled.
ECHO Password Reset to "8786@dmiN"
goto done

:admincus
ECHO Password must be at least 8 characters, and include a number, and a capital letter.
set /p pass=Please enter the desired password:
ECHO.
echo Updating Admin Account
net user administrator %pass% /active:yes
ECHO.
ECHO Local Admin Account Enabled.
ECHO Password Reset to "%pass%"
goto done

:refresh
ECHO.
ipconfig /release
ECHO.
ECHO.
echo [    5...4...3...2...1...    ]
ECHO.
ECHO.
ipconfig /flushdns
ECHO.
ECHO.
echo [    5...4...3...2...1...    ]
ECHO.
ECHO.
ipconfig /renew
ECHO.
goto done

:pingdns
ECHO.
@ECHO Pinging Google Primary DNS Server
ping 8.8.8.8
ECHO.
@ECHO Pinging Google Secondary DNS Server
ping 8.8.4.4
ECHO.
goto done

:active
ECHO.
SETLOCAL ENABLEDELAYEDEXPANSION
echo The following computers are on (and responding in less than 150mS)

for /f %%c in ('dsquery computer -limit 2000 -o rdn') do @(
  
    ping %%~c -n 1 -w 150 >nul
    if !errorlevel!==0 (
        for /f "tokens=3 delims=: " %%i in ('ping %%~c -n 1 -w 150 ^| find "Reply from"') do set ip=%%i 
        echo %%~c - !ip!^
    )

)
ECHO.
goto done

:pingweb
ECHO.
set /p address=Please enter the website or IP Address you would like to ping:
ECHO.
ECHO Pinging %address%
ping %address%
ECHO.
goto done

:tracert
ECHO.
set /p address=Please enter the website or IP Address you would like to trace:
ECHO.
ECHO Tracing %address%
tracert %address%
ECHO.
goto done

:print
ECHO.
@ECHO Clearing Print Spooler...
net stop spooler
del %systemroot%\System32\spool\printers\* /Q
ECHO.
net start spooler
goto done

:remap
ECHO.
@ECHO Remapping S:\
ECHO.
ECHO Deleting Current Mapping...
net use /del S:
ECHO.
ECHO Reassigning Mapping...
net use S: \\radiatemedia\corp
ECHO Completed
ECHO.
goto done

:clean
CLS
ECHO.
ECHO                                         PC Cleanup Utility                               
ECHO              __________________________________________________________________________
ECHO             [                                                                          ] 
ECHO             [   [1] Delete Cookies                                                     ]
ECHO             [                                                                          ] 
ECHO             [   [2] Delete Temporary Files                                             ]
ECHO             [       Clears temporary internet files                                    ] 
ECHO             [                                                                          ] 
ECHO             [   [3] Disk Cleanup                                                       ]
ECHO             [       Runs a cleanup of the user folder                                  ] 
ECHO             [                                                                          ] 
ECHO             [   [4] Disk Defrag                                                        ] 
ECHO             [       Defragments the local hard drives                                  ] 
ECHO             [                                                                          ] 
ECHO             [   [0] Return To Main Menu                                                ]
ECHO             [__________________________________________________________________________]  
ECHO.
set /p cleanch=Please select an option:
ECHO.
if [%cleanch%]==[0] goto ret
if [%cleanch%]==[ ] goto clean
if [%cleanch%]==[1] goto cookie
if [%cleanch%]==[2] goto temp
if [%cleanch%]==[3] goto dcleanup
if [%cleanch%]==[4] goto defrag
ECHO.
ECHO INCORRECT CHOICE, CHOOSE AGAIN
goto clean
ECHO.

:ret
ECHO.
CLS
goto again

:cookie
ECHO.
ECHO Deleting Cookies...
del /f /q "%userprofile%\Cookies\*.*"
ECHO Cookies Deleted
goto cdone

:temp
ECHO.
ECHO Deleting Temporary Files...
del /f /q "%userprofile%\AppData\Local\Microsoft\Windows\Temporary Internet Files\*.*"
ECHO Temporary Internet Files Deleted
goto cdone


:dcleanup
ECHO.
ECHO Running Disk Cleanup
if exist "C:\WINDOWS\temp"del /f /q "C:WINDOWS\temp\*.*"
if exist "C:\WINDOWS\tmp" del /f /q "C:\WINDOWS\tmp\*.*"
if exist "C:\tmp" del /f /q "C:\tmp\*.*"
if exist "C:\temp" del /f /q "C:\temp\*.*"
if exist "%temp%" del /f /q "%temp%\*.*"
if exist "%tmp%" del /f /q "%tmp%\*.*"
if not exist "C:\WINDOWS\Users\*.*" goto skip
if exist "C:\WINDOWS\Users\*.zip" del "C:\WINDOWS\Users\*.zip" /f /q
if exist "C:\WINDOWS\Users\*.exe" del "C:\WINDOWS\Users\*.exe" /f /q
if exist "C:\WINDOWS\Users\*.gif" del "C:\WINDOWS\Users\*.gif" /f /q
if exist "C:\WINDOWS\Users\*.jpg" del "C:\WINDOWS\Users\*.jpg" /f /q
if exist "C:\WINDOWS\Users\*.png" del "C:\WINDOWS\Users\*.png" /f /q
if exist "C:\WINDOWS\Users\*.bmp" del "C:\WINDOWS\Users\*.bmp" /f /q
if exist "C:\WINDOWS\Users\*.avi" del "C:\WINDOWS\Users\*.avi" /f /q
if exist "C:\WINDOWS\Users\*.mpg" del "C:\WINDOWS\Users\*.mpg" /f /q
if exist "C:\WINDOWS\Users\*.mpeg" del "C:\WINDOWS\Users\*.mpeg" /f /q
if exist "C:\WINDOWS\Users\*.ra" del "C:\WINDOWS\Users\*.ra" /f /q
if exist "C:\WINDOWS\Users\*.ram" del "C:\WINDOWS\Users\*.ram"/f /q
if exist "C:\WINDOWS\Users\*.mp3" del "C:\WINDOWS\Users\*.mp3" /f /q
if exist "C:\WINDOWS\Users\*.mov" del "C:\WINDOWS\Users\*.mov" /f /q
if exist "C:\WINDOWS\Users\*.qt" del "C:\WINDOWS\Users\*.qt" /f /q
if exist "C:\WINDOWS\Users\*.asf" del "C:\WINDOWS\Users\*.asf" /f /q
ECHO.
ECHO Disk Cleanup Completed
goto cdone

:defrag
ECHO.
ECHO Running Disk Defrag
ECHO Defragging local hard disks....
defrag -c -v
ECHO.
ECHO Disk Defrag Completed
goto cdone

:skip
if not exist C:\WINDOWS\Users\Users\*.* goto skip2 /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.zip del C:\WINDOWS\Users\Users\*.zip /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.exe del C:\WINDOWS\Users\Users\*.exe /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.gif del C:\WINDOWS\Users\Users\*.gif /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.jpg del C:\WINDOWS\Users\Users\*.jpg /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.png del C:\WINDOWS\Users\Users\*.png /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.bmp del C:\WINDOWS\Users\Users\*.bmp /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.avi del C:\WINDOWS\Users\Users\*.avi /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.mpg del C:\WINDOWS\Users\Users\*.mpg /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.mpeg del C:\WINDOWS\Users\Users\*.mpeg /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.ra del C:\WINDOWS\Users\Users\*.ra /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.ram del C:\WINDOWS\Users\Users\*.ram /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.mp3 del C:\WINDOWS\Users\Users\*.mp3 /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.asf del C:\WINDOWS\Users\Users\*.asf /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.qt del C:\WINDOWS\Users\Users\*.qt /f /q
if exist C:\WINDOWS\Users\AppData\Temp\*.mov del C:\WINDOWS\Users\Users\*.mov /f /q

:skip2
if exist "C:\WINDOWS\ff*.tmp" del C:\WINDOWS\ff*.tmp /f /q
if exist C:\WINDOWS\ShellIconCache del /f /q "C:\WINDOWS\ShellI~1\*.*"

:cdone
ECHO.
ECHO [        ACTION COMPLETED         ]
ECHO.
pause
cls
goto clean

:done
ECHO.
ECHO [        ACTION COMPLETED         ]
ECHO.
pause
cls
goto again

:quit
cls
:exit
