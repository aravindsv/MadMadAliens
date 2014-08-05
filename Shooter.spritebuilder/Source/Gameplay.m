//
//  Gameplay.m
//  Shooter
//
//  Created by Aravind Vadali on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Crosshair.h"
#import "Bullet.h"
#import "Enemy.h"
#import "GameOver.h"

#import <CoreMotion/CoreMotion.h>

static const int SENSITIVITY = 10;

@implementation Gameplay
{
    CMMotionManager *_motionManager;
    
    CCNode *_enemyNode;
    Crosshair *_crosshair;
    CCNode *_base;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_healthLabel;
    
    float timer;
    int enemiesKilled;
    int health;
}

#pragma mark - Initialization Methods

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    health = 100;
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

#pragma mark - Touch Handling Methods

-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    Bullet *newBullet = (Bullet *)[CCBReader load:@"Bullet"];
    newBullet.positionType = CCPositionTypeNormalized;
    newBullet.position = _crosshair.position;
    [self addChild:newBullet];
    
    for (Enemy *enemy in [_enemyNode.children copy])
    {
        if (CGRectContainsPoint(enemy.boundingBox, newBullet.positionInPoints))
        {
            [enemy removeFromParentAndCleanup:YES];
            enemiesKilled++;
        }
    }
}

#pragma mark - Update Method
-(void)update:(CCTime)delta
{
    timer += delta;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", enemiesKilled];
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _crosshair.position.x + acceleration.x * SENSITIVITY * delta;
    CGFloat newYPosition = _crosshair.position.y + acceleration.y * SENSITIVITY * delta;
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    newYPosition = clampf(newYPosition, 0, self.contentSize.height);
    _crosshair.position = CGPointMake(newXPosition, newYPosition);
    
    if (timer >= 2)
    {
        Enemy *newEnemy = (Enemy *)[CCBReader load:@"Enemy"];
        newEnemy.positionInPoints = [self randomPositionOffScreen];
        [_enemyNode addChild:newEnemy];
        timer = 0;
    }
    
    for (Enemy *enemy in _enemyNode.children)
    {
        CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:50.f position:_base.positionInPoints];
        [enemy runAction:actionMoveTo];
        
        if (CGRectContainsPoint(enemy.boundingBox, _base.positionInPoints))
        {
            health--;
        }
    }
    
    if (health <= 0)
    {
        [self gameOver];
    }
}

#pragma mark - Random Point Generation Methods

-(CGPoint)randomPositionOffScreen
{
    if (arc4random() % 2 == 0)
    {
        return ccp([self randomXFloatOffScreen], [self randomYFloatOnScreen]);
    }
    else
    {
        return ccp([self randomXFloatOnScreen], [self randomYFloatOffScreen]);
    }
}

-(float)randomXFloatOnScreen
{
    int size = self.contentSizeInPoints.width;
    return arc4random() % size;
}

-(float)randomXFloatOffScreen
{
    if (arc4random() % 2 == 0)
    {
        return (arc4random() % 50) * -1;
    }
    else
    {
        return (arc4random() % 50) + self.contentSizeInPoints.width;
    }
}

-(float)randomYFloatOnScreen
{
    int size = self.contentSizeInPoints.height;
    return arc4random() % size;
}

-(float)randomYFloatOffScreen
{
    if (arc4random() % 2 == 0)
    {
        return (arc4random() % 50) * -1;
    }
    else
    {
        return (arc4random() % 50) + self.contentSizeInPoints.height;
    }
}

#pragma mark - GameOver Method

-(void)gameOver
{
//    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
//    if (enemiesKilled > [highScore intValue])
//    {
//        highScore = [NSNumber numberWithInt:enemiesKilled];
//        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highscore"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    GameOver *gameOver = (GameOver *)[CCBReader load:@"GameOver"];
//    [gameOver setScore:enemiesKilled andHighscore:[highScore intValue]];
//    [[CCDirector sharedDirector] pushScene:(CCScene *)gameOver];
}


@end
