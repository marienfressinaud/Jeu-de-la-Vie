SOURCES = cellule.vala monde.vala jeu.vala

PKG = sdl

LINK = valac --pkg $(PKG) -g

EXE = jeu_de_la_vie

jeu_de_la_vie: $(SOURCES)
	$(LINK) $(SOURCES) -o jeu_de_la_vie

.PHONY: all clean test

all: $(EXE)

clean:
	/bin/rm -f $(EXE) *.c

test: jeu_de_la_vie
	./jeu_de_la_vie -t 16
