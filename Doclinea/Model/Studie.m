//
//  Studie.m
//  Doclinea
//
//  Created by Developer on 9/10/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "Studie.h"

@implementation Studie

-(instancetype)initWithStudieInfo:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _instituteName = dictionary[@"institute_name"];
        _degree = dictionary[@"degree"];
        _startYear = dictionary[@"year_start"];
        _endYear = dictionary[@"year_end"];
        _highlights = dictionary[@"hilights"];
    }
    return self;
}

-(NSDictionary *)studieAsDictionary {
    NSString *institute = nil;
    if (self.instituteName) {
        institute =self.instituteName;
    } else {
        institute = @"";
    }
    
    NSString *degree = nil;
    if (self.degree) {
        degree = self.degree;
    } else {
        degree = @"";
    }
    
    NSString *startYear = nil;
    if (self.startYear) {
        startYear = self.startYear;
    } else {
        startYear = @"";
    }
    
    NSString *endYear = nil;
    if (self.endYear) {
        endYear = self.endYear;
    } else {
        endYear = @"";
    }
    
    NSString *highlights = nil;
    if (self.highlights) {
        highlights = self.highlights;
    } else {
        highlights = @"";
    }
    
    NSDictionary *studieDic = @{@"institute_name" : institute,
                                @"degree" : degree,
                                @"year_start" : startYear,
                                @"year_end" : endYear,
                                @"hilights" : highlights};
    return studieDic;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _instituteName = [aDecoder decodeObjectForKey:@"institute_name"];
        _degree = [aDecoder decodeObjectForKey:@"degree"];
        _startYear = [aDecoder decodeObjectForKey:@"year_start"];
        _endYear = [aDecoder decodeObjectForKey:@"year_end"];
        _highlights = [aDecoder decodeObjectForKey:@"highlights"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_instituteName forKey:@"institute_name"];
    [aCoder encodeObject:_degree forKey:@"degree"];
    [aCoder encodeObject:_startYear forKey:@"year_start"];
    [aCoder encodeObject:_endYear forKey:@"year_end"];
    [aCoder encodeObject:_highlights forKey:@"highlights"];
}

@end
