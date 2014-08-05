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
    CCParticleSystem *_fire;
    CCParticleSystem *_fire2;
}

-(void)didLoadFromCCB
{
//    _health = 100;
}

-(void)update:(CCTime)delta
{
    _scoreLabel.string = [NSString stringWithFormat:@"%d",_score];
    _healthLabel.string = [NSString stringWithFormat:@"Health: %d", _health];
    if (_health == 250 && _fire == nil)
    {
        CCLOG(@"Added fire particle");
        [_fire removeFromParent];
        _fire = (CCParticleSystem *)[CCBReader load:@"Fire"];
//        _fire.position = ccp(arc4random() % (int)self.contentSizeInPoints.width, arc4random() % (int)self.contentSizeInPoints.height);
        _fire.positionType = CCPositionTypeNormalized;
        _fire.position = ccp(.5, .5);
        [self addChild:_fire];
    }
    if (_health == 100 && _fire2 == nil)
    {
        CCLOG(@"Added fire particle");
        //[_fire removeFromParent];
        _fire2 = (CCParticleSystem *)[CCBReader load:@"Fire"];
        //        _fire.position = ccp(arc4random() % (int)self.contentSizeInPoints.width, arc4random() % (int)self.contentSizeInPoints.height);
        _fire2.positionType = CCPositionTypeNormalized;
        _fire2.position = ccp(.5, .75);
        [self addChild:_fire2];
    }
    if (_health == 1)
    {
        CCLOG(@"Added LARGE fire particle");
        [_fire removeFromParent];
        [_fire2 removeFromParent];
        _fire = (CCParticleSystem *)[CCBReader load:@"LargeFire"];
        _fire.positionType = CCPositionTypeNormalized;
        _fire.position = ccp(.5, .5);
        [self addChild:_fire];
    }
}

@end
