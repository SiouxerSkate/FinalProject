safeC: lex.yy.c prepos.tab.c
	gcc prepos.tab.c lex.yy.c -lfl -ly -o safeC

lex.yy.c: prepos.l
	flex prepos.l

prepos.tab.c: prepos.y
	bison -dv prepos.y

clean:
	rm -rf lex.yy.c
	rm -rf prepos.output
	rm -rf prepos.tab.h
	rm -rf prepos.tab.c
