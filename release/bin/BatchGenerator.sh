export SCRIPT_PATH="$(readlink -f $(dirname "$0"))"
export JACE_HOME=%SCRIPT_PATH%..
export CLASSPATH="$(JACE_HOME)\lib\asm-3.3.jar":"$(JACE_HOME)\lib\asm-commons-3.3.jar":"$(JACE_HOME)\lib\asm-tree-3.3.jar":"$(JACE_HOME)\lib\jace.jar":"$(JACE_HOME)\lib\logback-classic-0.9.21.jar":"$(JACE_HOME)\lib\logback-core-0.9.21.jar":"$(JACE_HOME)\lib\retroweaver-rt-2.0.7.jar":"$(JACE_HOME)\lib\slf4j-api-1.6.0.jar":"%JACE_HOME%\lib"
java -classpath $(CLASSPATH) jace.proxygen.BatchGenerator $*
