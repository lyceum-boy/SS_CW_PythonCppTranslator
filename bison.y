%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex(void);
extern FILE *yyin;
extern FILE *yyout;
extern char *yytext;
extern int yylineno;
#define YYERROR_VERBOSE 1
void yyerror(const char *s) {
    fprintf(stderr, "Error at line %d near '%s': %s\n", yylineno, yytext, s);
}
%}

%union {
    char data[8192];
}

%token DEF
%token LPAREN RPAREN COLON ARROW
%token LBRACKET RBRACKET COMMA
%token FOR IN RANGE APPEND DOT
%token PRINT
%token IF ELIF ELSE
%token <data> IDENT FLOAT INT OP RETURN WHILE STRING COMMENT

%type <data> START ROOT HEADER CONST_PI
%type <data> FUNC_DECL FUNC_CIRCLE FUNC_FACT
%type <data> TERM EXPR
%type <data> ASSIGNMENT T_INT T_FLOAT T_NONE
%type <data> BLOCK_LISTS LIST_NUMBERS LIST_SQUARES LIST_VALUES
%type <data> FOR_HEADER APPEND_CALL BLOCK_FOR LOOP_BODY
%type <data> MAIN BLOCK_PRINTS PRINT_STMT PRINT_IN_LOOP
%type <data> COMMENT_LINE TEXT_ASSIGN LENGTH_ASSIGN BLOCK_STRINGS
%type <data> COND_BLOCK IF_PART ELIF_PART ELSE_PART
%type <data> BLOCK_WHILE BLOCK_FOR_CONTINUE
%type <data> BLOCK_CALLS PRINT_FUNC_CALL
%type <data> STR_LIST_VALUES WORDS_LIST
%type <data> PRINT_JOIN_ALL PRINT_JOIN_REVERSED
%type <data> BLOCK_WORDS

%start START

%%

START: ROOT { fprintf(yyout, "%s", $1); };

ROOT: HEADER CONST_PI FUNC_CIRCLE FUNC_FACT BLOCK_LISTS MAIN {
    strcpy($$, $1);
    strcat($$, $2); strcat($$, "\n");
    strcat($$, $3); strcat($$, "\n");
    strcat($$, $4); strcat($$, "\n");
    strcat($$, $5); strcat($$, "\n");
    strcat($$, $6);
};

HEADER: {
    strcpy(
        $$,
        "#include <iostream>\n"
        "#include <vector>\n"
        "#include <string>\n\n"
        "using namespace std;\n\n"
        "template<typename T>\n"
        "ostream &operator<<(ostream &out, const vector<T> &vec) {\n"
        "    if (!vec.empty()) {\n"
        "        out << \"{\";\n"
        "        for (size_t i = 0; i < vec.size(); ++i) {\n"
        "            out << vec[i];\n"
        "            if (i + 1 != vec.size()) out << \", \";\n"
        "        }\n"
        "        out << \"}\";\n"
        "    }\n"
        "    return out;\n"
        "}\n\n"
        "size_t utf8_len(const std::string &s) {\n"
        "    size_t len = 0;\n"
        "    for (unsigned char c: s) {\n"
        "        if ((c & 0xC0) != 0x80) ++len;\n"
        "    }\n"
        "    return len;\n"
        "}\n\n"
    );
};

MAIN: BLOCK_FOR BLOCK_PRINTS BLOCK_STRINGS COND_BLOCK BLOCK_WHILE BLOCK_FOR_CONTINUE BLOCK_CALLS BLOCK_WORDS PRINT_STMT {
    strcpy($$, "int main() {\n");
    strcat($$, "    system(\"chcp 65001\");\n");
    strcat($$, "    system(\"cls\");\n\n");
    strcat($$, $1); strcat($$, "\n");
    strcat($$, $2); strcat($$, "\n");
    strcat($$, $3); strcat($$, "\n");
    strcat($$, $4); strcat($$, "\n");
    strcat($$, $5); strcat($$, "\n");
    strcat($$, $6); strcat($$, "\n");
    strcat($$, $7); strcat($$, "\n");
    strcat($$, $8); strcat($$, "\n");
    strcat($$, "    "); strcat($$, $9);  strcat($$, "\n");
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
  : IDENT {
        if (strcmp($1, "True") == 0) {
            strcpy($$, "true");
        } else if (strcmp($1, "False") == 0) {
            strcpy($$, "false");
        } else {
            strcpy($$, $1);
        }
    }
  | FLOAT  { strcpy($$, $1); }
  | INT    { strcpy($$, $1); }
  | STRING { strcpy($$, $1); }
  ;

EXPR
  : TERM { strcpy($$, $1); }
  | EXPR OP TERM {
        strcpy($$, $1);
        strcat($$, " ");
        strcat($$, $2);
        strcat($$, " ");
        strcat($$, $3);
    }
  | IDENT LPAREN IDENT RPAREN {
        if (strcmp($1, "len") == 0) {
            strcpy($$, "utf8_len(");
            strcat($$, $3);
            strcat($$, ")");
        } else {
            strcpy($$, $1);
            strcat($$, "(");
            strcat($$, $3);
            strcat($$, ")");
        }
    }
  ;

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

FUNC_FACT
  : FUNC_DECL
        T_INT ASSIGNMENT
        T_INT ASSIGNMENT
        WHILE EXPR COLON
            T_NONE ASSIGNMENT
            T_NONE ASSIGNMENT
        RETURN IDENT
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
    }
  ;

LIST_NUMBERS: IDENT OP LBRACKET LIST_VALUES RBRACKET {
    strcpy($$, "vector<int> ");
    strcat($$, $1);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, " {");
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
  : FOR IDENT IN IDENT COLON {
        strcpy($$, "for (auto ");
        strcat($$, $2);
        strcat($$, ": ");
        strcat($$, $4);
        strcat($$, ") {\n");
    }
  | FOR IDENT IN RANGE LPAREN INT COMMA INT RPAREN COLON {
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
    }
  ;

APPEND_CALL: IDENT DOT APPEND LPAREN IDENT RPAREN {
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

PRINT_STMT
  : PRINT LPAREN RPAREN {
        strcpy($$, "cout << endl;");
    }
  | PRINT LPAREN STRING RPAREN {
        strcpy($$, "cout << ");
        strcat($$, $3);
        strcat($$, " << endl;");
    }
  | PRINT LPAREN STRING COMMA IDENT RPAREN {
        strcpy($$, "cout << ");
        strcat($$, $3);
        strcat($$, " << \" \" << ");
        strcat($$, $5);
        strcat($$, " << endl;");
    }
  ;

PRINT_IN_LOOP: PRINT LPAREN IDENT COMMA IDENT OP STRING RPAREN {
    strcpy($$, "cout << ");
    strcat($$, $3);
    strcat($$, " << ");
    strcat($$, $7);
    strcat($$, ";");
};

BLOCK_PRINTS
  : PRINT_STMT
    FOR_HEADER
        PRINT_IN_LOOP
    PRINT_STMT
{
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, "\n");

    strcat($$, "    "); strcat($$, $2);

    strcat($$, "        ");
    strcat($$, $3);
    strcat($$, "\n");
    strcat($$, "    }\n");

    strcat($$, "    ");
    strcat($$, $4);
    strcat($$, "\n");
};

COMMENT_LINE: COMMENT {
    strcpy($$, "//");
    strcat($$, $1 + 1);
};

TEXT_ASSIGN: IDENT OP STRING {
    strcpy($$, "string ");
    strcat($$, $1);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, " ");
    strcat($$, $3);
    strcat($$, ";");
};

LENGTH_ASSIGN: IDENT OP IDENT LPAREN IDENT RPAREN {
    strcpy($$, "int ");
    strcat($$, $1);
    strcat($$, " = ");
    if (strcmp($3, "len") == 0) {
        strcat($$, "utf8_len(");
        strcat($$, $5);
        strcat($$, ");");
    } else {
        strcat($$, $3);
        strcat($$, "(");
        strcat($$, $5);
        strcat($$, ");");
    }
};

BLOCK_STRINGS: COMMENT_LINE TEXT_ASSIGN LENGTH_ASSIGN PRINT_STMT {
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $2);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $3);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $4);
    strcat($$, "\n");
};

IF_PART: IF EXPR COLON PRINT_STMT {
    strcpy($$, "    if (");
    strcat($$, $2);
    strcat($$, ") {\n        ");
    strcat($$, $4);
    strcat($$, "\n    }");
};

ELIF_PART:
    { strcpy($$, ""); }
  | ELIF EXPR COLON PRINT_STMT {
        strcpy($$, " else if (");
        strcat($$, $2);
        strcat($$, ") {\n        ");
        strcat($$, $4);
        strcat($$, "\n    }");
    }
  ;

ELSE_PART:
    { strcpy($$, ""); }
  | ELSE COLON PRINT_STMT {
        strcpy($$, " else {\n        ");
        strcat($$, $3);
        strcat($$, "\n    }\n");
    }
  ;

COND_BLOCK: IF_PART ELIF_PART ELSE_PART {
    strcpy($$, $1);
    strcat($$, $2);
    strcat($$, $3);
};

BLOCK_WHILE
  : COMMENT_LINE
    T_INT ASSIGNMENT
    T_INT ASSIGNMENT
    WHILE EXPR COLON
        IF EXPR COLON
            IDENT
        IF EXPR COLON
            T_NONE ASSIGNMENT
        T_NONE ASSIGNMENT
    PRINT_STMT
{
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $2);
    strcat($$, $3);
    strcat($$, ";\n");

    strcat($$, "    ");
    strcat($$, $4);
    strcat($$, $5);
    strcat($$, ";\n");

    strcat($$, "    while (");
    strcat($$, $7);
    strcat($$, ") {\n");

    strcat($$, "        if (");
    strcat($$, $10);
    strcat($$, ") {\n");
    strcat($$, "            ");
    if (strcmp($12, "break") == 0) {
        strcat($$, "break;\n");
    } else {
        strcat($$, $12);
        strcat($$, ";\n");
    }
    strcat($$, "        }\n");

    strcat($$, "        if (");
    strcat($$, $14);
    strcat($$, ") {\n");
    strcat($$, "            ");
    strcat($$, $17);
    strcat($$, ";\n");
    strcat($$, "        }\n");

    strcat($$, "        ");
    strcat($$, $19);
    strcat($$, ";\n");

    strcat($$, "    }\n");

    strcat($$, "    ");
    strcat($$, $20);
    strcat($$, "\n");
};

BLOCK_FOR_CONTINUE
  : COMMENT_LINE
    LIST_SQUARES
    FOR_HEADER
        IF EXPR COLON
            IDENT
        APPEND_CALL
    PRINT_STMT
{
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $2);

    strcat($$, "    ");
    strcat($$, $3);

    strcat($$, "        if (");
    strcat($$, $5);
    strcat($$, ") {\n");
    strcat($$, "            ");
    if (strcmp($7, "continue") == 0) {
        strcat($$, "continue;\n");
    } else {
        strcat($$, $7);
        strcat($$, ";\n");
    }
    strcat($$, "        }\n");

    strcat($$, "        ");
    strcat($$, $8);
    strcat($$, "\n");

    strcat($$, "    }\n");

    strcat($$, "    ");
    strcat($$, $9);
    strcat($$, "\n");
};

PRINT_FUNC_CALL: PRINT LPAREN STRING COMMA IDENT COMMA STRING COMMA IDENT LPAREN IDENT RPAREN RPAREN {
    strcpy($$, "cout << ");
    strcat($$, $3);
    strcat($$, " << \" \" << ");
    strcat($$, $5);
    strcat($$, " << \" \" << ");
    strcat($$, $7);
    strcat($$, " << \" \" << ");
    strcat($$, $9);
    strcat($$, "(");
    strcat($$, $11);
    strcat($$, ") << endl;");
};

BLOCK_CALLS
  : COMMENT_LINE
    T_INT ASSIGNMENT
    PRINT_FUNC_CALL
    T_INT ASSIGNMENT
    PRINT_FUNC_CALL
{
    strcpy($$, "    ");
    strcat($$, $1);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $2);
    strcat($$, $3);
    strcat($$, ";\n");

    strcat($$, "    ");
    strcat($$, $4);
    strcat($$, "\n");

    strcat($$, "    ");
    strcat($$, $5);
    strcat($$, $6);
    strcat($$, ";\n");

    strcat($$, "    ");
    strcat($$, $7);
    strcat($$, "\n");
};

STR_LIST_VALUES
  : STRING { strcpy($$, $1); }
  | STR_LIST_VALUES COMMA STRING {
        strcpy($$, $1);
        strcat($$, ", ");
        strcat($$, $3);
    }
  ;

WORDS_LIST: IDENT OP LBRACKET STR_LIST_VALUES RBRACKET {
    strcpy($$, "vector<string> ");
    strcat($$, $1);
    strcat($$, " ");
    strcat($$, $2);
    strcat($$, " {");
    strcat($$, $4);
    strcat($$, "};\n");
};

PRINT_JOIN_ALL: PRINT LPAREN IDENT RPAREN {
    strcpy($$, "cout << "); strcat($$, $3); strcat($$, " << endl;");
};

PRINT_JOIN_REVERSED: PRINT LPAREN STRING COMMA STRING DOT IDENT LPAREN IDENT LPAREN IDENT RPAREN RPAREN RPAREN {
    char buf[8192];
    strcpy(buf, "cout << ");
    strcat(buf, $3);
    strcat(buf, " << \" \";\n");
    strcat(buf, "    for (auto it = ");
    strcat(buf, $11);
    strcat(buf, ".rbegin(); it != ");
    strcat(buf, $11);
    strcat(buf, ".rend(); ++it) {\n");
    strcat(buf, "        cout << *it << \" \";\n");
    strcat(buf, "    }\n");
    strcat(buf, "    cout << endl;");
    strcpy($$, buf);
};

BLOCK_WORDS
  : COMMENT_LINE
    WORDS_LIST
    TEXT_ASSIGN
    FOR_HEADER
        T_NONE ASSIGNMENT
    PRINT_JOIN_ALL
    PRINT_JOIN_REVERSED
{
    strcpy($$, "    "); strcat($$, $1); strcat($$, "\n");
    strcat($$, "    "); strcat($$, $2);
    strcat($$, "    "); strcat($$, $3); strcat($$, "\n");
    strcat($$, "    "); strcat($$, $4);
    strcat($$, "        "); strcat($$, $6); strcat($$, ";\n");
    strcat($$, "    }\n");
    strcat($$, "    "); strcat($$, $7); strcat($$, "\n");
    strcat($$, "    "); strcat($$, $8); strcat($$, "\n");
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
