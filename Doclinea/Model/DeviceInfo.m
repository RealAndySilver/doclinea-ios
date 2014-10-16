//
//  DeviceInfo.m
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "DeviceInfo.h"

@implementation DeviceInfo

+(DeviceInfo *)sharedInstance {
    static DeviceInfo *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[DeviceInfo alloc] init];
        });
    }
    return shared;
}

@end
