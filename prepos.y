
%{
#define VAR_SIZE 1024

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.c"

typedef struct 
{
 char thestr[VAR_SIZE];
 int ival;
 float fval;
 char cval;
 char numlist[100]; /*for assigning list of numbers to arrays, i just chose an arbitrary # for now */
 int arrayBound;
 int ttype;
}tstruct ; 

#define YYSTYPE  tstruct 

FILE * fp;
char filename[] = "target.c";
char temp[VAR_SIZE];
int level = 0;

%}

%error-verbose

%token theader
%token tmain  
%token tret   
%token tvoid
%token tint  
%token tfloat  
%token tchar  
%token tfunction
%token telse
%token tif  
%token tfor
%token twhile  
%token tlt  
%token tgt
%token tle
%token tge
%token teq  
%token tne
%token tfalse  
%token ttrue  
%token tassign  
%token tstrlit  
%token tid  
%token tnum
%token tchrlit

%%

p	: prog						{ 
							  printf("Master of C!\n");
							  fprintf(fp, "\n}\n");
							  showtab(); 
							}
	;

/* should account for all sets of program possibilities at high level */
prog	: header main '{' '}'				{ printf("empty program\n"); }
	| header main '{' DL SL '}'			{ printf("DL & SL good\n"); }
	| header main '{' DL '}'			{ printf("Just DL\n"); }
	| header main '{' SL '}'			{ printf("Just SL\n"); }
	;

/* includes header files to be transfered over during code generation */
header	: /* no headers */
	| header theader				{ fprintf(fp, "%s", $2.thestr); }
	;

/* 
** main's definition can include int or void as return type
** tmain includes entire string (e.g. main(int argc, char *argv[]) for code generation
*/
main	: tint tmain					{ fprintf(fp, "int %s\n{\n", $2.thestr); }
	| tvoid tmain					{ fprintf(fp, "void %s\n{\n", $2.thestr); }
	;

/* if declarations exist, they will always be above statements */
DL	: DL D						{}
	| D						{}
	;

D	: type tid tassign tnum ';'			{ 
							  addtab($2.thestr, $1.ttype, 1);
							  switch($1.ttype)
							  {
								case 10:
									fprintf(fp, "\tint %s = %d;\n", $2.thestr, $4.ival);
									break;
								case 20:
									fprintf(fp, "\tfloat %s = %f;\n", $2.thestr, $4.fval);
									break;
								case 30:
									printf("Cannot assign int into char\n");
									errorclosefile();
							  }
							}
	| type tid tassign tchrlit ';'			{ 
							  addtab($2.thestr, $1.ttype, 1); 
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign char into int\n");
									errorclosefile();
								case 20:
									printf("Cannot assign char into float\n");
									errorclosefile();
								case 30:
									fprintf(fp, "\tchar %s = %s;\n", $2.thestr, $4.thestr);
									break;
							  }
							}
        | type tid '[' tnum ']'tassign tnumlist';'	{ 
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, ($4.ival-1)); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, ($4.ival-1)); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, ($4.ival-1)); //char array
							  int type;
							  switch($1.ttype)
							  {
								case 10:
									printf("\tint %s[%d] = %s;\n", $2.thestr, $4.ival, $7.numlist);
									fprintf(fp, "\tint %s[%d] = %s;\n", $2.thestr, $4.ival, $7.numlist);
									break;
								case 20:
									printf("\tfloat %s[%d] = %s;\n", $2.thestr, $4.ival, $7.numlist);
									fprintf(fp, "\tfloat %s[%d] = %s;\n", $2.thestr, $4.ival, $7.numlist);
									break;
								case 30:
									printf("Cannot assign number into char array\n");
									errorclosefile();
							  }
							}
        | type tid '[' tnum ']'tassign tchrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, ($4.ival-1)); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, ($4.ival-1)); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, ($4.ival-1)); //char array
							  
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign char into int array\n");
									errorclosefile();
								case 20:
									printf("Cannot assign char into float array\n");
									errorclosefile();
								case 30:
									fprintf(fp, "\tchar %s[%d] = %s;\n", $2.thestr, $4.ival, $7.thestr);
									break;
							  }
							 }
        | type tid '[' tnum']'tassign tstrlit';' 	{
							  if ($4.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  if ($1.ttype == 10)  
							     addtab($2.thestr, 11, ($4.ival-1)); //int array
							  else if ($1.ttype == 20)
							     addtab($2.thestr, 22, ($4.ival -1)); //float array
							  else if ($1.ttype == 30)
							     addtab($2.thestr, 33, ($4.ival-1)); //char array
							  
							  switch($1.ttype)
							  {
								case 10:
									printf("Cannot assign string into int array\n");
									errorclosefile();
								case 20:
									printf("Cannot assign string into float array\n");
									errorclosefile();
								case 30:
									fprintf(fp, "\tchar %s[%d] = %s;\n", $2.thestr, $4.ival, $7.thestr);
									if (strlen($7.thestr) > $4.ival)
									{
										printf("String literal larger than char array size\n");
										errorclosefile();
									}
									break;
							  }
							 }
	;

type	: tint {$$.ttype = 10;} | tfloat {$$.ttype = 20;} | tchar {$$.ttype = 30;} ;			

block	: openpar S closepar				{sprintf($$.thestr, "\t{\n\t\t%s\n\t}\n", $2.thestr);}
	;

openpar : '{'						{level++;}
	;

closepar: '}'						{level--;}
	;

SL 	: SL S		 				{fprintf( fp, "%s", $2.thestr);}
	| S						{fprintf(fp , "\n");fprintf(fp, "%s", $1.thestr);}
	;

S	: select		 			{}
	| loop			 			{}
	| tid tassign tchrlit ';'			{intab($1.thestr); sprintf($$.thestr, "\t%s = %s;\n", $1.thestr, $3.thestr);}
	| tid tassign expr ';'				{intab($1.thestr); sprintf($$.thestr, "\t%s = %s;\n", $1.thestr, $3.thestr);}
        | assignarray					{}
	| tid tassign expr 				{sprintf($$.thestr, "\t%s = %s\n", $1.thestr, $3.thestr);}
	| tret tnum ';'					{sprintf($$.thestr, "return %d;\n", $2.ival); }
	| error ';'					{}
	;

select	: tif '(' cond ')' block			{}
	| telse block					{}
	;

/* condition needs to allow for no semicolon to work with looping */
cond	: expr relop expr				{}
	| expr relop expr ';'				{}
	;

relop 	: tlt {} | tgt {} | tle {} | tge {} | teq {} | tne {} ;

tnumlist: tnumlist',' tnum				{
							  strcat($$.numlist, ", ");
							  if ($3.ttype == 10)
							  {
							    sprintf($3.numlist, "%d", $3.ival);
							    strcat($$.numlist, $3.numlist);
							  }
							  else if ($3.ttype == 20)
							  {
							    sprintf($3.numlist, "%f", $3.fval);
							    strcat($$.numlist, $3.numlist);
							  }
							}
        | tnum						{
							  if ($1.ttype == 10)
							    sprintf($$.numlist, "%d", $1.ival);
							  else if ($1.ttype == 20)
							    sprintf($$.numlist, "%f", $1.fval);
							}
	;

assignarray: tid '[' tid ']'tassign tnum';'	{
							  intab($1.thestr);
							  int type;
							  type = gettype($1.thestr);
							  if(type != 11 && type != 22 && type != 33)
							  {
							    printf("%s is not an array!\n", $1.thestr);
							    errorclosefile();
							  }
							  int indextype;
							  indextype = gettype($3.thestr);
							  if (indextype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  int bound;
							  bound = arraybound($1.thestr);
							  char intf[] = "%d";
							  switch(type)
							  {
							    case 11:
								sprintf($$.thestr, "\tif (%s > %d)\n\t{\n\t\tprintf(\"Error: index %s out of bounds. %s has bound %d.\\n\", %s);\n", $3.thestr, bound, intf, $1.thestr, bound, $3.thestr);
								sprintf(temp, "\t\texit(1);\n\t}\n"); strcat($$.thestr, temp);
							    	sprintf(temp, "\t%s[%s] = %d;\n", $1.thestr, $3.thestr, $6.ival); strcat($$.thestr, temp);
								break;
							    
							    case 22:
								sprintf($$.thestr, "\tif (%s > %d)\n\t{\n\t\tprintf(\"Error: index %s out of bounds. %s has bound %d.\\n\", %s);\n", $3.thestr, bound, intf, $1.thestr, bound, $3.thestr);
								sprintf(temp, "\t\texit(1);\n\t}\n"); strcat($$.thestr, temp);
							    	sprintf(temp, "\t%s[%s] = %d;\n", $1.thestr, $3.thestr, $6.ival); strcat($$.thestr, temp);
								break;
							    
							    case 33:
							    	printf("Cannot assign number into char array\n");
							    	errorclosefile();
								break;
							  }
						}
	| tid '[' tnum ']'tassign tnum';'	{
							  intab($1.thestr);
							  int type;
							  type = gettype($1.thestr);
							  if(type != 11 && type != 22 && type != 33)
							  {
							    printf("%s is not an array!\n", $1.thestr);
							    errorclosefile();
							  }
							  if ($3.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  int bound;
							  bound = arraybound($1.thestr);
							  if ($3.ival > bound)
							  {
							    printf("Index %d out of bounds. %s has bound %d.\n", $3.ival, $1.thestr, bound);
							    errorclosefile();
							  }			
							  switch(type)
							  {
							    case 11:
							    	sprintf($$.thestr, "\t%s[%d] = %d;\n", $1.thestr, $3.ival, $6.ival);
								break;
							    
							    case 22:
							   	sprintf($$.thestr, "\t%s[%d] = %f;\n", $1.thestr, $3.ival, $6.fval);
								break;
							    
							    case 33:
							   	printf("Cannot assign number into char array\n");
								errorclosefile();
								break;
							  }
						}
        | tid '[' tnum ']'tassign tchrlit';' 	{
							  intab($1.thestr);
							  int type;
							  type = gettype($1.thestr);
							  if(type != 11 && type != 22 && type != 33)
							  {
							    printf("%s is not an array!\n", $1.thestr);
							    errorclosefile();
							  }
							  if ($3.ttype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  int bound;
							  bound = arraybound($1.thestr);
							  if ($3.ival > bound)
							  {
							    printf("Index %d out of bounds. %s has bound %d.\n", $3.ival, $1.thestr, bound);
							    errorclosefile();
							  }
							  switch(type)
							  {
							    case 11:
							    	printf("Cannot assign char into int array\n");
							    	errorclosefile();
								break;
							    
							    case 22:
							    	printf("Cannot assign char into float array\n");
							    	errorclosefile();
								break;
							    
							    case 33:
							    	sprintf($$.thestr, "\t%s[%d] = %s;\n", $1.thestr, $3.ival, $6.thestr);
								break;
							  }
						}			
        | tid '[' tid ']'tassign tchrlit';' 	{
							  intab($1.thestr);
							  int type;
							  type = gettype($1.thestr);
							  if(type != 11 && type != 22 && type != 33)
							  {
							    printf("%s is not an array!\n", $1.thestr);
							    errorclosefile();
							  }
							  int indextype;
							  indextype = gettype($3.thestr);
							  if (indextype != 10)
							  {
							    printf("Array size must be an integer!\n");
							    errorclosefile();
							  }
							  int bound;
							  bound = arraybound($1.thestr);
							  char intf[] = "%d";
							  switch(type)
							  {
							    case 11:
							    	printf("Cannot assign char into int array\n");
							    	errorclosefile();
								break;
							    
							    case 22:
							    	printf("Cannot assign char into float array\n");
							    	errorclosefile();
								break;
							    
							    case 33:
								sprintf($$.thestr, "\tif (%s > %d)\n\t{\n\t\tprintf(\"Error: index %d out of bounds. %s has bound %d.\\n\", %s);\n", $3.thestr, bound, intf, $1.thestr, bound, $3.thestr);
								sprintf(temp, "\t\texit(1);\n\t}\n"); strcat($$.thestr, temp);
							    	sprintf(temp, "\t%s[%s] = %s;\n", $1.thestr, $3.thestr, $6.thestr); strcat($$.thestr, temp);
								break;
							  }			
					 	}

	;

loop	: twhile block					{sprintf($$.thestr, "\t%s\n%s\n", $1.thestr, $2.thestr);}
	/* the semicolons are handled by rules above */
	| tfor '(' S  cond  S ')' block 		{}
	;

expr 	: expr '+' term					{strcat($$.thestr, " + "); strcat($$.thestr, $3.thestr);}
	| expr '-' term					{strcat($$.thestr, " - "); strcat($$.thestr, $3.thestr);}
	| term						{sprintf($$.thestr, "%s", $1.thestr);}
	;
	
term	: term '*' factor				{strcat($$.thestr, " * "); strcat($$.thestr, $3.thestr);}
	| term '/' factor				{strcat($$.thestr, " / "); strcat($$.thestr, $3.thestr);}
	| term '%' factor				{strcat($$.thestr, " % "); strcat($$.thestr, $3.thestr);}
	| factor					{sprintf($$.thestr, "%s", $1.thestr);}
	;

factor	: tnum						{
							  if ($1.ttype == 10)
							    sprintf($$.thestr, "%d", $1.ival);
							  else if ($1.ttype == 20)
							    sprintf($$.thestr, "%f", $1.fval);
							}
	| tid						{sprintf($$.thestr, "%s", $1.thestr);}

	| '(' expr ')'					{sprintf($$.thestr, "(%s)", $2.thestr);}
	;

%%

main()
{
    fp = fopen(filename, "w+");
    setuptab();
    yyparse();
    printf("---------------------------\n");
    fclose(fp);
}

int errorclosefile()
{
	remove(filename);
	fclose(fp);
	exit(1);
}
