CC = gcc

PROG = a.out
SRC = main.c board.c
OBJ = $(SRC:.c=.o)

all: $(PROG)

$(PROG): $(OBJ)
	$(CC) $< -o $@

%.o: %.c
	$(CC) -c $< -o $@
