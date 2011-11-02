//
//  NetworkManager.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"

@implementation NetworkManager

@synthesize chooserDelegate = _chooserDelegate;
@synthesize gameDelegate = _gameDelegate;
@synthesize gameSession = _gameSession;

+ (NetworkManager *)manger {
    static NetworkManager *manager;
    
    if (!manager) {
        manager = [[NetworkManager alloc] init];
    }
    
    return manager;
}

- (void)initNetworkGame {
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}

- (void)chooseAnimal:(Animal)animal {
    
}

- (void)startGame {
    
}

- (void)moveAnimal {
    
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
    self.gameSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{   
    picker.delegate = nil;
    [picker autorelease];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state)
    {
        case GKPeerStateConnected:
            break;
        case GKPeerStateDisconnected:
            break;
    }
}

- (void) mySendDataToPeers: (NSData *) data
{
    [self.gameSession sendDataToAllPeers: data withDataMode: GKSendDataReliable error: nil];
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    
}

- (void)dealloc {
    _chooserDelegate = nil;
    _gameDelegate = nil;
    
    [super dealloc];
}

@end
