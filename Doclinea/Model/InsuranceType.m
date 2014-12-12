//
//  InsuranceType.m
//  Doclinea
//
//  Created by Developer on 12/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "InsuranceType.h"

@implementation InsuranceType

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _category = dictionary[@"category"];
        _name = dictionary[@"name"];
    }
    return self;
}

@end
