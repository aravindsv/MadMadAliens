//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Crosshair.h"
#import "Bullet.h"

#import <CoreMotion/CoreMotion.h>

static const int SENSITIVITY = 10;

@implementation MainScene
{
    CMMotionManager *_motionManager;
    
    CCNode *_startNode;
    Crosshair *_crosshair;
}

#pragma mark - Initilization Methods

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
}

-(id)init
{
    if (self == [super init])
    {
        _motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [_motionManager startAccelerometerUpdates];
}

-(void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

#pragma mark - Touch Methods

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    Bullet *newBullet = (Bullet *)[CCBReader load:@"Bullet"];
    newBullet.positionType = CCPositionTypeNormalized;
    newBullet.position = _crosshair.position;
    [self addChild:newBullet];
    
    if (CGRectContainsPoint(_startNode.boundingBox, newBullet.positionInPoints))
    {
        CCLOG(@"Going to GameplayScene");
    }
}

#pragma mark - Update Method

-(void)update:(CCTime)delta
{
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _crosshair.position.x + acceleration.x * SENSITIVITY * delta;
    CGFloat newYPosition = _crosshair.position.y + acceleration.y * SENSITIVITY * delta;
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    newYPosition = clampf(newYPosition, 0, self.contentSize.height);
    _crosshair.position = CGPointMake(newXPosition, newYPosition);
    
    
}

@end
