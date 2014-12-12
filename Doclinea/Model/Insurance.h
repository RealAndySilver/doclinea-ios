//
//  Insurance.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Insurance : NSObject
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *logoURL;
@property (strong, nonatomic) NSArray *typeList;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
