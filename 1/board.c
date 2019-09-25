#include "board.h"

// Public functions

// Returns a board if the string is correct
baord_t* deserialize_board(char* str) {
  board_t* b = NULL;

  // Invalid string
  if (is_board_string_valid(str) == -1) {
    return NULL;
  }

  printf("%d bytes\n", sizeof *b);
  // b = malloc(sizeof *b);

  return 1;
}

// Static functions

// Returns position of last move if the string is valid
// Returns -1 otherwise
static int is_board_string_valid(char* str) {
  int i;
  int x = 0;
  int o = 0;
  int pos;

  // Only 'x', 'o' and '.' at the beginning
  for (i = 0; i < 81; i++) {
    switch(str[i]) {
      case 'x': x++; break;
      case 'o': o++; break;
      case '.': break;
      default: return -1;
    }
  }

  // There should at most be one more 'x' than the number of 'o's
  if (x - o < 0 || x - o > 1) {
    return -1;
  }
  
  // Then, there should be a colon
  if (str[i++] != ':') {
    return -1;
  }

  // There should be a number between 0 and 80 after that
  pos = atoi(&str[i]);
  if (pos < 0 || pos > 80 || str[pos] == '.') {
    return -1;
  }
}
