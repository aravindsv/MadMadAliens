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
#import "Base.h"

#import <CoreMotion/CoreMotion.h>

static const int SENSITIVITY = 5;
static const int MAX_ENEMIES = 20;

@implementation Gameplay
{
    CMMotionManager *_motionManager;
    
    CCNode *_enemyNode;
    Crosshair *_crosshair;
    Base *_base;
    CCNode *_replayButton;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_healthLabel;
    
    float timer;
    
    int probability;
    float enemySpeed;
    
    bool gameRunning;
    GameOver *gameOver;
}

#pragma mark - Initialization Methods

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    _base.health = 500;
    probability = 60;
    enemySpeed = 50.f;
    gameRunning = true;
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
//            CCLOG(@"Added explosion");
            CCParticleSystem *_explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
            _explosion.positionInPoints = enemy.positionInPoints;
            _explosion.autoRemoveOnFinish = true;
            [self addChild:_explosion];
            [enemy removeFromParent];
            if (gameRunning)
            {
                _base.score++;
            }
        }
    }
    if (!gameRunning)
    {
        CGPoint bulletLocation = newBullet.positionInPoints;
        CGPoint worldTouch = [self convertToWorldSpace:bulletLocation];
        CGPoint bulletNodeLocation = [gameOver convertToNodeSpace:worldTouch];
        if (CGRectContainsPoint(gameOver.replayButton.boundingBox, bulletNodeLocation))
        {
            CCScene *gameplay = [CCBReader loadAsScene:@"Gameplay"];
            [[CCDirector sharedDirector] replaceScene:gameplay];
        }
    }
}

#pragma mark - Update Method
-(void)update:(CCTime)delta
{
    timer += delta;
    //_scoreLabel.string = [NSString stringWithFormat:@"%d", enemiesKilled];
    //_healthLabel.string = [NSString stringWithFormat:@"Health: %d", _base.health];
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _crosshair.position.x - acceleration.y * SENSITIVITY * delta;
    CGFloat newYPosition = _crosshair.position.y + acceleration.x * SENSITIVITY * delta;
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    newYPosition = clampf(newYPosition, 0, self.contentSize.height);
    _crosshair.position = CGPointMake(newXPosition, newYPosition);
    
    if (gameRunning)
    {
        if ((timer >= 2) && (arc4random() % probability == 0) && ([_enemyNode.children count] < MAX_ENEMIES))
        {
            [self spawnEnemy];
//            Enemy *newEnemy = (Enemy *)[CCBReader load:@"Enemy"];
//            newEnemy.positionInPoints = [self randomPositionOffScreen];
//            CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:100/enemySpeed position:_base.positionInPoints];
//            [newEnemy runAction:actionMoveTo];
//            [_enemyNode addChild:newEnemy];
            //timer = 0;
        }
        else if ([_enemyNode.children count] >= MAX_ENEMIES)
        {
            CCLOG(@"Array full! Emptying array and increasing enemy frequency");
            [_enemyNode removeAllChildren];
            probability *= .5;
        }
        if (_base.score != 0 && _base.score % 10 == 0)
        {
//            probability *= .5;
        }
    
        for (Enemy *enemy in _enemyNode.children)
        {
            
            //enemySpeed *= 1.5;
        
            if (CGRectContainsPoint(_base.boundingBox, enemy.positionInPoints))
            {
                _base.health -= .5;
            }
        }
    
        if (_base.health <= 0)
        {
            [self gameOver];
        }
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
    gameRunning = false;
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
    if (_base.score > [highScore intValue])
    {
        highScore = [NSNumber numberWithInt:_base.score];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highscore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    gameOver = (GameOver *)[CCBReader load:@"GameOver" owner:self];
    gameOver.zOrder = 9;
    [gameOver setScore:_base.score andHighscore:[highScore intValue]];
    gameOver.positionType = CCPositionTypeNormalized;
    gameOver.position = ccp(.25, 0.035);
//    [[CCDirector sharedDirector] pushScene:(CCScene *)gameOver];
    [self addChild:gameOver];
}

-(void)spawnEnemy
{
    Enemy *newEnemy = (Enemy *)[CCBReader load:@"Enemy"];
    int spawnArea = arc4random() % 4;
    int width = self.contentSizeInPoints.width;
    int height = self.contentSizeInPoints.height;
    float xpos = 0.0;
    float ypos = 0.0;
    int val = arc4random() % 50;
    switch (spawnArea) {
        case 0:
        {
            //Enemies come in from top
            xpos = arc4random() % width;
            ypos = val + height;
            newEnemy.positionInPoints = ccp(xpos, ypos);
            break;
        }
        case 1:
        {
            //Enemies come in from bottom
            xpos = arc4random() % width;
            ypos = 0 - val;
            break;
        }
        case 2:
        {
            //Enemies come in from left
            xpos = 0 - val;
            ypos = arc4random() % height;
            break;
        }
        case 3:
        {
            //Enemies come in from right
            xpos = val + width;
            ypos = arc4random() % height;
            break;
        }
        default:
            break;
    }
    newEnemy.positionInPoints = ccp(xpos, ypos);
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:100/enemySpeed position:_base.positionInPoints];
    [newEnemy runAction:actionMoveTo];
    [_enemyNode addChild:newEnemy];

}




@end