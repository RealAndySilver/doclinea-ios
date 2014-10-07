//
//  Localidad.h
//  Doclinea
//
//  Created by Developer on 3/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Localidad : NSObject
@property (assign, nonatomic) float latitude;
@property (assign, nonatomic) float longitude;
@property (strong, nonatomic) NSString *name;
-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
@end
