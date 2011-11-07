//
//  Game.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 24/10/2011.
//  Copyright (c) 2011 Stefan Church. All rights reserved.
//

typedef enum {
    kGameOutcomeDraw = 0,
    kGameOutcomeCowWon = 1,
    kGameOutcomePenguinWon = 2
} GameOutcome;

typedef enum {
    kAnimalNone = 0,
    kAnimalCow = 1,
    kAnimalPenguin = 2
} Animal;

typedef enum {
    kGameStateStart = 0,
    kGameStatePaused = 1,
    kGameStateRunning = 2
} GameState;