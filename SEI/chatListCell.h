//
//  chatListCell.h
//  SEI
//
//  Created by Apple on 22/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *chatImgView;
@property (strong, nonatomic) IBOutlet UIImageView *chatImg;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *lastMessageLbl;
@property (strong, nonatomic) IBOutlet UILabel *timeLbl;

@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UILabel *lblCount;


@end
