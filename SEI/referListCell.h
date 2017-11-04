//
//  referListCell.h
//  SEI
//
//  Created by Apple on 25/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface referListCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *profileImgCont;
@property (strong, nonatomic) IBOutlet UIImageView *profileImgView;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *refersCount;
@property (strong, nonatomic) IBOutlet UILabel *referAmount;


@end
