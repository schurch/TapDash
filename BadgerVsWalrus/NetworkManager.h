//
//  NetworkManager.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GKPeerPickerController.h>
#import "Game.h"

@interface NetworkManager : NSObject<GKPeerPickerControllerDelegate, GKSessionDelegate> {
    id _chooserDelegate;
    id _gameDelegate;
    GKSession *_gameSession;
}

@property (assign, nonatomic) id chooserDelegate;
@property (assign, nonatomic) id gameDelegate;
@property (nonatomic, retain) GKSession *gameSession;

+ (NetworkManager *)manger;

- (void)initNetworkGame;
- (void)chooseAnimal:(Animal)animal;
- (void)startGame;
- (void)moveAnimal;
- (void)disconnect;
@end

@protocol NetworkManagerDelegate <NSObject>
- (void)otherPlayerChoseAnimal:(Animal)animal;
- (void)otherPlayerMovedAnimal;
- (void)otherPlayerStartedGame;
@end
