//
//  singleChatVC.h
//  SEI
//
//  Created by Apple on 20/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"


@interface singleChatVC : UIViewController <HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextField *writeMsgTF;
@property (strong, nonatomic) IBOutlet UIButton *attachBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (strong, nonatomic) IBOutlet UITableView *tblChat;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacemessageEntry;
@property (strong, nonatomic) IBOutlet UILabel *chatUserNameLbl;

@property (strong, nonatomic) IBOutlet UIView *chatImgView;
@property (strong, nonatomic) IBOutlet UIImageView *chatterImg;

@property (strong, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *vertHeight;


@end
