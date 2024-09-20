PD=pandoc
src=./rapport-src

all: doc-utilisateur.pdf doc-technique.pdf

doc-utilisateur.pdf: $(src)/doc-utilisateur.md
	$(PD) $(src)/doc-utilisateur.md -o doc-utilisateur.pdf

doc-technique.pdf: $(src)/doc-technique.md
	$(PD) $(src)/doc-technique.md -o doc-technique.pdf
