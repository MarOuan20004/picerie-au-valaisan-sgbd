# ==============================================================================
# Makefile - Au Valaisan SGBD & Démonstrateur JDBC
# Université Grenoble Alpes - Ensimag
# ==============================================================================

JAVAC       := javac
JAVA        := java
MVN         := mvn
CP_SEP      := :
LIBS_DIR    := libs
JDBC_JAR    := $(LIBS_DIR)/ojdbc17.jar
SRC_DIR     := src/main/java
RESOURCES   := src/main/resources
BIN_DIR     := bin
TARGET_DIR  := target

CLASSPATH   := $(BIN_DIR)$(CP_SEP)$(JDBC_JAR)$(CP_SEP)$(RESOURCES)

SOURCES     := $(shell find $(SRC_DIR) -name "*.java")

.PHONY: all compile compile-mvn run-client run-epicier run-systeme clean package help

all: compile

## compile       : Compile les sources Java avec javac et le pilote ojdbc17
compile:
	@mkdir -p $(BIN_DIR)
	@echo "Compilation des sources Java..."
	$(JAVAC) -encoding UTF-8 -cp "$(JDBC_JAR)" -d $(BIN_DIR) $(SOURCES)
	@echo "Compilation terminee avec succes dans $(BIN_DIR)/"

## compile-mvn   : Compile le projet via Apache Maven
compile-mvn:
	$(MVN) compile

## run-client    : Lance l'application Espace Client (UtilisateurApp)
run-client: compile
	$(JAVA) -cp "$(CLASSPATH)" jdbc.UtilisateurApp

## run-epicier   : Lance l'application Espace Epicier / Gerant (EpicierApp)
run-epicier: compile
	$(JAVA) -cp "$(CLASSPATH)" jdbc.EpicierApp

## run-systeme   : Lance le service demon de surveillance des peremptions (SystemeEpicerie)
run-systeme: compile
	$(JAVA) -cp "$(CLASSPATH)" jdbc.SystemeEpicerie

## package       : Construit le package JAR executable via Maven
package:
	$(MVN) package

## clean         : Supprime les fichiers compiles bin/ et target/
clean:
	@rm -rf $(BIN_DIR) $(TARGET_DIR)
	@echo "Nettoyage effectue."

## help          : Affiche cette aide
help:
	@echo "Commandes disponibles pour le projet Au Valaisan :"
	@echo "  make compile      - Compile les fichiers Java vers bin/"
	@echo "  make compile-mvn  - Compile via Maven vers target/"
	@echo "  make run-client   - Lance l'interface Espace Client"
	@echo "  make run-epicier  - Lance l'interface Espace Epicier"
	@echo "  make run-systeme  - Lance le daemon d'alertes peremption"
	@echo "  make package      - Construit le package JAR"
	@echo "  make clean        - Nettoie les repertoires de build"
	@echo "  make help         - Affiche cette aide"
