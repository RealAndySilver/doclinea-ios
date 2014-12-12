//
//  FormListsParser.h
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FormListsParser : NSObject
+(FormListsParser *)sharedInstance;
-(NSArray *)parsedPracticesArrayFromArray:(NSArray *)practicesArray;
-(NSArray *)parsedInsurancesListFromArray:(NSArray *)insurancesArray;
@end
