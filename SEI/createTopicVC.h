//
//  createTopicVC.h
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface createTopicVC : UIViewController

@property (strong, nonatomic) IBOutlet UIView *topLayer;
@property (strong, nonatomic) IBOutlet UIView *locationView;
@property (strong, nonatomic) IBOutlet UIView *loctView;
@property (strong, nonatomic) IBOutlet UIImageView *dropDownImg;

@property (strong, nonatomic) IBOutlet UIView *topicNameView;
@property (strong, nonatomic) IBOutlet UITextField *topicTitleTF;
@property (strong, nonatomic) IBOutlet UIView *topicTitleView;
@property (strong, nonatomic) IBOutlet UIView *topicDescView;
@property (strong, nonatomic) IBOutlet UITextView *topicDescTV;

@property (strong, nonatomic) IBOutlet UIView *selectedImgView;

@property (strong, nonatomic) IBOutlet UICollectionView *imageColView;

@property (strong, nonatomic) IBOutlet UIView *uploadImgView;
@property (strong, nonatomic) IBOutlet UIButton *uploadImgBtn;

@property (strong, nonatomic) IBOutlet UIView *finishView;
@property (strong, nonatomic) IBOutlet UIButton *finishBtn;

@property (strong, nonatomic) IBOutlet UIView *uploadView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *rowHeight;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *colViewWidth;
@property (strong, nonatomic) IBOutlet UIButton *uploadVideoBtn;
@property (strong, nonatomic) IBOutlet UIButton *uploadImageBtn;

@property (strong, nonatomic) IBOutlet UIView *mainview;


@end
