//
//  Practice.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Practice : NSObject
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *reasonList;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
