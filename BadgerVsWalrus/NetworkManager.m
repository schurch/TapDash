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
    kPacketTypeMoveAnimal,
    kPacketTypeWon,
    kPacketTypePlayAgain,
    kPacketTypeGameHeartbeat,
    kPacketTypeNetworkHeartbeat
} PacketType; 

@implementation NetworkManager

#pragma mark properties

@synthesize chooserDelegate = _chooserDelegate;
@synthesize gameDelegate = _gameDelegate;
@synthesize gameSession = _gameSession;
@synthesize gameOverDelegate = _gameOverDelegate;


#pragma mark -
#pragma mark class methods

+ (NetworkManager *)manger {
    static NetworkManager *manager;
    
    if (!manager) {
        manager = [[NetworkManager alloc] init];
    }
    
    return manager;
}

#pragma mark -
#pragma mark init

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

- (void)initNetworkGame {
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    [picker show];
}

#pragma mark -
#pragma mark GKPeerPickerControllerDelegate

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    self.gameSession = session;
    self.gameSession.delegate = self;
    [self.gameSession setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    GKSession* session = [[GKSession alloc] initWithSessionID:@"BadgerVsWalrus" displayName:nil sessionMode:GKSessionModePeer];
    return [session autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {   
    picker.delegate = nil;
    [picker autorelease];
    
    if([[self chooserDelegate] respondsToSelector:@selector(pickerCanceled)]) {
        [[self chooserDelegate] pickerCanceled];
    }
}

#pragma mark -
#pragma mark GKSessionDelegate

- (void)sendDataToPeers:(NSData *)data ofType:(PacketType)type {
    NSMutableData * newPacket = [NSMutableData dataWithCapacity:([data length]+sizeof(uint32_t))];
    uint32_t swappedType = CFSwapInt32HostToBig((uint32_t)type);
    [newPacket appendBytes:&swappedType length:sizeof(uint32_t)];
    [newPacket appendData:data];
 
    NSError *error;
    if (![self.gameSession sendDataToAllPeers:newPacket withDataMode:GKSendDataUnreliable error:&error]) {
        NSLog(@"%@",[error localizedDescription]);
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
        uint32_t otherPlayerXPostion;
        
        switch (header) {
            case kPacketTypeChooseAnimal:
                [payload getBytes:&swappedAnimal length:sizeof(uint32_t)];
                Animal animal = (Animal)CFSwapInt32BigToHost(swappedAnimal);
                if([self.chooserDelegate respondsToSelector:@selector(otherPlayerChoseAnimal:)]) {
                    [self.chooserDelegate otherPlayerChoseAnimal:animal];
                }
                break;
            case kPacketTypeStartGame:
                if([self.chooserDelegate respondsToSelector:@selector(otherPlayerStartedGame)]) {
                    [self.chooserDelegate otherPlayerStartedGame];
                }
                break;
            case kPacketTypeWon:
                if([self.gameDelegate respondsToSelector:@selector(otherPlayerWon)]) {
                    [self.gameDelegate otherPlayerWon];
                }
                break;
            case kPacketTypePlayAgain:
                if([self.gameOverDelegate respondsToSelector:@selector(otherPlayerPlayedAgain)]) {
                    [self.gameOverDelegate otherPlayerPlayedAgain];
                }
                break;
            case kPacketTypeGameHeartbeat:
                [payload getBytes:&otherPlayerXPostion length:sizeof(uint32_t)];
                int xPostion = CFSwapInt32BigToHost(otherPlayerXPostion);
                if([self.gameDelegate respondsToSelector:@selector(heartbeatWithOtherPlayerXPosition:)]) {
                    [self.gameDelegate heartbeatWithOtherPlayerXPosition:xPostion];
                }
                break;
            default:
                NSLog(@"Unrecognized packet type.");
                break;
        }
    }   
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    switch (state) {
        case GKPeerStateConnecting:
            NSLog(@"%@ peer Connecting.", peerID);
            break;
        case GKPeerStateConnected:
            NSLog(@"%@ peer Connected.", peerID);
            break;
        case GKPeerStateDisconnected:
            NSLog(@"%@ peer Disconnected.", peerID);
            [self invalidateSession];
            break;
        case GKPeerStateAvailable:
            NSLog(@"%@ peer State Available.", peerID);
            break;
        case GKPeerStateUnavailable:
            NSLog(@"%@ peer State Unavailable.", peerID);
            break;
    }
}

#pragma mark -
#pragma mark methods

- (void)chooseAnimal:(Animal)animal {
    uint32_t animalType = CFSwapInt32HostToBig((uint32_t)animal);
    NSData *data = [NSData dataWithBytes:&animalType length:sizeof(uint32_t)];
    [self sendDataToPeers:data ofType:kPacketTypeChooseAnimal];
}

- (void)startGame {
    [self sendDataToPeers:nil ofType:kPacketTypeStartGame];
}

- (void)heartbeatWithXPostion:(int)postion {
    uint32_t xPosition = CFSwapInt32HostToBig((uint32_t)postion);
    NSData *postionData = [NSData dataWithBytes:&xPosition length:sizeof(uint32_t)];
    [self sendDataToPeers:postionData ofType:kPacketTypeGameHeartbeat];
}

- (void)won {
    [self sendDataToPeers:nil ofType:kPacketTypeWon];
}

- (void)invalidateSession {
    
    NSLog(@"Lost network connection.");
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Network Problem." message:@"There was an error with the network and the connection has been lost." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
	[alertView release];
    
    if([self.chooserDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.chooserDelegate connectionLost];
    }
    
    if([self.gameDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.gameDelegate connectionLost];
    }
    
    if([self.gameOverDelegate respondsToSelector:@selector(connectionLost)]) {
        [self.gameOverDelegate connectionLost];
    }
    
    [self.gameSession disconnectFromAllPeers];    
    self.chooserDelegate = nil;
    self.gameDelegate = nil;
    self.gameOverDelegate = nil;
    [self.gameSession setDataReceiveHandler:nil withContext:nil];
    self.gameSession.available = NO;
}

- (void)playAgain {
    [self sendDataToPeers:nil ofType:kPacketTypePlayAgain];
}

#pragma mark -
#pragma mark cleanup

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (self.gameSession) {
        [self invalidateSession];
    }
    
    [_gameSession release];
    _chooserDelegate = nil;
    _gameDelegate = nil;
    
    [super dealloc];
}

@end
