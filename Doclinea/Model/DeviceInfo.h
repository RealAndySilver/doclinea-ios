//
//  DeviceInfo.h
//  Doclinea
//
//  Created by Developer on 8/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject
+(DeviceInfo *)sharedInstance;
@property (strong, nonatomic) NSString *deviceToken;
@end
