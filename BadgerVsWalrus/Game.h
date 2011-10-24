//
//  Game.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 24/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef BadgerVsWalrus_Game_h
#define BadgerVsWalrus_Game_h

typedef enum {
    kBWGameOutcomeDraw = 0,
    kBWGameOutcomePlayer1Won = 1,
    KBWGameOutcomePlayer2won = 2
} BWGameOutcome;

typedef enum {
    kBWGameStateStart = 0,
    kBWGameStatePaused = 1,
    kBWGameStateRunning = 2
} BWGameState;


#endif
