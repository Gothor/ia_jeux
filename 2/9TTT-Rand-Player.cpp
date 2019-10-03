#include <cstdlib>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string.h>
#include <string>
#include <vector>

#define ERROR -1

#define EMPTY '.'
#define X_PLAYER 'x'
#define O_PLAYER 'o'
#define TIE '$'

struct NTTT_t {

  char mBoard[9];
  char board[81];
  int lastMove;
  std::vector<int> nextMoves;

  NTTT_t(): mBoard{}, board{}, lastMove(-1), nextMoves() {}

  void init() {
    std::memset(mBoard, EMPTY, sizeof mBoard);
    std::memset(board, EMPTY, sizeof board);
    lastMove = -1;
    nextMoves.clear();
    for (int i = 0; i < 81; i++) {
      nextMoves.push_back(i);
    }
  }

  int genmove() {
    if (nextMoves.size() == 0)
      return ERROR;

    int i = rand() * 1.0 / RAND_MAX * nextMoves.size();
    return nextMoves[i];
  }

  bool isValidPosition(int pos) {
    for (std::vector<int>::iterator it = nextMoves.begin(); it != nextMoves.end(); ++it) {
      if (pos == *it) return true;
    }

    return false;
  }

  void updateNextMoves() {
    nextMoves.clear();

    if (endgame()) return;

    int x = lastMove % 3;
    int y = (lastMove % 27) / 9;
    int tl = y * 27 + x * 3;
    int mPos = (lastMove / 27) * 3 + (lastMove % 9) / 3;

    if (mBoard[mPos] == EMPTY) {
      // Look for empty cell in the target grid
      for (int y = 0; y < 3; y++) {
        for (int x = 0; x < 3; x++) {
          if (board[tl + y * 9 + x] == EMPTY) {
            nextMoves.push_back(tl + y * 9 + x);
          }
        }
      }

      if (nextMoves.size() != 0) return;
    }

    // If empty => you can play on any empty cell
    for (int i = 0; i < 81; i++) {
      //fprintf(stderr, "- %d => %d (%c)\n", i, (i / 27) * 3 + (i % 9) / 3, mBoard[(i / 27) * 3 + (i % 9) / 3]);
      if (board[i] == EMPTY && mBoard[(i / 27) * 3 + (i % 9) / 3] == EMPTY) {
        fprintf(stderr, "  => push %d\n", i);
        nextMoves.push_back(i);
      }
    }
  }

  void checkMetaBoard() {
    // Get top left position of the last move grid
    int tl = lastMove - lastMove % 27 + lastMove % 9 - lastMove % 3;
    int mp = tl + 10;
    int br = tl + 20;
    int mPos = (lastMove / 27) * 3 + (lastMove % 9) / 3;

    if (mBoard[mPos] != EMPTY) return;

    // Check all lines
    if (board[tl] != EMPTY) {
      if ((board[tl] == board[tl+1] && board[tl] == board[tl+2])
        || (board[tl] == board[tl+9] && board[tl] == board[tl+18])
        || (board[tl] == board[tl+10] && board[tl] == board[tl+20])) {
        mBoard[mPos] = board[tl];
        return;
      }
    }
    if (board[mp] != EMPTY) {
      if ((board[mp] == board[mp-9] && board[mp] == board[mp+9])
        || (board[mp] == board[mp-8] && board[mp] == board[mp+8])
        || (board[mp] == board[mp-1] && board[mp] == board[mp+1])) {
        mBoard[mPos] = board[mp];
        return;
      }
    }
    if (board[br] != EMPTY) {
      if ((board[br] == board[br-9] && board[br] == board[br-18])
        || (board[br] == board[br-2] && board[br] == board[br-1])) {
        mBoard[mPos] = board[br];
        return;
      }
    }

    // Look for empty cell
    for (int i = 0; i < 3; i++) {
      if (board[tl+i] == EMPTY || board[tl+9+i] == EMPTY || board[tl+18+i] == EMPTY)
        return;
    }

    // TIED GRID !
    mBoard[mPos] = TIE;
  }

  bool play(int pos) {
    char current = ((lastMove == -1) || (board[lastMove] == O_PLAYER) ? X_PLAYER : O_PLAYER);

    if (!isValidPosition(pos)) {
      return false;
    }

    board[pos] = current;
    lastMove = pos;
    checkMetaBoard();
    updateNextMoves();
    
    return true;
  }

  bool endgame() {
    // Check all lines
    if (mBoard[0] != EMPTY) {
      if ((mBoard[0] == mBoard[1] && mBoard[0] == mBoard[2])
        || (mBoard[0] == mBoard[3] && mBoard[0] == mBoard[6])
        || (mBoard[0] == mBoard[4] && mBoard[0] == mBoard[8])) {
        return true;
      }
    }
    if (mBoard[4] != EMPTY) {
      if ((mBoard[4] == mBoard[1] && mBoard[4] == mBoard[7])
        || (mBoard[4] == mBoard[2] && mBoard[4] == mBoard[6])
        || (mBoard[4] == mBoard[3] && mBoard[4] == mBoard[5])) {
        return true;
      }
    }
    if (mBoard[8] != EMPTY) {
      if ((mBoard[8] == mBoard[5] && mBoard[8] == mBoard[2])
        || (mBoard[8] == mBoard[6] && mBoard[8] == mBoard[7])) {
        return true;
      }
    }

    // Look for empty cell
    for (int i = 0; i < 9; i++) {
      if (mBoard[i] == EMPTY)
        return false;
    }

    // Tie
    return true;
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
      player.init();
      fprintf(stdout, "= \n\n");
      return true;
    }
    if(_v[0].compare("genmove") == 0) {
      int ret = player.genmove();
      if(ret == ERROR) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      else { 
        if(player.play(ret)) { 
          fprintf(stdout, "= %d\n\n", ret); 
          return true; 
        } else {
          fprintf(stdout, "= ?\n\n");
          return true;
        }
      }
    }
    if(_v[0].compare("play") == 0) {
      if(_v.size() != 2) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      if(player.play(std::stoi(_v[1]))) {
        fprintf(stdout, "= \n\n");
        return true;
      }
      fprintf(stdout, "= ?\n\n");
      return true; 
    }
    if(_v[0].compare("opp_play") == 0) {
      if(_v.size() != 2) {
        fprintf(stdout, "= ?\n\n");
        return true;
      }
      if(player.play(std::stoi(_v[1]))) {
        fprintf(stdout, "= \n\n");
        return true;
      }
      fprintf(stdout, "= ?\n\n");
      return true; 
    }
    if(_v[0].compare("endgame") == 0) {
      if(player.endgame()==false){
	      fprintf(stdout, "= ?\n\n");
        return true;
      }
      fprintf(stdout, "= \n\n");
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
