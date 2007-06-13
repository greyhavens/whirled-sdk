::
:: fatserver.bat
::
:: Runs the ant task for running the FAT server with GUI

@echo off

set CP=dist\lib\ant-launcher.jar;dist\lib\ant.jar
set CLASS=org.apache.tools.ant.launch.Launcher
java -classpath %CP% %CLASS% fatserver
