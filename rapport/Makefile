PD=pandoc
PUML=plantuml

all: doc-utilisateur.pdf doc-technique.pdf

doc-utilisateur.pdf: doc-utilisateur.md
	$(PD) doc-utilisateur.md -o doc-utilisateur.pdf

doc-technique.pdf: doc-technique.md activite.svg
	$(PD) doc-technique.md -o doc-technique.pdf

activite.svg: activite.puml
	$(PUML) -tsvg activite.puml
