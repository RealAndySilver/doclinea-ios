//
//  Studie.h
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Studie : NSObject <NSCoding>
@property (strong, nonatomic) NSString *instituteName;
@property (strong, nonatomic) NSString *degree;
@property (strong, nonatomic) NSString *startYear;
@property (strong, nonatomic) NSString *endYear;
@property (strong, nonatomic) NSString *highlights;
-(instancetype)initWithStudieInfo:(NSDictionary *)dictionary;
-(NSDictionary *)studieAsDictionary;
@end
