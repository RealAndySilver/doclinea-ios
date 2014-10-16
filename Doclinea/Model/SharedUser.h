//
//  SharedUser.h
//  Doclinea
//
//  Created by Developer on 16/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;

@interface SharedUser : NSObject
-(User *)getSavedUser;
+(instancetype)sharedUser;
@end
