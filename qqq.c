#include <assert.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// surround board with zeroes in all directions
#define PADDING 2
#define X_PADDING " "

#define DIRECTIONS 13

#define PLAYERS 2
#define NO_PLAYER 0
#define FIRST_PLAYER 1

#define WIN 4

#define X_MIN 1
#define X_MAX 7
#define X_WIDTH (X_MAX+PADDING)
#define X_LEFT -1
#define X_RIGHT 1

#define Y_MIN 1
#define Y_MAX 6
#define Y_HEIGHT (Y_MAX+PADDING)
#define Y_DOWN -1
#define Y_UP 1

#define Z_MIN 1
#define Z_MAX 1
#define Z_DEPTH (Z_MAX+PADDING)
#define Z_FORWARD -1
#define Z_BACKWARD 1

static const short int directions[DIRECTIONS][2][3] = {
    {{X_LEFT, 0, 0}, {X_RIGHT, 0, 0}},
    {{0, Y_DOWN, 0}, {0, Y_UP, 0}},
    {{0, 0, Z_FORWARD}, {0, 0, Z_BACKWARD}},

    {{X_LEFT, Y_DOWN, 0}, {X_RIGHT, Y_UP, 0}},
    {{X_LEFT, Y_UP, 0}, {X_RIGHT, Y_DOWN, 0}},
    {{X_LEFT, 0, Z_FORWARD}, {X_RIGHT, 0, Z_BACKWARD}},
    {{X_LEFT, 0, Z_BACKWARD}, {X_RIGHT, 0, Z_FORWARD}},
    {{0, Y_DOWN, Z_FORWARD}, {0, Y_UP, Z_BACKWARD}},
    {{0, Y_UP, Z_FORWARD}, {0, Y_DOWN, Z_BACKWARD}},

    {{X_LEFT, Y_DOWN, Z_FORWARD}, {X_RIGHT, Y_UP, Z_BACKWARD}},
    {{X_LEFT, Y_UP, Z_FORWARD}, {X_RIGHT, Y_DOWN, Z_BACKWARD}},
    {{X_LEFT, Y_DOWN, Z_BACKWARD}, {X_RIGHT, Y_UP, Z_FORWARD}},
    {{X_LEFT, Y_UP, Z_BACKWARD}, {X_RIGHT, Y_DOWN, Z_FORWARD}},
};

typedef short int Player;  // 0:no player, [1...n]: real player

typedef struct {
    short int amounts[DIRECTIONS];
    short int potentials[DIRECTIONS];
    // TODO:  what else? 4, double3, 3, ...
} Scores;

typedef struct {
    Player pos[X_WIDTH][Y_HEIGHT][Z_DEPTH];
    short int amountPresent[X_WIDTH][Z_DEPTH];
} Board;

typedef struct Move Move;
struct Move {
    Player player;
    short int x;
    short int y;
    short int z;
    Move* previousMove;
    Move* nextMove;
    Board* board;
    Scores* scores;
};

typedef struct {
    Move* currentMove;
} Game;

Player nextPlayer(Player player)
{
    if (player == NO_PLAYER) {
        return FIRST_PLAYER;
    }
    // +1 to skip over non-existing player 0
    return ((player++) % PLAYERS) + 1;
}

void printBoard(Board* board)
{
    assert(board != NULL);
    printf("Board:\n");
    for (short int y = Y_MAX; y >= Y_MIN; --y) {
        for (short int z = Z_MIN; z <= Z_MAX; ++z) {
            printf("%s", X_PADDING);
            for (short int x = X_MIN; x <= X_MAX; ++x) {
                printf("%i", board->pos[x][y][z]);
            }
            printf("%s", X_PADDING);
        }
        printf("\n");
    }
    printf("AmountPresent:\n");
    for (short int z = Z_MIN; z <= Z_MAX; ++z) {
        for (short int x = X_MIN; x <= X_MAX; ++x) {
            printf("%s%i", X_PADDING, board->amountPresent[x][z]);
        }
        printf("\n");
    }
}

Board* createBoard(Board* origBoard)
{
    Board* newBoard = (Board*)malloc(sizeof(Board));
    assert(newBoard != NULL);
    if (origBoard == NULL) {
        memset((void*)newBoard, 0x00, sizeof(Board));
    } else {
        memcpy((void*)newBoard, (void*)origBoard, sizeof(Board));
    }
    return newBoard;
}

bool posIsValid(short int x, short int y, short int z)
{
    return ((x >= X_MIN) && (x <= X_MAX)) &&
        ((y >= Y_MIN) && (y <= Y_MAX)) &&
        ((z >= Z_MIN) && (z <= Z_MAX));
}

short int amountInDirection(Move* move, int direction, short int dx, short int dy, short int dz)
{
    assert(move != NULL);
    assert(move->scores != NULL);
    Board* board = move->board;
    short int amount = 0;
    short int x = move->x + dx;
    short int y = move->y + dy;
    short int z = move->z + dz;
    while (posIsValid(x, y, z)) {
        if (board->pos[x][y][z] != move->player) {
            if (board->amountPresent[x][z] == (y - 1)) {
                move->scores->potentials[direction] += 1;
            }
            break;
        }
        ++amount;
        x += dx;
        y += dy;
        z += dz;
    }
#ifdef DEBUG_AMOUNTS
    printf("amountInDirection(%i, %i, %i): %i  player:%i\n", dx, dy, dz, amount, move->player);
#endif
    return amount;
}

#ifdef DEBUG
void printScores(Move* move)
{
    assert(move != NULL);
    assert(move->scores != NULL);
    printf("Scores:\n");
    for (int dir = 0; dir < DIRECTIONS; ++dir) {
        printf(" Direction:%i amount:%i potential:%i\n", dir, move->scores->amounts[dir], move->scores->potentials[dir]);
    }
}
#endif

Scores* calcScores(Move* move)
{
    assert(move != NULL);
    assert(move->scores == NULL);
    const Board* board = move->board;
    move->scores = (Scores*)malloc(sizeof(Scores));
    assert(move->scores != NULL);
    for (int dir = 0; dir < DIRECTIONS; ++dir) {
        move->scores->amounts[dir] =
            amountInDirection(move, dir, directions[dir][0][0], directions[dir][0][1], directions[dir][0][2]) +
            1 +
            amountInDirection(move, dir, directions[dir][1][0], directions[dir][1][1], directions[dir][1][2]);
    }
#ifdef DEBUG
    printScores(move);
#endif
    return move->scores;
}

void playMove(Game* game, Player player, short int x, short int z)
{
    assert(game != NULL);
    assert((x >= X_MIN) && (x <= X_MAX));
    assert((z >= Z_MIN) && (z <= Z_MAX));

    // Add new move to list:
    Move* previousMove = game->currentMove;
    Move* newMove = (Move*)malloc(sizeof(Move));
    assert(newMove != NULL);
    newMove->previousMove = previousMove;
    newMove->nextMove = NULL;
    if (previousMove != NULL) {
        previousMove->nextMove = newMove;
    }

    // Init values:
    newMove->board = createBoard(previousMove == NULL ? NULL : previousMove->board);
    newMove->player = nextPlayer(previousMove == NULL ? NO_PLAYER : previousMove->player);
    newMove->x = x;
    const short int y = newMove->board->amountPresent[x][z] + 1;
    assert((y >= Y_MIN) && (y <= Y_MAX));
    newMove->y = y;
    newMove->z = z;
    assert(newMove->board->pos[x][y][z] == NO_PLAYER);
    newMove->board->pos[x][y][z] = newMove->player;
    newMove->board->amountPresent[x][z] = y;
#ifdef DEBUG
    printf("## Move: player:%i move:[%i, %i, %i]\n", newMove->player, x, y, z);
    printBoard(newMove->board);
#endif

    // Calculate scores:
    newMove->scores = calcScores(newMove);

    // Update game:
    game->currentMove = newMove;
}

void undoLastMove(Game* game)
{
#ifdef DEBUG
    printf("## Undo last move!\n");
#endif
    assert(game != NULL);
    assert(game->currentMove != NULL);
    // only undo latest move in list):
    assert(game->currentMove->nextMove == NULL);

    // free the board:
    free((void*)game->currentMove->board);
    game->currentMove->board = NULL;

    // free the scores:
    free((void*)game->currentMove->scores);
    game->currentMove->scores = NULL;

    // free the move:
    Move* previousMove = game->currentMove->previousMove;
    free((void*)game->currentMove);
    game->currentMove = previousMove;
}

void testNextPlayer()
{
    Player player = FIRST_PLAYER;
    printf("%u\n", player);
    for (int i = 0; i < 20; ++i) {
        player = nextPlayer(player);
        printf("%u\n", player);
    }
}

Game createGame()
{
    Game game;
    game.currentMove = NULL;
    return game;
}

int main(void)
{
    //testNextPlayer();
    Game game = createGame();
    Player player = FIRST_PLAYER;
    playMove(&game, player, 4, 1);
    player = nextPlayer(player);
    playMove(&game, player, 4, 1);
    player = nextPlayer(player);
    playMove(&game, player, 3, 1);
    player = nextPlayer(player);
    playMove(&game, player, 3, 1);
    player = nextPlayer(player);
    playMove(&game, player, 5, 1);
    player = nextPlayer(player);
    playMove(&game, player, 5, 1);

    // TODO
    return 0;
}

