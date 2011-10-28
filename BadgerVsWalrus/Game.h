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
    kGameOutcomeDraw = 0,
    kGameOutcomePlayer1Won = 1,
    kGameOutcomePlayer2won = 2
} GameOutcome;

typedef enum {
    kGameStateStart = 0,
    kGameStatePaused = 1,
    kGameStateRunning = 2
} GameState;


#endif
