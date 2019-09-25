#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "board.h"

#define PROG_AUTHOR "Rodolphe Peccatte"
#define PROG_VERSION_MAJOR 0
#define PROG_VERSION_MINOR 1

void playout();

int main(int argc, char* argv) {
  
  fd_set readfds;
  int num_readable;
  int fd_stdin = fileno(stdin);

  char buff[256];
  int i = 0;

  while(1) {
    FD_ZERO(&readfds);
    FD_SET(fd_stdin, &readfds);
    num_readable = select(fd_stdin + 1, &readfds, NULL, NULL, NULL);

    if (num_readable <= 0) continue;

    read(STDIN_FILENO, buff, 255);

    i = 0;
    while (i < 255 && buff[i] != '\n') i++;
    buff[i] = '\0';

    if (strcmp(buff, "name") == 0) {
      printf("%s\n", PROG_AUTHOR);
    } else if (strcmp(buff, "version") == 0) {
      printf("%d.%d\n", PROG_VERSION_MAJOR, PROG_VERSION_MINOR);
    } else if (strcmp(buff, "showboard") == 0) {
      printBoard();
    } else if (b = deserialize_board(buff)) {
      playout();
    } else {
      printf("Invalid command\n");
    }
  }
  return 0;
}

void playout() {
  printf("playout\n");
}

