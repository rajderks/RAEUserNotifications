//
//  AppDelegate.m
//  RAEUserNotifications
//
//  Created by Roy Derks on 20/09/2017.
//  Copyright © 2017 RAE. All rights reserved.
//

#import "AppDelegate.h"
#import "RAEUserNotificationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self authorizeNotifications];
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [RAEUserNotificationManager deliveredNotifications:^(NSArray<UNNotification *> * _Nonnull notifications) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication sharedApplication].applicationIconBadgeNumber = notifications.count;
        });
    }];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark Notifications

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [RAEUserNotificationManager applicationDidRegisterForRemoteNotifications:deviceToken];
}

-(void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    
}

-(void)authorizeNotifications
{
    [RAEUserNotificationManager registerForNotifications:^(BOOL authorizationGranted) {
        if(authorizationGranted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }
    }];
}

@end
