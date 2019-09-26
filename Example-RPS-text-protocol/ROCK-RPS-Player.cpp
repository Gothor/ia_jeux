#include <cstdlib>
#include <cstdio>
#include <iostream>
#include <string.h>
#include <vector>
#include <string>
#include <ctime>
#include <unistd.h>
#include <cfloat>
#include <sys/time.h>

#define HIDDEN -1
#define ROCK 0
#define PAPER 1
#define SCISORS 2

#define ERROR -2

#define ME 0
#define OPP 1

struct RPS_t {
  int hands[2];

  void init() {
    std::srand(std::time(0));
    hands[ME] = HIDDEN;
    hands[OPP] = HIDDEN;
  }
  static std::string val2str(int _val) {
    if(_val == HIDDEN) return std::string("HIDDEN");
    if(_val == ROCK) return std::string("ROCK");
    if(_val == PAPER) return std::string("PAPER");
    if(_val == SCISORS) return std::string("SCISORS");
    return std::string("ERROR");
  }
  static int str2val(std::string _str) {
    if(_str.compare("HIDDEN") == 0) return HIDDEN;
    if(_str.compare("ROCK") == 0) return ROCK;
    if(_str.compare("PAPER") == 0) return PAPER;
    if(_str.compare("SCISORS") == 0) return SCISORS;
    return ERROR;
  }
  bool print(FILE* _fp) {
    fprintf(_fp, "MY:%s OPP:%s\n",
	    val2str(hands[ME]).c_str(),
	    val2str(hands[OPP]).c_str());
    return true;
  }
  bool play(int _who, int _val) {
    hands[_who] = _val;
    return true;
  }
  int genmove() {
    usleep(100000);
    return ROCK; 
  }
  bool endgame() {
    if(hands[ME]==HIDDEN) return false;
    if(hands[OPP]==HIDDEN) return false;
    return true;
  }
};

struct RPS_parser_t {
  bool parser_alive;
  RPS_t player;
  char playername[512];
  
  FILE* fp;
  RPS_parser_t(char* _name) {
    char* trace_file = (char*)"/tmp/cmd_trace_file.txt";
    fp = fopen(trace_file,"w");
    parser_alive = true;
    strncpy(playername, _name, 512);
  }
  ~RPS_parser_t() {
    fclose(fp);
  }
  bool vcmd_parser(std::vector<std::string> _v) {
    if(_v[0].compare("help") == 0) {
      fprintf(stderr, "  quit\n");
      fprintf(stderr, "  name\n");
      fprintf(stderr, "  version\n");
      fprintf(stderr, "  showboard\n");
      fprintf(stderr, "  newgame\n");
      fprintf(stderr, "  genmove\n");
      fprintf(stderr, "  play ROCK | PAPER | SCISORS\n");
      fprintf(stderr, "  opp_play ROCK | PAPER | SCISORS\n");
      fprintf(stderr, "  endgame\n");
      fprintf(stderr, "  list_commands\n");
      fflush(stderr);
      return true;
    }

    if(_v[0].compare("quit") == 0) {
      fprintf(stdout, "= \n\n"); parser_alive = false; return true;
    } 
    if(_v[0].compare("name") == 0) {
      fprintf(stdout, "= %s\n\n", playername); return true;
    } 
    if(_v[0].compare("version") == 0) {
      fprintf(stdout, "= 1.0\n\n"); return true;
    }
    if(_v[0].compare("showboard") == 0) {
      if(player.print(stdout)) { fprintf(stdout, "= \n\n"); return true; }
      fprintf(stdout, "= ?\n\n"); return true;
    }
    if(_v[0].compare("newgame") == 0) {
      player.init(); fprintf(stdout, "= \n\n"); return true;
    }
    if(_v[0].compare("genmove") == 0) {
      int ret = player.genmove();
      if(ret == ERROR) {fprintf(stdout, "= ?\n\n"); return true; }
      else { 
	if(player.play(ME, ret)) { 
	  fprintf(stdout, "= %s\n\n", RPS_t::val2str(ret).c_str()); 
	  return true; 
	} else {
	  fprintf(stdout, "= ?\n\n"); return true;
	}
      }
    }
    if(_v[0].compare("play") == 0) {
      if(_v.size() != 2) { fprintf(stdout, "= ?\n\n"); return true; }
      if(player.play(ME, RPS_t::str2val(_v[1]))) { fprintf(stdout, "= \n\n"); return true; }
      fprintf(stdout, "= ?\n\n"); return true; 
    }
    if(_v[0].compare("opp_play") == 0) {
      if(_v.size() != 2) { fprintf(stdout, "= ?\n\n"); return true; }
      if(player.play(OPP, RPS_t::str2val(_v[1]))) { fprintf(stdout, "= \n\n"); return true; }
      fprintf(stdout, "= ?\n\n"); return true; 
    }
    if(_v[0].compare("endgame") == 0) {
      if(player.endgame()==false){
	fprintf(stdout, "= ?\n\n"); return true; 
      }
      fprintf(stdout, "= \n\n"); return true;
    }
    if(_v[0].compare("list_commands") == 0) {
      fprintf(stdout, "= quit\nname\nversion\nshowboard\nnewgame\ngenmove\nplay\nopp_play\nendgame\nlist_commands\n\n"); return true;
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

/* g++ -O2 -std=c++11 ROCK-RPS-Player.cpp -o ROCK-RPS-Player */
int main(int _ac, char** _av) {
  setbuf(stdout, 0);
  setbuf(stderr, 0);

  RPS_parser_t P((char*)"Rand-RPS-Player");
  P.stdin_text_parser();
  return 1;
}
