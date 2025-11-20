.PHONY: translate clean ast rebuild

translate:
	bison -dy -v bison.y
	flex -v lex.l
	gcc lex.yy.c y.tab.c -o a.exe
	./a.exe

clean:
	rm -f y.output y.tab.c y.tab.h
	rm -f lex.yy.c
	rm -f a.exe main.cpp
	rm -f bison.tab.c bison.dot bison.dot.png

ast:
	bison -g bison.y
	dot -Tpng -O bison.dot

rebuild: clean translate ast
