#!/usr/bin/env pike
// read https://pike.lysator.liu.se/

// pike 9TTT_tp.pike -f ./player0 -s ./player1 -o data1 -n 2 -v 1

#define DUMP_RPSTP_PIPES		0

array (int) pos2topleft_on_board = ({
  0, 0, 0, 3, 3, 3, 6, 6, 6,
  0, 0, 0, 3, 3, 3, 6, 6, 6,
  0, 0, 0, 3, 3, 3, 6, 6, 6,
  27,27,27, 30,30,30, 33,33,33,
  27,27,27, 30,30,30, 33,33,33,
  27,27,27, 30,30,30, 33,33,33,
  54,54,54, 57,57,57, 60,60,60,
  54,54,54, 57,57,57, 60,60,60,
  54,54,54, 57,57,57, 60,60,60
});
array(int) board2mboard = ({
  0, 0, 0, 1, 1, 1, 2, 2, 2,
  0, 0, 0, 1, 1, 1, 2, 2, 2,
  0, 0, 0, 1, 1, 1, 2, 2, 2,
  3, 3, 3, 4, 4, 4, 5, 5, 5,
  3, 3, 3, 4, 4, 4, 5, 5, 5,
  3, 3, 3, 4, 4, 4, 5, 5, 5,
  6, 6, 6, 7, 7, 7, 8, 8, 8,
  6, 6, 6, 7, 7, 7, 8, 8, 8,
  6, 6, 6, 7, 7, 7, 8, 8, 8
});

class nineTTT_board {
  string mboard = ".........";
  string board = ".................................................................................";
  string turn;
  string winner;

  void init() {
    for(int i=0; i < 9;i++) mboard[i] = '.';
    for(int i=0; i < 81;i++) board[i] = '.';
    turn="x";
    winner=".";
  }
  void printlineboard(int line) {
    werror("  %c %c %c  %c %c %c  %c %c %c\n",
	    board[line+0], board[line+1], board[line+2],
	    board[line+3], board[line+4], board[line+5],
	    board[line+6], board[line+7], board[line+8]);
  }
  void printboard() {
    printlineboard(0); printlineboard(9); printlineboard(18);
    werror("\n");
    printlineboard(27); printlineboard(36); printlineboard(45);
    werror("\n");
    printlineboard(54); printlineboard(63); printlineboard(72); 
    werror("\n");
    werror("  %c %c %c\n", mboard[0], mboard[1], mboard[2]);
    werror("  %c %c %c\n", mboard[3], mboard[4], mboard[5]);
    werror("  %c %c %c\n", mboard[6], mboard[7], mboard[8]);
    werror("  turn: %s\n", turn);
  }
  bool play(string _str_pos) {
    int pos = (int)_str_pos;
    if(board[pos]!='.') return false;
    if(mboard[board2mboard[pos]]!='.') return false;
    board[pos]=turn[0];
    if(turn[0]=='x') turn[0]='o';
    else turn[0]='x';
    update_mboard(pos);
    return true;
  }
  bool endgame() {
    winner = newwin_on_mboard();
    if(winner[0]=='x' || winner[0]=='o') return true;
    else {
      if(full_mboard()) {
	winner[0]='$';
	return true;
      }
    }
    return false;
  }
  void update_mboard(int _pos) {
    string local_winner = newwin_on_board(_pos);
    if(local_winner[0] == 'x') {
      mboard[board2mboard[_pos]] = 'x';
    } else if(local_winner[0] == 'o') {
      mboard[board2mboard[_pos]] = 'o';
    } else {
      if(full_board(_pos)) {
	mboard[board2mboard[_pos]] = '$';
      }
    }
  }
  bool full_board(int _pos) {
    int top_left_corner = pos2topleft_on_board[_pos];
    for(int i = 0; i < 3; i++) {
      if(board[top_left_corner+i] == '.') return false;
    }
    for(int i = 0; i < 3; i++) {
      if(board[top_left_corner+9+i] == '.') return false;
    }
    for(int i = 0; i < 3; i++) {
      if(board[top_left_corner+18+i] == '.') return false;
    }
    return true;
  }
  bool full_mboard() {
    for(int i = 0; i < 9; i++) {
      if(mboard[i] == '.') return false;
    }
    return true;
  }
  string newwin_on_board(int _pos){
    int top_left_corner = pos2topleft_on_board[_pos];
    if(board[top_left_corner] == 'x' || board[top_left_corner] == 'o') {
      if(board[top_left_corner] == board[top_left_corner+1] &&
	 board[top_left_corner] == board[top_left_corner+2])
	return sprintf("%c",board[top_left_corner]);
      if(board[top_left_corner] == board[top_left_corner+9] &&
	 board[top_left_corner] == board[top_left_corner+18])
	return sprintf("%c",board[top_left_corner]);
      if(board[top_left_corner] == board[top_left_corner+10] &&
	 board[top_left_corner] == board[top_left_corner+20])
	return sprintf("%c",board[top_left_corner]);
    }
    int middle_on_board = top_left_corner+10;
    if(board[middle_on_board] == 'x' || board[middle_on_board] == 'o') {
      if(board[middle_on_board] == board[middle_on_board-9] &&
	 board[middle_on_board] == board[middle_on_board+9])
	return sprintf("%c",board[middle_on_board]);
      if(board[middle_on_board] == board[middle_on_board-1] &&
	 board[middle_on_board] == board[middle_on_board+1])
	return sprintf("%c",board[middle_on_board]);
      if(board[middle_on_board] == board[middle_on_board-8] &&
	 board[middle_on_board] == board[middle_on_board+8])
	return sprintf("%c",board[middle_on_board]);
    }
    int bot_right_corner = top_left_corner+20;
    if(board[bot_right_corner] == 'x' || board[bot_right_corner] == 'o') {
      if(board[bot_right_corner] == board[bot_right_corner-18] &&
	 board[bot_right_corner] == board[bot_right_corner-9])
	return sprintf("%c",board[bot_right_corner]);
      if(board[bot_right_corner] == board[bot_right_corner-1] &&
	 board[bot_right_corner] == board[bot_right_corner-2])
	return sprintf("%c",board[bot_right_corner]);
    }
    return ".";
  }
  string newwin_on_mboard(){
    if(mboard[0] == 'x' || mboard[0] == 'o') {
      if(mboard[0] == mboard[1] && mboard[0] == mboard[2])
	return sprintf("%c",mboard[0]);
      if(mboard[0] == mboard[3] && mboard[0] == mboard[6])
	return sprintf("%c",mboard[0]);
      if(mboard[0] == mboard[4] && mboard[0] == mboard[8])
	return sprintf("%c",mboard[0]);
    }
    if(mboard[4] == 'x' || mboard[4] == 'o') {
      if(mboard[4] == mboard[1] && mboard[4] == mboard[7])
	return sprintf("%c",mboard[4]);
      if(mboard[4] == mboard[3] && mboard[4] == mboard[5])
	return sprintf("%c",mboard[4]);
      if(mboard[4] == mboard[2] && mboard[4] == mboard[6])
	return sprintf("%c",mboard[4]);
    }
    if(mboard[8] == 'x' || mboard[8] == 'o') {
      if(mboard[8] == mboard[2] && mboard[8] == mboard[5])
	return sprintf("%c",mboard[8]);
      if(mboard[8] == mboard[7] && mboard[8] == mboard[6])
	return sprintf("%c",mboard[8]);
    }
    return ".";
  }
}

class nineTTTtp_server {
  int server_is_up;
  private Stdio.File file_out;
  private Stdio.FILE file_in;
  string command_line;
  string full_engine_name;

  void create(string _command_line) {
    file_out = Stdio.File();
    file_in = Stdio.FILE();
    command_line = _command_line;
    array error = catch { 
	Process.create_process(command_line / " ",
			       ([ "stdin" : file_out->pipe(),
				  "stdout" : file_in->pipe() ])); };
    if (error) {
      werror(error[0]); werror("Command line was `%s'.\n", command_line);
      destruct(this_object());
    } else {
      array error = catch {
	  full_engine_name = get_full_engine_name(); server_is_up = 1; };
      if (error) {
	werror("Engine `%s' crashed at startup.\nPerhaps command line is wrong.\n",
	       command_line);
	destruct(this_object());
      }
    }
  }
  
  array send_command(string command) {
#if DUMP_RPSTP_PIPES
    werror("[%s%s] %s\n", full_engine_name ? full_engine_name + ", " : "", command);
#endif
    command = String.trim_all_whites(command);
    sscanf(command, "%[0-9]", string id);
    if (command[0] == '#' || command == id) return ({ 0, "" });
    file_out->write("%s\n", command);
    string response = file_in->gets();
    if (!response) {
      server_is_up = 0;
      error("Engine `%s' playing crashed!", command_line);
    }
#if DUMP_RPSTP_PIPES
    werror("%s\n", response);
#endif
    array result;
    int id_length = strlen(id);
    if (response && response[..id_length] == "=" + id)
      result = ({ 0, response[id_length + 1 ..] });
    else if (response && response[..id_length] == "?" + id)
      result = ({ 1, response[id_length + 1 ..] });
    else
      result = ({ -1, response });
    result[1] = String.trim_all_whites(result[1]);
    while (1) {
      response = file_in->gets();
#if DUMP_RPSTP_PIPES
      werror("%s\n", response);
#endif
      if (response == "") {
	if (result[0] < 0) {
	  werror("Warning, unrecognized response to command `%s':\n", command);
	  werror("%s\n", result[1]);
	}
	return result;
      }
      result[1] += "\n" + response;
    }
  }
  void quit() {
    send_command("quit");
  }
  string get_full_engine_name() {
    return send_command("name")[1] + " " + send_command("version")[1];
  }
  void newgame() {
    send_command("newgame ");
  }
  string genmove() {
    return send_command("genmove ")[1];
  }
  void play(string _movestr) {
    send_command("play "+_movestr);
  }
};

class nineTTTtp_game {
  private nineTTTtp_server p1;
  private nineTTTtp_server p2;
  private int verbose;

  nineTTT_board board;
  public int nb_games;

  public string p1_name;
  public int p1_new_win;
  public int p1_wins;

  public string p2_name;
  public int p2_new_win;
  public int p2_wins;

  float p1_remaining_time;
  float p2_remaining_time;

  public string output_dir = "data";

  void create(string command_line_player0, string command_line_player1,
	      string new_output_dir, int _verbose) {
    verbose = _verbose;
    p1 = nineTTTtp_server(command_line_player0);
    if (p1) p2 = nineTTTtp_server(command_line_player1);
    if (!p1 || !p2) {
      werror("!p1 || !p2"); finalize(); exit(0);
    }
    
    board = nineTTT_board();
    nb_games = 0;
    p1_name = command_line_player0; p1_new_win = 0; p1_wins = 0;
    p2_name = command_line_player1; p2_new_win = 0; p2_wins = 0;
    
    if(new_output_dir != "") {
      output_dir = new_output_dir;
    }
  }

  void printScore(string file_name) {
    Stdio.File o = Stdio.File();
    if(!o->open(file_name,"wac")) {
        write("Failed to open file.\n");
        return;
    }
    if(p1_new_win == 1) {
      o->write("=> "+p1_name+" win\n");
    } else if(p2_new_win == 1) {
      o->write("=> "+p2_name+" win\n");
    } else {
      o->write("=> draw game\n");
    }
    o->write(" (%s %d) (%s %d) ",
	     p1_name, p1_wins, 
	     p2_name, p2_wins);
    o->close();
  }

  void init_board() {
    p1_remaining_time = 1.0;
    p2_remaining_time = 1.0;
    board.init();
  }
  void print_board() {
    board.printboard();
    werror("timers : %.2f : %.2f\n", 
	   p1_remaining_time, p2_remaining_time);
  }
  void play() {
    if (verbose) werror("\nNew game.\n");

    p1_new_win = 0;
    p2_new_win = 0;
    p1->newgame();
    p2->newgame();
    init_board();
    if(verbose) { print_board(); werror("...\n"); }

    // perform a match
    while(true) {
      array(int) Ti = System.gettimeofday();
      string p1_move = p1->genmove();
      if(verbose) werror("p1_move : %s\n", p1_move);
      array(int) Tf = System.gettimeofday();
      float ms = (float)((Tf[0] - Ti[0]))+(float)(Tf[1] - Ti[1])/1000000;
      p1_remaining_time -= ms;
      if(p1_remaining_time < 0.0) {
	p2_new_win = 1;
	print_board();
	werror(" ===> "+p1_name+" time exceeded\n");
	werror(" ===> "+p2_name+" WIN\n");
	break;
      }
      if(board.play(p1_move)) {
	p1->play(p1_move);
	p2->play(p1_move);
      } else {
	p2_new_win = 1;
	werror(" ===> "+p1_name+" genmove error at %d\n", p1_move);
	werror(" ===> "+p2_name+" WIN\n");
	break;
      }
      
      if(board.endgame()) {
	if(verbose) board.printboard();
	if(board.winner[0]=='x') p1_new_win = 1;
	if(board.winner[0]=='o') p2_new_win = 1;
	break;
      }

      Ti = System.gettimeofday();
      string p2_move = p2->genmove();
      if(verbose) werror("p2_move : %s\n", p2_move);
      Tf = System.gettimeofday();
      ms = (float)((Tf[0] - Ti[0]))+(float)(Tf[1] - Ti[1])/1000000;
      p2_remaining_time -= ms;
      if(p2_remaining_time < 0.0) {
	p1_new_win = 1; 
	print_board();
	werror(" ===> "+p1_name+" WIN\n");
	werror(" ===> "+p2_name+" time exceeded\n");
	break;
      }
      if(board.play(p2_move)) {
	p1->play(p2_move);
	p2->play(p2_move);
      } else {
	p1_new_win = 1;
	werror(" ===> "+p2_name+" genmove error at %d\n", p2_move);
	werror(" ===> "+p1_name+" WIN\n");
	break;
      }
      sleep(0.1);

      if(board.endgame()) {
	if(verbose) board.printboard();
	if(board.winner[0]=='x') p1_new_win = 1;
	if(board.winner[0]=='o') p2_new_win = 1;
	break;
      }
    }
  }

  void finalize() {
    p1->quit(); p2->quit(); 
  }
}

void run_many_games(nineTTTtp_game game, int _nb_games_to_play, int verbose) {
  game->nb_games = 0;
  for (int k = 0; k < _nb_games_to_play; k++) {
    game->play();
    if(game->p1_new_win == 1) {
      werror("===== p1 WIN\n\n");
      game->p1_wins ++;
    } 
    if(game->p2_new_win == 1) {
      werror("===== p2 WIN\n\n");
      game->p2_wins ++;
    } 
    if(game->p1_new_win == 0 && game->p2_new_win == 0) {
      werror("===== noone WIN\n\n");
    }
    game->nb_games ++;
    werror("===== p1_name: %s\n", game->p1_name);
    werror("===== p2_name: %s\n", game->p2_name);
    werror("===== nb_games: %d  p1_wins: %d  p2_wins: %d\n", game->nb_games, game->p1_wins, game->p2_wins);
    game->printScore(game->output_dir+"/scores.txt");
  }
  game->finalize();
}

string help_message =
  "Usage: %s [OPTION]... [FILE]...\n\n"
  "Runs either a match or endgame contest between two GTP engines.\n"
  "`--white' and `--black' options are mandatory.\n\n"
  "Options:\n"
  "  -n, --number=NB_GAMES         the number of games to play\n"
  "  -f, --first=COMMAND_LINE\n"
  "  -s, --second=COMMAND_LINE     command lines to run the two engines with.\n\n"
  "  -o, --outputdir=OUTPUT_DIRECTORY (default ouput is data)\n"
  "      --help                    display this help and exit.\n"
  "  -v, --verbose=LEVEL           1 - print moves, 2 and higher - draw boards.\n";

int main(int argc, array(string) argv) {
  string hint = sprintf("Try `%s --help' for more information.\n",
			basename(argv[0]));
  if (Getopt.find_option(argv, UNDEFINED, "help")) {
    write(help_message, basename(argv[0]));
    return 0;
  }
  string str_p1 = Getopt.find_option(argv, "f", "first", UNDEFINED, "");
  if (str_p1 == "") {
    werror("First player is not specified.\n" + hint);
    return 1;
  }
  string str_p2 = Getopt.find_option(argv, "s", "second", UNDEFINED, "");
  if (str_p2 == "") {
    werror("Second player is not specified.\n" + hint);
    return 1;
  }
  string str_output_dir = Getopt.find_option(argv, "o", "outputdir", UNDEFINED, "");
  int verbose = (int) Getopt.find_option(argv, "v", "verbose", UNDEFINED, "0");

  string str_nb_games = Getopt.find_option(argv, "n", "games", UNDEFINED, "");

  int nb_games = 1;
  if (str_nb_games != "") {
    sscanf(str_nb_games, "%d", nb_games);
    if(nb_games <= 0) nb_games = 1;
  }
  nineTTTtp_game game = nineTTTtp_game(str_p1, str_p2, str_output_dir, verbose);
  if (game) {
    run_many_games(game, nb_games, verbose);
  }
  return 0;
}
