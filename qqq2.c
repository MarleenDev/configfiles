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
    short int x;
    short int y;
    short int z;
} Move;

typedef struct {
    short int amounts[DIRECTIONS];
} Scores;

struct Board;
typedef struct {
    Player pos[X_WIDTH][Y_HEIGHT][Z_DEPTH];
    short int amountPresent[X_WIDTH][Z_DEPTH];
    uint16_t movesDone;
    Player player;
    Move move;
    struct Board* board;
    Scores* scores;
} Board;

Player nextPlayer(Player player)
{
    if (player == NO_PLAYER) {
        return FIRST_PLAYER;
    }
    // +1 to skip over non-existing player 0
    return ((player++) % PLAYERS) + 1;
}

#ifdef DEBUG
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
    printf("MovesDone:%i\n", board->movesDone);
    printf("Player:%i\n", board->player);
}
#endif

void initBoard(Board* board)
{
    assert(board != NULL);
    memset((void*)board, 0, sizeof(Board));
    board->player = NO_PLAYER;
#ifdef DEBUG
    printBoard(board);
#endif
}

void copyBoard(Board* newBoard, Board* origBoard)
{
    assert(origBoard != NULL);
    assert(newBoard != NULL);
    memcpy((void*)newBoard, (void*)origBoard, sizeof(Board));
}

bool posIsValid(short int x, short int y, short int z)
{
    return ((x >= X_MIN) && (x <= X_MAX)) &&
        ((y >= Y_MIN) && (y <= Y_MAX)) &&
        ((z >= Z_MIN) && (z <= Z_MAX));
}

short int amountInDirection(Board* board, short int dx, short int dy, short int dz)
{
    assert(board != NULL);
    short int amount = 0;
    short int x = board->move.x + dx;
    short int y = board->move.y + dy;
    short int z = board->move.z + dz;
    while (posIsValid(x, y, z)) {
        // look for potential here
        //const short int amountPresentBelow = board->amountPresent[x][z];
        if (board->pos[x][y][z] != board->player) {
            break;
        }
        ++amount;
        x += dx;
        y += dy;
        z += dz;
    }
#ifdef DEBUG
    printf("amountInDirection(%i, %i, %i): %i  player:%i\n", dx, dy, dz, amount, board->player);
#endif
    return amount;
}

#ifdef DEBUG
void printScores(Board* board)
{
    assert(board != NULL);
    printf("Scores:\n");
    for (int dir = 0; dir < DIRECTIONS; ++dir) {
        printf(" Amount for direction %i: %i\n", dir, board->scores->amounts[dir]);
    }
}
#endif

void calcScores(Board* board)
{
    assert(board != NULL);
    board->scores = (Scores*)malloc(sizeof(Scores));
    assert(board->scores != NULL);
    for (int dir = 0; dir < DIRECTIONS; ++dir) {
        board->scores->amounts[dir] =
            amountInDirection(board, directions[dir][0][0], directions[dir][0][1], directions[dir][0][2]) +
            1 +
            amountInDirection(board, directions[dir][1][0], directions[dir][1][1], directions[dir][1][2]);
    }
#ifdef DEBUG
    printScores(board);
#endif
}

void makeMove(Board* board, short int x, short int z)
{
    // This will create a new board containing the move and scores
    assert(board != NULL);
    assert((x >= X_MIN) && (x <= X_MAX));
    assert((z >= Z_MIN) && (z <= Z_MAX));
    const short int y = board->amountPresent[x][z] + 1;
    assert((y >= Y_MIN) && (y <= Y_MAX));
    assert(board->pos[x][y][z] == NO_PLAYER);

    Board* newBoard = (Board*)malloc(sizeof(Board));
    assert(newBoard != NULL);
    copyBoard(newBoard, board);
    newBoard->player = nextPlayer(board->player);
    newBoard->pos[x][y][z] = newBoard->player;
    newBoard->amountPresent[x][z] = y;
    newBoard->movesDone = board->movesDone += 1;
    newBoard->move.x = x;
    newBoard->move.y = y;
    newBoard->move.z = z;
    newBoard->board = NULL;
    newBoard->scores = NULL;
#ifdef DEBUG
    printBoard(newBoard);
#endif
    calcScores(newBoard);
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

int main(void)
{
    //testNextPlayer();

    Board board;
    initBoard(&board);
    makeMove(&board, 4, 1);
    // TODO
    return 0;
}
