//
//  paymentVC.m
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "paymentVC.h"
#import "homePageVC.h"
#import "termsCondVC.h"

#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"


@interface paymentVC ()
@property (nonatomic, strong)  PayPalConfiguration *payPalconfig;
@end

@implementation paymentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI Design ***
    
    self.acceptTVLbl.text = [NSString stringWithFormat:@"I Accept Terms and Conditions"];
    NSRange range3 = [self.acceptTVLbl.text rangeOfString:@"I Accept "];
    NSRange range4 = [self.acceptTVLbl.text rangeOfString:@"Terms and Conditions"];
    NSMutableAttributedString *loginattributedText = [[NSMutableAttributedString alloc] initWithString:self.acceptTVLbl.text];
    
    NSDictionary *attrDictDummy = @{
                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0],
                                    NSForegroundColorAttributeName : [UIColor whiteColor]
                                    };
    NSDictionary *attrDictLogin = @{
                                    NSFontAttributeName : [UIFont boldSystemFontOfSize:15.0],
                                    NSForegroundColorAttributeName : [UIColor colorWithRed:63/255.0f green:92/255.0f blue:122/255.0f alpha:1.0f]
                                    
                                    };
    [loginattributedText setAttributes:attrDictDummy
                                 range:range3];
    [loginattributedText setAttributes:attrDictLogin
                                 range:range4];
    self.acceptTVLbl.attributedText = loginattributedText;

    
    
    _profileImgView.layer.cornerRadius = 60.0f;
    _profileImg.layer.masksToBounds = YES;
    [_profileImg layoutIfNeeded];
    _profileImg.layer.cornerRadius = 58.0f;
    _payBtn.layer.cornerRadius = 3.0f;
    
    [_profileImg sd_setImageWithURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]
                 placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];

    _userName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFullName"];
    
    // PayPal integration ***
    _payPalconfig = [[PayPalConfiguration alloc] init];
    _payPalconfig.acceptCreditCards = YES;
    _payPalconfig.merchantName = @"SmitivMobile";
    _payPalconfig.merchantPrivacyPolicyURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/privacy-full"];
    _payPalconfig.merchantUserAgreementURL = [NSURL URLWithString:@"https://www.paypal.com/webapps/mpp/ua/useragreement-full"];
    
    _payPalconfig.languageOrLocale = [NSLocale preferredLanguages][0];
    _payPalconfig.payPalShippingAddressOption = PayPalShippingAddressOptionPayPal;
    
    NSLog(@"Pay Pal SDK: %@", [PayPalMobile libraryVersion]);
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"Alert Controller Called!!");
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Refer and make Money" message:@"Subscribed users refer Friends to SEI and earn money for the same. So start referring" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];

}


- (IBAction)paymentAction:(id)sender{
    
    if([self.acceptTCBtn tag] == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Please accept terms and conditions" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        NSDecimalNumber *subTotal = [NSDecimalNumber decimalNumberWithString:@"20.00"];
        NSDecimalNumber *tax = [[NSDecimalNumber alloc] initWithString:@"0.00"];
        
        PayPalPaymentDetails *paymentDetails = [PayPalPaymentDetails paymentDetailsWithSubtotal:subTotal withShipping:nil withTax:tax];
        
        NSDecimalNumber *total = [subTotal decimalNumberByAdding:tax];
        PayPalPayment *payment = [[PayPalPayment alloc] init];
        payment.amount = total;
        payment.currencyCode = @"USD";
        payment.shortDescription = @"SEI Subscription Fee";
        payment.paymentDetails = paymentDetails;
        
        if(!payment.processable){
            
        }
        PayPalPaymentViewController *paymentViewController = [[PayPalPaymentViewController alloc] initWithPayment:payment configuration:self.payPalconfig delegate:self];
        [self presentViewController:paymentViewController animated:YES completion:nil];

    }
    
}

#pragma mark PayPal SDK Methods

- (void)payPalPaymentDidCancel:(PayPalPaymentViewController *)paymentViewController {
    
    NSLog(@"PayPal Payment Cancelled!!");
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)payPalPaymentViewController:(PayPalPaymentViewController *)paymentViewController didCompletePayment:(PayPalPayment *)completedPayment{
    
    
    NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/add_payment_details.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFullName"], @"fb_name",
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"], @"fb_image",
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserEmail"], @"fb_email",
                                           @"test", @"payment_id",
                                           @"5000", @"payment_amount",
                                           @"approved", @"payment_status", nil];
    
    NSLog(@"Add payment details Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Add payment details Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        } else {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"LIke Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
    
    NSLog(@"PayPal Payment Success!!");
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];

}

- (IBAction)termsBtn:(id)sender{
    if ([self.acceptTCBtn tag] == 0) {
        self.acceptTCBtn.tag = 1;
        _acceptImgView.image = [UIImage imageNamed:@"checkIcon"];
    } else {
        self.acceptTCBtn.tag = 0;
        _acceptImgView.image = [UIImage imageNamed:@"uncheckIcon"];
    }

}

- (IBAction)showTCAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    termsCondVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"termsCondVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];

    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)backAction:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.mainView.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


@end
