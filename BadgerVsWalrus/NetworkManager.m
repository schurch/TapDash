//
//  NetworkManager.m
//  BadgerVsWalrus
//
//  Created by Stefan Church on 02/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NetworkManager.h"

typedef enum {
    kPacketTypeChooseAnimal,
    kPacketTypeStartGame,
    kPacketTypeMoveAnimal
} PacketType; 

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

- (void)sendDataToPeers:(NSData *)data ofType:(PacketType)type {
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];

    NSError *error;
    if (![self.gameSession sendDataToAllPeers:newPacket withDataMode:GKSendDataUnreliable error: nil]) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    
}

- (void)chooseAnimal:(Animal)animal {
    uint32_t animalType = CFSwapInt32HostToBig((uint32_t)animal);
    NSData *data = [NSData dataWithBytes:&animalType length:sizeof(uint32_t)];
    [self sendDataToPeers:data ofType:kPacketTypeChooseAnimal];
}

- (void)startGame {
    [self sendDataToPeers:nil ofType:kPacketTypeStartGame];
}

- (void)moveAnimal {
    [self sendDataToPeers:nil ofType:kPacketTypeMoveAnimal];    
}

- (void)disconnect {
    [self.gameSession disconnectFromAllPeers];
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
    self.gameSession = session;
    session.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {   
    picker.delegate = nil;
    [picker autorelease];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state)
    {
        case GKPeerStateConnecting:
            break;
        case GKPeerStateConnected:
            break;
        case GKPeerStateDisconnected:
            //
            break;
        case GKPeerStateAvailable:
            break;
        case GKPeerStateUnavailable:
            break;
    }
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
    PacketType header;
    uint32_t swappedHeader;
    if ([data length] >= sizeof(uint32_t)) {    
        [data getBytes:&swappedHeader length:sizeof(uint32_t)];
        header = (PacketType)CFSwapInt32BigToHost(swappedHeader);
        NSRange payloadRange = {sizeof(uint32_t), [data length]-sizeof(uint32_t)};
        NSData* payload = [data subdataWithRange:payloadRange];
        
        uint32_t swappedAnimal;
        
        switch (header) {
            case kPacketTypeChooseAnimal:
                [payload getBytes:&swappedAnimal length:sizeof(uint32_t)];
                Animal animal = (Animal)CFSwapInt32BigToHost(swappedAnimal);
                if([[self chooserDelegate] respondsToSelector:@selector(otherPlayerChoseAnimal:)]) {
                    [[self chooserDelegate] otherPlayerChoseAnimal:animal];
                }
                break;
            case kPacketTypeStartGame:
                if([[self gameDelegate] respondsToSelector:@selector(otherPlayerStartedGame)]) {
                    [[self gameDelegate] otherPlayerStartedGame];
                }
                break;
            case kPacketTypeMoveAnimal:
                if([[self gameDelegate] respondsToSelector:@selector(otherPlayerMovedAnimal)]) {
                    [[self gameDelegate] otherPlayerMovedAnimal];
                }
                break;
            default:
                NSLog(@"Unrecognized packet type.");
                break;
        }
    }   
}

- (void)dealloc {
    _chooserDelegate = nil;
    _gameDelegate = nil;
    
    [super dealloc];
}

@end
