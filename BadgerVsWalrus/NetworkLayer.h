//
//  NetworkLayer.h
//  BadgerVsWalrus
//
//  Created by Stefan Church on 05/11/2011.
//  Copyright 2011 Stefan Church. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "NetworkManager.h"

@interface NetworkLayer : CCLayer<NetworkManagerDelegate> {
    NetworkManager *_networkManager;
}

@property (nonatomic, retain) NetworkManager *networkManager;

@end
