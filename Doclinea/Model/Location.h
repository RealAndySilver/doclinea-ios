//
//  Location.h
//  Doclinea
//
//  Created by Developer on 28/01/15.
//  Copyright (c) 2015 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject
@property (strong, nonatomic) NSString *latitude;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *locationAddress;
@property (strong, nonatomic) NSString *locationName;
@property (assign, nonatomic) BOOL parking;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
