//
//  withdrawVC.h
//  SEI
//
//  Created by Apple on 31/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface withdrawVC : UIViewController

@property (strong, nonatomic) IBOutlet UIView *payPalEmailView;
@property (strong, nonatomic) IBOutlet UITextField *payPalEmailTF;

@property (strong, nonatomic) IBOutlet UIView *messageView;
@property (strong, nonatomic) IBOutlet UITextView *messageTextView;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;


- (IBAction)sendAction:(id)sender;
- (IBAction)backBtnAction:(id)sender;

@end
