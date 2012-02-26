//
//  SHThumbstick.m
//  Sparrow
//
//  Created by Shilo White on 2/12/11.
//  Copyright 2011 Shilocity Productions. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the Simplified BSD License.
//

#define PI 3.14159265359f
#define SP_R2D(rad) ((rad) / PI * 180.0f)

#define DEFAULT_TOUCHRADIUS 50.0f
#define DEFAULT_OUTERRADIUS 50.0f
#define DEFAULT_INNERRADIUS 25.0f
#define DEBUGDRAW_BOUNDSCOLOR [UIColor redColor].CGColor
#define DEBUGDRAW_TOUCHCOLOR [UIColor whiteColor].CGColor
#define DEBUGDRAW_OUTERCOLOR [UIColor greenColor].CGColor
#define DEBUGDRAW_INNERCOLOR [UIColor yellowColor].CGColor

#import "SHThumbstick.h"
#import "SPStage.h"
#import "SPTexture.h"
#import "SPImage.h"
#import "SPRectangle.h"
#import "SPTouchEvent.h"
#import "SPTouch.h"
#import "SPPoint.h"
#import "SPDisplayObject.h"

@interface SHThumbstick ()
- (void)drawDebugDraw;
- (void)drawDebugDrawBounds;
- (void)redrawDebugDrawBounds;
- (void)positionContent;
- (void)onTouch:(SPTouch *)touch;
- (void)onStaticTouch:(SPTouch *)touch;
- (void)onRelativeTouch:(SPTouch *)touch;
- (void)onAbsoluteTouch:(SPTouch *)touch;
- (void)onFloatTouch:(SPTouch *)touch;
- (void)onMove:(SPTouch *)move;
- (void)onStaticMove:(SPTouch *)move;
- (void)onRelativeMove:(SPTouch *)move;
- (void)onAbsoluteMove:(SPTouch *)move;
- (void)onFloatMove:(SPTouch *)move;
- (void)onTouchUp:(SPTouch *)touchUp;
- (void)dispatchEvent:(NSString *)event distance:(float)distance direction:(float)direction;
@end

@implementation SHThumbstick

@synthesize outerImage = mOuterImage;
@synthesize innerImage = mInnerImage;
@synthesize type = mType;
@synthesize touchRadius = mTouchRadius;
@synthesize outerRadius = mOuterRadius;
@synthesize innerRadius = mInnerRadius;
@synthesize debugDraw = mDebugDraw;
@synthesize bounds = mBounds;
@synthesize innerImageScaleOnTouch = mInnerImageScaleOnTouch;
@synthesize distance = mDistance;
@synthesize direction = mDirection;

- (id)init {
	if (self = [super init]) {
		mType = SHThumbstickStatic;
		mTouchRadius = DEFAULT_TOUCHRADIUS;
		mOuterRadius = DEFAULT_OUTERRADIUS;
		mInnerRadius = DEFAULT_INNERRADIUS;
		mBounds = nil;
		mInnerImageScaleOnTouch = 1.0f;
		[self addEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
	}
	return self;	
}

+ (SHThumbstick *)thumbstick {
	return [[[SHThumbstick alloc] init] autorelease];
}

- (void)onAddedToStage:(SPEvent *)event {
	[self removeEventListener:@selector(onAddedToStage:) atObject:self forType:SP_EVENT_TYPE_ADDED_TO_STAGE];
	[self start];
}

- (void)onTouchEvent:(SPTouchEvent *)event {
	NSArray *touches = [[event touchesWithTarget:(SPDisplayObject *)mStage andPhase:SPTouchPhaseBegan] allObjects];
	NSArray *moves = [[event touchesWithTarget:(SPDisplayObject *)mStage andPhase:SPTouchPhaseMoved] allObjects];
	NSArray *touchUps = [[event touchesWithTarget:(SPDisplayObject *)mStage andPhase:SPTouchPhaseEnded] allObjects];
	
	if (touches.count) {
		for (SPTouch *touch in touches) {
			[self onTouch:touch];
		}
	}
	if (moves.count) {
		for (SPTouch *move in moves) {
			[self onMove:move];
		}
	}
	if (touchUps.count) {
		for (SPTouch *touchUp in touchUps) {
			[self onTouchUp:touchUp];
		}
	}
}

- (void)onTouch:(SPTouch *)touch {
	if (touch.target.root != self.stage) return;
	switch (mType) {
		case SHThumbstickStatic:
			[self onStaticTouch:touch];
			break;
		case SHThumbstickRelative:
			[self onRelativeTouch:touch];
			break;
		case SHThumbstickAbsolute:
			[self onAbsoluteTouch:touch];
			break;
		case SHThumbstickFloat:
			[self onFloatTouch:touch];
			break;
	}
}

- (void)onStaticTouch:(SPTouch *)touch {
	SPPoint *touchPosition = [touch locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(touchPosition.x-centerX), 2)+pow(abs(touchPosition.y-centerY), 2));
	if (distance > mTouchRadius) return;
	
	mCurTouch = touch;
	float radians = atan2(centerX-touchPosition.x, centerY-touchPosition.y);
	if (distance > mOuterRadius-mInnerRadius) {
		distance = mOuterRadius-mInnerRadius;	
		if (mInnerImage) {
			mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
			mInnerImage.x = (centerX-mInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mInnerImage.y = (centerY-mInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = (centerX-mDebugDrawInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mDebugDrawInnerImage.y = (centerY-mDebugDrawInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
	} else {
		if (mInnerImage) {
			mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
			mInnerImage.x = touchPosition.x-(mInnerImage.width/2);
			mInnerImage.y = touchPosition.y-(mInnerImage.height/2);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = touchPosition.x-(mDebugDrawInnerImage.width/2);
			mDebugDrawInnerImage.y = touchPosition.y-(mDebugDrawInnerImage.height/2);
		}
	}
    self.direction = SP_R2D(-radians);
    self.distance = distance/(mOuterRadius-mInnerRadius);
	[self dispatchEvent:SH_THUMBSTICK_EVENT_TOUCH distance:distance/(mOuterRadius-mInnerRadius) direction:SP_R2D(-radians)];
}

- (void)onRelativeTouch:(SPTouch *)touch {
	SPPoint *touchPosition = [touch locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(touchPosition.x-centerX), 2)+pow(abs(touchPosition.y-centerY), 2));
	if (distance > mTouchRadius) return;
	
	mCurTouch = touch;
	mRelativeX = touchPosition.x;
	mRelativeY = touchPosition.y;
	if (mInnerImage) {
		mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
		mInnerImage.x = centerX-mInnerImage.width/2;
		mInnerImage.y = centerY-mInnerImage.height/2;
	}
	if (mDebugDraw) {
		mDebugDrawInnerImage.x = centerX-mDebugDrawInnerImage.width/2;
		mDebugDrawInnerImage.y = centerY-mDebugDrawInnerImage.height/2;
	}
    self.direction = 0;
    self.distance = 0;
	[self dispatchEvent:SH_THUMBSTICK_EVENT_TOUCH distance:0 direction:0];
}

- (void)onAbsoluteTouch:(SPTouch *)touch {
	SPPoint *touchPosition = [touch locationInSpace:self.parent];
	if (![self isWithinBounds:touchPosition]) return;
	
	float centerX = self.width/2;
	float centerY = self.height/2;
	mCurTouch = touch;
	if (mInnerImage) {
		mInnerImage.scaleX = mInnerImage.scaleY = mInnerImageScaleOnTouch;
		mInnerImage.x = centerX-mInnerImage.width/2;
		mInnerImage.y = centerY-mInnerImage.height/2;
	}
	if (mDebugDraw) {
		mDebugDrawInnerImage.x = centerX-mDebugDrawInnerImage.width/2;
		mDebugDrawInnerImage.y = centerY-mDebugDrawInnerImage.height/2;
	}
	self.centerX = touchPosition.x;
	self.centerY = touchPosition.y;
	if (mDebugDraw) [self drawDebugDraw];
	[self show];
    self.direction = 0;
    self.distance = 0;
	[self dispatchEvent:SH_THUMBSTICK_EVENT_TOUCH distance:0 direction:0];
}

- (void)onFloatTouch:(SPTouch *)touch {
	[self onAbsoluteTouch:touch];
}

- (void)onMove:(SPTouch *)move {
	if (move != mCurTouch) return;
	
	switch (mType) {
		case SHThumbstickStatic:
			[self onStaticMove:move];
			break;
		case SHThumbstickRelative:
			[self onRelativeMove:move];
			break;
		case SHThumbstickAbsolute:
			[self onAbsoluteMove:move];
			break;
		case SHThumbstickFloat:
			[self onFloatMove:move];
			break;
	}
}

- (void)onStaticMove:(SPTouch *)move {
	SPPoint *movePosition = [move locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(movePosition.x-centerX), 2)+pow(abs(movePosition.y-centerY), 2));
	
	float radians = atan2(centerX-movePosition.x, centerY-movePosition.y);
	if (distance > mOuterRadius-mInnerRadius) {
		distance = mOuterRadius-mInnerRadius;
		if (mInnerImage) {
			mInnerImage.x = (centerX-mInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mInnerImage.y = (centerY-mInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = (centerX-mDebugDrawInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mDebugDrawInnerImage.y = (centerY-mDebugDrawInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
	} else {
		if (mInnerImage) {
			mInnerImage.x = movePosition.x-(mInnerImage.width/2);
			mInnerImage.y = movePosition.y-(mInnerImage.height/2);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = movePosition.x-(mDebugDrawInnerImage.width/2);
			mDebugDrawInnerImage.y = movePosition.y-(mDebugDrawInnerImage.height/2);
		}
	} 
    self.direction = SP_R2D(-radians);
    self.distance = distance/(mOuterRadius-mInnerRadius);
	[self dispatchEvent:SH_THUMBSTICK_EVENT_MOVE distance:distance/(mOuterRadius-mInnerRadius) direction:SP_R2D(-radians)];
}

- (void)onRelativeMove:(SPTouch *)move {
	SPPoint *movePosition = [move locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(movePosition.x-mRelativeX), 2)+pow(abs(movePosition.y-mRelativeY), 2));
	
	float radians = atan2(mRelativeX-movePosition.x, mRelativeY-movePosition.y);
	if (distance > mOuterRadius-mInnerRadius) {
		distance = mOuterRadius-mInnerRadius;
		if (mInnerImage) {
			mInnerImage.x = (centerX-mInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mInnerImage.y = (centerY-mInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = (centerX-mDebugDrawInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mDebugDrawInnerImage.y = (centerY-mDebugDrawInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
	} else {
		if (mInnerImage) {
			mInnerImage.x = movePosition.x-mRelativeX-(mInnerImage.width/2)+centerX;
			mInnerImage.y = movePosition.y-mRelativeY-(mInnerImage.height/2)+centerY;
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = movePosition.x-mRelativeX-(mDebugDrawInnerImage.width/2)+centerX;
			mDebugDrawInnerImage.y = movePosition.y-mRelativeY-(mDebugDrawInnerImage.height/2)+centerY;
		}
	}
    self.direction = SP_R2D(-radians);
    self.distance = distance/(mOuterRadius-mInnerRadius);
	[self dispatchEvent:SH_THUMBSTICK_EVENT_MOVE distance:distance/(mOuterRadius-mInnerRadius) direction:SP_R2D(-radians)];
}

- (void)onAbsoluteMove:(SPTouch *)move {
	SPPoint *movePosition = [move locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(movePosition.x-centerX), 2)+pow(abs(movePosition.y-centerY), 2));
	
	float radians = atan2(centerX-movePosition.x, centerY-movePosition.y);
	if (distance > mOuterRadius-mInnerRadius) {
		distance = mOuterRadius-mInnerRadius;
		if (mInnerImage) {
			mInnerImage.x = (centerX-mInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mInnerImage.y = (centerY-mInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = (centerX-mDebugDrawInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mDebugDrawInnerImage.y = (centerY-mDebugDrawInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
	} else {
		if (mInnerImage) {
			mInnerImage.x = movePosition.x-(mInnerImage.width/2);
			mInnerImage.y = movePosition.y-(mInnerImage.height/2);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = movePosition.x-(mDebugDrawInnerImage.width/2);
			mDebugDrawInnerImage.y = movePosition.y-(mDebugDrawInnerImage.height/2);
		}
	}
    self.direction = SP_R2D(-radians);
    self.distance = distance/(mOuterRadius-mInnerRadius);
	[self dispatchEvent:SH_THUMBSTICK_EVENT_MOVE distance:distance/(mOuterRadius-mInnerRadius) direction:SP_R2D(-radians)];
}

- (void)onFloatMove:(SPTouch *)move {
	SPPoint *movePosition = [move locationInSpace:self];
	float centerX = self.width/2;
	float centerY = self.height/2;
	float distance = sqrt(pow(abs(movePosition.x-centerX), 2)+pow(abs(movePosition.y-centerY), 2));
	
	float radians = atan2(centerX-movePosition.x, centerY-movePosition.y);
	if (distance > mOuterRadius-mInnerRadius) {
		distance = mOuterRadius-mInnerRadius;
		SPPoint *touchPosition = [move locationInSpace:self.parent];
		self.centerX = touchPosition.x + sin(radians)*(mOuterRadius-mInnerRadius);
		self.centerY = touchPosition.y + cos(radians)*(mOuterRadius-mInnerRadius);
		if (self.centerX < mBounds.x) self.centerX = mBounds.x;
		else if (self.centerX > mBounds.x+mBounds.width) self.centerX = mBounds.x+mBounds.width;
		if (self.centerY < mBounds.y) self.centerY = mBounds.y;
		else if (self.centerY > mBounds.y+mBounds.height) self.centerY = mBounds.y+mBounds.height;
		if (mInnerImage) {
			mInnerImage.x = (centerX-mInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mInnerImage.y = (centerY-mInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
		if (mDebugDraw) {
			[self drawDebugDrawBounds];
			mDebugDrawInnerImage.x = (centerX-mDebugDrawInnerImage.width/2) - sin(radians)*(mOuterRadius-mInnerRadius);
			mDebugDrawInnerImage.y = (centerY-mDebugDrawInnerImage.height/2) - cos(radians)*(mOuterRadius-mInnerRadius);
		}
	} else {
		if (mInnerImage) {
			mInnerImage.x = movePosition.x-(mInnerImage.width/2);
			mInnerImage.y = movePosition.y-(mInnerImage.height/2);
		}
		if (mDebugDraw) {
			mDebugDrawInnerImage.x = movePosition.x-(mDebugDrawInnerImage.width/2);
			mDebugDrawInnerImage.y = movePosition.y-(mDebugDrawInnerImage.height/2);
		}
	}
    self.direction = SP_R2D(-radians);
    self.distance = distance/(mOuterRadius-mInnerRadius);
	[self dispatchEvent:SH_THUMBSTICK_EVENT_MOVE distance:distance/(mOuterRadius-mInnerRadius) direction:SP_R2D(-radians)];
}

- (void)onTouchUp:(SPTouch *)touchUp {
	if (touchUp != mCurTouch) return;
	
	switch (mType) {
		case SHThumbstickStatic:
		case SHThumbstickRelative:
			if (mInnerImage) {
				mInnerImage.scaleX = mInnerImage.scaleY = 1.0f;
				mInnerImage.x = (self.width-mInnerImage.width)/2;
				mInnerImage.y = (self.height-mInnerImage.height)/2;
			}
			if (mDebugDraw) {
				mDebugDrawInnerImage.x = (self.width-mDebugDrawInnerImage.width)/2;
				mDebugDrawInnerImage.y = (self.height-mDebugDrawInnerImage.height)/2;
			}
			break;
		case SHThumbstickAbsolute:
		case SHThumbstickFloat:
			[self hide];
			break;
	}
	mCurTouch = nil;
    self.direction = 0;
    self.distance = 0;
	[self dispatchEvent:SH_THUMBSTICK_EVENT_TOUCHUP distance:0 direction:0];
}

- (void)start {
	if (mRender) return;
	
	if (!self.stage)
		[NSException raise:NSInvalidArgumentException format:@"SHThumbstick must be added to the stage before starting.", NSStringFromSelector(_cmd)];
	
	if (!mStage) mStage = self.stage;
	[mStage addEventListener:@selector(onTouchEvent:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	
	mRender = YES;
}

- (void)stop {
	if (!mRender) return;
	
	[mStage removeEventListener:@selector(onTouchEvent:) atObject:self forType:SP_EVENT_TYPE_TOUCH];
	mStage = nil;
	mRender = NO;
}

- (void)setOuterImage:(SPImage *)outerImage {
	if (mOuterImage) [self removeChild:mOuterImage];
	mOuterImage = outerImage;
	[self addChild:mOuterImage atIndex:0];
	
	mOuterRadius = (mOuterImage.width > mOuterImage.height) ? mOuterImage.width/2 : mOuterImage.height/2;
	if (mDebugDraw) [self drawDebugDraw];
	[self positionContent];
}

- (void)setInnerImage:(SPImage *)innerImage {
	if (mInnerImage) [self removeChild:mInnerImage];
	mInnerImage = innerImage;
	[self addChild:mInnerImage];
	
	mInnerRadius = (mInnerImage.width > mInnerImage.height) ? mInnerImage.width/2 : mInnerImage.height/2;
	if (mDebugDraw) [self drawDebugDraw];
	[self positionContent];
}

- (void)setType:(int)type {
	if (type != mType) {
		mType = type;
		switch (mType) {
			case SHThumbstickStatic:
			case SHThumbstickRelative:
				self.bounds = nil;
				if (mDebugDraw) [self drawDebugDraw];
				[self show];
				break;
			case SHThumbstickAbsolute:
			case SHThumbstickFloat:
				self.bounds = [SPRectangle rectangleWithX:0 y:0 width:320 height:480];
				if (mDebugDraw) [self drawDebugDraw];
				[self hide];
				break;
		}
	}
}

- (void)setTouchRadius:(float)touchRadius {
	if (touchRadius != mTouchRadius) {
		mTouchRadius = touchRadius;
		if (mDebugDraw) [self drawDebugDraw];
	}
}

- (void)setOuterRadius:(float)outerRadius {
	if (outerRadius != mOuterRadius) {
		mOuterRadius = outerRadius;
		if (mDebugDraw) [self drawDebugDraw];
		[self positionContent];
	}
}

- (void)setInnerRadius:(float)innerRadius {
	if (innerRadius != mInnerRadius) {
		mInnerRadius = innerRadius;
		if (mDebugDraw) [self drawDebugDraw];
	}
}

- (void)setDebugDraw:(BOOL)debugDraw {
	if (debugDraw != mDebugDraw) {
		mDebugDraw = debugDraw;
		if (mDebugDraw) {
			[self drawDebugDraw];
		} else {
			if (mDebugDrawImage) [self removeChild:mDebugDrawImage];
			if (mDebugDrawInnerImage) [self removeChild:mDebugDrawInnerImage];
			if (mDebugDrawBoundsImage) [self removeChild:mDebugDrawBoundsImage];
		}
	}
}

- (void)setBounds:(SPRectangle *)bounds {
	if (mBounds) [mBounds release];
	mBounds = [bounds retain];
	if (mDebugDraw) [self drawDebugDraw];
}

- (void)drawDebugDraw {	
	[self drawDebugDrawBounds];
	
	float maxRadius = (mTouchRadius > mOuterRadius) ? mTouchRadius : mOuterRadius;
	SPTexture *debugDrawTexture = [SPTexture textureWithWidth:maxRadius*2 height:maxRadius*2 
	draw:^(CGContextRef context) {
		if (mType != SHThumbstickAbsolute && mType != SHThumbstickFloat) {
			CGContextSetStrokeColorWithColor(context, DEBUGDRAW_TOUCHCOLOR);
			CGContextStrokeEllipseInRect(context, CGRectMake(maxRadius-mTouchRadius+0.5, maxRadius-mTouchRadius+0.5, mTouchRadius*2-1, mTouchRadius*2-1));
		}
		CGContextSetStrokeColorWithColor(context, DEBUGDRAW_OUTERCOLOR);
		CGContextStrokeEllipseInRect(context, CGRectMake(maxRadius-mOuterRadius+0.5, maxRadius-mOuterRadius+0.5, mOuterRadius*2-1, mOuterRadius*2-1));
	}];
	
	float outerRadius = (mOuterRadius > mOuterImage.width/2) ? (mOuterRadius > mOuterImage.height/2) ? mOuterRadius : mOuterImage.height/2 : mOuterImage.width/2;
	if (mDebugDrawImage) [self removeChild:mDebugDrawImage];
	mDebugDrawImage = [SPImage imageWithTexture:debugDrawTexture];
	mDebugDrawImage.x = outerRadius-maxRadius;
	mDebugDrawImage.y = outerRadius-maxRadius;
	[self addChild:mDebugDrawImage];
	
	float innerDiameter = (mInnerRadius<1.0) ? 2.0 : mInnerRadius*2;
	SPTexture *debugDrawInnerTexture = [SPTexture textureWithWidth:innerDiameter height:innerDiameter
	draw:^(CGContextRef context) {
		CGContextSetStrokeColorWithColor(context, DEBUGDRAW_INNERCOLOR);
		CGContextStrokeEllipseInRect(context, CGRectMake(0.5, 0.5, innerDiameter-1, innerDiameter-1));
	}];
	
	if (mDebugDrawInnerImage) [self removeChild:mDebugDrawInnerImage];
	mDebugDrawInnerImage = [SPImage imageWithTexture:debugDrawInnerTexture];
	mDebugDrawInnerImage.x = outerRadius-mInnerRadius;
	mDebugDrawInnerImage.y = outerRadius-mInnerRadius;
	[self addChild:mDebugDrawInnerImage];
	
    // may have introduced a bug here.. remove parens after || to put it back how it was
	if (mType == SHThumbstickAbsolute || (mType == SHThumbstickFloat && !mCurTouch)) {
		if (mDebugDrawImage) mDebugDrawImage.visible = NO;
		if (mDebugDrawInnerImage) mDebugDrawInnerImage.visible = NO;
	}
}

- (void)drawDebugDrawBounds {
	if (mType == SHThumbstickAbsolute || mType == SHThumbstickFloat) {
		if (!mDebugDrawBoundsImage || mDebugDrawBoundsImage.width != mBounds.width || mDebugDrawBoundsImage.height != mBounds.height) {
			[self redrawDebugDrawBounds];
		}
		mDebugDrawBoundsImage.x = -self.x+mBounds.x;
		mDebugDrawBoundsImage.y = -self.y+mBounds.y;
		[self addChild:mDebugDrawBoundsImage];
	}
}

- (void)redrawDebugDrawBounds {
	SPTexture *debugDrawBoundsTexture = [SPTexture textureWithWidth:mBounds.width height:mBounds.height 
	draw:^(CGContextRef context) {
			CGContextSetStrokeColorWithColor(context, DEBUGDRAW_BOUNDSCOLOR);
			CGContextStrokeRect(context, CGRectMake(0, 0, mBounds.width, mBounds.height));
	}];
	if (mDebugDrawBoundsImage) [self removeChild:mDebugDrawBoundsImage];
	mDebugDrawBoundsImage = [SPImage imageWithTexture:debugDrawBoundsTexture];
	mDebugDrawBoundsImage.x = -self.x+mBounds.x;
	mDebugDrawBoundsImage.y = -self.y+mBounds.y;
	[self addChild:mDebugDrawBoundsImage];
}

- (void)positionContent {
	float outerRadius = (mOuterRadius > mOuterImage.width/2) ? (mOuterRadius > mOuterImage.height/2) ? mOuterRadius : mOuterImage.height/2 : mOuterImage.width/2;
	
	if (mOuterImage) {
		mOuterImage.x = outerRadius-mOuterImage.width/2;
		mOuterImage.y = outerRadius-mOuterImage.height/2;
	}
	if (mInnerImage) {
		mInnerImage.x = outerRadius-mInnerImage.width/2;
		mInnerImage.y = outerRadius-mInnerImage.height/2;
	}
}

- (float)width {
	if (mOuterRadius*2 > mOuterImage.width) {
		return mOuterRadius*2;
	} else {
		return mOuterImage.width;
	}
}

- (float)height {
	if (mOuterRadius*2 > mOuterImage.height) {
		return mOuterRadius*2;
	} else {
		return mOuterImage.height;
	}
}

- (void)setCenterX:(float)centerX {
	self.x = centerX - self.width/2;
}

- (float)centerX {
	return self.x + self.width/2;
}

- (void)setCenterY:(float)centerY {
	self.y = centerY - self.height/2;
}

- (float)centerY {
	return self.y + self.height/2;
}

- (void)show {
	if (mInnerImage) mInnerImage.visible = YES;
	if (mOuterImage) mOuterImage.visible = YES;
	if (mDebugDrawImage) mDebugDrawImage.visible = YES;
	if (mDebugDrawInnerImage) mDebugDrawInnerImage.visible = YES;
}

- (void)hide {
	if (mInnerImage) mInnerImage.visible = NO;
	if (mOuterImage) mOuterImage.visible = NO;
	if (mDebugDrawImage) mDebugDrawImage.visible = NO;
	if (mDebugDrawInnerImage) mDebugDrawInnerImage.visible = NO;
}

- (BOOL)isWithinBounds:(SPPoint *)point {
	if (point.x < mBounds.x || point.x > mBounds.x + mBounds.width || point.y < mBounds.y || point.y > mBounds.y + mBounds.height) {
		return NO;
	} else {
		return YES;
	}
}

- (void)dispatchEvent:(NSString *)event distance:(float)distance direction:(float)direction {
	if (direction<0) direction += 360;
	
	SHThumbstickEvent *touchEvent = [[SHThumbstickEvent alloc] initWithType:event distance:distance direction:direction];
	SHThumbstickEvent *changedEvent = [[SHThumbstickEvent alloc] initWithType:SH_THUMBSTICK_EVENT_CHANGED distance:distance direction:direction];
	[self dispatchEvent:touchEvent];
	[self dispatchEvent:changedEvent];
	[touchEvent release];
	[changedEvent release];
}


- (void)dealloc {
	if (mCurTouch) [mCurTouch release];
	if (mRender) [self stop];
	if (mBounds) [mBounds release];
	[self removeAllChildren];
	[super dealloc];
}
@end

@implementation SHThumbstickEvent

@synthesize distance = mDistance;
@synthesize direction = mDirection;

- (id)initWithType:(NSString *)type distance:(float)distance direction:(float)direction {
	return [self initWithType:type distance:distance direction:direction bubbles:YES];
}

- (id)initWithType:(NSString *)type distance:(float)distance direction:(float)direction bubbles:(BOOL)bubbles {
	if (self = [super initWithType:type bubbles:bubbles]) {        
		mDistance = distance;
		mDirection = direction;
    }
    return self;
}

+ (SHThumbstickEvent *)eventWithType:(NSString *)type distance:(float)distance direction:(float)direction {
	return [[[SHThumbstickEvent alloc] initWithType:type distance:distance direction:direction bubbles:YES] autorelease];
}

+ (SHThumbstickEvent *)eventWithType:(NSString *)type distance:(float)distance direction:(float)direction bubbles:(BOOL)bubbles {
	return [[[SHThumbstickEvent alloc] initWithType:type distance:distance direction:direction bubbles:bubbles] autorelease];
}
@end