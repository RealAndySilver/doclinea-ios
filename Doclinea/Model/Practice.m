//
//  Practice.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Practice.h"
#import "Reason.h"

@implementation Practice

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _name = dictionary[@"name"];
        
        NSArray *reasonsArray = dictionary[@"reason_list"];
        NSMutableArray *tempReasonsArray = [[NSMutableArray alloc] init];
        if (reasonsArray) {
            for (int i = 0; i < reasonsArray.count; i++) {
                NSDictionary *reasonDic = reasonsArray[i];
                Reason *reason = [[Reason alloc] initWithDictionary:reasonDic];
                [tempReasonsArray addObject:reason];
            }
            _reasonList = tempReasonsArray;
        }
    }
    return self;
}

@end
