flex lex.l
flex -v lex.l
flex -Ca -v lex.l

bison -dy -v bison.y
flex -v lex.l
gcc lex.yy.c y.tab.c -o a.exe
start a.exe
