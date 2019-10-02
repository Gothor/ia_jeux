#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <string.h>
#include <string>
#include <vector>

#define EMPTY '.'
#define X_PLAYER 'x'
#define O_PLAYER 'o'
#define TIE '$'

struct NTTT_t {

  char mBoard[9];
  char board[81];

  NTTT_t(): mBoard{}, board{} {
    for (int i = 0; i < 9; i++) {
      mBoard[i] = EMPTY;
      board[i] = EMPTY;
    }
    for (int i = 9; i < 81; i++) {
      board[i] = EMPTY;
    }
  }

  bool print(FILE* _fp) {
    fprintf(_fp, "Meta board:\n");
    printMBoard(_fp);

    fprintf(_fp, "\nBoard:\n");
    printBoard(_fp);

    fprintf(_fp, "\n");
  }

  void printMBoard(FILE* _fp) {
    for (int i = 0; i < 9; i++) {
      if (i % 3 == 0 && i > 0) {
        fprintf(_fp, "\n");
      }
      fprintf(_fp, "%c", mBoard[i]);
    }
  }

  void printBoard(FILE* _fp) {
    for (int i = 0; i < 81; i++) {
      if (i % 9 != 0 && i % 3 == 0 && i > 0) {
        fprintf(_fp, " ");
      } else if (i % 9 == 0 && i > 0) {
        fprintf(_fp, "\n");
      }
      if (i % 27 == 0 && i > 0) {
        fprintf(_fp, "\n");
      }
      fprintf(_fp, "%c", board[i]);
    }
  }

};

struct NTTT_parser_t {
  bool parser_alive;
  NTTT_t player;
  char playername[512];

  NTTT_parser_t(char* _name): player() {
    parser_alive = true;
    strncpy(playername, _name, 512);
  }

  bool vcmd_parser(std::vector<std::string> _v) {
    if(_v[0].compare("help") == 0) {
      fprintf(stderr, "  quit\n");
      fprintf(stderr, "  name\n");
      fprintf(stderr, "  version\n");
      fprintf(stderr, "  showboard\n");
      fprintf(stderr, "  newgame\n");
      fprintf(stderr, "  genmove\n");
      fprintf(stderr, "  play [0-80]\n");
      fprintf(stderr, "  opp_play [0-80]\n");
      fprintf(stderr, "  endgame\n");
      fprintf(stderr, "  list_commands\n");
      fflush(stderr);
      return true;
    }

    if(_v[0].compare("quit") == 0) {
      fprintf(stdout, "= \n\n"); parser_alive = false;
      return true;
    } 
    if(_v[0].compare("name") == 0) {
      fprintf(stdout, "= %s\n\n", playername);
      return true;
    } 
    if(_v[0].compare("version") == 0) {
      fprintf(stdout, "= 1.0\n\n");
      return true;
    }
    if(_v[0].compare("showboard") == 0) {
      if(player.print(stdout)) {
        fprintf(stdout, "= \n\n");
        return true;
      }
      fprintf(stdout, "= ?\n\n");
      return true;
    }
    if(_v[0].compare("newgame") == 0) {
      /*
      player.init();
      fprintf(stdout, "= \n\n");
      */
      return true;
    }
    if(_v[0].compare("genmove") == 0) {
      return true;
      /*
      int ret = player.genmove();
      if(ret == ERROR) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      else { 
        if(player.play(ME, ret)) { 
          fprintf(stdout, "= %s\n\n", RPS_t::val2str(ret).c_str()); 
          return true; 
        } else {
          fprintf(stdout, "= ?\n\n");
          return true;
        }
      }
      */
    }
    if(_v[0].compare("play") == 0) {
      /*
      if(_v.size() != 2) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      if(player.play(ME, RPS_t::str2val(_v[1]))) {
        fprintf(stdout, "= \n\n");
        return true;
      }
      fprintf(stdout, "= ?\n\n");
      */
      return true; 
    }
    if(_v[0].compare("opp_play") == 0) {
      /*
      if(_v.size() != 2) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      if(player.play(OPP, RPS_t::str2val(_v[1]))) {
        fprintf(stdout, "= \n\n");
        return true;
      }
      fprintf(stdout, "= ?\n\n");
      */
      return true; 
    }
    if(_v[0].compare("endgame") == 0) {
      /*
      if(player.endgame()==false){
	      fprintf(stdout, "= ?\n\n");
        return true;
      }
      fprintf(stdout, "= \n\n");
      */
      return true;
    }
    if(_v[0].compare("list_commands") == 0) {
      fprintf(stdout, "= quit\nname\nversion\nshowboard\nnewgame\ngenmove\nplay\nopp_play\nendgame\nlist_commands\n\n");
      return true;
    }
    return false;
  }

  void stdin_text_parser() {
    std::string command;
    while(parser_alive == true) {
      getline(std::cin, command);
      if(0 != (int)command.length()) {
        if(command.c_str()[0] != '#') {
          char* cstr = new char [command.size()+1];
          strcpy (cstr, command.c_str());
          char* cstr2 = strtok(cstr, " ");
          std::vector<std::string> vcmd;
          while(cstr2 != 0) {
            vcmd.push_back(std::string(cstr2));
            cstr2 = strtok(0, " ");
          }
          delete cstr;
          vcmd_parser(vcmd);
        }
      }
    }
  }

};

/* g++ -O2 -std=c++11 9TTT-Rand-Player.cpp -o 9TTT-Rand-Player */
int main(int _ac, char** _av) {
  setbuf(stdout, 0);
  setbuf(stderr, 0);
  std::srand(1);

  NTTT_parser_t P((char*)"9TTT-Rand-Player");
  P.stdin_text_parser();
  return 1;
}
