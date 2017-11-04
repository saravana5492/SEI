//
//  newReferVC.m
//  SEI
//
//  Created by Apple on 25/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "newReferVC.h"
#import "referedListVC.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"


@interface newReferVC ()

@end

@implementation newReferVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _emailTFView.layer.cornerRadius = 3.0f;
    _emailTFView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _emailTFView.layer.borderWidth = 1.0f;
    
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Email Address" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.emailTF.attributedPlaceholder = str1;
    
    _sendBtn.layer.cornerRadius = 3.0f;
    
    [self.emailTF setDelegate:self];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void) dismissKeyboard
{
    // add self
    [self.emailTF resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)backBtnAction:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sendBtnAction:(id)sender {
    
   
    
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    if ([emailTest evaluateWithObject:_emailTF.text] == YES || _emailTF.text.length != 0)
    {
         showProgress(YES);
        NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/send_referral_link.php"];
        
        NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"refer_from_fb_id", _emailTF.text, @"referral_email_id",  nil];
        
        NSLog(@"New Referral Request Body: %@", parametersDictionary);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            
            NSLog(@"New Referral Response Data: %@", responseObject);
            showProgress(NO);
            
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionPush;
                    transition.subtype = kCATransitionFromLeft;
                    [self.view.window.layer addAnimation:transition forKey:nil];
                    
                    [self dismissViewControllerAnimated:NO completion:nil];
                    
                }];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            showProgress(NO);
            NSLog(@"New Referral error: %@", error);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];

    }
    else
    {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Please enter valid email" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
