//
//  Insurance.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Insurance.h"
#import "InsuranceType.h"

@implementation Insurance

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _identifier = dictionary[@"_id"];
        _email = dictionary[@"email"];
        _name = dictionary[@"name"];
        _logoURL = dictionary[@"logo"][@"image_url"];
        
        NSArray *typeListArray = dictionary[@"type_list"];
        NSMutableArray *tempTypeList = [[NSMutableArray alloc] init];
        for (int i = 0; i < typeListArray.count; i++) {
            NSDictionary *typeDic = typeListArray[i];
            InsuranceType *insuranceType = [[InsuranceType alloc] initWithDictionary:typeDic];
            if (insuranceType) {
                [tempTypeList addObject:insuranceType];
            }
        }
        _typeList = tempTypeList;
    }
    return self;
}

@end
