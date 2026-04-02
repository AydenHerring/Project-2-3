/*Authors: Parker Riggs and Ayden Herring */

%{
#include <stdio.h>

int yywrap(void) { return 1; }
%}

%%

    /* ignore whitespace (including \r for Windows CRLF files) */
[ \t\n\r]+    ;

    /* remove comments */
"//".*                    { }
"/*"([^*]|\*+[^*/])*"*/"  { }

    /* capture buildnode */
 "buildnode"        { printf("BUILDNODE\n"); }
 "name"             { printf("NAME\n"); }
 "weight"           { printf("WEIGHT\n"); }
 "isachildof"       { printf("ISACHILDOF\n"); }
 
    /* capture for var in [?:?] */
 "for"              { printf("FOR\n"); }
 "in"               { printf("IN\n"); }
 
    /*capture prints */
 "print"            { printf("PRINT\n"); }

    /* string literals */
 \"[^\"]*\"         { printf("STRING: %s\n", yytext); }

    /* integers */
 [0-9]+             { printf("INT: %s\n", yytext); }

    /* variables: standard (letter/_ start) or digit-start with at least one letter or _ */
 [a-zA-Z_][a-zA-Z0-9_]*        { printf("VAR: %s\n", yytext); }
 [0-9]+[a-zA-Z_][a-zA-Z0-9_]* { printf("VAR: %s\n", yytext); }

    /* pass symbols directly */
 [{}();=+,\[\]:]    { printf("%s\n", yytext); }

    /* catch anything unexpected */
 .                  { printf("UNKNOWN: %s\n", yytext); }

%%

int main() {
    yylex();
    return 0;
}