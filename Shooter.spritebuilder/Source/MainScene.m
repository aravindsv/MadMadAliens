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
#import "Gameplay.h"

#import <CoreMotion/CoreMotion.h>

//static const int SENSITIVITY = 5;

@implementation MainScene
{
    CMMotionManager *_motionManager;
    
    CCNode *_startNode;
    Crosshair *_crosshair;
}

#pragma mark - Initialization Methods

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    [self.animationManager runAnimationsForSequenceNamed:@"Opening"];
    NSNumber *sensit = [[NSUserDefaults standardUserDefaults] valueForKey:@"sensit"];
    if ([sensit intValue] == 0)
    {
        sensit = [NSNumber numberWithInt:7];
        [[NSUserDefaults standardUserDefaults] setObject:sensit forKey:@"sensit"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    _sensitivity = [sensit intValue];
    
    //Send push notification in 24 hours
    [self sendNotification];
}

- (IBAction)sendNotification
{
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:86400];
    localNotification.alertBody = @"Mad Mad Aliens are attacking! Defend the Earth!";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.applicationIconBadgeNumber = 0;//[[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(id)init
{
    if (self == [super init])
    {
        _motionManager = [[CMMotionManager alloc] init];
        NSNumber *xCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"xCalib"];
        NSNumber *yCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"yCalib"];
        _calibX = [xCalib floatValue];
        _calibY = [yCalib floatValue];
    }
    return self;
}

-(void)onEnter
{
    [super onEnter];
    [_motionManager performSelector:@selector(startAccelerometerUpdates) withObject:nil afterDelay:.1f];
}

-(void)onExit
{
    [super onExit];
    [_motionManager stopAccelerometerUpdates];
}

#pragma mark - Touch Handling Methods

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    Bullet *newBullet = (Bullet *)[CCBReader load:@"Bullet"];
    newBullet.positionType = CCPositionTypeNormalized;
    newBullet.position = _crosshair.position;
    [self addChild:newBullet];
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[OALSimpleAudio sharedInstance] playEffect:@"thin_laser.wav"];
    
    CCParticleSystem *_explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
    _explosion.positionInPoints = newBullet.positionInPoints;
    _explosion.autoRemoveOnFinish = true;
    [self addChild:_explosion];
    
    if (CGRectContainsPoint(_startNode.boundingBox, newBullet.positionInPoints))
    {
        CCLOG(@"Going to GameplayScene");
        
        CCScene *gameplay = (Gameplay *)[CCBReader loadAsScene:@"Gameplay"];
        Gameplay *gameLevel = gameplay.children[0];
        [gameLevel setCalibrationX:_calibX andY:_calibY];
        [[CCDirector sharedDirector] replaceScene:gameplay];
    }
}

#pragma mark - Update Method

-(void)update:(CCTime)delta
{
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _crosshair.position.x - ((acceleration.y - _calibY) * _sensitivity * delta);
    CGFloat newYPosition = _crosshair.position.y + ((acceleration.x - _calibX) * _sensitivity * delta);
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    newYPosition = clampf(newYPosition, 0, self.contentSize.height);
    _crosshair.position = CGPointMake(newXPosition, newYPosition);
}

-(void)calibrate
{
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    _calibX = acceleration.x;
    _calibY = acceleration.y;
    NSNumber *xCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"xCalib"];
    NSNumber *yCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"yCalib"];
    xCalib = [NSNumber numberWithFloat:_calibX];
    yCalib = [NSNumber numberWithFloat:_calibY];
    [[NSUserDefaults standardUserDefaults] setObject:xCalib forKey:@"xCalib"];
    [[NSUserDefaults standardUserDefaults] setObject:yCalib forKey:@"yCalib"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    _crosshair.positionType = CCPositionTypeNormalized;
//    _crosshair.position = ccp(.5, .5);
}

@end
