//
//  SharedUser.m
//  Doclinea
//
//  Created by Developer on 16/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "SharedUser.h"

@implementation SharedUser

+(instancetype)sharedUser {
    static SharedUser *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[SharedUser alloc] init];
        });
    }
    return shared;
}

-(User *)getSavedUser {
    NSData *encodedData = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    User *user = [NSKeyedUnarchiver unarchiveObjectWithData:encodedData];
    return user;
}

@end
