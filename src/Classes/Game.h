//
//  Game.h
//  SparrowExtensionSandbox
//
//  Created by Elliot Franford on 1/16/12.
//  Copyright (c) 2012 Abandon Hope Games, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EMedia.h"
#import "ESpriteManager.h"
#import "ESprite.h"
#import "TMXMap.h"
#import "BEScreen.h"
#import "SHThumbstick.h"

@interface Game : SPStage
{
    SHThumbstick* thumbstick;
    BEScreen* screen;
    TMXMap* map;
    ESprite* player;
}
-(void)setupBEScreen;
-(void)setupThumbstick;
-(void)setupMap;
-(void)setupPlayer;
@end
