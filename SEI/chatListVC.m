//
//  chatListVC.m
//  SEI
//
//  Created by Apple on 22/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "chatListVC.h"
#import "AppDelegate.h"
#import "chatListCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "singleChatVC.h"
#import "SlideAlertiOS7.h"



@interface chatListVC () <UITableViewDelegate, UITableViewDataSource>

{
    NSMutableArray *chatListArray;
    NSMutableArray *filteredChatListArray;
    BOOL isPushNot;
}

@end

@implementation chatListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTextCount:) name:@"UPDATECHATCOUNT" object:nil];
    
    isPushNot = NO;
    
    [self performSelector:@selector(fetchChatList) withObject:nil afterDelay:0.2f];
    
    _chatListTV.separatorColor = [UIColor clearColor];
    
    // search bar setup ----------------
    
    _searchBar.backgroundImage = [[UIImage alloc] init];
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.layer.borderColor = [[UIColor whiteColor] CGColor];
    _searchBar.layer.borderWidth = 1.0f;
    _searchBar.layer.cornerRadius = 5.0f;

    
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self performSelector:@selector(fetchChatList) withObject:nil afterDelay:0.2f];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recievedMessage:) name:@"RecievedMessageinChatList" object:nil];
    //[self performSelector:@selector(getChatList) withObject:nil afterDelay:0.25];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"RecievedMessageinChatList" object:nil];
}

- (AppDelegate *)appDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)getUnreadMessageCountforFriendId:(NSString *)friendId withIndexPath:(NSIndexPath *)indexpath
{
//    __block NSData *dataFromServer = nil;
    NSBlockOperation *downloadOperation = [[NSBlockOperation alloc] init];
//    __weak NSBlockOperation *weakDownloadOperation = downloadOperation;
    
    [self requestGetUnreadMessagesfor:friendId withIndexPath:indexpath];
    
    [[NSOperationQueue mainQueue] addOperation:downloadOperation];
}

- (void)requestGetUnreadMessagesfor:(NSString *)friendId withIndexPath:(NSIndexPath *)indexpath
{
    NSString * urlString = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/get_unread_msg_count.php"];
    NSURL * url = [NSURL URLWithString: urlString];
    
    NSMutableURLRequest *request1 = [[NSMutableURLRequest alloc] initWithURL: url];
    [request1 setHTTPMethod:@"POST"];
    [request1 setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *string = [NSString stringWithFormat:@"from_fb_id=%@&to_fb_id=%@",[defaults valueForKey:@"UserFbID"],friendId];
    NSLog(@"unread message alert = %@",string);
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    
    request1.accessibilityValue = [NSString stringWithFormat:@"%li",(long)indexpath.row];
    request1.HTTPBody = data;
    [NSURLConnection sendAsynchronousRequest:request1
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data1, NSError *error)
     {
         
         NSDictionary * unreadMessages = nil;
         
         
         if([data1 length] >= 1) {
             unreadMessages = [NSJSONSerialization JSONObjectWithData:data1 options: 0 error: nil];
             
             if(unreadMessages != nil) {
                 
                 if ([unreadMessages[@"status"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
                     chatListCell *cell = (chatListCell *)[_chatListTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:request1.accessibilityValue.integerValue inSection:0]];
                     
                     cell.lblCount.text = [NSString stringWithFormat:@"%@",unreadMessages[@"unreadmessages_count"]];
                     NSLog(@"unread message = %@ for %@",unreadMessages[@"unreadmessages_count"],friendId);
                     cell.lblCount.hidden = NO;
                     [[[self appDelegate] chatCounts] setObject:[NSString stringWithFormat:@"%@",unreadMessages[@"unreadmessages_count"]] forKey:friendId];
                 }
                 else
                 {
                     
                 }
                 
             }
         }
         
     }];
}

- (void)recievedMessage:(NSNotification *)notification
{
    isPushNot = YES;
    [self fetchChatList];
}

- (void)updateTextCount:(NSNotification *)notification
{
    [_chatListTV reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return filteredChatListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    chatListCell *cell = (chatListCell *)[tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    
    NSDictionary *dataDict = [filteredChatListArray objectAtIndex:indexPath.row];
    
    NSLog(@"chat list dict: %@", dataDict);
    
   // if ([[dataDict valueForKey:@"blocked_user"] integerValue] == 0) {
        cell.userNameLbl.text = [dataDict valueForKey:@"receiver_name"];
        
        if([[dataDict valueForKey:@"message_type"] integerValue] == 1) {
            cell.lastMessageLbl.text = @"Image";
        } else {
            
            NSData *data = [[dataDict valueForKey:@"message"] dataUsingEncoding:NSNonLossyASCIIStringEncoding];
            NSString *valueUnicode = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
            NSData *dataa = [valueUnicode dataUsingEncoding:NSUTF8StringEncoding];
            NSString *goodValue = [[NSString alloc] initWithData:dataa encoding:NSNonLossyASCIIStringEncoding];

            cell.lastMessageLbl.text = goodValue;
        }
        
        cell.timeLbl.text = [NSString stringWithFormat:@"%@", [dataDict valueForKey:@"sent_time"]];
        
        [cell.chatImg sd_setImageWithURL:[NSURL URLWithString:[dataDict objectForKey:@"receiver_image"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
        }];
    
        if([[dataDict valueForKey:@"unread_msg_count"] integerValue] > 0) {
            cell.containerView.backgroundColor = [UIColor colorWithRed:39/255.0 green:85/255.0 blue:118/255.0 alpha:1.0f];
        } else {
            cell.containerView.backgroundColor = [UIColor clearColor];
        }
    
    
        cell.chatImgView.layer.cornerRadius = 31.5f;
        cell.chatImg.layer.masksToBounds = YES;
        [cell.chatImg layoutIfNeeded];
        cell.chatImg.layer.cornerRadius = 29.5f;
    
    cell.lblCount.layer.cornerRadius = 10.0f;
    cell.lblCount.layer.masksToBounds = YES;
    cell.lblCount.hidden = YES;

    
    
    [self getUnreadMessageCountforFriendId:[dataDict valueForKey:@"receiver_id"] withIndexPath:indexPath];
        
        return cell;
  //  } else {
  //      return nil;
  //  }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [_searchBar resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataDict = [filteredChatListArray objectAtIndex:indexPath.row];
    if([[dataDict valueForKey:@"blocked_user"] integerValue] == 1) {
        return 0;
    } else {
        return 104.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"fromHomeMenu" forKey:@"privateChatPath"];
    NSDictionary *dataDict = [filteredChatListArray objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:dataDict forKey:@"fromFbDetailsCL"];
    
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
    
}

- (void)fetchChatList {
    
    if (isPushNot == NO) {
        showProgress(YES);
    } else {
        showProgress(NO);
    }
    
    NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/user_chats.php"];
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"sender_fb_id", nil];
    
    NSLog(@"Private chat list Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Private chat list Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            chatListArray = [responseObject valueForKey:@"chat_lists"];
            filteredChatListArray = chatListArray;
            [_chatListTV reloadData];
            isPushNot = NO;
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Private chat list Response error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}


//// SearchBar Handling--------------------


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked");
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0) {
        self->filteredChatListArray = self->chatListArray;
    }else{
        NSString *searchKey = searchBar.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"receiver_name  contains[c] %@", searchKey];
        self->filteredChatListArray = (NSMutableArray *) [self->chatListArray filteredArrayUsingPredicate:predicate];
        NSLog(@"Searched Array: %@", filteredChatListArray);
    }
    [self.chatListTV reloadData];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self->filteredChatListArray = self->chatListArray;
    [self.chatListTV reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)backBtnAction:(id)sender {
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
