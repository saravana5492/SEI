//
//  referedListVC.h
//  SEI
//
//  Created by Apple on 25/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface referedListVC : UIViewController

@property (strong, nonatomic) IBOutlet UIView *profileImgCont;
@property (strong, nonatomic) IBOutlet UIImageView *profileImgView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UIButton *withDrawBtn;
@property (strong, nonatomic) IBOutlet UILabel *referedMoneyLbl;
@property (strong, nonatomic) IBOutlet UITableView *referralsListTV;

@end
