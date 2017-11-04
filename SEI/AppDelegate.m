//
//  AppDelegate.m
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
// com.smitiv.sei

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "MBProgressHUD.h"
#import <UserNotifications/UserNotifications.h>
#import "IQKeyboardManager.h"
#import "singleChatVC.h"
#import "singleChatVC.h"
#import "SlideAlertiOS7.h"
#import "AFNetworking.h"


@import GoogleMaps;
@import GooglePlaces;

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface AppDelegate ()<CLLocationManagerDelegate, UNUserNotificationCenterDelegate>
{
    MBProgressHUD *HUD;
    NSMutableArray *chats;
    int totalMessages;
}

@end

@implementation AppDelegate

@synthesize locationManager;
@synthesize location;
@synthesize token;
@synthesize chatCounts;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUnreadMessageCountforFriendId) name:@"LogedInSuccessfully" object:nil];
    
    // Facebook Login ***
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];

    
    // Device Token ***
#if TARGET_IPHONE_SIMULATOR
    token = @"simulator";
#endif
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],@"firstLaunch",nil]];

    
    // Activity Indicator **
    HUD = [[MBProgressHUD alloc] initWithView:self.window];

    // CLLocationManager to get current lat long value ***
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 20;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [GMSServices provideAPIKey:@"AIzaSyDtKYr7BcB05sGJBghwUCDtLEbiv7-t9Os"];
    [GMSPlacesClient provideAPIKey:@"AIzaSyBCuM2fZvUcKEevT7quqzTFVXI6trnLBrQ"];

    
    [PayPalMobile initializeWithClientIdsForEnvironments:@{PayPalEnvironmentProduction :@"test", PayPalEnvironmentSandbox: @"AcKIEyLyReKiLhDBTEOarFZ8SAEXz-s9-GOUM7g49D_z1UUfuBg5AvS9c7kZkEkEKZHtZ4yNbnoxuM4B"}];
    
    [self registerForRemoteNotification];
    
    //[UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    return YES;
}

- (void)registerForRemoteNotification {
    if(SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            if( !error ){
                NSLog(@"Push Notif iOS 10 can run");
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            } else {
                NSLog(@"Push Notif iOS 10 error %@: ", error);
            }
        }];
    }
    else {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
#if TARGET_IPHONE_SIMULATOR
    token = @"simulator";
#else
    token = [deviceToken description];
    token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"My device is: %@", token);
#endif
     NSLog(@"My device is: %@", token);
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"deviceToken"];

}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Did Fail to Register for Remote Notifications");
    NSLog(@"%@, %@", error, error.localizedDescription);
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void(^)())completionHandler
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"Did Receive Notification called!!");
    //[UIApplication sharedApplication].applicationIconBadgeNumber = [[[userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];

    /*  if (application.applicationState == UIApplicationStateActive) {
     // Nothing to do if applicationState is Inactive, the iOS already displayed an alert view.
     UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Did receive a Remote Notification" message:[NSString stringWithFormat:@"Your App name received this notification while it was running:\n%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
     [alertView show];
     } else {
     
     } */
    
    [self getUnreadMessageCountforFriendId];
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    UIViewController *lastViewController = topController.presentedViewController.presentedViewController;
    
    if ([[lastViewController class] isEqual:[singleChatVC class]]) {
        NSLog(@"Inside ChatView");
        NSDictionary *dict = @{@"alert" : userInfo[@"aps"][@"alert"], @"facebookId" : userInfo[@"person"][@"friendid"], @"name" : userInfo[@"person"][@"name"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageRecievedInChatScreen" object:dict];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecievedMessageinChatList" object:nil];
        //[[SlideAlertiOS7 sharedSlideAlert] showSlideAlertViewWithHighDurationWithStatus:@"Failre" withText:[NSString stringWithFormat:@"You have a new message from %@",userInfo[@"person"][@"name"]]];
    }
}


#pragma mark - UNUserNotificationCenter Delegate // >= iOS 10

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"User Info Will present = %@",notification.request.content.userInfo);
    
    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge | UNNotificationPresentationOptionSound);
    
    [self getUnreadMessageCountforFriendId];
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    UIViewController *lastViewController = topController.presentedViewController.presentedViewController;
    
    if ([[lastViewController class] isEqual:[singleChatVC class]]) {
        NSLog(@"Inside ChatView");
        NSDictionary *dict = @{@"alert" : notification.request.content.userInfo[@"aps"][@"alert"], @"facebookId" : notification.request.content.userInfo[@"person"][@"friendid"], @"name" : notification.request.content.userInfo[@"person"][@"name"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageRecievedInChatScreen" object:dict];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecievedMessageinChatList" object:nil];
        //[[SlideAlertiOS7 sharedSlideAlert] showSlideAlertViewWithHighDurationWithStatus:@"Failre" withText:[NSString stringWithFormat:@"You have a new message from %@",notification.request.content.userInfo[@"person"][@"name"]]];
    }
    
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
    
    NSLog(@"User Info Did Receive = %@",response.notification.request.content.userInfo);
    
    completionHandler();
    
    //[UIApplication sharedApplication].applicationIconBadgeNumber = [[[response.notification.request.content.userInfo objectForKey:@"aps"] objectForKey: @"badgecount"] intValue];
    
    
    [self getUnreadMessageCountforFriendId];
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController.presentedViewController;
    UIViewController *lastViewController = topController.presentedViewController.presentedViewController;
    
    if ([[lastViewController class] isEqual:[singleChatVC class]]) {
        NSLog(@"Inside ChatView");
        NSDictionary *dict = @{@"alert" : response.notification.request.content.userInfo[@"aps"][@"alert"], @"facebookId" : response.notification.request.content.userInfo[@"person"][@"friendid"], @"name" : response.notification.request.content.userInfo[@"person"][@"name"]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MessageRecievedInChatScreen" object:dict];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RecievedMessageinChatList" object:nil];
        //[[SlideAlertiOS7 sharedSlideAlert] showSlideAlertViewWithHighDurationWithStatus:@"Failre" withText:[NSString stringWithFormat:@"You have a new message from %@",response.notification.request.content.userInfo[@"person"][@"name"]]];
    }
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [self getUnreadMessageCountforFriendId];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


- (void)getUnreadMessageCountforFriendId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults stringForKey:@"ProfileID"]) {
        
        __block NSData *dataFromServer = nil;
        NSBlockOperation *downloadOperation = [[NSBlockOperation alloc] init];
        __weak NSBlockOperation *weakDownloadOperation = downloadOperation;
        
       [self getChatList];

        [[NSOperationQueue mainQueue] addOperation:downloadOperation];
    }
}

- (void)getChatList
{
    NSString  *urlPath    = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/chat_box_contacts.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"fb_id", nil];
    
    NSLog(@"Get chat list Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:urlPath parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Get chat list Response Data: %@", responseObject);
        showProgress(NO);
        
        if (responseObject) {
            if ([responseObject[@"status"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                if (responseObject[@"result"] != [NSNull null]) {
                    chats = responseObject[@"result"];
                    if (chats.count > 0) {
                          [self requestGetUnreadMessages];
                    }
                }
            }else{
            }
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Create topic Response error: %@", error);
    }];
}

- (void)requestGetUnreadMessages
{
    for (NSDictionary *dict in chats) {
        NSString * urlString = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/get_unread_msg_count.php"];
        NSURL * url = [NSURL URLWithString: urlString];
        
        NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL: url];
        [request1 setHTTPMethod:@"POST"];
        [request1 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *string = [NSString stringWithFormat:@"from_fb_id=%@&to_fb_id=%@",[defaults objectForKey:@"UserFbID"],dict[@"facebookid"]];
        NSLog(@"unread message alert = %@",string);
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
        
        request1.accessibilityValue = dict[@"facebookid"];
        request1.HTTPBody = data;
        [NSURLConnection sendAsynchronousRequest:request1
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data1, NSError *error)
         {
             
             NSDictionary * unreadMessages = nil;
             
             
             if([data1 length] >= 1) {
                 unreadMessages = [NSJSONSerialization JSONObjectWithData:data1 options: 0 error: nil];
                 
                 if(unreadMessages != nil) {
                     
                     if ([unreadMessages[@"status"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                         [[self chatCounts] setObject:[NSString stringWithFormat:@"%@",unreadMessages[@"unreadmessages_count"]] forKey:request1.accessibilityValue];
                         
                         totalMessages += [unreadMessages[@"unreadmessages_count"] integerValue];
                     }
                     else
                     {
                         
                     }
                     
                 }
             }
             
         }];
    }
    
    NSLog(@"Total received messages of the user: %d", totalMessages);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATECHATCOUNT" object:nil];
    
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"SEI"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    location = newLocation;
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
    location = [locations lastObject];
}

-(void)showProgress:(BOOL)staus{
    if (staus) {
        HUD.labelText = @"Loading...";
        [self.window addSubview:HUD];
        [HUD show:staus];
    }else{
        [HUD removeFromSuperview];
        [HUD hide:staus];
    }
}

+(void) showProgressForState:(BOOL)status{
    AppDelegate *appDel=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    [appDel showProgress:status];
}



@end
