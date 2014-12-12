//
//  FormListsParser.m
//  Doclinea
//
//  Created by Developer on 11/12/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "FormListsParser.h"
#import "Practice.h"
#import "Insurance.h"

@implementation FormListsParser

+(FormListsParser *)sharedInstance {
    static FormListsParser *shared = nil;
    if (!shared) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            shared = [[FormListsParser alloc] init];
        });
    }
    return shared;
}

-(NSArray *)parsedPracticesArrayFromArray:(NSArray *)practicesArray {
    NSMutableArray *tempPracticeArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < practicesArray.count; i++) {
        NSDictionary *practiceDic = practicesArray[i];
        Practice *practice = [[Practice alloc] initWithDictionary:practiceDic];
        [tempPracticeArray addObject:practice];
    }
    return tempPracticeArray;
}

-(NSArray *)parsedInsurancesListFromArray:(NSArray *)insurancesArray {
    NSMutableArray *tempInsurances = [[NSMutableArray alloc] init];
    for (int i = 0; i < insurancesArray.count; i++) {
        NSDictionary *insuranceDic = insurancesArray[i];
        Insurance *insurance = [[Insurance alloc] initWithDictionary:insuranceDic];
        if (insurance) {
            [tempInsurances addObject:insurance];
        }
    }
    return tempInsurances;
}

@end
