//
//  groupChatVC.m
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "groupChatVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "profileVC.h"
#import "singleChatVC.h"

#import "NYTPhotoViewer/NYTPhotosViewController.h"
#import "NYTPhoto.h"
#import "NYTExamplePhoto.h"
#import "IQKeyboardManager.h"



@interface groupChatVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate>
{
    NSDictionary *topicDict;
    NSArray *fbDetails;
    
    UIRefreshControl *refreshControl;
    NSIndexPath *finalIndexPath;
    BOOL fetchComplete;
    UIImage *chosenImage;
    UIImageView *chatImg;
    NSString *messageType;
    NSString *getImg;
    NSDictionary *dict;
    NSDictionary *dictMinus;
    BOOL sendMsg;
    NSArray *messagesArray;
    NSString *fbIdbyPath;
    NSString *profImgFbId;
    NSString *profImgName;
    NSArray *fromFbDetails;
    NSString *blockStatus;
    BOOL tabMove;

}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *sortedMessages;

@end


@implementation groupChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _userProfOptionView.hidden = YES;
    _userProfOptionView.layer.cornerRadius = 4.0f;
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];

    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"]){
        //topicDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTopic"];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTopic"];
        topicDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"profileFbDetail"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        topicDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTopic"];
        fbDetails = [[NSUserDefaults standardUserDefaults] objectForKey:@"profileFbDetail"];
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]) {
        topicDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectedTopic"];
    }

    
    tabMove = NO;
    
    NSLog(@"Topic Selected: %@", topicDict);
    NSLog(@"Fb details: %@", fbDetails);
    
    // Load datas ***
    _topicTitleLbl.text = [topicDict valueForKey:@"topic_title"];
    _topicDescLbl.text = [topicDict valueForKey:@"topic_description"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        _userNameLbl.text = [topicDict valueForKeyPath:@"fb_details.fb_name"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        _userNameLbl.text = [fbDetails valueForKey:@"fb_name"];
    }
    
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        if ([[topicDict valueForKey:@"topic_subscribe_status"] integerValue] == 1){
            _addTopicBtn.hidden = YES;
        } else {
            _addTopicBtn.hidden = NO;
        }
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]) {
        if ([[topicDict valueForKey:@"subscribe_status"] integerValue] == 1){
            _addTopicBtn.hidden = YES;
        } else {
            _addTopicBtn.hidden = NO;
        }
    }
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"]){
        if ([[topicDict valueForKey:@"user_subscribe_status"] integerValue] == 1 || [[topicDict valueForKeyPath:@"fb_details.fb_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserFbID"]]){
            _addUserBtn.hidden = YES;
        } else {
            _addUserBtn.hidden = NO;
        }
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        if ([[topicDict valueForKey:@"user_subscribe_status"] integerValue] == 1 || [[fbDetails valueForKey:@"fb_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserFbID"]]){
            _addUserBtn.hidden = YES;
        } else {
            _addUserBtn.hidden = NO;
        }
    } else if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"] || [[topicDict valueForKeyPath:@"fb_details.fb_id"] isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserFbID"]]) {
        if ([[topicDict valueForKey:@"user_subscribe_status"] integerValue] == 1 ){
            _addUserBtn.hidden = YES;
        } else {
            _addUserBtn.hidden = NO;
        }
    }
    
    _viewersCountLbl.text = [NSString stringWithFormat:@"%@ Viewers", [topicDict valueForKey:@"total_viewers"]];
    
    _topicDateLbl.text = [NSString stringWithFormat:@"%@ %@", [topicDict valueForKey:@"created_date"], [topicDict valueForKey:@"created_time"]];
    _topicPlace.text = [topicDict valueForKey:@"location_name"];
    
    _likeCountLbl.text = [NSString stringWithFormat:@"%@", [topicDict valueForKey:@"total_likes"]];
    _dislikeCountLbl.text = [NSString stringWithFormat:@"%@", [topicDict valueForKey:@"total_unlikes"]];
    
    _userView.layer.borderWidth = 1.0f;
    _userView.layer.borderColor = [UIColor colorWithRed:45/255.0 green:95/255.0 blue:135/255.0 alpha:1.0].CGColor;
    _userView.layer.cornerRadius = 3.0f;
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Type your message.." attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.writeMsgTF.attributedPlaceholder = str;
    
    _tblChat.separatorColor = [UIColor clearColor];
    
    if([[topicDict valueForKey:@"like_val"] integerValue] == 1){
        _likeImgView.image = [_likeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_likeImgView setTintColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:51/255.0 alpha:1.0f]];
        
        _unlikeImgView.image = [_unlikeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else if([[topicDict valueForKey:@"unlike_val"] integerValue] == 1){
        _unlikeImgView.image = [_unlikeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_unlikeImgView setTintColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:0/255.0 alpha:1.0f]];
        
        _likeImgView.image = [_likeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
         _unlikeImgView.image = [_unlikeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        _likeImgView.image = [_likeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    
    //Chat process ***
    sendMsg = NO;

    _messages = [[NSMutableArray alloc] init];
    _sortedMessages = [[NSMutableDictionary alloc] init];

    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblChat addSubview:refreshControl];

    _tblChat.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self getMessages];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppears:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHides:) name:UIKeyboardWillHideNotification object:nil];

    
    UILongPressGestureRecognizer *twoTouchLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    twoTouchLongPress.delegate = self;
    twoTouchLongPress.numberOfTouchesRequired = 1;
    [self.userNameLbl addGestureRecognizer:twoTouchLongPress];
    
    
    _attachBtn.layer.cornerRadius = 11.0f;
    //_sendBtn.layer.cornerRadius = 8.0f;
    
    // Type text view option ***
    
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 4;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _textView.returnKeyType = UIReturnKeyGo; //just as an example
    _textView.textColor = [UIColor whiteColor];
    _textView.font = [UIFont systemFontOfSize:13.0f];
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor colorWithRed:63/255.0 green:92/255.0 blue:122/255.0 alpha:1.0f];
    _textView.placeholder = @"Type your message..";
    _textView.layer.cornerRadius = 5.0f;
    _textView.tintColor = [UIColor whiteColor];
    _textView.returnKeyType = UIReturnKeyDefault;
    
}


- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    
    float diff = (growingTextView.frame.size.height - height);
    NSLog(@"Sort Msg Count: %f", diff);
 
    _containerHeight.constant -= diff;
    
    _scrollTopSpace.constant += diff;
    //CGRect r = _scrollContView.frame;
    //r.origin.y += diff;
    //_scrollContView.frame = r;
    
    
/*    if (_sortedMessages.count > 0 && tabMove == NO){
        tabMove = NO;
        finalIndexPath = [NSIndexPath indexPathForRow:[_tblChat numberOfRowsInSection:_sortedMessages.count - 1] - 1 inSection:_sortedMessages.count - 1];
        [_tblChat scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }*/
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, _topViewHeight.constant + 307.0);
    self.tableHeight.constant = self.scrollView.contentSize.height - _topViewHeight.constant;
    
    [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(getMessagesByTime) userInfo:nil repeats:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@"Gesture called!!");

    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        NSLog(@"No gesture called!!");
        return;
    }
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
    }

    if (![fbIdbyPath isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"]]) {
        

        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Do you want to block the user?" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            
            [self blockUser];
            
        }];
        
        [alertController addAction:cancel];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        // Do the stuff

    }
}


-(void)blockUser {
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/block_user.php"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
    }
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           fbIdbyPath, @"block_id",
                                           @"1", @"block_status", nil];
    
    NSLog(@"Block User Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Block User Response Data: %@", responseObject);
        showProgress(NO);
        
        messagesArray = [responseObject valueForKey:@"messages"];
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];

            } else {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:ok];
                
                [self presentViewController:alertController animated:YES completion:nil];

            }
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Block User Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
    
}

- (IBAction)selectPhoto:(UIButton *)sender{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    chosenImage = info[UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    [self sendChatImage];
    
}



- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)sendChatImage{
    
    showProgress(YES);
    NSString *imageValue = [UIImageJPEGRepresentation(chosenImage, 0.8) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/upload_chat_images.php"];
    
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
    }
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"sender_fb_id",
                                           fbIdbyPath, @"receiver_fb_id",
                                           imageValue, @"chat_image",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Group chat send image Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Group chat send image Response Data: %@", responseObject);
        //showProgress(NO);
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                [self getMessages];
            }
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

- (IBAction)actionSend:(id)sender {
    
    if (_textView.text.length != 0) {
        showProgress(YES);

        sendMsg = YES;
        
        NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/send_message.php"];
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"]){
            
        } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
            
        }
        
        if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
            fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
        } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
            fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
        }
        
        
        NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"sender_fb_id",
                                               fbIdbyPath, @"receiver_fb_id",
                                               _textView.text, @"message",
                                               [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
        
        NSLog(@"Group chat send msg Request Body: %@", parametersDictionary);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            
            NSLog(@"Group chat send msg Response Data: %@", responseObject);
            //showProgress(NO);
            
            if(responseObject)
            {
                if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                    [self getMessages];
                }
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            showProgress(NO);
            NSLog(@"Create topic Response error: %@", error);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    } else {
        
    }
}

- (void) getMessagesByTime {
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/receive_message.php"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"]){
        
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        
    }
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
    }
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"from_fb_id",
                                           fbIdbyPath, @"to_fb_id",
                                           @"0", @"limit",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Group chat receive message Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Group chat receive message Response Data: %@", responseObject);
        showProgress(NO);
        
        messagesArray = [responseObject valueForKey:@"messages"];
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                if (messagesArray.count > 0){
                    if ([responseObject[@"msg"] isEqualToString:@"Result Found"]) {
                        [_messages removeAllObjects];
                        [_messages addObjectsFromArray:messagesArray];
                        
                        NSLog(@"responseee messages: %@", _messages);
                        [self sortMessageswitDate];
                        if (!fetchComplete) {
                            
                            NSLog(@"Its working fetching");
                            
                            if (sendMsg){
                                _textView.text = @"";
                            }
                            [_tblChat reloadData];
                            finalIndexPath = [NSIndexPath indexPathForRow:[_tblChat numberOfRowsInSection:_sortedMessages.count - 1] - 1 inSection:_sortedMessages.count - 1];
                            [_tblChat scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                        }
                    }
                }
            }
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

- (void)getMessages {
    
    
    if(sendMsg == NO) {
        showProgress(YES);
    }
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/receive_message.php"];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"]){
        
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        
    }

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        fbIdbyPath = [topicDict valueForKeyPath:@"fb_details.fb_id"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        fbIdbyPath = [fbDetails valueForKey:@"fb_id"];
    }
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"from_fb_id",
                                           fbIdbyPath, @"to_fb_id",
                                           @"0", @"limit",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Group chat receive message Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Group chat receive message Response Data: %@", responseObject);
        showProgress(NO);
        
        messagesArray = [responseObject valueForKey:@"messages"];
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                if (messagesArray.count > 0){
                    if ([responseObject[@"msg"] isEqualToString:@"Result Found"]) {
                        [_messages removeAllObjects];
                        [_messages addObjectsFromArray:messagesArray];
                        
                        NSLog(@"responseee messages: %@", _messages);
                        [self sortMessageswitDate];
                        if (!fetchComplete) {
                            if (sendMsg){
                                tabMove = YES;
                                _textView.text = @"";
                            }
                            [_tblChat reloadData];
                            finalIndexPath = [NSIndexPath indexPathForRow:[_tblChat numberOfRowsInSection:_sortedMessages.count - 1] - 1 inSection:_sortedMessages.count - 1];
                            [_tblChat scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                            
                        }
                    }
                }
            }
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


#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _sortedMessages.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_sortedMessages objectForKey:[[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:section]] count] + 1;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"date" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *lblDate = (UILabel *)[cell viewWithTag:43];
        
        NSString *sortedDate = [[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPath.section];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSDate *sendDate = [formatter dateFromString:sortedDate];

        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy - EEE"];
        lblDate.text = [dateFormatter stringFromDate:sendDate];
        
        return cell;
    } else {
        
        dict = [[_sortedMessages objectForKey:[[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row - 1];
        
        NSLog(@"Dict Datas and Previous: %@, %@", dict, dictMinus);
        
        
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        getImg = [dict valueForKey:@"chat_image_url"];
        
        
        messageType = [dict valueForKey:@"message_type"];

        //NSData *data = [dict[@"message"] dataUsingEncoding:NSUTF8StringEncoding];
        //NSString *goodValue = [[NSString alloc] initWithData:data encoding:NSNonLossyASCIIStringEncoding];
        
         NSData *data = [dict[@"message"] dataUsingEncoding:NSNonLossyASCIIStringEncoding];
         NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         
         NSData *dataa = [valueUnicode dataUsingEncoding:NSUTF8StringEncoding];
         NSString *goodValue = [[NSString alloc] initWithData:dataa encoding:NSNonLossyASCIIStringEncoding];
         
        
        
        if ([dict[@"from_fb_id"] isEqualToString:[defaults stringForKey:@"UserFbID"]]) {
            UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"right" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:10];
            UIImageView *arrowView = (UIImageView *)[cell viewWithTag:95];
            UILabel *lblTime = (UILabel *)[cell viewWithTag:93];
            UILabel *lblName = (UILabel *)[cell viewWithTag:37];
            UIActivityIndicatorView *profAct = (UIActivityIndicatorView *)[cell viewWithTag:94];
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cell viewWithTag:53];
            
            UILabel *lblDescription = (UILabel *)[cell viewWithTag:30];
            UIImageView *imgBackground = (UIImageView *)[cell viewWithTag:40];
            chatImg = (UIImageView *)[cell viewWithTag:50];
            [chatImg setClipsToBounds:YES];
            UIButton *btnView = (UIButton *)[cell viewWithTag:60];
            [btnView addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            
            UIButton *btnChatImg = (UIButton *)[cell viewWithTag:47];
            
            [btnChatImg addTarget:self action:@selector(showChatImage:) forControlEvents:UIControlEventTouchUpInside];
            
            if([messageType isEqualToString:@"0"]){
                chatImg.hidden = YES;
                btnChatImg.hidden = YES;
                lblDescription.hidden = NO;
                //chatImg.image = [UIImage imageWithData:imgData];
            } else if([messageType isEqualToString:@"1"]){
                chatImg.hidden = NO;
                btnChatImg.hidden = NO;
                lblDescription.hidden = YES;
            }
            
            imgView.layer.cornerRadius = 30.0f;
            imgView.layer.masksToBounds = YES;
            
            arrowView.image = [arrowView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [arrowView setTintColor:[UIColor colorWithRed:213/255.0 green:230/255.0 blue:232/255.0 alpha:1.0f]];
            
            if([dict valueForKeyPath:@"from_fb_details.from_fb_image_url"] == [NSNull null]){
                imgView.image = [UIImage imageNamed:@"profilePlaceholder"];
            } else {
                profAct.hidden = NO;
                [profAct startAnimating];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKeyPath:@"from_fb_details.from_fb_image_url"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [profAct stopAnimating];
                    profAct.hidden = YES;
                }];
            }

            
            
            imgBackground.layer.cornerRadius = 8.0;
            [imgBackground.layer setMasksToBounds:YES];
            imgBackground.contentMode = UIViewContentModeScaleAspectFill;

            
            
            //NSString *aString = [dict valueForKeyPath:@"from_fb_details.from_fb_name"];
            //NSArray *array = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            //array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            lblName.text = @"Me";
            lblTime.text = [dict valueForKey:@"sent_time"];
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
            //chatImg.image = [UIImage imageWithData:imgData];
            //[chatImg sd_setImageWithURL:[NSURL URLWithString:getImg] placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0];
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:getImg] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (image && finished) {
                    // Cache image to disk or memory
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"image%ld%ld", (long)indexPath.section,(long)indexPath.row] toDisk:YES];
                }
            }];

            
            activity.hidden = NO;
            [activity startAnimating];
            [chatImg sd_setImageWithURL:[NSURL URLWithString:getImg] placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activity stopAnimating];
                activity.hidden = YES;
            }];
            
            lblDescription.text = goodValue;
            
            return cell;
        }
        else
        {
            UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:@"left" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIActivityIndicatorView *activity = (UIActivityIndicatorView *)[cell viewWithTag:53];
            UIImageView *imgView = (UIImageView *)[cell viewWithTag:10];
            UIImageView *arrowView = (UIImageView *)[cell viewWithTag:95];
            UILabel *lblTime = (UILabel *)[cell viewWithTag:93];
            UILabel *lblName = (UILabel *)[cell viewWithTag:37];
            UILabel *lblNameHide = (UILabel *)[cell viewWithTag:20];
            UILabel *lblidHide = (UILabel *)[cell viewWithTag:143];
            
            UIActivityIndicatorView *profAct = (UIActivityIndicatorView *)[cell viewWithTag:94];
            UILabel *lblDescription = (UILabel *)[cell viewWithTag:30];
            UIImageView *imgBackground = (UIImageView *)[cell viewWithTag:40];
            chatImg = (UIImageView *)[cell viewWithTag:50];
            [chatImg setClipsToBounds:YES];
            UIButton *btnView = (UIButton *)[cell viewWithTag:60];
            [btnView addTarget:self action:@selector(showImage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            UIButton *btnProfile = (UIButton *)[cell viewWithTag:100];
            btnProfile.tag = indexPath.row;
            
            NSLog(@"Profile Img btn tag: %ld", (long)btnProfile.tag);
            
            [btnProfile addTarget:self action:@selector(actionShowProfile:) forControlEvents:UIControlEventTouchUpInside];
            imgView.layer.cornerRadius = 30.0f;
            imgView.layer.masksToBounds = YES;
            
            imgBackground.layer.cornerRadius = 8.0;
            [imgBackground.layer setMasksToBounds:YES];
            imgBackground.contentMode = UIViewContentModeScaleAspectFill;
            
            UIButton *btnChatImg = (UIButton *)[cell viewWithTag:47];
            
            [btnChatImg addTarget:self action:@selector(showChatImage:) forControlEvents:UIControlEventTouchUpInside];
            
            if([messageType isEqualToString:@"0"]){
                chatImg.hidden = YES;
                btnChatImg.hidden = YES;
                lblDescription.hidden = NO;
                //chatImg.image = [UIImage imageWithData:imgData];
            } else if([messageType isEqualToString:@"1"]){
                chatImg.hidden = NO;
                btnChatImg.hidden = NO;
                lblDescription.hidden = YES;
            }
            
            arrowView.image = [arrowView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [arrowView setTintColor:[UIColor colorWithRed:249/255.0 green:232/255.0 blue:232/255.0 alpha:1.0f]];
            
            if([dict valueForKeyPath:@"from_fb_details.from_fb_image_url"] == [NSNull null]){
                imgView.image = [UIImage imageNamed:@"profilePlaceholder"];
            } else {
                profAct.hidden = NO;
                [profAct startAnimating];
                [imgView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKeyPath:@"from_fb_details.from_fb_image_url"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [profAct stopAnimating];
                    profAct.hidden = YES;
                }];
            }

            if([dict valueForKeyPath:@"from_fb_details.from_fb_name"] == [NSNull null] || [[dict valueForKeyPath:@"from_fb_details.from_fb_name"] isEqualToString:@""]){
                lblName.text  = @"";
                lblNameHide.text = @"";
            } else {
                
                lblNameHide.text = [dict valueForKeyPath:@"from_fb_details.from_fb_name"];
                
                NSString *aString = [dict valueForKeyPath:@"from_fb_details.from_fb_name"];
                NSArray *array = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
                
                lblName.text = array[0];
            }
            
            lblTime.text = [dict valueForKey:@"sent_time"];
            lblidHide.text = [dict valueForKey:@"from_fb_id"];
            
            NSLog(@"Profile fb id check: %@", lblidHide.text);
            
            
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.backgroundColor = [UIColor clearColor];
            
            
            [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:getImg] options:SDWebImageDownloaderUseNSURLCache progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                
                if (image && finished) {
                    // Cache image to disk or memory
                    [[SDImageCache sharedImageCache] storeImage:image forKey:[NSString stringWithFormat:@"image%ld%ld", (long)indexPath.section,(long)indexPath.row] toDisk:YES];
                }
            }];
            
            activity.hidden = NO;
            [activity startAnimating];
            [chatImg sd_setImageWithURL:[NSURL URLWithString:getImg] placeholderImage:nil options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [activity stopAnimating];
                activity.hidden = YES;
            }];
            
            
            lblDescription.text = goodValue;
            
            return cell;
        }
    }
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //minimum size of your cell, it should be single line of label if you are not clear min. then return UITableViewAutomaticDimension;
    if (indexPath.row == 0) {
        return 33;
    } else if(!chatImg.hidden){
        return 221;
    }
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 33;
    } else if(!chatImg.hidden){
        return 221;
    }
    return UITableViewAutomaticDimension;
    
}



- (NSArray *)sortArrayonDaye:(NSArray *)array
{
    NSMutableArray *arraytoSort = [[NSMutableArray alloc] initWithArray:array];
    NSDateFormatter *fmtDate = [[NSDateFormatter alloc] init];
    [fmtDate setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    
    
    NSComparator compareDates = ^(id string1, id string2)
    {
        NSDate *date1 = [fmtDate dateFromString:string1];
        NSDate *date2 = [fmtDate dateFromString:string2];
        
        return [date1 compare:date2];
    };
    
    
    NSSortDescriptor * sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"sent_time" ascending:YES comparator:compareDates];
    [arraytoSort sortUsingDescriptors:@[sortDesc1]];
    
    return arraytoSort;
}

- (void)sortMessageswitDate
{
    fetchComplete = NO;
    int containCount = 0;
    for (NSDictionary *dict1 in _messages) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM dd, yyyy HH:mm a"];
        NSDate *sendDate = [formatter dateFromString:[NSString stringWithFormat:@"%@ %@", dict1[@"sent_date"], dict1[@"sent_time"]]];
        
        //May 19, 2017 17:24 PM
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *strSendDate = [dateFormatter stringFromDate:sendDate];
        
        NSLog(@"Date String: %@,%@", strSendDate, [NSString stringWithFormat:@"%@ %@", dict1[@"sent_date"], dict1[@"sent_time"]]);
        
        if (![[_sortedMessages allKeys] containsObject:strSendDate]) {
            [_sortedMessages setObject:[[NSMutableArray alloc] init] forKey:strSendDate];
            
        }
        if (![[_sortedMessages objectForKey:strSendDate] containsObject:dict1]) {
            [[_sortedMessages objectForKey:strSendDate] addObject:dict1];
        }
        else
        {
            containCount ++;
            
        }
    }
    if (_messages.count == containCount) {
        fetchComplete = YES;
        
    }
}

- (NSArray *)sortArrayofDates:(NSArray *)arraytobesorted
{
    NSSortDescriptor *descriptor=[[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
    NSArray *descriptors=[NSArray arrayWithObject: descriptor];
    NSArray *reverseOrder=[arraytobesorted sortedArrayUsingDescriptors:descriptors];
    
    return reverseOrder;
}


- (IBAction)showChatImage:(UIButton *)btn{
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tblChat];
    NSIndexPath *indexPathtopic = [self.tblChat indexPathForRowAtPoint:buttonPosition];
    if (indexPathtopic != nil) {
        //NSDictionary *dictPass = [[_sortedMessages objectForKey:[[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPathtopic.section]] objectAtIndex:indexPathtopic.row - 1];

        UIImage *img1 = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[NSString stringWithFormat:@"image%ld%ld", (long)indexPathtopic.section,(long)indexPathtopic.row]];
        
        NSMutableArray *imgArray = [[NSMutableArray alloc] init];
        if (img1 != nil) {
            NYTExamplePhoto *photo1 = [[NYTExamplePhoto alloc] init];
            photo1.image = img1;
            [imgArray addObject:photo1];
        }
        
        NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:imgArray];
        photosViewController.rightBarButtonItem = nil;
        [self presentViewController:photosViewController animated:YES completion:nil];
        
    }
}


- (IBAction)actionShowProfile:(UIButton *)btn{
    _userProfOptionView.hidden = NO;

    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tblChat];
    NSIndexPath *indexPathtopic = [self.tblChat indexPathForRowAtPoint:buttonPosition];
    if (indexPathtopic != nil) {
        
        NSDictionary *dictPass = [[_sortedMessages objectForKey:[[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPathtopic.section]] objectAtIndex:indexPathtopic.row - 1];
        
        blockStatus = [dictPass valueForKey:@"blocked_user"];
        
        NSLog(@"Block User State: %@", blockStatus);
        
        fromFbDetails = [dictPass valueForKey:@"from_fb_details"];
        
        NSLog(@"PAssdict: %@", fromFbDetails);
        
        UITableViewCell *cell = (UITableViewCell *)[_tblChat cellForRowAtIndexPath:indexPathtopic];
        
        UILabel *lblValue = (UILabel *)[cell viewWithTag:143];
        UILabel *lblNamehi = (UILabel *)[cell viewWithTag:20];
        
        profImgFbId = lblValue.text;
        profImgName = lblNamehi.text;
        
     }
}

- (IBAction)singleChatAction:(id)sender {
    
    if([blockStatus integerValue] == 0){
        _userProfOptionView.hidden = YES;
        
        [[NSUserDefaults standardUserDefaults] setValue:profImgFbId forKey:@"grChatFbId"];
        [[NSUserDefaults standardUserDefaults] setObject:fromFbDetails forKey:@"fromFbDetails"];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"fromGroupChat" forKey:@"privateChatPath"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
        singleChatVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"singleChatVC"];
        CATransition *transition = [CATransition animation];
        transition.duration = 0.3;
        transition.timingFunction =
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        
        UIView *containerView = self.view.window;
        [containerView.layer addAnimation:transition forKey:nil];
        [self presentViewController:UIVC animated:NO completion:nil];
        
    } else {
        _userProfOptionView.hidden = YES;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"You have blocked this user" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (IBAction)showProfileAction:(id)sender {
    _userProfOptionView.hidden = YES;
    [[NSUserDefaults standardUserDefaults] setValue:profImgFbId forKey:@"grChatFbId"];
    
    [[NSUserDefaults standardUserDefaults] setValue:@"profileFromGrCt" forKey:@"profilePath"];
    
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


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    NSLog(@"Touch outside!!");
    
    UITouch *touch = [touches anyObject];
    if(touch.view.tag!=88 && touch.view.tag != 38){
        NSLog(@"Touch inside!!");
        _userProfOptionView.hidden=YES;
    }
}

- (void)keyBoardAppears:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = keyboardSize.height;
    
    
    
    
    [UIView animateWithDuration:0.75 animations:^{
        //[_tblChat setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        NSLog(@"top View Height: %f",76 + _topicDescHeight.constant + _placeAddreHeight.constant);
        
        _bottomSpacemessageEntry.constant = height;
        _scrollTopSpace.constant = - height;
        _scrollView.scrollEnabled = NO;
        [self.view layoutIfNeeded];}];
}

- (void)keyBoardHides:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = keyboardSize.height;
    
    _bottomSpacemessageEntry.constant = 0;
    _scrollTopSpace.constant = 0;
    _scrollView.scrollEnabled = YES;


    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.75 animations:^{[self.view layoutIfNeeded];}];
}

- (void)handleRefresh:(id)sender
{
    [self getMessages];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;

    float reload_distance = 10;
    if(y > h + reload_distance) {
        NSLog(@"load more rows");
        [self getMessages];
    }
}



- (IBAction)likeAction:(id)sender {
    
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_like_unlike.php"];
    NSString *selfLike = [[NSString alloc] init];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[topicDict valueForKeyPath:@"fb_details.fb_id"]] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[fbDetails valueForKey:@"fb_id"]]) {
        selfLike = @"1";
    } else {
        selfLike = @"0";
    }
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           @"1", @"like_request",
                                           @"0", @"unlike_request",
                                           selfLike, @"like_status",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Like the topic Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Like the topic Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            _likeCountLbl.text = [responseObject valueForKey:@"total_likes"];
            _dislikeCountLbl.text = [responseObject valueForKey:@"total_unlikes"];
            
            if([[responseObject valueForKey:@"like_request"] integerValue] == 1){
                _likeImgView.image = [_likeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [_likeImgView setTintColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:51/255.0 alpha:1.0f]];
                
                _unlikeImgView.image = [_unlikeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
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

- (IBAction)unlikeAction:(id)sender {
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_like_unlike.php"];
    NSString *selfLike = [[NSString alloc] init];
    
    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[topicDict valueForKeyPath:@"fb_details.fb_id"]] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[fbDetails valueForKey:@"fb_id"]]) {
        selfLike = @"1";
    } else {
        selfLike = @"0";
    }
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           @"0", @"like_request",
                                           @"1", @"unlike_request",
                                           selfLike, @"like_status",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"un Like the topic Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"un Like the topic Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            _likeCountLbl.text = [responseObject valueForKey:@"total_likes"];
            _dislikeCountLbl.text = [responseObject valueForKey:@"total_unlikes"];
            
            if([[responseObject valueForKey:@"unlike_request"] integerValue] == 1){
                _unlikeImgView.image = [_unlikeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                [_unlikeImgView setTintColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:0/255.0 alpha:1.0f]];
                
                _likeImgView.image = [_likeImgView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            }
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



- (IBAction)topicSubscribeAction:(id)sender {
    
    showProgress(YES);
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_subscribe.php"];
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Topic Subscription Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Topic Subscription Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"Topic Added Successfully" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                _addTopicBtn.hidden = YES;
            }];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
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


- (IBAction)userSubscribeAction:(id)sender {
    showProgress(YES);
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_user_subscribe.php"];
    
    
    NSDictionary * parametersDictionary = [[NSDictionary alloc] init];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHome"] || [[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromHomeSubs"]){
        parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                [topicDict valueForKey:@"topic_id"], @"topic_id",
                                [topicDict valueForKey:@"location_lat"], @"location_lat",
                                [topicDict valueForKey:@"location_lang"], @"location_lang",
                                [topicDict valueForKey:@"location_name"], @"location_name",
                                [topicDict valueForKeyPath:@"fb_details.fb_id"], @"topic_user_fb_id",
                                [topicDict valueForKeyPath:@"fb_details.fb_name"], @"topic_user_fb_name",
                                [topicDict valueForKeyPath:@"fb_details.fb_email"], @"topic_user_fb_email",
                                [topicDict valueForKeyPath:@"fb_details.fb_image_url"], @"topic_user_fb_image_url",
                                [topicDict valueForKey:@"topic_description"], @"topic_description", nil];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"chatPath"] isEqualToString:@"chatFromProfile"]){
        parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                [topicDict valueForKey:@"topic_id"], @"topic_id",
                                [topicDict valueForKey:@"location_lat"], @"location_lat",
                                [topicDict valueForKey:@"location_lang"], @"location_lang",
                                [topicDict valueForKey:@"location_name"], @"location_name",
                                [fbDetails valueForKey:@"fb_id"], @"topic_user_fb_id",
                                [fbDetails valueForKey:@"fb_name"], @"topic_user_fb_name",
                                [fbDetails valueForKey:@"fb_email"], @"topic_user_fb_email",
                                [fbDetails valueForKey:@"fb_image_url"], @"topic_user_fb_image_url",
                                [topicDict valueForKey:@"topic_description"], @"topic_description", nil];
    }

    NSLog(@"User Subscription Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"User Subscription Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:@"User Added Successfully" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                _addUserBtn.hidden = YES;
            }];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
