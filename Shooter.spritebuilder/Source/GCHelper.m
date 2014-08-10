//
//  GCHelper.m
//  Shooter
//
//  Created by Aravind Vadali on 8/9/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "GCHelper.h"

@implementation GCHelper

@synthesize gameCenterAvailable;

#pragma mark Initialization

static GCHelper *sharedHelper = nil;
+ (GCHelper *) sharedInstance {
    if (!sharedHelper) {
        sharedHelper = [[GCHelper alloc] init];
    }
    return sharedHelper;
}

- (BOOL)isGameCenterAvailable {
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (id)init {
    if ((self = [super init])) {
        gameCenterAvailable = [self isGameCenterAvailable];
        if (gameCenterAvailable) {
            NSNotificationCenter *nc =
            [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}

- (void)authenticationChanged {
    
    if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
        NSLog(@"Authentication changed: player authenticated.");
        userAuthenticated = TRUE;
    } else if (![GKLocalPlayer localPlayer].isAuthenticated && userAuthenticated) {
        NSLog(@"Authentication changed: player not authenticated");
        userAuthenticated = FALSE;
    }
    
}


#pragma mark User functions

- (void)authenticateLocalUser {
    
    if (!gameCenterAvailable) return;
    
    NSLog(@"Authenticating local user...");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        //[[GKLocalPlayer localPlayer] authenticateHandler:nil];
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:nil];
    } else {
        NSLog(@"Already authenticated!");
    }
}


- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)identifier
{
    GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: identifier];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    [GKScore reportScores:@[scoreReporter] withCompletionHandler:^(NSError *error) {
        if (error == nil) {
            NSLog(@"Score reported successfully!");
        } else {
            NSLog(@"Unable to report score!");
        }
    }];
}

static GCHelper *_sharedHelper = nil;


+ (GCHelper*)defaultHelper {
    
    // dispatch_once will ensure that the method is only called once (thread-safe)
    
    static dispatch_once_t pred = 0;
    
    dispatch_once(&pred, ^{
        
        _sharedHelper = [[GCHelper alloc] init];
        
    });
    
    return _sharedHelper;
    
}

- (void)loadAchievements

{
    
    self.achievementsDictionary = [[NSMutableDictionary alloc] init];
    
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        
        if (error != nil)
            
        {
            
            // Handle the error.
            
            NSLog(@"Error while loading achievements: %@", error.description);
            
        }
        
        else if (achievements != nil)
        
        {
            
            // Process the array of achievements.
            
            for (GKAchievement* achievement in achievements)
                
                self.achievementsDictionary[achievement.identifier] = achievement;
            
        }
        
    }];
    
}

- (GKAchievement*)getAchievementForIdentifier: (NSString*) identifier

{
    
    GKAchievement *achievement = [self.achievementsDictionary objectForKey:identifier];
    
    if (achievement == nil)
        
    {
        
        achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
        
        self.achievementsDictionary[achievement.identifier] = achievement;
        
    }
    
    return achievement;
    
}

- (void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    GKAchievement *achievement = [self getAchievementForIdentifier:identifier];
    if (achievement && achievement.percentComplete != 100.0) {
        achievement.percentComplete = percent;
        achievement.showsCompletionBanner = YES;
        
        [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"Error while reporting achievement: %@", error.description);
            }
        }];
    }
}



- (void)resetAchievements
{
    // Clear all locally saved achievement objects.
    self.achievementsDictionary = [[NSMutableDictionary alloc] init];
    // Clear all progress saved on Game Center.
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error)
     {
         if (error != nil) {
             // handle the error.
             NSLog(@"Error while reseting achievements: %@", error.description);
             
         }
     }];
}


@end