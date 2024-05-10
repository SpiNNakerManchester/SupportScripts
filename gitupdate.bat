for /d %%i in (%cd%\*) do (CALL :do_dir %%i %~1 || EXIT /B)
ECHO SUCCESS!
EXIT /B

:do_dir
    cd %~1
    git fetch
    if %ERRORLEVEL% EQU 0 (
        (CALL :do_git %~2 || EXIT /B 1)
    )
    cd ..
    EXIT /B

:do_git
    (git checkout master && call :do_default master %~1) || (git checkout main && CALL :do_default main %~1) || EXIT /B 1
    EXIT /B
	
:do_default
    (git merge origin/%~1) || (EXIT /B 1)
    (git checkout %~2) || (EXIT /B 0)
    (git merge %~1 || EXIT /B 1)
    git merge origin/%~2
    EXIT /B 0