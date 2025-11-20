%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
extern FILE *yyin;
extern FILE *yyout;
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
%}

%union {
    char data[8192];
}

%token DEF
%token LPAREN RPAREN COLON ARROW
%token LBRACKET RBRACKET COMMA
%token FOR IN RANGE APPEND DOT
%token <data> IDENT FLOAT INT OP RETURN WHILE

%type <data> START ROOT HEADER CONST_PI
%type <data> FUNC_DECL FUNC_CIRCLE FUNC_FACT
%type <data> TERM EXPR
%type <data> ASSIGNMENT T_INT T_FLOAT T_NONE
%type <data> BLOCK_LISTS LIST_NUMBERS LIST_SQUARES LIST_VALUES
%type <data> FOR_HEADER APPEND_CALL BLOCK_FOR LOOP_BODY
%type <data> MAIN

%start START

%%

START: ROOT { fprintf(yyout, "%s", $1); };

ROOT: HEADER CONST_PI FUNC_CIRCLE FUNC_FACT BLOCK_LISTS MAIN {
    strcpy($$, $1);
    strcat($$, $2);
    strcat($$, "\n");
    strcat($$, $3);
    strcat($$, "\n");
    strcat($$, $4);
    strcat($$, "\n");
    strcat($$, $5);
    strcat($$, "\n");
    strcat($$, $6);
};

HEADER: {
    strcpy(
        $$,
        "#include <iostream>\n"
        "#include <vector>\n\n"
        "using namespace std;\n\n"
    );
};

MAIN: BLOCK_FOR {
    strcpy($$, "int main() {\n");
    strcat($$, $1);
    strcat($$, "    return 0;\n");
    strcat($$, "}\n");
};

CONST_PI: T_FLOAT IDENT OP FLOAT {
    strcpy($$, "const ");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, " ");
    strcat($$, $3);
    strcat($$, " ");
    strcat($$, $4);
    strcat($$, ";\n");
};

TERM
  : IDENT { strcpy($$, $1); }
  | FLOAT { strcpy($$, $1); }
  | INT   { strcpy($$, $1); };

EXPR
  : TERM { strcpy($$, $1); }
  | EXPR OP TERM {
    strcpy($$, $1);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, " ");
    strcat($$, $3);
};

ASSIGNMENT: IDENT OP EXPR {
    strcpy($$, $1);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, " ");
    strcat($$, $3);
};

T_INT:   { strcpy($$, "int "); };
T_FLOAT: { strcpy($$, "double "); };
T_NONE:  { strcpy($$, ""); };

FUNC_DECL: DEF IDENT LPAREN IDENT COLON IDENT RPAREN ARROW IDENT COLON {
    char ret_type[32];
    char arg_type[32];

    if (strcmp($9, "float") == 0) {
        strcpy(ret_type, "double");
    } else {
        strcpy(ret_type, $9);
    }

    if (strcmp($6, "float") == 0) {
        strcpy(arg_type, "double");
    } else {
        strcpy(arg_type, $6);
    }

    strcpy($$, ret_type);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, "(");
    strcat($$, arg_type);
    strcat($$, " ");
    strcat($$, $4);
    strcat($$, ") {\n");
};

FUNC_CIRCLE: FUNC_DECL T_FLOAT ASSIGNMENT RETURN IDENT {
    strcpy($$, $1);
    strcat($$, "    ");
    strcat($$, $2);
    strcat($$, $3);
    strcat($$, ";\n    ");
    strcat($$, $4);
    strcat($$, " ");
    strcat($$, $5);
    strcat($$, ";\n}\n");
};

FUNC_FACT: FUNC_DECL
    T_INT   ASSIGNMENT
    T_INT   ASSIGNMENT
    WHILE   EXPR COLON
    T_NONE  ASSIGNMENT
    T_NONE  ASSIGNMENT
    RETURN  IDENT
{
    strcpy($$, $1);

    strcat($$, "    ");
    strcat($$, $2);
    strcat($$, $3);
    strcat($$, ";\n");

    strcat($$, "    ");
    strcat($$, $4);
    strcat($$, $5);
    strcat($$, ";\n");

    strcat($$, "    ");
    strcat($$, $6);
    strcat($$, " (");
    strcat($$, $7);
    strcat($$, ") {\n");

    strcat($$, "        ");
    strcat($$, $9);
    strcat($$, $10);
    strcat($$, ";\n");

    strcat($$, "        ");
    strcat($$, $11);
    strcat($$, $12);
    strcat($$, ";\n");

    strcat($$, "    }\n");

    strcat($$, "    ");
    strcat($$, $13);
    strcat($$, " ");
    strcat($$, $14);
    strcat($$, ";\n}\n");
};

LIST_VALUES
  : INT { strcpy($$, $1); }
  | LIST_VALUES COMMA INT {
        strcpy($$, $1);
        strcat($$, ", ");
        strcat($$, $3);
};

LIST_NUMBERS: IDENT OP LBRACKET LIST_VALUES RBRACKET {
    strcpy($$, "vector<int> ");
    strcat($$, $1);
    strcat($$, " = {");
    strcat($$, $4);
    strcat($$, "};\n");
};

LIST_SQUARES: IDENT OP LBRACKET RBRACKET {
    strcpy($$, "vector<int> ");
    strcat($$, $1);
    strcat($$, ";\n");
};

BLOCK_LISTS: LIST_NUMBERS LIST_SQUARES {
    strcpy($$, $1);
    strcat($$, $2);
};

FOR_HEADER
    : FOR IDENT IN IDENT COLON
{
    strcpy($$, "for (auto ");
    strcat($$, $2);
    strcat($$, " : ");
    strcat($$, $4);
    strcat($$, ") {\n");
}
    | FOR IDENT IN RANGE LPAREN INT COMMA INT RPAREN COLON
{
    strcpy($$, "for (int ");
    strcat($$, $2);
    strcat($$, " = ");
    strcat($$, $6);
    strcat($$, "; ");
    strcat($$, $2);
    strcat($$, " < ");
    strcat($$, $8);
    strcat($$, "; ");
    strcat($$, $2);
    strcat($$, "++) {\n");
};

APPEND_CALL
    : IDENT DOT APPEND LPAREN IDENT RPAREN
{
    strcpy($$, $1);
    strcat($$, ".push_back(");
    strcat($$, $5);
    strcat($$, ");");
}

LOOP_BODY: T_INT ASSIGNMENT APPEND_CALL {
    strcpy($$, "        ");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, ";\n");

    strcat($$, "        ");
    strcat($$, $3);
    strcat($$, ";\n");
};

BLOCK_FOR: FOR_HEADER LOOP_BODY {
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, $2);
    strcat($$, "    }\n");
};

%%

int main(void) {
    yyin = fopen("main.py", "r");
    if (!yyin) {
        perror("Error opening main.py");
        return 1;
    }
    yyout = fopen("main.cpp", "w");
    if (!yyout) {
        perror("Error opening main.cpp");
        fclose(yyin);
        return 1;
    }
    int rc = yyparse();
    fclose(yyin);
    fclose(yyout);
    return rc;
}
