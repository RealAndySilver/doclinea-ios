//
//  AppDelegate.m
//  Doclinea
//
//  Created by Developer on 29/09/14.
//  Copyright (c) 2014 iAm Studio. All rights reserved.
//

#import "AppDelegate.h"
#import "DeviceInfo.h"
#import "NewPasswordView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //Register for remote notifications
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if (!url) {
        return NO;
    }
    
    NSString *urlString = [url absoluteString];
    NSLog(@"URL: %@", urlString);
    NSLog(@"*********************************************");
    NSLog(@"scheme: %@", [url scheme]);
    NSLog(@"host: %@", [url host]);
    NSLog(@"port: %@", [url port]);
    NSLog(@"path: %@", [url path]);
    NSLog(@"path components: %@", [url pathComponents]);
    NSLog(@"parameterString: %@", [url parameterString]);
    NSLog(@"query: %@", [url query]);
    NSLog(@"fragment: %@", [url fragment]);
    
    //NSString *tokenParamString = [url query];
    //NSString *token = [tokenParamString stringByReplacingOccurrencesOfString:@"token=" withString:@""];
    //NSLog(@"TOKEN: %@", token);
    NSDictionary *parametersDic = [self URLQueryParameters:url];
    NSLog(@"Parametros en el dic: %@", parametersDic);
    NSString *token = parametersDic[@"token"];
    NSString *userType = parametersDic[@"type"];
    NSString *requestType = parametersDic[@"request"];
    NSLog(@"TOKEN: %@", token);
    NSLog(@"USER TYPE: %@", userType);
    NSLog(@"REQUEST TYPE: %@", requestType);
    
    //Save strings in user defaults
    if ([requestType isEqualToString:@"new_password"]) {
        //The user is recovering the password
        [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"token"];
        [[NSUserDefaults standardUserDefaults] setObject:userType forKey:@"userType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self performSelector:@selector(showPasswordView) withObject:nil afterDelay:1.0];
    }
    return YES;
}

-(void)showPasswordView {
    NewPasswordView *newPasswordView = [[NewPasswordView alloc] initWithFrame:CGRectMake(20.0, self.window.bounds.size.height/2.0 - 100.0, self.window.frame.size.width - 40.0, 200.0)];
    [newPasswordView showInWindow:self.window];
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    NSLog(@"entreeeee");
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"entre aca tambieeeeeennnn");
    NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"content---%@", token);
    [DeviceInfo sharedInstance].deviceToken = token;
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Falle en registrarmeee: %@", [error localizedDescription]);
}

- (NSDictionary *)URLQueryParameters:(NSURL *)URL
{
    NSString *queryString = [URL query];
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    NSArray *parameters = [queryString componentsSeparatedByString:@"&"];
    for (NSString *parameter in parameters)
    {
        NSArray *parts = [parameter componentsSeparatedByString:@"="];
        if ([parts count] > 1)
        {
            NSString *key = [parts[0] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *value = [parts[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            result[key] = value;
        }
    }
    return result;
}

@end
