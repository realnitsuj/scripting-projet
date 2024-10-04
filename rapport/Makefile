PD=pandoc
PUML=plantuml

all: doc-utilisateur.pdf memoire-technique.pdf

doc-utilisateur.pdf: doc-utilisateur.md
	$(PD) settings.yaml doc-utilisateur.md -o doc-utilisateur.pdf

memoire-technique.pdf: memoire-technique.md activite.svg
	$(PD) settings.yaml memoire-technique.md -o memoire-technique.pdf

activite.svg: activite.puml
	$(PUML) -tsvg activite.puml
