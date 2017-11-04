//
//  singleChatVC.m
//  SEI
//
//  Created by Apple on 20/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "singleChatVC.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"

#import "NYTPhotoViewer/NYTPhotosViewController.h"
#import "NYTPhoto.h"
#import "NYTExamplePhoto.h"
#import "IQKeyboardManager.h"
#import "SlideAlertiOS7.h"



@interface singleChatVC ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
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
    BOOL sendMsg;
    NSArray *messagesArray;
    NSString *fbIdbyPath;
    NSString *profImgFbId;
    NSString *chatUserName;
    NSArray *userProfileArray;
    NSArray *userDetailsFromChatList;
    BOOL tabMove;
    BOOL isPushNot;
    
}

@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *sortedMessages;

@end


@implementation singleChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"privateChatPath"] isEqualToString:@"fromGroupChat"]){
        fbIdbyPath =  [[NSUserDefaults standardUserDefaults]  valueForKey:@"grChatFbId"];
        userProfileArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"fromFbDetails"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"privateChatPath"] isEqualToString:@"fromHomeMenu"]){
        userDetailsFromChatList = [[NSUserDefaults standardUserDefaults] objectForKey:@"fromFbDetailsCL"];
        fbIdbyPath = [userDetailsFromChatList valueForKey:@"receiver_id"];
        NSLog(@"User details from CL: %@", [userDetailsFromChatList valueForKey:@"receiver_image"]);
    }
    
    tabMove = NO;
    
    NSLog(@"User details from CL: %@", [userDetailsFromChatList valueForKey:@"receiver_image"]);
    
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:@"Type your message.." attributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }];
    self.writeMsgTF.attributedPlaceholder = str;
    
    _chatImgView.layer.cornerRadius = 24.0f;
    _chatterImg.layer.masksToBounds = YES;
    [_chatterImg layoutIfNeeded];
    _chatterImg.layer.cornerRadius = 23.0f;

    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"privateChatPath"] isEqualToString:@"fromGroupChat"]){
        [_chatterImg sd_setImageWithURL:[userProfileArray valueForKey:@"from_fb_image_url"]
                       placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
        
        _chatUserNameLbl.text = [userProfileArray valueForKey:@"from_fb_name"];

    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"privateChatPath"] isEqualToString:@"fromHomeMenu"]){
        [_chatterImg sd_setImageWithURL:[userDetailsFromChatList valueForKey:@"receiver_image"]
                       placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
        
        _chatUserNameLbl.text = [userDetailsFromChatList valueForKey:@"receiver_name"];

    }
    
    _tblChat.separatorColor = [UIColor clearColor];
    
    //Chat process ***
    sendMsg = NO;
    
    _messages = [[NSMutableArray alloc] init];
    _sortedMessages = [[NSMutableDictionary alloc] init];
    
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tblChat addSubview:refreshControl];
    
    _tblChat.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    isPushNot = NO;
    
    [self getMessages];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedMessage:) name:@"MessageRecievedInChatScreen" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardAppears:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardHides:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    _containerHeight.constant -= diff;
    
    NSLog(@"Sort Msg Count: %lu", (unsigned long)_sortedMessages.count);
    
    if (_sortedMessages.count > 0 && tabMove == NO){
        tabMove = NO;
        finalIndexPath = [NSIndexPath indexPathForRow:[_tblChat numberOfRowsInSection:_sortedMessages.count - 1] - 1 inSection:_sortedMessages.count - 1];
        [_tblChat scrollToRowAtIndexPath:finalIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    //[NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(getMessagesByTime) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MessageRecievedInChatScreen" object:nil];
    [self clearUnreadMessages];

}

- (void)clearUnreadMessages
{
    NSString  *urlPath    = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/makemsgread.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"from_fb_id", @"", @"to_fb_id", nil];
    
    NSLog(@"Get chat list Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:urlPath parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Get chat list Response Data: %@", responseObject);
        showProgress(NO);
        
        if (responseObject) {
            if ([responseObject[@"status"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                [[[self appDelegate] chatCounts] setObject:@"0" forKey:fbIdbyPath];
                [UIApplication sharedApplication].applicationIconBadgeNumber = 10;
            }else{
            }
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Create topic Response error: %@", error);
    }];

    
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)recievedMessage:(NSNotification *)notification
{
    isPushNot = YES;
    NSDictionary *person = (NSDictionary *)[notification object];
    if ([person[@"facebookId"] isEqualToString:fbIdbyPath]) {
        [self getMessages];
    }
    else
    {
        [[SlideAlertiOS7 sharedSlideAlert] showSlideAlertViewWithHighDurationWithStatus:@"Failure" withText:[NSString stringWithFormat:@"You have a new message from %@",person[@"name"]]];
    }
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
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/user_upload_chat_images_new.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"sender_fb_id",
                                           fbIdbyPath, @"receiver_fb_id",
                                           imageValue, @"chat_image",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Private chat send image Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Private chat send image Response Data: %@", responseObject);
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
        
        NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/user_send_message_new.php"];
        
        
        NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"sender_fb_id",
                                               fbIdbyPath, @"receiver_fb_id",
                                               _textView.text, @"message",
                                               [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
        
        NSLog(@"Private chat send msg Request Body: %@", parametersDictionary);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            
            NSLog(@"Private chat send msg Response Data: %@", responseObject);
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
     // Do nothing...
    }
}


- (void) getMessagesByTime {
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/user_receive_message.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"from_fb_id",
                                           fbIdbyPath, @"to_fb_id",
                                           @"0", @"limit",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Private chat receive message Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Private chat receive message Response Data: %@", responseObject);
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
                                _writeMsgTF.text = @"";
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
    
    
    if (isPushNot == NO) {
        showProgress(YES);
    } else {
        showProgress(NO);
    }
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/user_receive_message.php"];
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"from_fb_id",
                                           fbIdbyPath, @"to_fb_id",
                                           @"0", @"limit",
                                           [topicDict valueForKey:@"topic_id"], @"topic_id", nil];
    
    NSLog(@"Private chat receive message Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Private chat receive message Response Data: %@", responseObject);
        showProgress(NO);
        
        messagesArray = [responseObject valueForKey:@"messages"];
        
        if(responseObject)
        {
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                isPushNot = NO;
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

        NSLog(@"Section of Msg: %@", [[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPath.section]);
        
        dict = [[_sortedMessages objectForKey:[[self sortArrayofDates:[_sortedMessages allKeys]] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row - 1];
        
        NSLog(@"Dict Datas: %@", dict);
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        //NSData *data = [dict[@"message"] dataUsingEncoding:NSUTF8StringEncoding];
        getImg = [dict valueForKey:@"chat_image_url"];
        
        
        messageType = [dict valueForKey:@"message_type"];
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

           // [chatImg setClipsToBounds:YES];

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
            [arrowView setTintColor:[UIColor colorWithRed:169/255.0 green:193/255.0 blue:213/255.0 alpha:1.0f]];
            
            profAct.hidden = NO;
            [profAct startAnimating];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKeyPath:@"from_fb_details.from_fb_image_url"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [profAct stopAnimating];
                profAct.hidden = YES;
            }];
            
            imgBackground.layer.cornerRadius = 8.0;
            [imgBackground.layer setMasksToBounds:YES];
            imgBackground.contentMode = UIViewContentModeScaleAspectFill;
            
            NSString *aString = [dict valueForKeyPath:@"from_fb_details.from_fb_name"];
            NSArray *array = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
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
            [arrowView setTintColor:[UIColor colorWithRed:240/255.0 green:248/255.0 blue:255/255.0 alpha:1.0f]];
            
            profAct.hidden = NO;
            [profAct startAnimating];
            [imgView sd_setImageWithURL:[NSURL URLWithString:[dict valueForKeyPath:@"from_fb_details.from_fb_image_url"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] options:indexPath.row == 0 ? SDWebImageRefreshCached : 0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [profAct stopAnimating];
                profAct.hidden = YES;
            }];
            
            NSString *aString = [dict valueForKeyPath:@"from_fb_details.from_fb_name"];
            NSArray *array = [aString componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            array = [array filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF != ''"]];
            
            lblName.text = array[0];
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
        return 200;
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


- (void)keyBoardAppears:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = keyboardSize.height;
    
    
    
    
    [UIView animateWithDuration:0.75 animations:^{
        [_tblChat setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
        _bottomSpacemessageEntry.constant = height;
        [self.view layoutIfNeeded];}];
}

- (void)keyBoardHides:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    //Given size may not account for screen rotation
    int height = keyboardSize.height;
    
    _bottomSpacemessageEntry.constant = 0;
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

@end
