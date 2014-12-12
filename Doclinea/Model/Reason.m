//
//  Reason.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Reason.h"

@implementation Reason

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _name = dictionary[@"reason"];
    }
    return self;
}

@end
