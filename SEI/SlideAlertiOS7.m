//
//  SlideAlert.m
//  badgeTest
//
//  Created by Openwave Computing on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SlideAlertiOS7.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
//Loading View Width and Height 

#define SLIDE_ALERT_WIDTH [UIScreen mainScreen].bounds.size.width //SlideAlert view Width
#define SLIDE_ALERT_HEIGHT 64 //Loading view Height

#define PUSH_ANIM_DURATION 0.25
#define POP_ANIM_DURATION 0.20

#define SLIDE_ALERT_VIEW_DURATION 3
#define SLIDE_ALERT_VIEW_MORE_DURATION 12



#pragma mark - Categories

@implementation UIView (rn_Screenshot)

- (UIImage *)rn_screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end

#import <Accelerate/Accelerate.h>

@implementation UIImage (rn_Blur)

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
    // Check pre-conditions.
    if (self.size.width < 1 || self.size.height < 1) {
        NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
        return nil;
    }
    if (!self.CGImage) {
        NSLog (@"*** error: image must be backed by a CGImage: %@", self);
        return nil;
    }
    if (maskImage && !maskImage.CGImage) {
        NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
        return nil;
    }
    
    CGRect imageRect = { CGPointZero, self.size };
    UIImage *effectImage = self;
    
    BOOL hasBlur = blurRadius > __FLT_EPSILON__;
    BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
    if (hasBlur || hasSaturationChange) {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectInContext = UIGraphicsGetCurrentContext();
        CGContextScaleCTM(effectInContext, 1.0, -1.0);
        CGContextTranslateCTM(effectInContext, 0, -self.size.height);
        CGContextDrawImage(effectInContext, imageRect, self.CGImage);
        
        vImage_Buffer effectInBuffer;
        effectInBuffer.data     = CGBitmapContextGetData(effectInContext);
        effectInBuffer.width    = CGBitmapContextGetWidth(effectInContext);
        effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
        effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
        
        UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
        CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
        vImage_Buffer effectOutBuffer;
        effectOutBuffer.data     = CGBitmapContextGetData(effectOutContext);
        effectOutBuffer.width    = CGBitmapContextGetWidth(effectOutContext);
        effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
        effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);
        
        if (hasBlur) {
            // A description of how to compute the box kernel width from the Gaussian
            // radius (aka standard deviation) appears in the SVG spec:
            // http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
            //
            // For larger values of 's' (s >= 2.0), an approximation can be used: Three
            // successive box-blurs build a piece-wise quadratic convolution kernel, which
            // approximates the Gaussian kernel to within roughly 3%.
            //
            // let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
            //
            // ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
            //
            CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
            NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
            if (radius % 2 != 1) {
                radius += 1; // force radius to be odd so that the three box-blur methodology works.
            }
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
            vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
        }
        BOOL effectImageBuffersAreSwapped = NO;
        if (hasSaturationChange) {
            CGFloat s = saturationDeltaFactor;
            CGFloat floatingPointSaturationMatrix[] = {
                0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                0,                    0,                    0,  1,
            };
            const int32_t divisor = 256;
            NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
            int16_t saturationMatrix[matrixSize];
            for (NSUInteger i = 0; i < matrixSize; ++i) {
                saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
            }
            if (hasBlur) {
                vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
                effectImageBuffersAreSwapped = YES;
            }
            else {
                vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
            }
        }
        if (!effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (effectImageBuffersAreSwapped)
            effectImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    // Set up output context.
    UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
    CGContextRef outputContext = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(outputContext, 1.0, -1.0);
    CGContextTranslateCTM(outputContext, 0, -self.size.height);
    
    // Draw base image.
    CGContextDrawImage(outputContext, imageRect, self.CGImage);
    
    // Draw effect image.
    if (hasBlur) {
        CGContextSaveGState(outputContext);
        if (maskImage) {
            CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
        }
        CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
        CGContextRestoreGState(outputContext);
    }
    
    // Add in color tint.
    if (tintColor) {
        CGContextSaveGState(outputContext);
        CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
        CGContextFillRect(outputContext, imageRect);
        CGContextRestoreGState(outputContext);
    }
    
    // Output image is ready.
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return outputImage;
}

@end




@implementation SlideAlertiOS7

@synthesize superView;
@synthesize imageViewSlideAlert;
@synthesize labelSlideAlert;
@synthesize alertText;

@synthesize slideAlertActive;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
       // [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"img-slidebg-signup.png"]]];
        
        imageViewSlideAlert = [[UIImageView alloc] init];
        imageViewSlideAlert.backgroundColor = [UIColor colorWithRed:101/255.0 green:167/255.0 blue:220/255.0 alpha:1.0];
        imageViewSlideAlert.frame = CGRectMake(0, 0, SLIDE_ALERT_WIDTH, SLIDE_ALERT_HEIGHT);
        

        [self addSubview:imageViewSlideAlert];
        
        
        //Add the UILabel to the UIImageView
        labelSlideAlert = [[UILabel alloc] init];
       [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
        labelSlideAlert.backgroundColor = [UIColor clearColor];
        labelSlideAlert.textColor = [UIColor whiteColor];
        labelSlideAlert.minimumScaleFactor = 10;
        labelSlideAlert.textAlignment = NSTextAlignmentCenter;
        //labelSlideAlert.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        labelSlideAlert.adjustsFontSizeToFitWidth = YES;
        labelSlideAlert.lineBreakMode =  NSLineBreakByWordWrapping;
        labelSlideAlert.numberOfLines = 2;

        labelSlideAlert.frame = CGRectMake(imageViewSlideAlert.frame.origin.x +2, imageViewSlideAlert.frame.origin.y +20 +2, imageViewSlideAlert.frame.size.width -4, imageViewSlideAlert.frame.size.height -20 -4);
        
        //Danger
        [self addSubview:labelSlideAlert];
        self.alpha = 1.0;
        
    }
    return self;
}

+ (SlideAlertiOS7 *) sharedSlideAlert{
    
    // the instance of this class is stored here
    static SlideAlertiOS7 *myInstance = nil;
    
    // check to see if an instance already exists
    if (nil == myInstance) {
        
        // initialize variables here
        
        //Slide From Bottom
        //CGRect frame = CGRectMake(0, 480 , SLIDE_ALERT_WIDTH, SLIDE_ALERT_HEIGHT);
        
        //Slide From Top
        CGRect frame = CGRectMake(0, -SLIDE_ALERT_HEIGHT, SLIDE_ALERT_WIDTH, SLIDE_ALERT_HEIGHT);
        
        myInstance  = [[[self class] alloc] initWithFrame:frame];
        
        
    }//End of if
    // return the instance of this class
    return myInstance;
    
}//End of class method 


#pragma mark -
#pragma mark Pushing and Popping Alerts

- (void)showSlideAlertViewWithStatus:(NSString *)status withText:(NSString *)displayString{
    if (self.slideAlertActive){
        [self popSlideAlert];
    }

    self.alertText = displayString;

    //self.imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-gds.png"];

    if ([status isEqualToString:@"Success"]){
        imageViewSlideAlert.image = [UIImage imageNamed:@"img-green"];
    }
    else if ([status compare:@"Alert"] == NSOrderedSame){
        imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-yellow.png"];
    }
    else if ([status compare:@"Failure"] == NSOrderedSame){
        imageViewSlideAlert.image = [UIImage imageNamed:@"img-red"];
    }
    else{
        //Do nothing
    }
    UIImage *blurImage = [imageViewSlideAlert rn_screenshot];
    imageViewSlideAlert.image = [blurImage applyBlurWithRadius:10 tintColor:[UIColor clearColor] saturationDeltaFactor:1.6 maskImage:nil];;
    
    [self pushSlideAlert];
}

- (void)pushSlideAlert{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    
    self.slideAlertActive = YES;
    
    self.labelSlideAlert.text = alertText;
    
    
  
    if ([alertText length] < 40) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 40 && [alertText length] < 80) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 80 && [alertText length] < 120) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 120 && [alertText length] < 130) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 130 && [alertText length] < 150) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else{
    }
    
    [self.labelSlideAlert setNeedsDisplayInRect:self.frame];
    
   
    //Slide From Top
    CGRect modifiedFrame;
    
    modifiedFrame.origin.x = 0;//((int)rootViewWidth - (int)loadingViewWidth)>>1;
    modifiedFrame.origin.y = 0;//((int)rootViewHeight + (int)loadingViewHeight);

    modifiedFrame.size.width = SLIDE_ALERT_WIDTH;
    modifiedFrame.size.height = SLIDE_ALERT_HEIGHT;
      
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:PUSH_ANIM_DURATION];
    [UIView setAnimationDelegate:nil];
    
    self.frame = modifiedFrame;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];

    [UIView commitAnimations];
    
  
 
    //[self performSelector:@selector(selectorBounceEffect1) withObject:nil afterDelay:PUSH_ANIM_DURATION];
    [self performSelector:@selector(popSlideAlert) withObject:nil afterDelay:SLIDE_ALERT_VIEW_DURATION];
    [self setNeedsDisplay];
    
}

- (void)showSlideAlertViewWithHighDurationWithStatus:(NSString *)status withText:(NSString *)displayString{
    if (self.slideAlertActive){
        [self popSlideAlert];
    }
    
    self.alertText = displayString;
    
    //self.imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-gds.png"];
    
    /*
     if ([status compare:@"Success"] == NSOrderedSame){
     self.imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-green.png"];
     }
     else if ([status compare:@"Alert"] == NSOrderedSame){
     self.imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-yellow.png"];
     }
     else if ([status compare:@"Failure"] == NSOrderedSame){
     self.imageViewSlideAlert.image = [UIImage imageNamed:@"img-slide-alert-red.png"];
     }
     else{
     //Do nothing
     }
     */
    
    [self pushSlideAlertWithHighDuration];
}

- (void)pushSlideAlertWithHighDuration{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    
    self.slideAlertActive = YES;
    
    self.labelSlideAlert.text = alertText;
    
    
    
    if ([alertText length] < 40) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 40 && [alertText length] < 80) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 80 && [alertText length] < 120) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 120 && [alertText length] < 130) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else if ([alertText length] > 130 && [alertText length] < 150) {
        [labelSlideAlert setFont:[UIFont boldSystemFontOfSize:13]];
    }
    else{
    }
    
    [self.labelSlideAlert setNeedsDisplayInRect:self.frame];
    
    
    //Slide From Top
    CGRect modifiedFrame;
//    if ([OnDeck sharedInstance].callRecieved) {
//        modifiedFrame.origin.x = 0;//((int)rootViewWidth - (int)loadingViewWidth)>>1;
//        modifiedFrame.origin.y = 24;//((int)rootViewHeight + (int)loadingViewHeight);
//    }
//    else
//    {
        modifiedFrame.origin.x = 0;//((int)rootViewWidth - (int)loadingViewWidth)>>1;
        modifiedFrame.origin.y = 0;//((int)rootViewHeight + (int)loadingViewHeight);
  //  }
    modifiedFrame.size.width = SLIDE_ALERT_WIDTH;
    modifiedFrame.size.height = SLIDE_ALERT_HEIGHT;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:PUSH_ANIM_DURATION];
    [UIView setAnimationDelegate:nil];
    
    self.frame = modifiedFrame;
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView commitAnimations];
    
    
    
    //[self performSelector:@selector(selectorBounceEffect1) withObject:nil afterDelay:PUSH_ANIM_DURATION];
    [self performSelector:@selector(popSlideAlert) withObject:nil afterDelay:SLIDE_ALERT_VIEW_DURATION];
    [self setNeedsDisplay];
    
}

- (void)popSlideAlert{
    
    //Slide From Top
        CGRect modifiedFrame;
    modifiedFrame.origin.x = 0;//((int)rootViewWidth - (int)loadingViewWidth)>>1;
    modifiedFrame.origin.y = -SLIDE_ALERT_HEIGHT;//((int)rootViewHeight - (int)loadingViewHeight);
       modifiedFrame.size.width = SLIDE_ALERT_WIDTH;
       modifiedFrame.size.height = SLIDE_ALERT_HEIGHT;
        
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:POP_ANIM_DURATION];
    [UIView setAnimationDelegate:nil];
    //[UIView setAnimationTransition:UIViewAnimationCurveLinear forView:viewObj cache:YES];
    
    self.frame = modifiedFrame;
    //[superView addSubview:self];
	
    [UIView commitAnimations];
    
    [self performSelector:@selector(hideSlideAlertView) withObject:nil afterDelay:POP_ANIM_DURATION];
}

- (void)hideSlideAlertView{    
    self.slideAlertActive = NO;

}

- (void)emergencyHideSlideAlertView{
    
    //Slide From Top
    CGRect modifiedFrame;
    modifiedFrame.origin.x = 0;//((int)rootViewWidth - (int)loadingViewWidth)>>1;
    modifiedFrame.origin.y = -SLIDE_ALERT_HEIGHT;//((int)rootViewHeight - (int)loadingViewHeight);
    modifiedFrame.size.width = SLIDE_ALERT_WIDTH;
    modifiedFrame.size.height = SLIDE_ALERT_HEIGHT;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:POP_ANIM_DURATION];
    [UIView setAnimationDelegate:nil];
    
    self.frame = modifiedFrame;
    //[superView addSubview:self];
	
    [UIView commitAnimations];
    
    self.slideAlertActive = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
}


- (void)dealloc
{
    //[super dealloc];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self emergencyHideSlideAlertView];
    
}

//#pragma mark BTBlurredView
//
//- (UIImage *)blurImageForBlurredView:(BTBlurredView *)blurredView image:(UIImage *)image
//{
//    //if you like to mess around with the effect, can be done on the fly, or inside the view itself
//    return /*[image applyBlurWithRadius:3 tintColor:[UIColor colorWithWhite:1.0 alpha:0.4] saturationDeltaFactor:1 maskImage:nil];*/[image applyLightEffect];
//}

@end
