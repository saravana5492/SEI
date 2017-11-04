//
//  SlideAlert.h
//  badgeTest
//
//  Created by Openwave Computing on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SlideAlertiOS7 : UIView  {
    
    UIView *superView;
    UIImageView *imageViewSlideAlert;
    //FontLabel *labelSlideAlert;
    
    UILabel *labelSlideAlert;
    NSString *alertText;
    
    BOOL slideAlertActive;
}

@property(nonatomic, retain) UIView *superView;
@property(nonatomic, retain) UIImageView *imageViewSlideAlert;
//@property(nonatomic, retain) FontLabel *labelSlideAlert;

@property(nonatomic, retain) UILabel *labelSlideAlert;
@property(nonatomic, retain) NSString *alertText;

@property(nonatomic, assign) BOOL slideAlertActive;

//Declare class method 

+ (SlideAlertiOS7 *)sharedSlideAlert;

- (void)showSlideAlertViewWithStatus:(NSString *)status withText:(NSString *)displayString;
- (void)showSlideAlertViewWithHighDurationWithStatus:(NSString *)status withText:(NSString *)displayString;
- (void)pushSlideAlert;
- (void)popSlideAlert;
- (void)hideSlideAlertView;

- (void)emergencyHideSlideAlertView;



@end