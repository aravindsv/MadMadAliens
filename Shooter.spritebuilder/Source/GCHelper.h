//
//  GCHelper.h
//  Shooter
//
//  Created by Aravind Vadali on 8/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GCHelper : NSObject {
    BOOL gameCenterAvailable;
    BOOL userAuthenticated;
}

@property (assign, readonly) BOOL gameCenterAvailable;

@property (nonatomic, strong) NSMutableDictionary *achievementsDictionary;

+ (GCHelper *)sharedInstance;
- (void)authenticateLocalUser;
- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier;
- (void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;


+ (GCHelper*)defaultHelper;


@end