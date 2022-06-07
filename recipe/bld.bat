if "%ARCH%"=="32" (
   set "PLATFORM=Win32"
) else (
  set "PLATFORM=x64"
)

REM Patch: need an information file for py3c that the package does not provide
echo "Version: 1.4 ?" > %LIBRARY_PREFIX%\py3c.pc.in
REM end-Patch

Set-PSDebug -Trace 1

REM echo  BUILD_PREFIX
REM echo  %BUILD_PREFIX%
REM dir %BUILD_PREFIX%

REM echo  PREFIX
REM echo  %PREFIX%
REM dir %PREFIX%

REM call conda env list

call conda install -p %PREFIX% %RECIPE_DIR%\serf-1.3.9-h77ee572_2.tar.bz2

REM call conda list -p %PREFIX%

REM dir %LIBRARY_INC%\*serf*.*
REM dir %LIBRARY_PREFIX%\*serf*.*
REM dir /s %LIBRARY_PREFIX%

REM call conda list -n %BUILD_PREFIX%


python gen-make.py -t vcproj --vsnet-version=%VS_YEAR% ^
             --with-openssl=%LIBRARY_PREFIX% ^
             --with-zlib=%LIBRARY_PREFIX% ^
             --with-apr=%LIBRARY_PREFIX% ^
             --with-apr-util=%LIBRARY_PREFIX% ^
             --with-apr-iconv=%LIBRARY_PREFIX% ^
             --with-sqlite=%LIBRARY_PREFIX% ^
             --with-py3c=%LIBRARY_PREFIX% ^
             --with-serf=%LIBRARY_INC% ^
             --release
if errorlevel 1 exit 1

msbuild subversion_vcnet.sln ^
        /t:__ALL_TESTS__ ^
        /p:Configuration=Release ^
        /p:Platform=%PLATFORM% ^
        /p:WindowsTargetPlatformVersion=%WindowsSDKVer%
if errorlevel 1 exit 1

pushd Release\subversion

FOR /D %%D in (.\*svn*) do (
    pushd %%D
    for %%F in (.\*.exe) do MOVE %%F %LIBRARY_BIN%\
    for %%F in (.\*.dll) do MOVE %%F %LIBRARY_BIN%\
    for %%F in (.\*.lib) do MOVE %%F %LIBRARY_LIB%\
    popd
)

popd
