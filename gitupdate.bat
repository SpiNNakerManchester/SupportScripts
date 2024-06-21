:: Copyright (c) 2022 The University of Manchester
::
:: Licensed under the Apache License, Version 2.0 (the "License");
:: you may not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
::     https://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an "AS IS" BASIS,
:: WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.

:: This script assumes it is run from the directory holding all github projects in parellel
:: sh SupportScripts/gitupdate.sh a_branch_name

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