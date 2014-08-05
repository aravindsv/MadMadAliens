//
//  Base.m
//  Shooter
//
//  Created by Aravind Vadali on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Base.h"

@implementation Base
{
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_healthLabel;
}

-(void)update:(CCTime)delta
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    _healthLabel.string = [NSString stringWithFormat:@"Health: %d", _health];
    if (_health % 20 == 0)
    {
        CCLOG(@"Added fire particle");
        CCParticleSystem *_fire = (CCParticleSystem *)[CCBReader load:@"Fire"];
        _fire.position = ccp(arc4random() % (int)self.contentSizeInPoints.width, arc4random() % (int)self.contentSizeInPoints.height);
        [self addChild:_fire];
    }
}

@end
