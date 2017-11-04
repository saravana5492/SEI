//
//  createdTopicCell.h
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface createdTopicCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *topicImg;
@property (strong, nonatomic) IBOutlet UILabel *topicName;
@property (strong, nonatomic) IBOutlet UILabel *topicDate;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (strong, nonatomic) IBOutlet UIButton *showImagesBtn;

@property (strong, nonatomic) IBOutlet UIImageView *playerImg;

@end
