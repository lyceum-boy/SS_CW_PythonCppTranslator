.PHONY: translate clean ast ast-color run rebuild

translate:
	bison -dy -v --graph=ast.dot bison.y
	flex -v lex.l
	gcc lex.yy.c y.tab.c -o a.exe
	./a.exe > debug.log 2>&1

clean:
	rm -f y.output y.tab.c y.tab.h
	rm -f lex.yy.c
	rm -f a.exe debug.log
	rm -f main.cpp main.exe 
	rm -f bison.tab.c 
	rm -f ast.dot ast.png
	rm -f ast-color.dot ast-color.png

ast: translate
	dot -Tpng ast.dot -o ast.png

ast-color: translate
	python ast_postproc.py < ast.dot > ast-color.dot
	dot -Tpng ast-color.dot -o ast-color.png

run: main.cpp
	g++ main.cpp -o main.exe
	./main.exe

rebuild: clean translate ast ast-color
