//
//  Enemy.m
//  Shooter
//
//  Created by Aravind Vadali on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"

//TODO: vary enemy motion

@implementation Enemy
{
    CCSprite *_enemySprite;
}


-(void)didLoadFromCCB
{
    self.zOrder = 10;
    _rand = arc4random() % 7;
    NSString *spriteName = [NSString stringWithFormat:@"Art/ghost%d.png", _rand];
    _enemySprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:spriteName];
}

@end