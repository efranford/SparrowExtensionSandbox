//
//  Game.m
//  SparrowExtensionSandbox
//
//  Created by Elliot Franford on 1/16/12.
//  Copyright (c) 2012 Abandon Hope Games, LLC. All rights reserved.
//

#import "Game.h" 

@implementation Game

- (id)initWithWidth:(float)width height:(float)height
{
    if ((self = [super initWithWidth:width height:height]))
    {
        [EMedia initAudio];
        [EMedia initStage];
        [ESpriteManager initManager];
        [self setupBEScreen];
        [self setupMap];
        [self setupThumbstick];
        [self setupPlayer];        
        [[EMedia getStage] addChild:screen];
        [self addChild:[EMedia getStage]];
    }
    return self;
}

-(void)setupBEScreen
{
    screen = [BEScreen screenWithOrientation:BEScreenOrientationLandscapeRight rotates:YES allowAllOrientations:NO];
}

-(void)setupThumbstick
{
    thumbstick = [SHThumbstick thumbstick];
    thumbstick.innerImage = [SPImage imageWithContentsOfFile:@"innerThumbstick.png"];
    thumbstick.outerImage = [SPImage imageWithContentsOfFile:@"outerThumbstick.png"];
    thumbstick.type = SHThumbstickStatic;
    thumbstick.x = thumbstick.width/2 -40;
    thumbstick.y = [[EMedia getStage]width]-thumbstick.height-10;
    thumbstick.innerRadius = 0;
    [screen addChild:thumbstick];
    [self addEventListener:@selector(onEnterFrame:) atObject:self
                   forType:SP_EVENT_TYPE_ENTER_FRAME];
}

-(void)setupPlayer
{
    player = [[ESprite alloc]initWithESpriteFile:@"Player.xml" AndInitialAnimation:@"toward"];
    [ESpriteManager addSprite:player withName:@"Player"];
    [screen addChild:player];
}

-(void)setupMap
{
    map = [[TMXMap alloc] initWithContentsOfFile:@"map.tmx" width:self.width height:self.height];
    [screen addChild:map];   
}

- (void)onEnterFrame:(SPEnterFrameEvent *)event
{
    double passedTime = event.passedTime;
    [ESpriteManager advanceTime:passedTime];
    [player onMoveSprite:event :thumbstick.distance :thumbstick.direction];
}

@end
