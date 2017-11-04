//
//  createTopicVC.m
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "createTopicVC.h"
#import "homePageVC.h"
#import "AppDelegate.h"
#import "imageCell.h"

#import "MVPlaceSearchTextField.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "IQKeyboardManager.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>

@import GooglePlaces;


@interface createTopicVC () <PlaceSearchTextFieldDelegate, CLLocationManagerDelegate, UITextFieldDelegate,  UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate, UIGestureRecognizerDelegate>
{
    //UICollectionView *imageCol;
    CLLocationManager *locationManager;
    float latitude;
    float longitude;
    float createLat;
    float createLong;
    
    NSString *placeParam;
    NSString *topicTitle;
    NSString *topicDescription;
    NSString *selMediaType;
    NSString *moviePath;
    NSString *videoURLStr;
    
    BOOL isImage;
    BOOL isVideo;
    
    UIImage *chosenImage;
    UIImage *chosenVideoImage;
    NSMutableArray *imagesArray;
    NSMutableArray *videoArray;
    
}

@property (strong, nonatomic) IBOutlet UIView *mainContent;
@property (strong, nonatomic) IBOutlet MVPlaceSearchTextField *locationTF;

@end

@implementation createTopicVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // CLLocationManager to get current lat long value ***
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = 20;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // PlaceSearch Autocomplete with MVPlaceSearchTextField library
    // To get Lat Long from the entered address
    _locationTF.placeSearchDelegate                 = self;
    _locationTF.strApiKey                           = @"AIzaSyDtKYr7BcB05sGJBghwUCDtLEbiv7-t9Os";
    _locationTF.superViewOfList                     = self.mainContent;  // View, on which Autocompletion list should be appeared.
    _locationTF.autoCompleteShouldHideOnSelection   = YES;
    _locationTF.maximumNumberOfAutoCompleteRows     = 5;

    _rowHeight.constant = 0.0f;
    
    isImage = NO;
    isVideo = NO;
    
    // UI Design ***
    
    _dropDownImg.image = [_dropDownImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [_dropDownImg setTintColor:[UIColor whiteColor]];
    
    _loctView.layer.cornerRadius = 3.0f;
    _loctView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _loctView.layer.borderWidth = 1.0f;
    
    _topicTitleView.layer.cornerRadius = 3.0f;
    _topicTitleView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _topicTitleView.layer.borderWidth = 1.0f;
    
    _topicDescView.layer.cornerRadius = 3.0f;
    _topicDescView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _topicDescView.layer.borderWidth = 1.0f;

    _uploadImgView.layer.cornerRadius = 3.0f;
    _uploadImgView.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    _uploadImgView.layer.borderWidth = 1.0f;
    
    NSAttributedString *str1 = [[NSAttributedString alloc] initWithString:@"Enter topic title" attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.topicTitleTF.attributedPlaceholder = str1;
    

    self.topicDescTV.text = @"Enter topic description";
    
    _uploadView.hidden = YES;
    _uploadView.layer.cornerRadius = 5.0f;
    _imageColView.scrollEnabled = NO;
    imagesArray = [[NSMutableArray alloc] init];
    videoArray = [[NSMutableArray alloc] init];
    
    //[self appDelegate].deviceToken
    //[self appDelegate].location.coordinate.latitude, [self appDelegate].location.coordinate.longitude
    // Do any additional setup after loading the view.
    
    
    [self.topicTitleTF setDelegate:self];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.mainContent addGestureRecognizer:tap];
    
    self.mainContent.userInteractionEnabled = YES;
    
}

- (void) dismissKeyboard
{
    // add self
    
    _uploadView.hidden = YES;
    [self.topicTitleTF resignFirstResponder];
    [self.topicDescTV resignFirstResponder];
    [self.locationTF resignFirstResponder];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch=[[event allTouches] anyObject];
    if([touch view] != _uploadView)
    {
        _uploadView.hidden = YES;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:IQAutoToolbarByPosition];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [self->locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
}


// Current location lattitude longitude value **

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSLog(@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    NSLog(@"NewLocation %f %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    latitude = newLocation.coordinate.latitude;//11.0169117;//newLocation.coordinate.latitude;
    longitude = newLocation.coordinate.longitude;//76.9792926;//newLocation.coordinate.longitude;
    
    createLat = newLocation.coordinate.latitude;//11.0169117;
    createLong = newLocation.coordinate.longitude;//76.9792926;
    
    NSLog(@"Current Lat -- Long: %f, %f", latitude, longitude);
    NSLog(@"Create Lat -- Long: %f, %f", createLat, createLong);
    
    //showProgress(YES);
    [self getAddressByLatLong];
}

// Getting exact address with the lat long value ***

- (void)getAddressByLatLong {
    CLGeocoder *ceo = [[CLGeocoder alloc]init];
    CLLocation *loc = [[CLLocation alloc]initWithLatitude:createLat longitude:createLong];
    
    NSLog(@"Address finder: %f, %f", createLat, createLong);
    
    [ceo reverseGeocodeLocation: loc completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark %@",placemark);
         //String to hold address
         NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         NSLog(@"addressDictionary %@", placemark.addressDictionary);
         
         //Print the location to console
         NSLog(@"I am currently at %@",locatedAt);
         
         _locationTF.text = locatedAt;
         
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
    _locationTF.autoCompleteTableFrame = CGRectMake(20.0, _locationTF.frame.size.height+70.0, _loctView.frame.size.width, 200.0);
}

#pragma mark - Place search Textfield Delegates

// Getting Lat long value from the entered address ***

-(void)placeSearch:(MVPlaceSearchTextField*)textField ResponseForSelectedPlace:(GMSPlace *)responseDict{
    [self.view endEditing:YES];
    //NSString *latLong = [responseDict valueForKey:@"coordinate"];
    NSLog(@"SELECTED ADDRESS CREATE :%f, %f",responseDict.coordinate.latitude, responseDict.coordinate.longitude);
    createLat = responseDict.coordinate.latitude;
    createLong = responseDict.coordinate.longitude;
    
    [self->locationManager stopUpdatingLocation];
    self->locationManager = nil;
    [self getAddressByLatLong];
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


-(IBAction)openUploadView:(id)sender{
    if(imagesArray.count == 3) {
        
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Sorry!" message:@"You can choose only three photos" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:nil];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];

    } else if (videoArray.count == 1){
        UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"Sorry!" message:@"You can choose only one video" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"Ok"
                                    style:UIAlertActionStyleDefault
                                    handler:nil];
        [alert addAction:yesButton];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        _uploadView.hidden = NO;
        if (imagesArray.count > 0) {
            _uploadVideoBtn.enabled = NO;
        } else {
            _uploadVideoBtn.enabled = YES;
        }
    }
}

- (IBAction)selectImage:(id)sender{
    _uploadView.hidden = YES;
    selMediaType = @"image";
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    CFStringRef mTypes[1] = { kUTTypeImage};
    CFArrayRef mTypesArray = CFArrayCreate(CFAllocatorGetDefault(), (const void**)mTypes, 1, &kCFTypeArrayCallBacks);
    picker.mediaTypes = (__bridge NSArray*)mTypesArray;
    CFRelease(mTypesArray);
    
    //picker.videoMaximumDuration = 60.0f;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];
}

- (IBAction)selectVideo:(id)sender {
    _uploadView.hidden = YES;
    selMediaType = @"video";
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    CFStringRef mTypes[2] = { kUTTypeMovie, kUTTypeVideo };
    CFArrayRef mTypesArray = CFArrayCreate(CFAllocatorGetDefault(), (const void**)mTypes, 2, &kCFTypeArrayCallBacks);
    picker.mediaTypes = (__bridge NSArray*)mTypesArray;
    CFRelease(mTypesArray);
    
    //picker.videoMaximumDuration = 60.0f;
    picker.allowsEditing = YES;
    
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:picker animated:YES completion:nil];

}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    if([selMediaType isEqualToString:@"image"])
    {
        //image
        NSLog(@"Image Picker Called");
        chosenImage = info[UIImagePickerControllerEditedImage];
        [imagesArray addObject:chosenImage];
        [_imageColView reloadData];
        _rowHeight.constant = 90.0f;
        _colViewWidth.constant = imagesArray.count * 90;
        
        isImage = YES;
        isVideo = NO;
        
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        NSLog(@"Selected Image array: %@", imagesArray);
    }
    else if ([selMediaType isEqualToString:@"video"])
    {
        // Video
        NSLog(@"Video Picker Called");
        
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        moviePath = [videoUrl path];

        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(2, 4);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        chosenVideoImage = [[UIImage alloc] initWithCGImage:oneRef];

        
        [videoArray addObject:chosenVideoImage];
        [_imageColView reloadData];
        _rowHeight.constant = 90.0f;
        _colViewWidth.constant = videoArray.count * 90;

        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
        }
        
        isImage = NO;
        isVideo = YES;
        
        NSLog(@"Video Path: %@, %@", moviePath, videoUrl);
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        [self videoCaptured];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    isImage = NO;
    isVideo = NO;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void) videoCaptured {
    
}


// Image collection view organising ***
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if (isImage) {
        return imagesArray.count;
    } else if(isVideo) {
        return videoArray.count;
    }
    return imagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    imageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCell" forIndexPath:indexPath];
    
    //cell.activity.hidden = NO;
    //[cell.activity startAnimating];

    if (isImage) {
        cell.playerImg.hidden = YES;
        cell.imageView.image = [imagesArray objectAtIndex:indexPath.row];
    } else if (isVideo) {
        NSLog(@"Video Image");
        cell.playerImg.hidden = NO;
        [cell.imageView setImage:[videoArray objectAtIndex:indexPath.row]];
    }
    
    //[cell.imageView sd_setImageWithURL:[NSURL URLWithString:[imagesArray objectAtIndex:indexPath.row]]placeholderImage:[UIImage imageNamed:@"placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        //[cell.activity stopAnimating];
        cell.activity.hidden = YES;
        
    //}];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.layer.cornerRadius = 5.0f;
    cell.cancelBtn.tag = indexPath.row;
    [cell.cancelBtn addTarget:self action:@selector(cancelImage:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(81.0f, 81.0f);

}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionView *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10; // This is the minimum inter item spacing, can be more
}

- (IBAction)cancelImage:(UIButton *)btn{
    
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.imageColView];
    NSIndexPath *indexPathimage = [self.imageColView indexPathForItemAtPoint:buttonPosition];
    if (indexPathimage != nil) {
        NSLog(@"Image Section, Row: %ld, %ld", (long)indexPathimage.section, (long)indexPathimage.row);
        
        if (isImage) {
            [imagesArray removeObjectAtIndex:indexPathimage.row];
            if (imagesArray.count == 0) {
                _rowHeight.constant = 0;
            }
            [_imageColView reloadData];
            
        } else if (isVideo) {
            [videoArray removeObjectAtIndex:indexPathimage.row];
            if (videoArray.count == 0) {
                _rowHeight.constant = 0;
            }
            [_imageColView reloadData];
            
        }
        
    }
}

- (IBAction)finishAction:(id)sender{
    
    if (_locationTF.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Add topic location" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else if (_topicTitleTF.text.length == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Enter topic title" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    } else if (_topicDescTV.text.length == 0 || [_topicDescTV.text isEqualToString:@"Enter topic description"]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:@"Enter topic description" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        
        if(isImage){
            [self createTopicWithImage];
        } else if (isVideo){
            [self uploadVideoToServer];
            
        } else {
            [self createTopicWithImage];
        }
    }
}

- (void)createTopicWithImage {
    showProgress(YES);
    NSString *imageValue1 = [[NSString alloc] init];
    NSString *imageValue2 = [[NSString alloc] init];
    NSString *imageValue3 = [[NSString alloc] init];

    if(imagesArray.count == 1){
        imageValue1 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:0], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        imageValue2 = @"";
        imageValue3 = @"";
        
    } else if (imagesArray.count == 2) {
        imageValue1 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:0], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        imageValue2 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:1], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        imageValue3 = @"";
        
    } else if (imagesArray.count == 3) {
        imageValue1 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:0], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        imageValue2 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:1], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
        imageValue3 = [UIImageJPEGRepresentation([imagesArray objectAtIndex:2], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        
    } else if (imagesArray.count == 0)  {
        
        imageValue1 = [UIImageJPEGRepresentation([UIImage imageNamed:@"top-bar-logo-192"], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    } else {
        //
    }
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    
    NSString *createDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_add.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           [NSString stringWithFormat:@"%f", latitude], @"location_lat",
                                           [NSString stringWithFormat:@"%f", longitude], @"location_lang",
                                           [NSString stringWithFormat:@"%f", createLat], @"create_latitude",
                                           [NSString stringWithFormat:@"%f", createLong], @"create_longitude",
                                           @"5", @"create_distance",
                                           _locationTF.text, @"location_name",
                                           imageValue1, @"topic_image1",
                                           imageValue2, @"topic_image2",
                                           imageValue3, @"topic_image3",
                                           _topicTitleTF.text, @"topic_title",
                                           _topicDescTV.text, @"topic_description",
                                           createDate, @"created_date",
                                           @"", @"video_url", nil];
    
    NSLog(@"Create Topic Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Create topic Response Data: %@", responseObject);
        showProgress(NO);
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                    //[imagesArray removeAllObjects];
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionPush;
                    transition.subtype = kCATransitionFromLeft;
                    [self.view.window.layer addAnimation:transition forKey:nil];
                    
                    [self dismissViewControllerAnimated:NO completion:nil];
                    isImage = NO;
                    isVideo = NO;

                }];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                //[_tripCV reloadData];
            }
        } else {
            
            // Do the else stuff here
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Create topic Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


- (void)uploadVideoToServer {
    
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/videoUpload.php"];

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURL *filePath = [NSURL fileURLWithPath:moviePath];
    [manager POST:url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:filePath name:@"myFile" error:nil];
    } progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                
                videoURLStr = [responseObject valueForKey:@"video_url"];
                
                [self createTopicWithVideo];
                
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                //[_tripCV reloadData];
            }
        } else {
            
            // Do the else stuff here
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Create topic Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];

}

- (void) createTopicWithVideo {
    
    NSString *videoImageValue1 = [[NSString alloc] init];
    
    if(videoArray.count == 1){
        videoImageValue1 = [UIImageJPEGRepresentation([videoArray objectAtIndex:0], 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    }
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss a"];
    // or @"yyyy-MM-dd hh:mm:ss a" if you prefer the time with AM/PM
    NSLog(@"%@",[dateFormatter stringFromDate:[NSDate date]]);
    
    NSString *createDate = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_add.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           [NSString stringWithFormat:@"%f", latitude], @"location_lat",
                                           [NSString stringWithFormat:@"%f", longitude], @"location_lang",
                                           [NSString stringWithFormat:@"%f", createLat], @"create_latitude",
                                           [NSString stringWithFormat:@"%f", createLong], @"create_longitude",
                                           @"5", @"create_distance",
                                           _locationTF.text, @"location_name",
                                           @"", @"topic_image1",
                                           @"", @"topic_image2",
                                           @"", @"topic_image3",
                                           _topicTitleTF.text, @"topic_title",
                                           _topicDescTV.text, @"topic_description",
                                           createDate, @"created_date",
                                           videoURLStr, @"video_url", videoImageValue1, @"video_image_url", nil];
    
    NSLog(@"Create Topic Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Create topic Response Data: %@", responseObject);
        showProgress(NO);
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    CATransition *transition = [CATransition animation];
                    transition.duration = 0.3;
                    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                    transition.type = kCATransitionPush;
                    transition.subtype = kCATransitionFromLeft;
                    [self.view.window.layer addAnimation:transition forKey:nil];
                    
                    [self dismissViewControllerAnimated:NO completion:nil];
                    isImage = NO;
                    isVideo = NO;

                }];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Failure" message:[responseObject objectForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];
                //[_tripCV reloadData];
            }
        } else {
            
            // Do the else stuff here
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Create topic Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([_topicDescTV.text isEqualToString:@"Enter topic description"]) {
        _topicDescTV.text = @"";
        _topicDescTV.textColor = [UIColor whiteColor]; //optional
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([_topicDescTV.text isEqualToString:@""]) {
        _topicDescTV.text = @"Enter topic description";
        _topicDescTV.textColor = [UIColor whiteColor]; //optional
    }
    [_topicDescTV resignFirstResponder];
}


- (BOOL)textView:(UITextView *)textView
shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
    }
    return YES;
}

- (IBAction)backAction:(id)sender {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
