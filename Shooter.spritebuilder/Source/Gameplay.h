//
//  Gameplay.h
//  Shooter
//
//  Created by Aravind Vadali on 8/5/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "CCScene.h"

@interface Gameplay : CCScene

@property float calibX;
@property float calibY;

-(void)setCalibrationX:(float)xVal andY:(float)yVal;

@end
