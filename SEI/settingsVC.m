//
//  settingsVC.m
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "settingsVC.h"
#import "homePageVC.h"
#import "ViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

#import <MessageUI/MessageUI.h>


@interface settingsVC () <MFMailComposeViewControllerDelegate>

@end

@implementation settingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI Design ***
    _profileImgView.layer.cornerRadius = 60.0f;
    _profileImg.layer.masksToBounds = YES;
    [_profileImg layoutIfNeeded];
    _profileImg.layer.cornerRadius = 58.0f;
    _logoutView.layer.cornerRadius = 5.0f;
    _feedbackView.layer.cornerRadius = 5.0f;

    _distListView.hidden = YES;
    
    _userName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFullName"];
    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]]
                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];

    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"5"]) {
        _distanceLbl.text = @"5";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"50"]) {
        _distanceLbl.text = @"50";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"500"]) {
        _distanceLbl.text = @"500";
    } else {
        _distanceLbl.text = @"5";
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    if(touch.view.tag!=27){
        _distListView.hidden=YES;
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

- (IBAction)logOut:(id)sender {
    
    
    
    //  Clear user data's here...
    
   /* NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    
    // Clear User Details
    
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    
    NSLog(@"Saved user details: %@", dict);
    
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];*/
    
    //hide Bar button
    
    self.hidesBottomBarWhenPushed = YES;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Do you want to logout?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
    UIAlertAction* dismiss = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ISUserLogined"];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
        ViewController * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"ViewController"];
        UIVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:UIVC animated:YES completion:nil];
        
    }];
    
    [alertController addAction:dismiss];
    [alertController addAction:Cancel];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}


- (IBAction)showDistView:(id)sender {
    _distListView.hidden = NO;
}

- (IBAction)distFiveAct:(id)sender {
 
    [[NSUserDefaults standardUserDefaults] setValue:@"5" forKey:@"topicDistRequest"];
    
    _distanceLbl.text = @"5";
    _distListView.hidden = YES;
}

- (IBAction)distFiftyAct:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"50" forKey:@"topicDistRequest"];
    _distanceLbl.text = @"50";
    _distListView.hidden = YES;

}

- (IBAction)distFiveHundAct:(id)sender {
    [[NSUserDefaults standardUserDefaults] setValue:@"500" forKey:@"topicDistRequest"];
    _distanceLbl.text = @"500";
    _distListView.hidden = YES;

}

- (IBAction)feedBackAction:(id)sender {
    
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"SEITHI FEEDBACK"];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[@"info@rgmobiles.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)backAction:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


@end
