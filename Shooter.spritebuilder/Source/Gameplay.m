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
#import "Tutorial.h"
#import "GCHelper.h"

#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>

//static const int SENSITIVITY = 7;
static const float ENEMY_DAMAGE = 1;
static const int MAX_ENEMIES = 20;
static const int COMET_CHANCE = 1500;
static const int INITIAL_HEALTH = 500;
//static const int PLANET_CHANCE = 1000;

@implementation Gameplay
{
    CMMotionManager *_motionManager;
    
    CCNode *_enemyNode;
    Crosshair *_crosshair;
    Base *_base;
    CCNode *_replayButton;
    CCNode *_mainScreenButton;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_healthLabel;
    Tutorial *tutorial;
    CCSprite *_target;
    
    CCNode *_cometNode;
    CCNode *_asteroidNode;
    CCNode *_planetNode;
    bool shotPlanet;
    float timer;
    
    int probability;
    float enemySpeed;
    int maxEnemies;
    
    bool gameRunning;
    bool tutorialOn;
    GameOver *gameOver;
}

#pragma mark - Initialization Methods

-(void)didLoadFromCCB
{
    self.userInteractionEnabled = true;
    _base.health = INITIAL_HEALTH;
    probability = 60;
    enemySpeed = 50.f;
    maxEnemies = 1;
    NSNumber *sensit = [[NSUserDefaults standardUserDefaults] valueForKey:@"sensit"];
    _sensitivity = [sensit intValue];
    gameRunning = true;
    NSNumber *timesPlayed = [[NSUserDefaults standardUserDefaults] valueForKey:@"timesPlayed"];
    timesPlayed = [NSNumber numberWithInt:[timesPlayed intValue]+1];
    [[NSUserDefaults standardUserDefaults] setObject:timesPlayed forKey:@"timesPlayed"];
    if ([timesPlayed intValue] == 1)
    {
        //Show tutorial message
        tutorialOn = true;
        gameRunning = false;
        tutorial = (Tutorial *)[CCBReader load:@"Tutorial" owner:self];
        [self addChild:tutorial];
    }
    else
    {
        tutorialOn = false;
    }
    NSNumber *xCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"xCalib"];
    NSNumber *yCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"yCalib"];
    [self setCalibrationX:[xCalib floatValue] andY:[yCalib floatValue]];
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

-(void)setCalibrationX:(float)xVal andY:(float)yVal
{
    _calibX = xVal;
    _calibY = yVal;
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
    
    if (tutorialOn)
    {
        if (CGRectContainsPoint(_target.boundingBox, newBullet.positionInPoints))
        {
            tutorialOn = false;
            [tutorial removeFromParent];
            gameRunning = true;
            [[OALSimpleAudio sharedInstance] playEffect:@"small_explosion.wav"];
        }
    }
    
    CCParticleSystem *_explosion = (CCParticleSystem *)[CCBReader load:@"Explosion"];
    _explosion.positionInPoints = newBullet.positionInPoints;
    _explosion.autoRemoveOnFinish = true;
    [self addChild:_explosion];
    
    for (Enemy *enemy in [_enemyNode.children copy])
    {
        if (CGRectContainsPoint(enemy.boundingBox, newBullet.positionInPoints))
        {
            [enemy removeFromParent];
            [[OALSimpleAudio sharedInstance] playEffect:@"small_explosion.wav"];
            if (gameRunning)
            {
                _base.score++;
                if (_base.score == 1)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"first_alien_killed" percentComplete:100.0];
                }
                else if (_base.score == 25)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"25_aliens_killed" percentComplete:100.0];
                }
                else if (_base.score == 50)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"50_aliens_killed" percentComplete:100.0];
                }
                else if (_base.score == 100)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"100_aliens_killed" percentComplete:100.0];
                }
                
                if (_base.score == 10 && _base.health == INITIAL_HEALTH)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"didnt_hurt_earth" percentComplete:100.0];
                }
                else if (_base.score == 20 && _base.health == INITIAL_HEALTH)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"didnt_destroy_earth" percentComplete:100.0];
                }
                else if (_base.score == 50 && _base.health == INITIAL_HEALTH)
                {
                    [[GCHelper defaultHelper] reportAchievementIdentifier:@"saved_earth" percentComplete:100.0];
                }
                maxEnemies++;
            }
        }
    }
    
    if (gameRunning && CGRectContainsPoint(_base.boundingBox, newBullet.positionInPoints))
    {
        [[OALSimpleAudio sharedInstance] playEffect:@"small_explosion.wav"];
        _base.health -= 10;
        _base.healthBar.scaleX -= .02;
        if (_base.health == 0)
        {
            [[GCHelper defaultHelper] reportAchievementIdentifier:@"destroyed_earth" percentComplete:100.0];
        }
    }
    
    //Check if player hit comet
    for (CCNode *comet in [_cometNode.children copy])
    {
        if (CGRectContainsPoint(comet.boundingBox, newBullet.positionInPoints))
        {
            CCLOG(@"Destroyed comet!");
            [comet removeFromParent];
            [[GCHelper defaultHelper] reportAchievementIdentifier:@"shot_comet" percentComplete:100.0];
            //TODO: Write code for achievement and powerups
        }
    }
    
//    //Check if player hit planet
//    for (CCNode *planet in _planetNode.children)
//    {
//        CCParticleSystem *fire = [CCBReader load:@"Fire"];
//        fire.positionInPoints = ;
//        [planet addChild:fire];
//    }
    
    if (!gameRunning)
    {
        CGPoint bulletLocation = newBullet.positionInPoints;
        CGPoint worldTouch = [self convertToWorldSpace:bulletLocation];
        CGPoint bulletNodeLocation = [gameOver convertToNodeSpace:worldTouch];
//        if (CGRectContainsPoint(_replayButton.boundingBox, bulletNodeLocation) || CGRectContainsPoint(_replayButton.boundingBox, [touch locationInWorld]))
//        {
//            CCScene *gameplay = [CCBReader loadAsScene:@"Gameplay"];
//            [[CCDirector sharedDirector] replaceScene:gameplay];
//        }
//        if (CGRectContainsPoint(gameOver.mainScreenButton.boundingBox, [touch locationInWorld]))
//        {
//            CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
//            [[CCDirector sharedDirector] replaceScene:mainScene];
//        }
    }
}

#pragma mark - Update Method
-(void)update:(CCTime)delta
{
    //timer for certain events
    timer += delta;
    
    //Accelerometer Data
    CMAccelerometerData *accelerometerData = _motionManager.accelerometerData;
    CMAcceleration acceleration = accelerometerData.acceleration;
    CGFloat newXPosition = _crosshair.position.x - ((acceleration.y - _calibY) * _sensitivity * delta);
    CGFloat newYPosition = _crosshair.position.y + ((acceleration.x - _calibX) * _sensitivity * delta);
    newXPosition = clampf(newXPosition, 0, self.contentSize.width);
    newYPosition = clampf(newYPosition, 0, self.contentSize.height);
    _crosshair.position = CGPointMake(newXPosition, newYPosition);
    
    
    if (gameRunning)
    {
        //Enemy Creation
        if ((timer >= 2) && (arc4random() % probability == 0) && ([_enemyNode.children count] < maxEnemies))
        {
            [self spawnEnemy];
        }
        
        //Remove enemies if there are too many
        else if ([_enemyNode.children count] >= MAX_ENEMIES)
        {
            CCLOG(@"Array full! Emptying array and increasing enemy frequency");
            //[_enemyNode removeAllChildren];
//            probability *= .5;
        }
        
        //Increase enemy spawn rate every ten enemies
        if (_base.score != 0 && _base.score % 10 == 0)
        {
//            probability *= .5;
        }
    
        //If enemy is touching base, reduce health
        for (Enemy *enemy in _enemyNode.children)
        {
            if (CGRectContainsPoint(_base.boundingBox, enemy.positionInPoints))
            {
                _base.health -= ENEMY_DAMAGE;
                _base.healthBar.scaleX -= .002;
                [enemy stopAllActions];
            }
        }
        
        //if health is 0, game over
        if (_base.health <= 0)
        {
            [[OALSimpleAudio sharedInstance] playEffect:@"large_explosion.wav"];
            [self gameOver];
        }
    }
    
    //Random chance to create comet on screen
    if (arc4random() % COMET_CHANCE == 0)
    {
        CCLOG(@"Comet passing!");
        CCNode *newComet = [CCBReader load:@"Comet"];
        [newComet setScale:.5];
        newComet.positionInPoints = ccp(self.contentSizeInPoints.width + 50, self.contentSizeInPoints.height + 50);
        CCAction *cometPath = [CCActionMoveTo actionWithDuration:1.5 position:ccp(-100, -100)];
        [newComet runAction:cometPath];
        [_cometNode addChild:newComet];
    }
    for (CCNode *comet in [_cometNode.children copy])
    {
        if (comet.positionInPoints.x == -100 && comet.positionInPoints.y == -100)
        {
            [comet removeFromParent];
        }
    }
    
//    //Random Chance for planet to pass by
//    if (arc4random() % PLANET_CHANCE == 0)
//    {
//        int val = arc4random() % 2;
//        CCNode *newPlanet;
//        CCAction *planetPath;
//        if (val == 0)
//        {
//            //Moon code
//            newPlanet = [CCBReader load:@"Moon"];
//            int ypos = arc4random() % ((int)self.contentSizeInPoints.height);
//            newPlanet.positionInPoints = ccp(-50, arc4random() % ypos);
//            planetPath = [CCActionMoveTo actionWithDuration:4 position:ccp(self.contentSizeInPoints.width + 50, ypos)];
//        }
//        else if (val == 1)
//        {
//            //Jupiter Code
//            newPlanet = [CCBReader load:@"Jupiter"];
//            int ypos = arc4random() % ((int)self.contentSizeInPoints.height);
//            newPlanet.positionInPoints = ccp(self.contentSizeInPoints.width + 100, arc4random() % ypos);
//            planetPath = [CCActionMoveTo actionWithDuration:4 position:ccp(-100, ypos)];
//        }
//        [newPlanet runAction:planetPath];
//        [_planetNode addChild:newPlanet];
//    }
    
}

#pragma mark - spawnEnemy Method

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
    if (newEnemy.positionInPoints.x > self.contentSizeInPoints.width/2)
    {
        [newEnemy setScaleX:-1.f];
    }
    [_enemyNode addChild:newEnemy];

}

#pragma mark - GameOver Method

-(void)gameOver
{
    gameRunning = false;
    [_enemyNode removeAllChildren];
    CCParticleSystem *explode = (CCParticleSystem *)[CCBReader load:@"LargeFire"];
    explode.positionInPoints = _base.positionInPoints;
    explode.autoRemoveOnFinish = true;
    [self addChild:explode];
    [_base removeFromParent];
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
    gameOver.position = ccp(.5, 0.5);
    [self addChild:gameOver];
}

@end