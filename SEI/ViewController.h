//
//  ViewController.h
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *logInBtnView;
@property (strong, nonatomic) IBOutlet UIButton *loginBtn;
@property (strong, nonatomic) IBOutlet UILabel *centerDot;
@property (strong, nonatomic) IBOutlet UILabel *rightDot;
@property (strong, nonatomic) IBOutlet UILabel *leftDot;


- (IBAction)loginWithFB:(id)sender;


@end

