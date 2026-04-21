%{
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include "parse_tree.h"

ParseTree tree;
extern int yylex(void);
void yyerror(const char *s);

// loop state
bool loop_active = false;
int loop_start = 0;
int loop_end = 0;
int current_i = 0;
std::string loop_var;
%}

%union {
    int ival;
    char* str;
}

%token BUILDNODE NAME WEIGHT ISACHILDOF PRINT FOR IN
%token <str> STRING
%token <ival> INT
%token <str> IDENTIFIER

%left '+'

%type <str> opt_parent
%type <str> expr
%type <ival> int_expr

%%

program:
    stmts
;

stmts:
    stmts stmt
    | stmt
;

stmt:
    buildnode_stmt
    | print_stmt
    | for_stmt
;

for_stmt:
    FOR IDENTIFIER IN '[' INT ':' INT ']' '{'
    {
        loop_active = true;
        loop_var = $2;
        loop_start = $5;
        loop_end = $7;
    }
    stmts
    '}' ';'
    {
        loop_active = false;
    }
;

buildnode_stmt:
    BUILDNODE '{'
        NAME '=' expr ';'
        WEIGHT '=' int_expr ';'
        opt_parent
    '}' ';'
    {
        std::string name($5);
        std::string parent($11);

        if (loop_active) {
            for (current_i = loop_start; current_i <= loop_end; current_i++) {
                std::string eval_name = name;
                std::string eval_parent = parent;

                size_t pos;
                if ((pos = eval_name.find("i")) != std::string::npos) {
                    eval_name.replace(pos, 1, std::to_string(current_i));
                }
                if ((pos = eval_parent.find("i")) != std::string::npos) {
                    eval_parent.replace(pos, 1, std::to_string(current_i));
                }

                tree.buildNode(eval_name, $9, eval_parent);
            }
        } else {
            tree.buildNode(name, $9, parent);
        }
    }
;

opt_parent:
    ISACHILDOF '=' expr ';' { $$ = $3; }
    | { $$ = strdup(""); }
;

print_stmt:
    PRINT '(' STRING ')' ';'
    {
        tree.printTree($3);
    }
;

expr:
    STRING { $$ = $1; }
    | IDENTIFIER { $$ = $1; }
    | expr '+' IDENTIFIER {
        std::string left($1);
        std::string right($3);
        $$ = strdup((left + right).c_str());
    }
    | expr '+' STRING {
        std::string left($1);
        std::string right($3);
        $$ = strdup((left + right).c_str());
    }
;

int_expr:
    INT { $$ = $1; }
    | IDENTIFIER { $$ = current_i; }
    | int_expr '+' int_expr { $$ = $1 + $3; }
;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}
