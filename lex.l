%option nodefault yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
%}

%%

"def"    { return DEF; }
"return" { strcpy(yylval.data, yytext); return RETURN; }
"while"  { strcpy(yylval.data, yytext); return WHILE; }

"for"    { return FOR; }
"in"     { return IN; }
"append" { return APPEND; }

"("      { return LPAREN; }
")"      { return RPAREN; }
":"      { return COLON; }
"->"     { return ARROW; }

"["      { return LBRACKET; }
"]"      { return RBRACKET; }
","      { return COMMA; }
"."      { return DOT; }

"<="|[=+*]      { strcpy(yylval.data, yytext); return OP; }
[0-9]+"."[0-9]+ { strcpy(yylval.data, yytext); return FLOAT; }
[0-9]+          { strcpy(yylval.data, yytext); return INT; }

[a-zA-Z_][a-zA-Z0-9_]* { strcpy(yylval.data, yytext); return IDENT; }

[ \t\r\n]+ ;

. { printf("Unknown char: %s\n", yytext); }

%%

int yywrap(void) {
    return 1;
}
