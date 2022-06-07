if "%ARCH%"=="32" (
   set "PLATFORM=Win32"
) else (
  set "PLATFORM=x64"
)

REM Patch: need an information file for py3c that the package does not provide
echo "Version: 1.4 ?" > %LIBRARY_PREFIX%\py3c.pc.in
REM end-Patch

dir %LIBRARY_INC%
dir %LIBRARY_PREFIX%

call conda list -n base
call conda install -n base %RECIPE_DIR%\serf-1.3.9-h77ee572_2.tar.bz2 -v -v
call conda list -n base

dir %LIBRARY_INC%\*serf*.*
dir %LIBRARY_PREFIX%\*serf*.*
dir /s %LIBRARY_PREFIX%

exit 1

python gen-make.py -t vcproj --vsnet-version=%VS_YEAR% ^
             --with-openssl=%LIBRARY_PREFIX% ^
             --with-zlib=%LIBRARY_PREFIX% ^
             --with-apr=%LIBRARY_PREFIX% ^
             --with-apr-util=%LIBRARY_PREFIX% ^
             --with-apr-iconv=%LIBRARY_PREFIX% ^
             --with-sqlite=%LIBRARY_PREFIX% ^
             --with-py3c=%LIBRARY_PREFIX% ^
             --with-serf=%LIBRARY_PREFIX% ^
             --release
if errorlevel 1 exit 1
exit

rem fix this later
REM             --with-serf=%LIBRARY_INC% ^

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
