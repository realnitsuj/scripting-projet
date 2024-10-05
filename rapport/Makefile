PD=pandoc
PUML=plantuml

all: doc-utilisateur.pdf memoire-technique.pdf

doc-utilisateur.pdf: doc-utilisateur.md settings.yaml
	$(PD) settings.yaml doc-utilisateur.md -o doc-utilisateur.pdf

memoire-technique.pdf: memoire-technique.md settings.yaml activite.svg
	$(PD) -f markdown-implicit_figures settings.yaml memoire-technique.md -o memoire-technique.pdf

activite.svg: activite.puml
	$(PUML) -tsvg activite.puml
