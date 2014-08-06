//
//  Enemy.m
//  Shooter
//
//  Created by Aravind Vadali on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy
{
    CCSprite *_enemySprite;
}


-(void)didLoadFromCCB
{
    self.zOrder = 10;
    int rand = arc4random() % 7;
    NSString *spriteName = [NSString stringWithFormat:@"Art/ghost%d.png", rand];
    _enemySprite.spriteFrame = [CCSpriteFrame frameWithImageNamed:spriteName];
}


@end
