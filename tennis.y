%code {

/* 
This  program reads a list  of players  from its input.
It prints the name and number if wins(the maximum that played at wimbeldon) 
   that satisfies the following conditions:
     (1)  maximum wins 
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

  /* yylex () and yyerror() need to be declared here */
extern int yylex (void);
void yyerror (const char *s);
}
%code requires {
/*enum for the gender types*/
typedef enum { MALE, FEMALE } Gender;
/*struct with player details we want to print and save always*/
 	 typedef struct { 
		char name[80];
		int numwins;
		Gender gender;
	}Player;
}

/* note: no semicolon after the union */
%union{
	Player player;
	char name[80];
	int yearwin;
	Gender gender;
	int numwins;
}

%token TITLE,NAME,GENDER,WIMBLEDON,AUSTRALIAN_OPEN,PSIK,AD
/*all the tokens that had field in our union*/
%token <name> PLAYER_NAME
%token <gender> PLAYER_GENDER
%token <yearwin> NUM

/*for the recursive*/
%type <player> list_of_players player
%type <numwins> list_of_years year_spec optional_wimbledon

%error-verbose

%%

input: TITLE list_of_players
	{if($2.numwins == -1)
		{
			printf("there is no player that answers the criteria");/*if empty , then theres no winning.*/
		}else{
			printf("Player with most wins at Wimbledon: %s (%d wins)",$2.name,$2.numwins);/*else we have reduced to the player with th max winning at wimbeldon.*/
		}
	};
list_of_players: list_of_players player{
			/*check whos got the highest number of winning*/
			if($1.numwins>=$2.numwins)
				$$=$1;
			else
				$$=$2;
				
			};
list_of_players: /* empty */{
			strcpy($$.name,"");
			$$.numwins=-1;
			$$.gender=FEMALE;/*doesn't really metter it could be man either*/
		};
player: NAME PLAYER_NAME GENDER PLAYER_GENDER/*we save the details we need for the union and for the check who's got the highest winning*/
 optional_wimbledon optional_australian_open{
		strcpy($$.name,$2);
		$$.numwins=$5;
		$$.gender=$4;
		} ;

optional_wimbledon: WIMBLEDON list_of_years{$$=$2;} |
 /* empty */{
		$$=-1;};/*we save the calculation only for wimbeldon because thats what we ask for*/
optional_australian_open: AUSTRALIAN_OPEN list_of_years |
 /* empty */;/*we are dont do nothing special here because it doesn't metter we only care about wimbeldon*/
list_of_years: list_of_years ',' year_spec{
			$$=$1+$3;/*the total num years of winning*/};
list_of_years: year_spec{
		$$=$1;/*we save the spec year we calculate at list years.*/
		};
year_spec: NUM{$$=1;} | NUM '-' NUM{$$=$3-$1+1;} ; /*if there is only one year apears we save the year else we calculate the substarction between years*/     

%%

int main (int argc, char **argv)
{
  extern FILE *yyin;
  if (argc != 2) {
     fprintf (stderr, "Usage: %s <input-file-name>\n", argv[0]);
	 return 1;
  }
  yyin = fopen (argv [1], "r");
  if (yyin == NULL) {
       fprintf (stderr, "failed to open %s\n", argv[1]);
	   return 2;
  }
  
  yyparse ();
  
  fclose (yyin);
  return 0;
}

void yyerror (const char *s)
{
  extern int line;
  fprintf (stderr, "line %d: %s\n", line, s);
}





