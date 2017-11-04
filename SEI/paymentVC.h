//
//  paymentVC.h
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PayPalMobile.h"
#import "PayPalConfiguration.h"
#import "PayPalPaymentViewController.h"

@interface paymentVC : UIViewController <PayPalPaymentDelegate>

@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *profileImgView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImg;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UIButton *payBtn;
@property (strong, nonatomic) IBOutlet UIButton *acceptTCBtn;
@property (strong, nonatomic) IBOutlet UILabel *acceptTVLbl;

@property (strong, nonatomic) IBOutlet UIButton *showTCBtn;
@property (strong, nonatomic) IBOutlet UIImageView *acceptImgView;


@end
