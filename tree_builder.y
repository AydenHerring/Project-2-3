%{
#include <stdio.h>
#include <stdlib.h>
#include <cstring>  // strdup
#include <string>
#include <vector>   // loop_strings
#include "parse_tree.h"

ParseTree tree;
extern int yylex(void);
void yyerror(const char *s);

// loop state — shared by both range loops and string-collection loops
bool loop_active    = false;
bool loop_is_string = false;          // true when iterating a ["a","b","c"] list
std::vector<std::string> loop_strings;// values for a string-collection loop
int  loop_start = 0;
int  loop_end   = 0;
int  current_i  = 0;
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
%type <str> string_list   /* accumulates into global loop_strings */
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

/* Comma-separated list of string literals — populates global loop_strings */
string_list:
    STRING {
        loop_strings.clear();
        loop_strings.push_back($1);
        $$ = $1;
    }
    | string_list ',' STRING {
        loop_strings.push_back($3);
        $$ = $3;
    }
;

for_stmt:
    /* Range loop:  for i in [1:5] { ... }; */
    FOR IDENTIFIER IN '[' INT ':' INT ']' '{'
    {
        loop_active    = true;
        loop_is_string = false;
        loop_var   = $2;
        loop_start = $5;
        loop_end   = $7;
    }
    stmts
    '}' ';'
    {
        loop_active = false;
    }
    /* String-collection loop:  for fruit in ["apple","banana"] { ... }; */
    | FOR IDENTIFIER IN '[' string_list ']' '{'
    {
        loop_active    = true;
        loop_is_string = true;
        loop_var = $2;
        /* loop_strings already populated by string_list rule above */
    }
    stmts
    '}' ';'
    {
        loop_active    = false;
        loop_is_string = false;
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

        if (loop_active && loop_is_string) {
            /* String-collection loop: substitute each string value for the variable */
            for (const auto& s : loop_strings) {
                std::string eval_name   = name;
                std::string eval_parent = parent;
                size_t pos = 0;
                while ((pos = eval_name.find(loop_var, pos)) != std::string::npos) {
                    eval_name.replace(pos, loop_var.length(), s);
                    pos += s.length();
                }
                pos = 0;
                while ((pos = eval_parent.find(loop_var, pos)) != std::string::npos) {
                    eval_parent.replace(pos, loop_var.length(), s);
                    pos += s.length();
                }
                tree.buildNode(eval_name, $9, eval_parent);
            }
        } else if (loop_active) {
            /* Integer range loop: substitute current iteration number for the variable */
            for (current_i = loop_start; current_i <= loop_end; current_i++) {
                std::string eval_name   = name;
                std::string eval_parent = parent;
                // Replace every occurrence so multiple uses of the var all expand
                size_t pos = 0;
                while ((pos = eval_name.find(loop_var, pos)) != std::string::npos) {
                    eval_name.replace(pos, loop_var.length(), std::to_string(current_i));
                    pos += std::to_string(current_i).length();
                }
                pos = 0;
                while ((pos = eval_parent.find(loop_var, pos)) != std::string::npos) {
                    eval_parent.replace(pos, loop_var.length(), std::to_string(current_i));
                    pos += std::to_string(current_i).length();
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
