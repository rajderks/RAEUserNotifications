//
//  UserNotificationManager.h
//  Clinicards
//
//  Created by Roy Derks on 19/09/2017.
//  Copyright © 2017 Synappz BV. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import <UIKit/UIKit.h>

@interface RAEUserNotificationManager : NSObject



/**
 Shared instance; delegate of UNUserNotificationCenter

 @return shared instance
 */
+(instancetype _Nonnull)sharedManager;

/**
 Returns the pending (local) notification requests.

 @param block a block containing an array of pending requests
 */
+(void)pendingNotificationsRequests:(void(^ _Nullable )(NSArray<UNNotificationRequest *> * _Nonnull requests))block;

/**
 Returns the unprocessed delivered notifications.
 These are the notifications that are shown in the notifications panel.

 @param block a block with an array of the unprocessed delivered notifications
 */
+(void)deliveredNotifications:(void(^ _Nullable )(NSArray<UNNotification *> * _Nonnull notifications))block;


/**
 Registers for notifications.
 If authorization is granted you may call application:registerForRemoteNotifications

 @param resultBlock a block with a bool parameter whether or not the user has authorized notifications
 */
+(void)registerForNotifications:(void(^ _Nullable )(BOOL authorizationGranted))resultBlock;


/**
 Call this from application:didRegisterForRemoteNotifications
 
 @param deviceToken the devicetoken
 */
+(void)applicationDidRegisterForRemoteNotifications:(NSData * _Nonnull)deviceToken;

@end
