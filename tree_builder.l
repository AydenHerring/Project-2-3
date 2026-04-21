/* Authors: Parker Riggs and Ayden Herring */

%{
#define YY_NO_UNPUT
#define YY_NO_INPUT

#include "tree_builder.tab.h"
#include <string.h>
#include <stdlib.h>

// Provide yylval for Bison
extern YYSTYPE yylval;
#ifdef __cplusplus
extern "C" int yywrap(void) { return 1; }
#else
int yywrap(void) { return 1; }
#endif
%}

%%

[ \t\r\n]+           ;
"//".*               ;
"/*"([^*]|\*+[^*/])*"*/" ;

"buildnode"          { return BUILDNODE; }
"name"               { return NAME; }
"weight"             { return WEIGHT; }
"isachildof"         { return ISACHILDOF; }
"print"              { return PRINT; }

\"[^\"]*\"           {
    yylval.str = strdup(yytext + 1);
    yylval.str[strlen(yylval.str) - 1] = 0;
    return STRING;
}

[0-9]+               {
    yylval.ival = atoi(yytext);
    return INT;
}


"for"                { return FOR; }
"in"                 { return IN; }

[a-zA-Z_][a-zA-Z0-9_]* {
    yylval.str = strdup(yytext);
    return IDENTIFIER;
}

"{"                   { return '{'; }
"}"                   { return '}'; }
"("                   { return '('; }
")"                   { return ')'; }
";"                   { return ';'; }
"="                   { return '='; }
"+"                   { return '+'; }
","                   { return ','; }
"["                   { return '['; }
"]"                   { return ']'; }
":"                   { return ':'; }

.                      { return *yytext; }

%%