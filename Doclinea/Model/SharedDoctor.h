//
//  SharedDoctor.h
//  Doclinea
//
//  Created by Developer on 6/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Doctor.h"

@interface SharedDoctor : NSObject
+(SharedDoctor *)sharedDoctor;
-(Doctor *)getSavedDoctor;
@end
