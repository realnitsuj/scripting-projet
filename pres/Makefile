PD=pandoc

all: pres.html

pres.html: pres.md
	$(PD) -s -t revealjs --slide-level=2 pres.md -o pres.html
