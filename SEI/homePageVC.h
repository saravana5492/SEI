//
//  homePageVC.h
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface homePageVC : UIViewController


@property (strong, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) IBOutlet UIView *locationView;
@property (strong, nonatomic) IBOutlet UILabel *locationLbl;
@property (strong, nonatomic) IBOutlet UIButton *findLocationBtn;
@property (strong, nonatomic) IBOutlet UIView *subjectView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *scrollContentView;

@property (strong, nonatomic) IBOutlet UICollectionView *homeColView;
@property (strong, nonatomic) IBOutlet UILabel *addressLbl;
@property (strong, nonatomic) IBOutlet UILabel *distanceLbl;
@property (strong, nonatomic) IBOutlet UICollectionView *createdTopicCV;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIButton *privateChat;
@property (strong, nonatomic) IBOutlet UIButton *privateChatImg;

@property (strong, nonatomic) IBOutlet UIImageView *chatImageView;

- (IBAction)locationBtnAction:(id)sender;
- (IBAction)createTopicAction:(id)sender;
- (IBAction)userDetailAction:(id)sender;
- (IBAction)chatAction:(id)sender;
- (IBAction)shareAction:(id)sender;
- (IBAction)referAction:(id)sender;
- (IBAction)walletAction:(id)sender;
- (IBAction)settingsAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *referBtn;
@property (strong, nonatomic) IBOutlet UIButton *paymentBtn;


@property (strong, nonatomic) IBOutlet UIView *noSubsView;
@property (strong, nonatomic) IBOutlet UIView *noTopicsView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topicTableHeight;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollContHeight;


@end
