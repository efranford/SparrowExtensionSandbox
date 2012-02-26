//
//  SHThumbstick.h
//  Sparrow
//
//  Created by Shilo White on 2/12/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//  http://wiki.sparrow-framework.org/users/shilo/extensions/shthumbstick

typedef enum {
    SHThumbstickStatic = 0,
    SHThumbstickRelative,
    SHThumbstickAbsolute,
    SHThumbstickFloat
} SHThumbstickType;


#define SH_THUMBSTICK_EVENT_TOUCH @"thumbstickTouch"
#define SH_THUMBSTICK_EVENT_MOVE @"thumbstickMove"
#define SH_THUMBSTICK_EVENT_TOUCHUP @"thumbstickTouchUp"
#define SH_THUMBSTICK_EVENT_CHANGED @"thumbstickChanged"

#import <Foundation/Foundation.h>
#import "SPDisplayObjectContainer.h"
#import "SPEvent.h"
@class SPStage;
@class SPImage;
@class SPRectangle;
@class SPTouch;
@class SPPoint;

@interface SHThumbstick : SPDisplayObjectContainer {
	SPStage *mStage;
	SPImage *mOuterImage;
	SPImage *mInnerImage;
	SPImage *mDebugDrawImage;
	SPImage *mDebugDrawInnerImage;
	SPImage *mDebugDrawBoundsImage;
	int mType;
	float mTouchRadius;
	float mOuterRadius;
	float mInnerRadius;
	BOOL mDebugDraw;
	SPRectangle *mBounds;
	BOOL mRender;
	SPTouch *mCurTouch;
	float mRelativeX;
	float mRelativeY;
	float mInnerImageScaleOnTouch;
    float mDistance;
    float mDirection;
}

@property (nonatomic, assign) SPImage *outerImage;
@property (nonatomic, assign) SPImage *innerImage;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) float centerX;
@property (nonatomic, assign) float centerY;
@property (nonatomic, assign) float touchRadius;
@property (nonatomic, assign) float outerRadius;
@property (nonatomic, assign) float innerRadius;
@property (nonatomic, assign) BOOL debugDraw;
@property (nonatomic, assign) SPRectangle *bounds;
@property (nonatomic, assign) float innerImageScaleOnTouch;
@property (nonatomic, assign) float distance;
@property (nonatomic, assign) float direction;

+ (SHThumbstick *)thumbstick;
- (void)start;
- (void)stop;
- (BOOL)isWithinBounds:(SPPoint *)point;
- (void)show;
- (void)hide;
@end

@interface SHThumbstickEvent : SPEvent {
	float mDistance;
	float mDirection;
}

@property (nonatomic, readonly) float distance;
@property (nonatomic, readonly) float direction;

- (id)initWithType:(NSString *)type distance:(float)distance direction:(float)direction;
- (id)initWithType:(NSString *)type distance:(float)distance direction:(float)direction bubbles:(BOOL)bubbles;
+ (SHThumbstickEvent *)eventWithType:(NSString *)type distance:(float)distance direction:(float)direction;
+ (SHThumbstickEvent *)eventWithType:(NSString *)type distance:(float)distance direction:(float)direction bubbles:(BOOL)bubbles;
@end