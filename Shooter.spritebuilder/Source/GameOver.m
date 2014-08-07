//
//  GameOver.m
//  Shooter
//
//  Created by Aravind Vadali on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GameOver.h"
#import "Gameplay.h"

@implementation GameOver
{
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highscoreLabel;
    
    int score;
    int highScore;
}

-(void)didLoadFromCCB
{
}

-(void)replay
{
    NSNumber *xCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"xCalib"];
    NSNumber *yCalib = [[NSUserDefaults standardUserDefaults] objectForKey:@"yCalib"];
    CCScene *gameplay = (Gameplay *)[CCBReader loadAsScene:@"Gameplay"];
    Gameplay *gameLevel = gameplay.children[0];
    [gameLevel setCalibrationX:[xCalib floatValue] andY:[yCalib floatValue]];
    [[CCDirector sharedDirector] replaceScene:gameplay];
}

-(void)setScore:(int)curScore andHighscore:(int)curHighscore
{
    score = curScore;
    highScore = curHighscore;
    
    _scoreLabel.string = [NSString stringWithFormat:@"Score: %d", score];
    _highscoreLabel.string = [NSString stringWithFormat:@"High Score: %d", highScore];
}

@end