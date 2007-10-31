::
:: distall.bat
::
:: Rebuilds all of Whirled on the command line

@echo off

set CP=lib\ant-launcher.jar;lib\ant.jar
set CLASS=org.apache.tools.ant.launch.Launcher
java -classpath %CP% %CLASS% distcleanall
java -classpath %CP% %CLASS% distall
pause
