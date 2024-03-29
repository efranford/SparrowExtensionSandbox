//
//  BEScreen.h
//
//  Created by Brian Ensor on 2/13/11.
//  Copyright 2011 Brian Ensor Apps. All rights reserved.
// http://wiki.sparrow-framework.org/extensions/be_screen

typedef enum {
    BEScreenOrientationPortrait = 0,
    BEScreenOrientationPortraitUpsideDown,
    BEScreenOrientationLandscapeRight,
    BEScreenOrientationLandscapeLeft
} BEScreenOrientation;

#define BE_SCREEN_EVENT_ORIENTATIONCHANGED @"orientationChanged"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SPSprite.h"
#import "SPStage.h"

@interface BEScreen : SPSprite {
	int mOrientation;
	BOOL mRotates;
	BOOL mAllowAllOrientations;
	float mCurrentWidth;
	float mCurrentHeight;
}

@property (nonatomic, assign) int orientation;
@property (nonatomic, assign) BOOL rotates;
@property (nonatomic, assign) BOOL allowAllOrientations;
@property (nonatomic, readonly) float currentWidth;
@property (nonatomic, readonly) float currentHeight;

- (id)initWithOrientation:(int)orientation rotates:(BOOL)rotates allowAllOrientations:(BOOL)allowAllOrientations;
- (id)initWithOrientation:(int)orientation rotates:(BOOL)rotates;
- (id)initWithOrientation:(int)orientation;

+ (BEScreen *)screenWithOrientation:(int)orientation rotates:(BOOL)rotates allowAllOrientations:(BOOL)allowAllOrientations;
+ (BEScreen *)screenWithOrientation:(int)orientation rotates:(BOOL)rotates;
+ (BEScreen *)screenWithOrientation:(int)orientation;

@end
