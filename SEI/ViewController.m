//
//  ViewController.m
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "ViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "homePageVC.h"
#import "AppDelegate.h"
#import "AFNetworking.h"


@interface ViewController ()
{
    NSString *userName;
    NSString *userFbId;
    NSString *userProfileImg;
    NSString *userEmail;
    NSString *deviceToken;
    BOOL isAlreadyLogin;
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSLog(@"Login Status: %d", [[NSUserDefaults standardUserDefaults] boolForKey:@"ISUserLogined"]);
    NSLog(@"User Email: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"]);
    
    // View design ***
    _logInBtnView.layer.cornerRadius = 3.0f;
    _leftDot.layer.masksToBounds = YES;
    _leftDot.layer.cornerRadius = 4.0f;
    _rightDot.layer.masksToBounds = YES;
    _rightDot.layer.cornerRadius = 4.0f;
    _centerDot.layer.masksToBounds = YES;
    _centerDot.layer.cornerRadius = 6.0f;
    
    //Unique device id ***
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    deviceToken = [[currentDevice identifierForVendor] UUIDString];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"ISUserLogined"] == YES)
    {
        NSLog(@"Logged In");
        isAlreadyLogin = YES;
        [self moveToHome];
    }
    else
    {
        NSLog(@"Not Logged In");
        isAlreadyLogin = NO;
    }
}


- (IBAction)loginWithFB:(id)sender {
    
    showProgress(YES);

    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
    [FBSDKAccessToken setCurrentAccessToken:nil];
    [FBSDKProfile setCurrentProfile:nil];
    
    login.loginBehavior = FBSDKLoginBehaviorWeb;
    
    
    [login logInWithReadPermissions:@[@"public_profile", @"email", @"user_friends", @"user_birthday"] handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
     {
         if (error)
         {
             showProgress(NO);
             NSLog(@"Process error %@",error.localizedDescription);
         }
         else if (result.isCancelled)
         {
             showProgress(NO);
             NSLog(@"Cancelled");
         }
         else
         {
             if ([result.grantedPermissions containsObject:@"email"])
             {
                 NSLog(@"Facebook Result is:%@",result);
                 if ([FBSDKAccessToken currentAccessToken])
                 {
                     [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"first_name, last_name, picture.type(large), email, name, id, gender, birthday"}]
                      startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id fbResult, NSError *error)
                      {
                          showProgress(NO);
                          if (!error)
                          {
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"email"] forKey:@"UserEmail"];
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"first_name"] forKey:@"UserName"];
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"name"] forKey:@"UserFullName"];
                              NSDictionary *picture =fbResult[@"picture"];
                              NSDictionary *data = picture[@"data"];
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"id"] forKey:@"UserFbID"];
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"id"]  forKey:@"ProfileID"];
                              
                              [[NSUserDefaults standardUserDefaults] setValue:fbResult[@"birthday"] forKey:@"Userdob"];
                              [[NSUserDefaults standardUserDefaults] setValue:data[@"url"] forKey:@"UserProfilePic"];
                              [[NSUserDefaults standardUserDefaults] synchronize];
                              
                              userName = fbResult[@"name"];
                              userFbId = fbResult[@"id"];
                              userProfileImg = data[@"url"];
                              
                              if(fbResult[@"email"] == (NSString *)[NSNull null]){
                                  userEmail = @"-";
                              } else {
                                  userEmail  = fbResult[@"email"];
                              }
                              
                              NSLog(@"FB -- NAme: %@, id: %@, img: %@, email: %@", userName, userFbId, userProfileImg, userEmail);
                              
                              [self registerUser];

                          }
                          else
                          {
                              showProgress(NO);
                              NSLog(@"Process error Two: %@",error.localizedDescription);
                          }
                      }];
                 }
             }
         }
     }];
}


- (void)registerUser {
    showProgress(YES);
    
    NSLog(@"Reg -- NAme: %@, id: %@, img: %@, email: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"], userFbId, userProfileImg, userEmail);

    NSString *device_Token = [[NSUserDefaults standardUserDefaults] valueForKey:@"deviceToken"];
    
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/login.php"];
    NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys: userFbId, @"fb_id", userName, @"fb_name",  userProfileImg, @"fb_image_url", device_Token, @"device_token", @"2", @"device_type", userEmail, @"fb_email", nil];
    
    NSLog(@"Register New User Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id
                                                                             _Nullable responseObject) {
        NSLog(@"Register New User Response Data: %@", responseObject);
        showProgress(NO);
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1)
            {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ISUserLogined"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [self setInitialScreen];
                
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SEI" message:[responseObject objectForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Registration failed" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        showProgress(NO);
        NSLog(@"Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }];
}

-(void)moveToHome
{
    if (isAlreadyLogin == YES)
    {
        NSLog(@"Login == YES");
        [self setInitialScreen];
    }
    else
    {
        isAlreadyLogin = YES;
    }
}

- (void)setInitialScreen {
    
    NSLog(@"Login: Home screen called");
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    homePageVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"homePageVC"];
    [self presentViewController:UIVC animated:YES completion:nil];

}

@end
