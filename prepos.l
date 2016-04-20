%{
    
#include <string.h>
#define TRUE        1
#define FALSE       0
    
typedef struct
{
    char  thestr[1024];
    int   ival;
    float fval;
    char  cval;
    char numlist[100];
    int   arrayBound;
    int   ttype;
}tstruct ;
    
#define YYSTYPE  tstruct
#include "prepos.tab.h"


int lineno = 1;
int DEBUG = FALSE;
    
%}

%option yylineno

D         [0-9]
L         [A-Za-z]
W         [ \t\r]

%%

\#(.*)\n		         { 
    				    if (DEBUG) printf("header:  -%s\n",yytext);
				    strcpy(yylval.thestr,yytext);
				    lineno++; 
				    return theader;
				 }

main\(.*\)         		 { 
    				    if (DEBUG) printf("  -%s\n",yytext);
				    strcpy(yylval.thestr,yytext);
				    return tmain;
		   		 } 

{L}+{W}*\(.*\){W}*(";")   	 { 
				    if (DEBUG) printf("token:  -%s\n",yytext);
				    strcpy(yylval.thestr,yytext);
				    return tfunction; 
				 }

while{W}*\(.*\)     		 { 
				    if (DEBUG) printf("token:  -%s\n",yytext); 
				    strcpy(yylval.thestr,yytext);
				    return twhile; 
				 }

return    { if (DEBUG) printf("token:  -%s\n",yytext); return tret; }
void	  { if (DEBUG) printf("token:  -%s\n",yytext); return tvoid; }
int       { if (DEBUG) printf("token:  -%s\n",yytext); return tint; }
float     { if (DEBUG) printf("token:  -%s\n",yytext); return tfloat; }
char      { if (DEBUG) printf("token:  -%s\n",yytext); return tchar; }
else      { if (DEBUG) printf("token:  -%s\n",yytext); return telse; }
if        { if (DEBUG) printf("token:  -%s\n",yytext); return tif; }
for       { if (DEBUG) printf("token:  -%s\n",yytext); return tfor; }
"<"       { if (DEBUG) printf("token:  -%s\n",yytext); return tlt; }
">"       { if (DEBUG) printf("token:  -%s\n",yytext); return tgt; }
"<="      { if (DEBUG) printf("token:  -%s\n",yytext); return tle; }
">="      { if (DEBUG) printf("token:  -%s\n",yytext); return tge; }
"=="      { if (DEBUG) printf("token:  -%s\n",yytext); return teq; }
"!="      { if (DEBUG) printf("token:  -%s\n",yytext); return tne; }
"="       { if (DEBUG) printf("token:  -%s\n",yytext); return tassign; }
"||"      { if (DEBUG) printf("token:  -%s\n",yytext); return tor; }
"&&"      { if (DEBUG) printf("token:  -%s\n",yytext); return tand; }
"!"       { if (DEBUG) printf("token:  -%s\n",yytext); return tnot; }
"&"       { if (DEBUG) printf("token:  -%s\n",yytext); return taddressof; }

\"([^"]*)\"          {  
    			if (DEBUG) printf("strlit:  -%s\n",yytext); 
			strcpy(yylval.thestr,yytext);
			return tstrlit;
		     }
\'.\'		     {
			if (DEBUG) printf("chrlit:  -%s\n",yytext);
			strcpy(yylval.thestr,yytext);
			return tchrlit;
		     }
{L}({L}|{D}|'_')*    { /* C identifier */
                        if (DEBUG) printf("id:  -%s\n",yytext);
                        strcpy(yylval.thestr,yytext);
			return tid;
                     }
('+'|'-')?{D}*\.{D}+ { /* signed or unsigned float */
                        if (DEBUG) printf("tnum-float:  -%s\n", yytext);
                        yylval.fval = atof(yytext);
			yylval.ttype = 20;
			return tnum;
                     }
('+'|'-')?{D}+       { /* signed or unsigned int */
                        if (DEBUG) printf("tnum-int:  -%s\n",yytext);
                        yylval.ival = atoi(yytext);
			yylval.ttype = 10;
			return tnum;
                     }
\/\/(.*)\n           {  lineno++; } /* throws away // comments */
\/\*(.*)\*\/		   /* consumes multiline comments */

[ \t]               /* ignore whitespace */

\n                   { lineno++; }

<<EOF>>   yyterminate();  /* signal end of dialogue */

.                    { if (DEBUG) printf("  -%c\n",yytext[0]); return yytext[0]; }

%%

yyerror(char* s)
{
	printf("%s at line %d\n", s, yylineno);
	exit(1);
}
