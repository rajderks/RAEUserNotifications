//
//  UserNotificationManager.m
//  Clinicards
//
//  Created by Roy Derks on 19/09/2017.
//  Copyright © 2017 Synappz BV. All rights reserved.
//

#if defined(DEBUG) && defined(DLog) == false
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#elif defined(DLog) == false
#   define DLog(...)
#endif



#import "RAEUserNotificationManager.h"

@interface RAEUserNotificationManager() <UNUserNotificationCenterDelegate>
{
    
}

@property(nonatomic,assign) UNNotificationPresentationOptions presentationOptions;
@property(nonatomic,strong) UNUserNotificationCenter *userNotificationCenter;


@end

@implementation RAEUserNotificationManager

#pragma mark Singleton Methods

+(id)sharedManager {
    static RAEUserNotificationManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [RAEUserNotificationManager new];
    });
    return sharedInstance;
}


-(instancetype)init
{
    self = [super init];
    if(self) {
        self.userNotificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        self.presentationOptions = UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert;
        self.userNotificationCenter.delegate = self;
    }
    return self;
}

#pragma mark Status

+(void)currentAuthorizationStatus:(void(^ _Nullable )(UNAuthorizationStatus status))resultBlock
{
    
    UNUserNotificationCenter *center = [RAEUserNotificationManager sharedManager].userNotificationCenter;
    [center getNotificationSettingsWithCompletionHandler:^void(UNNotificationSettings * _Nonnull settings) {
        if(resultBlock) {
            resultBlock(settings.authorizationStatus);
        }
    }];
}

#pragma mark Registration

+(void)registerForNotifications:(void(^ _Nullable )(BOOL authorizationGranted))resultBlock
{
    [RAEUserNotificationManager currentAuthorizationStatus:^(UNAuthorizationStatus status) {
        if(status == UNAuthorizationStatusNotDetermined) {
            UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound;
            [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
                if(error) {
                    DLog(@"%@", error.localizedDescription);
                }
                if(resultBlock) {
                    resultBlock(granted);
                }
            }];
        } else if(status == UNAuthorizationStatusAuthorized) {
            if(resultBlock) {
                resultBlock(true);
            }
        } else if(resultBlock) {
            resultBlock(false);
        }
    }];
}

#pragma mark Notifications

+(void)pendingNotificationsRequests:(void(^ _Nullable )(NSArray<UNNotificationRequest *> * _Nonnull requests))block
{
    [RAEUserNotificationManager currentAuthorizationStatus:^(UNAuthorizationStatus status) {
        if(status == UNAuthorizationStatusAuthorized) {
            [[UNUserNotificationCenter currentNotificationCenter] getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
                if(block) {
                    block(requests);
                }
            }];
        } else if(block) {
            block(@[]);
        }
    }];
}

+(void)deliveredNotifications:(void(^ _Nullable )(NSArray<UNNotification *> * _Nonnull notifications))block
{
    [RAEUserNotificationManager currentAuthorizationStatus:^(UNAuthorizationStatus status) {
        if(status == UNAuthorizationStatusAuthorized) {
            [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^void(NSArray<UNNotification *> * _Nonnull notifications) {
                if(block) {
                    block(notifications);
                }
            }];
        } else if(block) {
            block(@[]);
        }
    }];
}

#pragma mark APNS
+(void)applicationDidRegisterForRemoteNotifications:(NSData * _Nonnull )deviceToken
{
    NSString *pushToken = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

#pragma mark UNUserNotificationCenterDelegate

//Determines how to notify the user when the app is in the foreground whilst receiving a notification.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    completionHandler(self.presentationOptions);
}

//User tapped on notification whether or not the application is in foreground. Fires when app returns to foreground.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler
{
    completionHandler();
    [RAEUserNotificationManager deliveredNotifications:^(NSArray<UNNotification *> * _Nonnull notifications) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = notifications.count;
    }];
}

@end
