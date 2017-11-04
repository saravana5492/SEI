//
//  groupChatVC.h
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"


@interface groupChatVC : UIViewController <HPGrowingTextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *topicTitleLbl;
@property (strong, nonatomic) IBOutlet UIButton *addTopicBtn;
@property (strong, nonatomic) IBOutlet UILabel *topicDescLbl;

@property (strong, nonatomic) IBOutlet UIView *userView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UIButton *addUserBtn;
@property (strong, nonatomic) IBOutlet UILabel *topicDateLbl;

@property (strong, nonatomic) IBOutlet UITextField *writeMsgTF;
@property (strong, nonatomic) IBOutlet UIButton *attachBtn;
@property (strong, nonatomic) IBOutlet UIButton *sendBtn;
@property (strong, nonatomic) IBOutlet UILabel *viewersCountLbl;
@property (strong, nonatomic) IBOutlet UILabel *topicPlace;

@property (strong, nonatomic) IBOutlet UILabel *likeCountLbl;
@property (strong, nonatomic) IBOutlet UILabel *dislikeCountLbl;
@property (strong, nonatomic) IBOutlet UIImageView *likeImgView;
@property (strong, nonatomic) IBOutlet UIImageView *unlikeImgView;

@property (strong, nonatomic) IBOutlet UITableView *tblChat;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomSpacemessageEntry;

@property (strong, nonatomic) IBOutlet UIView *userProfOptionView;
@property (strong, nonatomic) IBOutlet UIButton *messageBtn;
@property (strong, nonatomic) IBOutlet UIButton *showProfileBtn;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet HPGrowingTextView *textView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *containerHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *placeAddreHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topicDescHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableHeight;

@property (strong, nonatomic) IBOutlet UIView *scrollContView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollTopSpace;


@end
