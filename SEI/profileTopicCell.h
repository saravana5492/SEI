//
//  profileTopicCell.h
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileTopicCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *topicTitle;
@property (strong, nonatomic) IBOutlet UILabel *topicViewers;
@property (strong, nonatomic) IBOutlet UILabel *unlikeLbl;
@property (strong, nonatomic) IBOutlet UIImageView *unlikeImg;
@property (strong, nonatomic) IBOutlet UILabel *likeLbl;
@property (strong, nonatomic) IBOutlet UIImageView *likeImg;
@property (strong, nonatomic) IBOutlet UIButton *likeBtn;
@property (strong, nonatomic) IBOutlet UIButton *unlikeBtn;


@end
