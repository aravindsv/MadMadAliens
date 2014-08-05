//
//  Bullet.m
//  Shooter
//
//  Created by Aravind Vadali on 8/4/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Bullet.h"

@implementation Bullet
{
    float timer;
}

-(void)didLoadFromCCB
{
    self.physicsBody.collisionType = @"Bullet";
    self.zOrder = 9001;
}

-(void)update:(CCTime)delta
{
    timer += delta;
    if (timer >= .75)
    {
        [self removeFromParentAndCleanup:YES];
    }
}

@end
