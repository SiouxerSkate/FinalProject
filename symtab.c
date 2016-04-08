/* constants */
#define TRUE        1
#define FALSE       0
#define SIZE        1024

/* type constants */
#define INT     	10
#define INT_ARRARY	11
#define FLOAT   	20
#define FLOAT_ARRAY	22
#define CHAR		30
#define CHAR_ARRAY	33


/* error constants */
#define ERROR_NOT_INIT          100
#define ERROR_UNKNOWN_TYPE      101
#define ERROR_WHO_KNOWS         102

/* declarations/definitions */
struct stelem
{
 char sname[1024];
 int  stype;    /* see type constants for types */	 
 int  binit;    /* boolean for initialization */
 int  ssize;    /* if not an array set to 1 */
};
typedef struct stelem entry;

/* global variables */
entry symtab[SIZE];
int nsym = 0;

/* functions */
void setuptab(void)
{
    int i;
    for (i = 1; i < SIZE; i++)
    {  
	symtab[i].sname[0] = '\0';
	symtab[i].stype = 0;
	symtab[i].binit = FALSE;    /* When initialized, we set to TRUE */
    }
}

void addtab( char *s)
{
    nsym++;
    strcpy( symtab[nsym].sname, s);
    symtab[nsym].stype = -1;   
}

void showtab()
{
 int i;
 for (i = 1; i <= nsym; ++i)
   printf("%d: %s %d\n", i, symtab[i].sname, symtab[i].stype);      /* add field for binit */
}

int intab( char *s)
{
 int i;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    return TRUE;
 }
 return FALSE;
}

 int varsInitialized(void)
 {
    int i;
     for ( i = 1; i <= nsym; ++i)
     {
        if (symtab[i].binit == FALSE)
        {
            printf("What are you thinking!? Initialize your variables!!!!\n");
            exit(ERROR_NOT_INIT);
        }
     }
     return TRUE;
 }
 
void addtype( char *s, int t)
{
 int i, loc = -1;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    loc = i;
 }
 if (loc > 0)
  {
   printf("Set type %s to %d\n", s, t);
   symtab[loc].stype = t;             
  }
 else
 {
   printf("Unable to set type %s to %d\n", s, t);
 } 
}

int initsym( char *s)
{
 int i, loc = -1;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    loc = i;
 }
 if (loc > 0)
  {
   printf("Symbol %s initialized\n", s);
   symtab[loc].binit = TRUE;          
  }
 else
 {
   printf("Unable to initialize %s\n", s);
 } 
}


int gettype( char *s)
{
 int t = -1;
 int i, loc = -1;
 for ( i = 1; i <= nsym; ++i)
 {
   if ( strcmp(symtab[i].sname, s) == 0)
    loc = i;
 }
 if (loc > 0)
  {
   t = symtab[loc].stype;
   printf("Get type for %s to %d\n", s, t);
  }
 if (loc <= 0)
   printf("gettype var %s not found\n", s);
 else if (t < 0)
   printf("gettype var %s has bad type %d\n", s, t);
 else 
   printf("gettype var %s has type %d\n", s, t);
 return t;
}



