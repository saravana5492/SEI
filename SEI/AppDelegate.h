//
//  AppDelegate.h
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>
#import "PayPalMobile.h"


#define showProgress(a)             [AppDelegate showProgressForState:a]

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, strong) CLLocationManager *locationManager;
//@property (nonatomic, strong) CLLocation *location;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSMutableDictionary *chatCounts;


- (void)saveContext;
-(void)showProgress:(BOOL)staus;
+(void) showProgressForState:(BOOL)status;


@end

//get_unread_msg_count.php
//chat_box_contacts.php
//makemsgread.php
