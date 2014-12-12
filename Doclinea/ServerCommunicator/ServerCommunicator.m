//
//  ServerCommunicator.m
//  WebConsumer
//
//  Created by Andres Abril on 19/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ServerCommunicator.h"
//#define ENDPOINT @"http://192.241.187.135:1414/api_1.0"
//#define ENDPOINT @"http://192.168.1.109:1414/api_1.0"
#define ENDPOINT @"http://192.168.1.129:1414/api_1.0"

@implementation ServerCommunicator
@synthesize tag,delegate;
-(id)init {
    self = [super init];
    if (self)
    {
        tag = 0;
    }
    return self;
}

-(void)callServerWithGETMethod:(NSString*)method andParameter:(NSString*)parameter{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@",ENDPOINT,method,parameter]];
    if ([parameter isEqualToString:@""]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
    }
    NSLog(@"URL : %@", [url description]);
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    //NSMutableURLRequest *theRequest = [self getHeaderForUrl:url];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
}
-(void)callServerWithPOSTMethod:(NSString *)method andParameter:(NSString *)parameter httpMethod:(NSString *)httpMethod{
    parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
    NSLog(@"URLLL: %@, Parameter: %@", url, parameter);
    NSMutableURLRequest *theRequest;
    theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:httpMethod];
    NSData *data=[NSData dataWithBytes:[parameter UTF8String] length:[parameter length]];
    [theRequest setHTTPBody: data];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                        if(error == nil){
                                                            NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                            [self.delegate receivedDataFromServer:dictionary
                                                                                   withMethodName:method];
                                                        }
                                                        else{
                                                            [self.delegate serverError:error];
                                                        }
                                                    }];
    [dataTask resume];
    NSLog(@"URL : %@ \n Body: %@", [url description],[[NSString alloc] initWithData:[theRequest HTTPBody] encoding:NSUTF8StringEncoding]);
}

-(void)callServerWithPOSTMethod:(NSString *)method andData:(NSData *)data {
    //parameter=[parameter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //parameter=[parameter stringByExpandingTildeInPath];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",ENDPOINT,method]];
    NSMutableURLRequest *theRequest;
    theRequest = [self getHeaderForUrl:url];
    //[theRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: data];
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    defaultConfigObject.timeoutIntervalForRequest = 60.0;
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultConfigObject
                                                                 delegate:nil
                                                            delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:theRequest
                                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                                                            if(error == nil){
                                                                NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                                                [self.delegate receivedDataFromServer:dictionary
                                                                                       withMethodName:method];
                                                            }
                                                            else{
                                                                [self.delegate serverError:error];
                                                            }
                                                        }];
    [dataTask resume];
}

#pragma mark - http header
-(NSMutableURLRequest*)getHeaderForUrl:(NSURL*)url{
   
    /*NSString *time = [IAmCoder dateString];
    NSString *email = [UserInfo sharedInstance].email;
    NSString *authString;
    NSString *token;
    if ([UserInfo sharedInstance].sendEmailAsAuth) {
        authString = email;
        token = [NSString stringWithFormat:@"%@~~%@", email, time];
    } else {
        authString = [NSString stringWithFormat:@"%@:%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password];
        token = [NSString stringWithFormat:@"%@~%@~%@", [UserInfo sharedInstance].userName, [UserInfo sharedInstance].password, time];
    }
    NSLog(@"authstring: %@", authString);
    
    NSLog(@"token sin hash: %@", token);
    NSString *hashToken = [IAmCoder hash256:token];
    
    NSString *langID = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSLog(@"email: %@", email);
    NSLog(@"auth: %@", authString);
    NSLog(@"TS70: %@", time);
    NSLog(@"token: %@", hashToken);
    NSLog(@"language: %@", langID);
    NSString *version =[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    NSLog(@"Version Actual del proyecto: %@", version);
    NSString *currentDevice = [UIDevice currentDevice].model;
    NSLog(@"Dispositivo: %@", currentDevice);
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    NSLog(@"Version: %@", systemVersion);
    NSString *userAgent = [NSString stringWithFormat:@"EKOOBOT3D/%@ (%@; iOS; %@)", version, currentDevice, systemVersion];
    NSLog(@"User Agent string: %@", userAgent);*/
    
    NSString *boundary = @"------VohpleBoundary4QuqLuM1cE5lMwCy";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    //[theRequest setValue:@"application/json" forHTTPHeaderField:@"accept"];
    [theRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    return theRequest;
}

@end
