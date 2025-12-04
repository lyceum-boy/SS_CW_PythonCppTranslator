.PHONY: translate clean ast run rebuild

translate:
	bison -dy -v bison.y
	flex -v lex.l
	gcc lex.yy.c y.tab.c -o a.exe
	./a.exe

clean:
	rm -f y.output y.tab.c y.tab.h
	rm -f lex.yy.c
	rm -f a.exe main.cpp main.exe
	rm -f bison.tab.c bison.dot bison.dot.png

ast:
	bison -g bison.y
	dot -Tpng -O bison.dot

run: translate
	g++ main.cpp -o main.exe
	./main.exe

rebuild: clean translate ast
