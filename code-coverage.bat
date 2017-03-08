REM create a code coverage report by means of CodeCoverage
REM
REM 1. Download the program from https://sourceforge.net/projects/delphicodecoverage/files/latest/download
REM 2. Save the CodeCoverage.exe and remember the location
REM 3. Activate the mapping of the executable of the tests: Project -> Options -> Delphi Compiler -> Linking -> select "Detailed"
REM 4. Execute the tests in order to have *.map file created
REM
REM The following script should be run form a folder containing units whose code coverage we want to create. 
REM The CodeCoverage.exe is in the parent folder.


..\CodeCoverage.exe -e Tests\Win32\Debug\Tests.exe -m Tests\Win32\Debug\Tests.map -od out\report\ -html -lt -u FrontEndRequest BackEndRequest