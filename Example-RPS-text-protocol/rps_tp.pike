#!/usr/bin/env pike
// read https://pike.lysator.liu.se/

// pike rps_tp.pike -f ./player0 -s ./player1 -o data1 -n 2 -v 1

#define DUMP_RPSTP_PIPES		0

class rpstp_server {
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
    send_command("play " +_movestr);
  }
  void opp_play(string _movestr) {
    send_command("opp_play " +_movestr);
  }
  void endgame() {
    send_command("endgame ");
  }
};

class rpstp_game {
  private rpstp_server p0;
  private rpstp_server p1;
  private int verbose;

  public int nb_games;

  public string p0_name;
  public string p0_move;
  public int p0_new_win;
  public int p0_wins;

  public string p1_name;
  public string p1_move;
  public int p1_new_win;
  public int p1_wins;

  float p0_remaining_time;
  float p1_remaining_time;

  public string output_dir = "data";

  void create(string command_line_player0, string command_line_player1,
	      string new_output_dir, int _verbose) {
    verbose = _verbose;
    p0 = rpstp_server(command_line_player0);
    if (p0) p1 = rpstp_server(command_line_player1);
    if (!p0 || !p1) {
      werror("!p0 || !p1"); finalize(); exit(0);
    }
    
    nb_games = 0; 
    p0_name = command_line_player0; p0_new_win = 0; p0_wins = 0;
    p1_name = command_line_player1; p1_new_win = 0; p1_wins = 0;
    
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
    o->write(" (%s %s %.2f) (%s %s %.2f) (%d %d) ",
	     p0_name, p0_move, p0_remaining_time,
	     p1_name, p1_move, p1_remaining_time,
             p0_wins, p1_wins);
    if(p0_new_win == 1) {
      o->write("=> "+p0_name+" win\n");
    } else if(p1_new_win == 1) {
      o->write("=> "+p1_name+" win\n");
    } else {
      o->write("=> draw game\n");
    }
    o->close();
  }

  void init_board() {
    p0_remaining_time = 1.0;
    p1_remaining_time = 1.0;
    p0_move = "HIDDEN";
    p1_move = "HIDDEN"; 
  }
  void print_board() {
    bool color_print = true;
    if(color_print) {
      werror("p0_move \x1b[31m%s\x1b[0m  p1_move %s\n", p0_move, p1_move);
      werror("timers : \x1b[31m%.2f\x1b[0m : %.2f\n", 
	     p0_remaining_time, p1_remaining_time);
    } else {
      werror("p0_move %s  p1_move %s\n", p0_move, p1_move);
      werror("timers : %.2f : %.2f\n", 
	     p0_remaining_time, p1_remaining_time);
    }
  }
  void endgame() {
    print_board();
    if(p0_move == "ROCK" && p1_move == "SCISORS") p0_new_win = 1;
    if(p1_move == "ROCK" && p0_move == "SCISORS") p1_new_win = 1;
    if(p0_move == "SCISORS" && p1_move == "PAPER") p0_new_win = 1;
    if(p1_move == "SCISORS" && p0_move == "PAPER") p1_new_win = 1;
    if(p0_move == "PAPER" && p1_move == "ROCK") p0_new_win = 1;
    if(p1_move == "PAPER" && p0_move == "ROCK") p1_new_win = 1;
  }
  void play() {
    if (verbose) werror("\nNew game.\n");

    p0_new_win = 0;
    p1_new_win = 0;
    p0->newgame();
    p1->newgame();

    init_board();
    if(verbose) { print_board(); werror("...\n"); }

    // perform a match
    while(true) {
      array(int) Ti = System.gettimeofday();
      p0_move = p0->genmove();
      array(int) Tf = System.gettimeofday();
      float ms = (float)((Tf[0] - Ti[0]))+(float)(Tf[1] - Ti[1])/1000000;
      p0_remaining_time -= ms;
      if(p0_remaining_time < 0.0) {
	p0_new_win = 0; p1_new_win = 1;
	print_board();
	werror(" ===> "+p0_name+" time exceeded\n");
	werror(" ===> "+p1_name+" WIN\n");
	break;
      }
      
      Ti = System.gettimeofday();
      p1_move = p1->genmove();
      Tf = System.gettimeofday();
      ms = (float)((Tf[0] - Ti[0]))+(float)(Tf[1] - Ti[1])/1000000;
      p1_remaining_time -= ms;
      if(p1_remaining_time < 0.0) {
	p0_new_win = 1; p1_new_win = 0;
	print_board();
	werror(" ===> "+p0_name+" WIN\n");
	werror(" ===> "+p1_name+" time exceeded\n");
	break;
      }

      p0->play(p0_move);
      p0->opp_play(p1_move);
      p1->play(p1_move);
      p1->opp_play(p0_move);
      sleep(0.1);
      endgame();
      p0->endgame();
      p1->endgame();
      break; // only one turn
    }
  }

  void finalize() {
    p0->quit(); p1->quit(); 
  }
}

void run_many_games(rpstp_game game, int _nb_games_to_play, int verbose) {
  game->nb_games = 0;
  for (int k = 0; k < _nb_games_to_play; k++) {
    game->play();
    if(game->p0_new_win == 1) {
      werror("===== p0 WIN\n");
      game->p0_wins ++;
    } 
    if(game->p1_new_win == 1) {
      werror("===== p1 WIN\n");
      game->p1_wins ++;
    } 
    if(game->p0_new_win == 0 && game->p1_new_win == 0) {
      werror("===== noone WIN\n");
    }
    game->nb_games ++;
    werror("===== nb_games: %d  p0_wins: %d  p1_wins: %d\n", game->nb_games, game->p0_wins, game->p1_wins);
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
  string str_p0 = Getopt.find_option(argv, "f", "first", UNDEFINED, "");
  if (str_p0 == "") {
    werror("First player is not specified.\n" + hint);
    return 1;
  }
  string str_p1 = Getopt.find_option(argv, "s", "second", UNDEFINED, "");
  if (str_p1 == "") {
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
  rpstp_game game = rpstp_game(str_p0, str_p1, str_output_dir, verbose);
  if (game) {
    run_many_games(game, nb_games, verbose);
  }
  return 0;
}
