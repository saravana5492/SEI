//
//  withdrawVC.m
//  SEI
//
//  Created by Apple on 31/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "withdrawVC.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

@interface withdrawVC ()<UITextFieldDelegate, UITextViewDelegate, UIGestureRecognizerDelegate>

@end

@implementation withdrawVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _payPalEmailView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _payPalEmailView.layer.borderWidth = 1.0f;
    _payPalEmailView.layer.cornerRadius = 3.0f;
    
    _messageView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _messageView.layer.borderWidth = 1.0f;
    _messageView.layer.cornerRadius = 3.0f;
    _sendBtn.layer.cornerRadius = 3.0f;
    
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Enter Paypal email address" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.payPalEmailTF.attributedPlaceholder = str1;

    self.messageTextView.text = @"Your message";
    
    [self.payPalEmailTF setDelegate:self];
    [self.messageTextView setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    
}

- (void) dismissKeyboard
{
    // add self
    [self.payPalEmailTF resignFirstResponder];
    [self.messageTextView resignFirstResponder];
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.messageTextView.text isEqualToString:@"Your message"]) {
        self.messageTextView.text = @"";
        self.messageTextView.textColor = [UIColor whiteColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([self.messageTextView.text isEqualToString:@""]) {
        self.messageTextView.text = @"Your message";
        self.messageTextView.textColor = [UIColor whiteColor]; //optional
    }
    [self.messageTextView resignFirstResponder];
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

- (IBAction)sendAction:(id)sender {
    
    if (_payPalEmailTF.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Please enter your Paypal email" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        
        NSString *messageText = [[NSString alloc] init];
        
        if ([self.messageTextView.text isEqualToString:@"Your message"]){
            messageText = @"-";
        } else {
            messageText = _messageTextView.text;
        }
        
        showProgress(YES);
        
        NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
        
        if ([emailTest evaluateWithObject:self.payPalEmailTF.text] == YES)
        {
            NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/referral_friend_withdraw.php"];
            
            NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                                   _payPalEmailTF.text, @"paypal_email_id",
                                                   messageText, @"withdraw_msg",
                                                   [[NSUserDefaults standardUserDefaults] objectForKey:@"totalAmount"], @"withdraw_amount", nil];
            
            NSLog(@"Withdraw Request Body: %@", parametersDictionary);
            
            AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
            [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
            manager.requestSerializer = [AFHTTPRequestSerializer serializer];
            [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                
                NSLog(@"Withdraw Response Data: %@", responseObject);
                showProgress(NO);
                
                if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                    
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                         {
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
                NSLog(@"Withdraw list error: %@", error);
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
            }];
            
        } else {
            showProgress(NO);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Please enter valid email format" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }

    }
    
    
}

- (IBAction)backBtnAction:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


@end
