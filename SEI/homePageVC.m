//
//  homePageVC.m
//  SEI
//
//  Created by Apple on 08/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "homePageVC.h"
#import "homeGridCell.h"
#import "createdTopicCell.h"
#import "createTopicVC.h"
#import "profileVC.h"
#import "paymentVC.h"
#import "settingsVC.h"
#import "groupChatVC.h"
#import "chatListVC.h"
#import "AppDelegate.h"
#import "referedListVC.h"

#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "MVPlaceSearchTextField.h"
#import "NYTPhotoViewer/NYTPhotosViewController.h"
#import "NYTPhoto.h"
#import "NYTExamplePhoto.h"


#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SlideAlertiOS7.h"

@import GooglePlaces;


@interface homePageVC () <PlaceSearchTextFieldDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate,UITextFieldDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate>
{
    CLLocationManager *locationManager;
    float latitude;
    float longitude;
    NSMutableArray *topicsArray;
    NSMutableArray *filteredArray;
    
    NSMutableArray *subscribedTopicsArray;
    NSString *topicDist;
    BOOL deleteTrip;
    NSIndexPath *indexPathNew;
    UITapGestureRecognizer *gestureRecognizera;
}

@property (strong, nonatomic) IBOutlet MVPlaceSearchTextField *locationTF;
@property (strong, nonatomic) AVPlayerViewController *playerViewController;

@end

@implementation homePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self performSelector:@selector(fetchSubscribedItems) withObject:nil afterDelay:0.2f];
    [self performSelector:@selector(newMessageAlert) withObject:nil afterDelay:0.2f];


    self.referBtn.hidden = YES;
    self.paymentBtn.hidden = YES;
    
    
    // CLLocationManager to get current lat long value ***
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 20;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    // PlaceSearch Autocomplete with MVPlaceSearchTextField library
    // To get Lat Long from the entered address
    _locationTF.placeSearchDelegate                 = self;
    _locationTF.strApiKey                           = @"AIzaSyDtKYr7BcB05sGJBghwUCDtLEbiv7-t9Os";
    _locationTF.superViewOfList                     = self.view;  // View, on which Autocompletion list should be appeared.
    _locationTF.autoCompleteShouldHideOnSelection   = YES;
    _locationTF.maximumNumberOfAutoCompleteRows     = 5;
    _locationTF.returnKeyType = UIReturnKeyDefault;
    
    // search bar UI design
    [self.searchBar setDelegate:self];

    _searchBar.backgroundImage = [[UIImage alloc] init];
    
    UIImage *imgClear = [UIImage imageNamed:@"searchClear"];
    [_searchBar setImage:imgClear forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    [self.searchBar setValue:[UIColor whiteColor] forKeyPath:@"_searchField._placeholderLabel.textColor"];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setFont:[UIFont systemFontOfSize:12]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setBackgroundColor:[UIColor clearColor]];
    [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor whiteColor]];
    
    _noSubsView.hidden = YES;
    _noTopicsView.hidden = YES;
    
    // Collection view organizing ***
    _createdTopicCV.scrollEnabled = NO;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.homeColView setPagingEnabled:NO];
    [self.homeColView setCollectionViewLayout:flowLayout];
    
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Location" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.locationTF.attributedPlaceholder = str1;
    
    
    /*UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"clearBtn"] forState:UIControlStateNormal];
    [clearButton setFrame:CGRectMake(0.0f, 0.0f, 15.0f, 15.0f)];
    [clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];
    
    _locationTF.rightViewMode = UITextFieldViewModeWhileEditing; //can be changed to UITextFieldViewModeNever,    UITextFieldViewModeWhileEditing,   UITextFieldViewModeUnlessEditing
    [_locationTF setRightView:clearButton]; */
    
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"5"]) {
        topicDist = @"5";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"50"]) {
        topicDist = @"50";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"500"]) {
        topicDist = @"500";
    } else {
        topicDist = @"5";
    }
    
    //Long Press Collection view cell ----------------------
    
    
    
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.homeColView addGestureRecognizer:lpgr];

    
    // Do any additional setup after loading the view.
}

- (IBAction)clearTextField:(id)sender{
    self.locationTF.text = @"";
}

- (void) hideKeyboard {
    [_searchBar resignFirstResponder];
    [_locationTF resignFirstResponder];
    [self.createdTopicCV setUserInteractionEnabled:YES];
    [self.createdTopicCV removeGestureRecognizer:gestureRecognizera];
    [self.homeColView removeGestureRecognizer:gestureRecognizera];
    [self.view removeGestureRecognizer:gestureRecognizera];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.homeColView];
    
    indexPathNew = [self.homeColView indexPathForItemAtPoint:p];
    
    if (indexPathNew == nil){
        NSLog(@"couldn't find index path");
    } else {
        homeGridCell* cell = (homeGridCell*) [self.homeColView cellForItemAtIndexPath:indexPathNew];
        
        NSDictionary *dataDict = [subscribedTopicsArray objectAtIndex:indexPathNew.row];
        
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Do you want to Unsubscribe?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        
        UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            
            
            if([[dataDict valueForKey:@"subscribe_type"] integerValue] == 1) {
                
                NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/unsubscribed_user_with_count.php"];
                
                NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"fb_id", [dataDict valueForKeyPath:@"topic_user_fb_id"], @"subscriber_id", nil];
                
                NSLog(@"Topic User Unsubscribe Request Body: %@", parametersDictionary);
                
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                    
                    
                    NSLog(@"Topic User Unsubscribe Response Data: %@", responseObject);
                    showProgress(NO);
                    if(responseObject)
                    {
                        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                            
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKey:@"message"] preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                [self performSelector:@selector(fetchSubscribedItems) withObject:nil afterDelay:0.0f];
                            }];;
                            [alertController addAction:ok];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                            
                        } else {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                
                            }];;
                            [alertController addAction:ok];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                    } else {
                        
                        // Do the else stuff here
                    }
                    
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    showProgress(NO);
                    NSLog(@"Error: %@", error);
                    NSLog(@"fetch topic Response error: %@", error);
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }];
                
            } else {
                NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/unsubscribed_topics_with_count.php"];
                
                NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [dataDict valueForKey:@"topic_id"], @"topic_id", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"fb_id", nil];
                
                NSLog(@"Topic Unsubscribe Request Body: %@", parametersDictionary);
                
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                    
                    NSLog(@"Topic Unsubscribe Response Data: %@", responseObject);
                    showProgress(NO);
                    if(responseObject)
                    {
                        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKeyPath:@"topic_unsubscribe.message"] preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                [self performSelector:@selector(fetchSubscribedItems) withObject:nil afterDelay:0.0f];
                                //[self performSelector:@selector(fetchTopics) withObject:nil afterDelay:0.2f];
                            }];;
                            [alertController addAction:ok];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                        } else {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                
                            }];;
                            [alertController addAction:ok];
                            
                            [self presentViewController:alertController animated:YES completion:nil];
                        }
                    } else {
                        
                        // Do the else stuff here
                    }
                    
                } failure:^(NSURLSessionTask *operation, NSError *error) {
                    showProgress(NO);
                    NSLog(@"Error: %@", error);
                    NSLog(@"fetch topic Response error: %@", error);
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }];
            }
            

        }];
        [alertController addAction:yes];
        [alertController addAction:Cancel];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    //[self.view endEditing:YES];
    [_locationTF resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(MVPlaceSearchTextField *)textField {
    
    NSLog(@"Text Field Editing began!!");
    
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"5"]) {
        topicDist = @"5";
        _distanceLbl.text = @"5 km";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"50"]) {
        topicDist = @"50";
        _distanceLbl.text = @"50 km";
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"topicDistRequest"] isEqualToString:@"500"]) {
        topicDist = @"500";
        _distanceLbl.text = @"500 km";
    } else {
        topicDist = @"5";
        _distanceLbl.text = @"5 km";
    }

    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDisk];
    
    [self performSelector:@selector(fetchSubscribedItems) withObject:nil afterDelay:0.2f];
    [self performSelector:@selector(fetchTopics) withObject:nil afterDelay:0.2f];
    [self performSelector:@selector(newMessageAlert) withObject:nil afterDelay:0.2f];
    
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self->locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

// Current location lattitude longitude value **

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    latitude = newLocation.coordinate.latitude;//11.0169117;//1.3589465;//newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;//76.9792926;//103.8555479;//newLocation.coordinate.longitude;
    
    NSLog(@"Lat Long finder: %f, %f", latitude, longitude);
    
    //showProgress(YES);
    [self getAddressByLatLong];
    [self performSelector:@selector(fetchTopics) withObject:nil afterDelay:0.2f];
}

// Getting exact address with the lat long value ***

- (void)getAddressByLatLong {
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:latitude longitude:longitude];
    
    NSLog(@"Address finder: %f, %f", latitude, longitude);
    
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark %@",placemark);
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         NSLog(@"addressDictionary %@", placemark.addressDictionary);
         
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         _addressLbl.text = locatedAt;
         
     }];
}

-(void)viewDidAppear:(BOOL)animated{
    
    
    // PLace Search Auto complete | Google map | Place Search
    //Optional Properties
    _locationTF.autoCompleteRegularFontName =  @"HelveticaNeue-Bold";
    _locationTF.autoCompleteBoldFontName = @"HelveticaNeue";
    _locationTF.autoCompleteTableCornerRadius=0.0;
    _locationTF.autoCompleteRowHeight=35;
    _locationTF.autoCompleteTableCellTextColor=[UIColor colorWithWhite:0.131 alpha:1.000];
    _locationTF.autoCompleteFontSize=14;
    _locationTF.autoCompleteTableBorderWidth=1.0;
    _locationTF.showTextFieldDropShadowWhenAutoCompleteTableIsOpen=YES;
    _locationTF.autoCompleteShouldHideOnSelection=YES;
    _locationTF.autoCompleteShouldHideClosingKeyboard=YES;
    _locationTF.autoCompleteShouldSelectOnExactMatchAutomatically = YES;
    //_locationTF.autoCompleteTableFrame = CGRectMake((self.view.frame.size.width-_subjectTF.frame.size.width)*0.5, _subjectTF.frame.size.height+100.0, _subjectTF.frame.size.width, 200.0);
    _locationTF.autoCompleteTableFrame = CGRectMake(57.0, _locationTF.frame.size.height+100.0, _locationTF.frame.size.width * 2, 200.0);
}

#pragma mark - Place search Textfield Delegates

// Getting Lat long value from the entered address ***

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace *)responseDict{
    [self.view endEditing:YES];
    //NSString *latLong = [responseDict valueForKey:@"coordinate"];
    NSLog(@"SELECTED ADDRESS HOME :%f, %f",responseDict.coordinate.latitude, responseDict.coordinate.longitude);
    latitude = responseDict.coordinate.latitude;
    longitude = responseDict.coordinate.longitude;
    
    
    [self->locationManager stopUpdatingLocation];
    self->locationManager = nil;
    [self getAddressByLatLong];
    [self performSelector:@selector(fetchTopics) withObject:nil afterDelay:0.2f];
}

-(void)placeSearchWillShowResult:(MVPlaceSearchTextField*)textField{
    
}

-(void)placeSearchWillHideResult:(MVPlaceSearchTextField*)textField{
    
}

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResultCell:(UITableViewCell*)cell withPlaceObject:(PlaceObject*)placeObject atIndex:(NSInteger)index{
    if(index%2==0){
        cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    }else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}


//Collection View Organizing!!!


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (collectionView == _homeColView) {
        return subscribedTopicsArray.count;
    } else {
        return filteredArray.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    if (collectionView == _homeColView) {
        NSString *reuseIdentifier = @"homeCell";
        homeGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
        NSDictionary *dataDict = [subscribedTopicsArray objectAtIndex:indexPath.row];
        
        if([[dataDict valueForKey:@"subscribe_type"] integerValue] == 1) {
            cell.nameLbl.text = [dataDict valueForKey:@"topic_user_fb_name"];
            cell.countLbl.text = [dataDict valueForKey:@"topic_count"];
        } else {
            cell.nameLbl.text = [dataDict valueForKey:@"topic_title"];
            cell.countLbl.text = [dataDict valueForKey:@"user_message_count"];
        }

        cell.countLbl.clipsToBounds = YES;
        cell.countLbl.layer.cornerRadius = 5.0f;
        cell.layer.cornerRadius = 3.0f;
        
        cell.layer.masksToBounds = NO;
        cell.layer.contentsScale = [UIScreen mainScreen].scale;
        cell.layer.rasterizationScale=[[UIScreen mainScreen] scale];
        cell.layer.shadowOpacity = 1.0f;
        cell.layer.shadowRadius = 5.0f;
        cell.layer.shadowOffset = CGSizeZero;
        cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
        cell.layer.shouldRasterize = YES;
        
        return cell;
        
    } else {
        NSString *reuseIdentifier = @"topicCell";
        createdTopicCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
        
         NSDictionary *dataDic = [filteredArray objectAtIndex:indexPath.row];
        
        if ([[dataDic valueForKey:@"video_url"] isEqualToString:@""]) {
            cell.activity.hidden = NO;
            [cell.activity startAnimating];
            
            [cell.topicImg sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"topic_image"]] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [cell.activity stopAnimating];
                cell.activity.hidden = YES;
                
            }];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[dataDic valueForKey:@"topic_image"]] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (image && finished) {
                    // Cache image to disk or memory
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"image1%ld", (long)indexPath.row] toDisk:YES];
                }
            }];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[dataDic valueForKey:@"topic_image2"]] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (image && finished) {
                    // Cache image to disk or memory
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"image2%ld", (long)indexPath.row] toDisk:YES];
                }
            }];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[dataDic valueForKey:@"topic_image3"]] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (image && finished) {
                    // Cache image to disk or memory
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"image3%ld", (long)indexPath.row] toDisk:YES];
                }
            }];
            
            cell.playerImg.hidden = YES;
            
        } else {
            
            cell.activity.hidden = NO;
            [cell.activity startAnimating];
            
            [cell.topicImg sd_setImageWithURL:[NSURL URLWithString:[dataDic objectForKey:@"video_image_url"]] placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [cell.activity stopAnimating];
                cell.activity.hidden = YES;
                
            }];
            

            cell.playerImg.hidden = NO;
        }
        

        cell.showImagesBtn.tag = indexPath.row;
        [cell.showImagesBtn addTarget:self action:@selector(showAllImages:) forControlEvents:UIControlEventTouchUpInside];

        
        cell.topicName.text = [[dataDic objectForKey:@"topic_title"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        cell.topicDate.text = [NSString stringWithFormat:@"%@ %@", [[dataDic objectForKey:@"created_date"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]], [[dataDic objectForKey:@"created_time"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
        
        cell.layer.cornerRadius = 5.0f;
        
        return cell;
    }

}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    if (collectionView == _createdTopicCV) {
        
        [[NSUserDefaults standardUserDefaults] setValue:@"chatFromHome" forKey:@"chatPath"];
        
        NSDictionary *dataDic = [filteredArray objectAtIndex:indexPath.row];
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dataDic];
        [currentDefaults setObject:data forKey:@"selectedTopic"];
        
        //[[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:@"selectedTopic"];
        [[NSUserDefaults standardUserDefaults] setValue:[dataDic valueForKey:@"topic_id"] forKey:@"updateTopicCount"];
        
        [self performSelector:@selector(updateViewCount) withObject:nil afterDelay:0.2f];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
        groupChatVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"groupChatVC"];    CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        UIView *containerView = self.view.window;
        [containerView.layer addAnimation:transition forKey:nil];
        [self presentViewController:UIVC animated:NO completion:nil];

    } else if (collectionView == _homeColView) {
        
        NSDictionary *dataDict = [subscribedTopicsArray objectAtIndex:indexPath.row];
        
        if([[dataDict valueForKey:@"subscribe_type"] integerValue] == 1) {
            NSString *fbIdFromSubs = [dataDict valueForKey:@"topic_user_fb_id"];
            [[NSUserDefaults standardUserDefaults] setValue:fbIdFromSubs forKey:@"otherFbId"];
            
            NSLog(@"Profile Data Dict id: %@", [[NSUserDefaults standardUserDefaults] valueForKey:@"otherFbId"]);
            
            [[NSUserDefaults standardUserDefaults] setValue:@"profileFromSubsc" forKey:@"profilePath"];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
            profileVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            
            UIView *containerView = self.view.window;
            [containerView.layer addAnimation:transition forKey:nil];
            [self presentViewController:UIVC animated:NO completion:nil];
            
        } else if([[dataDict valueForKey:@"subscribe_type"] integerValue] == 0) {
            
            [[NSUserDefaults standardUserDefaults] setValue:@"chatFromHomeSubs" forKey:@"chatPath"];
            
            NSDictionary *dataDic = [subscribedTopicsArray objectAtIndex:indexPath.row];
            [[NSUserDefaults standardUserDefaults] setObject:dataDic forKey:@"selectedTopic"];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
            groupChatVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"groupChatVC"];
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3;
            transition.timingFunction =
            [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromRight;
            
            UIView *containerView = self.view.window;
            [containerView.layer addAnimation:transition forKey:nil];
            [self presentViewController:UIVC animated:NO completion:nil];
        }
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _homeColView){
        return CGSizeMake((self.homeColView.frame.size.width / 3) - 20, (self.homeColView.frame.size.height / 2) - 10);
        
    } else {
        return CGSizeMake(self.createdTopicCV.frame.size.width, 75);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

/*- (IBAction)playVideo:(UIButton *)btn{
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.createdTopicCV];
    NSIndexPath *indexPathtrip = [self.createdTopicCV indexPathForItemAtPoint:buttonPosition];
    if (indexPathtrip != nil) {
        NSDictionary *dataDic = [filteredArray objectAtIndex:indexPathtrip.row];
        
        NSString *videoStr = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/%@", [dataDic valueForKey:@"video_url"]];
        
        NSURL *videoUrl = [NSURL URLWithString:videoStr];
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
        AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        _playerViewController = [[AVPlayerViewController alloc] init];
        _playerViewController.player = playVideo;
        _playerViewController.player.volume = 0;
        //_playerViewController.view.frame = self.view.bounds;
        //[self.view addSubview:_playerViewController.view];
        
        [self presentViewController:_playerViewController animated:YES completion:nil];
        _playerViewController.view.frame = self.view.frame;
        [playVideo play];
        
    }
}*/

- (IBAction)showAllImages:(UIButton *)btn{
    
    //showProgress(YES);
    
    //[[SDImageCache sharedImageCache]clearMemory];
    //[[SDImageCache sharedImageCache]clearDisk];
    
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.createdTopicCV];
    NSIndexPath *indexPathtrip = [self.createdTopicCV indexPathForItemAtPoint:buttonPosition];
    if (indexPathtrip != nil) {
        
        NSDictionary *dataDic = [filteredArray objectAtIndex:indexPathtrip.row];
        
        if ([[dataDic valueForKey:@"video_url"] isEqualToString:@""]) {
            UIImage *img1 = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"image1%ld", (long)indexPathtrip.row]];
            UIImage *img2 = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"image2%ld", (long)indexPathtrip.row]];
            UIImage *img3 =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"image3%ld", (long)indexPathtrip.row]];
            
            NSLog(@"Imagessss: %@, %@, %@", img1, img2, img3);
            
            NSMutableArray *imgArray = [[NSMutableArray alloc] init];
            if (img1 != nil) {
                NYTExamplePhoto *photo1 = [[NYTExamplePhoto alloc] init];
                photo1.image = img1;
                [imgArray addObject:photo1];
            }
            if (img2 != nil) {
                NYTExamplePhoto *photo2 = [[NYTExamplePhoto alloc] init];
                photo2.image = img2;
                [imgArray addObject:photo2];
            }
            if (img3 != nil) {
                NYTExamplePhoto *photo3 = [[NYTExamplePhoto alloc] init];
                photo3.image = img3;
                [imgArray addObject:photo3];
            }
            
            NSLog(@"Photo Images Array: %@", imgArray);
            
            NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:imgArray];
            photosViewController.rightBarButtonItem = nil;
            [self presentViewController:photosViewController animated:YES completion:nil];
        } else {
            NSString *videoStr = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/%@", [dataDic valueForKey:@"video_url"]];
            
            NSURL *videoUrl = [NSURL URLWithString:videoStr];
            AVPlayerItem* playerItem = [AVPlayerItem playerItemWithURL:videoUrl];
            AVPlayer* playVideo = [[AVPlayer alloc] initWithPlayerItem:playerItem];
            _playerViewController = [[AVPlayerViewController alloc] init];
            _playerViewController.player = playVideo;
            _playerViewController.player.volume = 0;
            //_playerViewController.view.frame = self.view.bounds;
            //[self.view addSubview:_playerViewController.view];
            
            [self presentViewController:_playerViewController animated:YES completion:nil];
            _playerViewController.view.frame = self.view.frame;
            [playVideo play];
        }
    }
}



- (void) updateViewCount {
    NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/topic_viewer_update.php"];
    
    NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"fb_id", [[NSUserDefaults standardUserDefaults] valueForKey:@"updateTopicCount"], @"topic_id", nil];
    
    NSLog(@"Update view Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Update view Response Data: %@", responseObject);
        showProgress(NO);
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:@"updateTopicCount"];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Error: %@", error);
        NSLog(@"Update view Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)fetchTopics {
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/landing_nearby_places.php"];
    
    NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [NSString stringWithFormat:@"%f", latitude],/*@"11.0169117",*/ @"lat", [NSString stringWithFormat:@"%f", longitude],/*@"76.9792926",*/ @"lang", [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"fb_id", topicDist, @"distance", nil];
    
    NSLog(@"fetch topics Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"fetch topics Response Data: %@", responseObject);
        showProgress(NO);
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                topicsArray = [NSMutableArray arrayWithArray:[responseObject objectForKey:@"topic_details"]];
                _createdTopicCV.hidden = NO;
                _noTopicsView.hidden = YES;
                filteredArray = topicsArray;
                
                [self.scrollView layoutIfNeeded];
                self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, (filteredArray.count * 85) + 560);
                _scrollContHeight.constant = (filteredArray.count * 85) + 560;
                _topicTableHeight.constant = filteredArray.count * 85;
                
                NSLog(@"Scroll cont height: %lu, %f, %f", (unsigned long)filteredArray.count, _topicTableHeight.constant,_scrollContHeight.constant);

                NSLog(@"topics Details: %@", filteredArray);
                
                [[SDImageCache sharedImageCache]clearMemory];
                [[SDImageCache sharedImageCache]clearDisk];
                
                [_createdTopicCV reloadData];
            } else {
                _createdTopicCV.hidden = YES;
                _noTopicsView.hidden = NO;
                //[filteredArray removeAllObjects];
                [self.scrollView layoutIfNeeded];
                self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, 0);
                
                [self viewDidLayoutSubviews];
                
            }
        } else {
            
            // Do the else stuff here
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Error: %@", error);
        NSLog(@"fetch topic Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


- (void)newMessageAlert {
    
    NSLog(@"New Messages Updating!!");
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/unread_message_count.php"];
    
    NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFbID"], @"sender_fb_id", nil];
    
    NSLog(@"New message alert Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"New message alert Response Data: %@", responseObject);
        showProgress(NO);
        if(responseObject)
        {
            if([[responseObject valueForKey:@"new_message_status"] integerValue] == 1) {
               _chatImageView.image  = [UIImage imageNamed:@"chatred"];
            } else {
                _chatImageView.image  = [UIImage imageNamed:@"chat-icon-128"];
            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Error: %@", error);
        NSLog(@"Update view Response error: %@", error);
    }];
}


- (void)fetchSubscribedItems {
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/subscribed_topics_with_count_ios.php"];
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id", nil];
    
    NSLog(@"Subscribed topics Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Subscribed topics Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            _noSubsView.hidden = YES;
            _homeColView.hidden = NO;
            subscribedTopicsArray = [responseObject valueForKey:@"result"];
            [_homeColView reloadData];
        } else {
            _noSubsView.hidden = NO;
            _homeColView.hidden = YES;
            //[subscribedTopicsArray removeAllObjects];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Topic Subscription Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


- (BOOL) searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    gestureRecognizera = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [gestureRecognizera setCancelsTouchesInView:NO];
    [self.createdTopicCV addGestureRecognizer:gestureRecognizera];
    [self.homeColView addGestureRecognizer:gestureRecognizera];
    [self.view addGestureRecognizer:gestureRecognizera];
    
    return YES;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        self->filteredArray = self->topicsArray;
    }else{
        NSString *searchKey = searchBar.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"topic_title contains[c] %@", searchKey];
        self->filteredArray = (NSMutableArray *) [self->topicsArray filteredArrayUsingPredicate:predicate];
        
        NSLog(@"Searched Array: %@", filteredArray);
    }
    [_createdTopicCV reloadData];
}


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
    _searchBar.text = @"";
    self->filteredArray = self->topicsArray;
    [_createdTopicCV reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self.view endEditing:YES];
}


- (IBAction)locationBtnAction:(id)sender {
}

- (IBAction)createTopicAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    createTopicVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"createTopicVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
}

- (IBAction)userDetailAction:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"profileFromHome" forKey:@"profilePath"];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    profileVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"profileVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
}

- (IBAction)chatAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    chatListVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"chatListVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
    
}

- (IBAction)shareAction:(id)sender {
    
    NSString *shareTitle = @"SEI is very useful App, To communicate Neighbors to next continent, New concept, very simple and powerful App, Am using it, download and make use of it www.seithiapp.com";
    NSArray*itemsToShare = @[shareTitle];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityVC.excludedActivityTypes = @[];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityVC animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        activityVC.modalPresentationStyle                   = UIModalPresentationPopover;
        activityVC.popoverPresentationController.sourceView = self.view;
        activityVC.popoverPresentationController.sourceRect = _createdTopicCV.frame;
        [self presentViewController:activityVC animated:YES completion:nil];
    
    }
    
}

- (IBAction)referAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    referedListVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"referedListVC"];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
}

- (IBAction)walletAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    paymentVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"paymentVC"];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
    
}

- (IBAction)settingsAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    settingsVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"settingsVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    UIView *containerView = self.view.window;
    [containerView.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDImageCache sharedImageCache]clearMemory];
    [[SDImageCache sharedImageCache]clearDisk];
    
    // Dispose of any resources that can be recreated.
}

@end

