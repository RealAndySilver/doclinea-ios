//
//  FormLists.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormLists : NSObject
@property (strong, nonatomic) NSArray *specialtiesArray;
@property (strong, nonatomic) NSArray *citiesArray;
@property (strong, nonatomic) NSArray *ensuranceArray;
+(FormLists *)sharedInstance;
@end
