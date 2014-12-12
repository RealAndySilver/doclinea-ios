//
//  Reason.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Reason : NSObject
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *name;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
