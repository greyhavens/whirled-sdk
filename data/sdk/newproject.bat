::
:: newproject.bat
::
:: Runs the ant task for creating a new project

@echo off

set CP=dist\lib\ant-launcher.jar;dist\lib\ant.jar
set CLASS=org.apache.tools.ant.launch.Launcher
java -classpath %CP% %CLASS% newproject
pause
