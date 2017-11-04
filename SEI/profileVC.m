//
//  profileVC.m
//  SEI
//
//  Created by Apple on 09/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "profileVC.h"
#import "profileTopicCell.h"
#import "homePageVC.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "groupChatVC.h"

@interface profileVC ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
{
    NSMutableArray *profileTopicsArray;
    NSArray *fbdetails;
    NSIndexPath *indexPathtopic;
    NSString *selectedFbId;
    NSIndexPath *indexPathNew;

    
    BOOL like;
}
@end

@implementation profileVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Page Design ***
    like = NO;
    _noTopicsView.hidden = YES;
    
    if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromHome"]){
        selectedFbId = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromSubsc"]){
        selectedFbId = [[NSUserDefaults standardUserDefaults] valueForKey:@"otherFbId"];
    } else if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromGrCt"]){
        selectedFbId = [[NSUserDefaults standardUserDefaults] valueForKey:@"grChatFbId"];
    }
    
    _profileTableView.separatorColor = [UIColor clearColor];
    
    [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.2f];
    
    
     _profileImgView.layer.cornerRadius = 60.0f;
    _profileImg.layer.masksToBounds = YES;
    [_profileImg layoutIfNeeded];
    _profileImg.layer.cornerRadius = 58.0f;
    
    
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.delegate = self;
    lpgr.delaysTouchesBegan = YES;
    [self.profileTableView addGestureRecognizer:lpgr];

    
    // Do any additional setup after loading the view.
}


-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
        return;
    }
    
    CGPoint p = [gestureRecognizer locationInView:self.profileTableView];
    
    indexPathNew = [self.profileTableView indexPathForRowAtPoint:p];
    
    if (indexPathNew == nil){
        NSLog(@"couldn't find index path");
    } else {
        if ([selectedFbId isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"]]){
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Alert" message:@"Do you want to delete this topic?" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* Cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
            
            UIAlertAction* yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                
                profileTopicCell* cell = (profileTopicCell*) [self.profileTableView cellForRowAtIndexPath:indexPathNew];
                
                NSDictionary *dataDict = [profileTopicsArray objectAtIndex:indexPathNew.row];
                
                like = YES;
                
                NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_unsubscribe.php"];
                
                NSDictionary* parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [dataDict valueForKey:@"topic_id"], @"topic_id", nil];
                
                NSLog(@"Delete Topic Request Body: %@", parametersDictionary);
                
                AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
                manager.requestSerializer = [AFHTTPRequestSerializer serializer];
                [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
                    
                    NSLog(@"Delete Topic Response Data: %@", responseObject);
                    showProgress(NO);
                    if(responseObject)
                    {
                        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Success" message:[responseObject valueForKeyPath:@"topics.message"] preferredStyle:UIAlertControllerStyleAlert];
                            
                            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action){
                                [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.2f];
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
                    NSLog(@"Delete Topic Response error: %@", error);
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
                    [alertController addAction:ok];
                    
                    [self presentViewController:alertController animated:YES completion:nil];
                }];
                
            }];
            [alertController addAction:yes];
            [alertController addAction:Cancel];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return profileTopicsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    profileTopicCell *cell = (profileTopicCell *)[tableView dequeueReusableCellWithIdentifier:@"topicCell" forIndexPath:indexPath];
    
    NSDictionary *dataDict = [profileTopicsArray objectAtIndex:indexPath.row];
    
    NSLog(@"Profile topics: %@", dataDict);
    
    
    if([selectedFbId isEqualToString:[[NSUserDefaults standardUserDefaults] stringForKey:@"UserFbID"]]){
        if([[dataDict valueForKey:@"like_val"] integerValue] == 1){
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.likeImg setTintColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:51/255.0 alpha:1.0f]];
            
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else if([[dataDict valueForKey:@"unlike_val"] integerValue] == 1){
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.unlikeImg setTintColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:0/255.0 alpha:1.0f]];
            
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
    } else {
        if([[dataDict valueForKey:@"profile_like"] integerValue] == 1){
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.likeImg setTintColor:[UIColor colorWithRed:0/255.0 green:153/255.0 blue:51/255.0 alpha:1.0f]];
            
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else if([[dataDict valueForKey:@"profile_unlike"] integerValue] == 1){
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.unlikeImg setTintColor:[UIColor colorWithRed:255/255.0 green:51/255.0 blue:0/255.0 alpha:1.0f]];
            
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        } else {
            cell.unlikeImg.image = [cell.unlikeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            cell.likeImg.image = [cell.likeImg.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }
        
    }
    
    
    
    
    cell.topicTitle.text = [dataDict valueForKey:@"topic_title"];
    cell.topicViewers.text = [NSString stringWithFormat:@"%@ Viewers", [dataDict valueForKey:@"total_viewers"]];
    cell.likeLbl.text = [NSString stringWithFormat:@"%@", [dataDict valueForKey:@"total_likes"]];
    cell.unlikeLbl.text = [NSString stringWithFormat:@"%@", [dataDict valueForKey:@"total_unlikes"]];
    
    cell.likeBtn.tag = indexPath.row;
    cell.unlikeBtn.tag = indexPath.row;
    
    [cell.likeBtn addTarget:self action:@selector(likeAction:) forControlEvents:UIControlEventTouchUpInside];

    [cell.unlikeBtn addTarget:self action:@selector(unlikeAction:) forControlEvents:UIControlEventTouchUpInside];

    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [[NSUserDefaults standardUserDefaults] setValue:@"chatFromProfile" forKey:@"chatPath"];
    NSDictionary *dataDict = [profileTopicsArray objectAtIndex:indexPath.row];
    [[NSUserDefaults standardUserDefaults] setObject:dataDict forKey:@"selectedTopic"];
    [[NSUserDefaults standardUserDefaults] setObject:fbdetails forKey:@"profileFbDetail"];
    
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


- (void)fetchProfile {
    
    if(like) {
        showProgress(NO);

    } else {
        showProgress(YES);
    }
    
    NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/profile_ios.php"];
    
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           selectedFbId, @"profile_fbid", [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id", nil];
    
    NSLog(@"Profile Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"Profile Response Data: %@", responseObject);
        showProgress(NO);
        
        _profileTableView.hidden = NO;
        _noTopicsView.hidden = YES;
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            if (like) {
                profileTopicsArray = [responseObject valueForKey:@"result"];
                [_profileTableView reloadData];

            } else {
                
                if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromHome"]){
                    
                    NSString *imgeStr = [responseObject valueForKeyPath:@"fb_details.fb_image_url"];
                    if(imgeStr.length == 0) {
                        
                        [_profileImg sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]]
                                       placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                        
                    } else {
                        [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                                       placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                    }
                    
                } else {
                    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];

                }

                
                _profileName.text = [responseObject valueForKeyPath:@"fb_details.fb_name"];
                
                profileTopicsArray = [responseObject valueForKey:@"result"];
                fbdetails = [responseObject valueForKey:@"fb_details"];
                [_profileTableView reloadData];
            }
            
            
        } else if ([[responseObject objectForKey:@"status"] integerValue] == 0 && ![selectedFbId isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"]]){
            _profileName.text = [responseObject valueForKeyPath:@"fb_details.fb_name"];
            
            if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromHome"]){
                
                NSString *imgeStr = [responseObject valueForKeyPath:@"fb_details.fb_image_url"];
                if(imgeStr.length == 0) {
                    
                    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]]
                                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                    
                } else {
                    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                }
                
            } else {
                [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                               placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                
            }
        } else if([selectedFbId isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"]] && [[responseObject objectForKey:@"status"] integerValue] == 0) {
            _profileName.text = [responseObject valueForKeyPath:@"fb_details.fb_name"];
            
            if([[[NSUserDefaults standardUserDefaults] valueForKey:@"profilePath"] isEqualToString:@"profileFromHome"]){
                
                NSString *imgeStr = [responseObject valueForKeyPath:@"fb_details.fb_image_url"];
                if(imgeStr.length == 0) {
                    
                    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]]
                                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                    
                } else {
                    [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                }
                
            } else {
                [_profileImg sd_setImageWithURL:[NSURL URLWithString:[responseObject valueForKeyPath:@"fb_details.fb_image_url"]]
                               placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
                
            }
            
            _profileTableView.hidden = YES;
            _noTopicsView.hidden = NO;
            
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"Profile Response error: %@", error);
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



- (IBAction)likeAction:(UIButton *)btn{
    
    showProgress(YES);
    
    like = YES;
    
    NSDictionary *dataDict = [[NSDictionary alloc] init];
    
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.profileTableView];
    indexPathtopic = [self.profileTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPathtopic != nil) {
        dataDict = [profileTopicsArray objectAtIndex:indexPathtopic.row];
        
        NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_like_unlike.php"];
        NSString *selfLike = [[NSString alloc] init];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[dataDict valueForKeyPath:@"fb_details.fb_id"]]) {
            selfLike = @"1";
        } else {
            selfLike = @"0";
        }
        
        
        NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                               @"1", @"like_request",
                                               @"0", @"unlike_request",
                                               selfLike, @"like_status",
                                               [dataDict valueForKey:@"topic_id"], @"topic_id", nil];
        
        NSLog(@"Like the topic Request Body: %@", parametersDictionary);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            
            NSLog(@"Like the topic Response Data: %@", responseObject);
            showProgress(NO);
            
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                
                [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.0f];
                
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            showProgress(NO);
            NSLog(@"LIke Response error: %@", error);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    }
}

- (IBAction)unlikeAction:(UIButton *)btn{
    showProgress(YES);
    
    like = YES;
    
    NSDictionary *dataDict = [[NSDictionary alloc] init];
    
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.profileTableView];
    indexPathtopic = [self.profileTableView indexPathForRowAtPoint:buttonPosition];
    if (indexPathtopic != nil) {
        dataDict = [profileTopicsArray objectAtIndex:indexPathtopic.row];
        
        NSString *url = [NSString stringWithFormat:@"http://rgmobiles.com/seithi_webservices/topic_like_unlike.php"];
        NSString *selfLike = [[NSString alloc] init];
        
        if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"] isEqualToString:[dataDict valueForKeyPath:@"fb_details.fb_id"]]) {
            selfLike = @"1";
        } else {
            selfLike = @"0";
        }
        
        
        NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id",
                                               @"0", @"like_request",
                                               @"1", @"unlike_request",
                                               selfLike, @"like_status",
                                               [dataDict valueForKey:@"topic_id"], @"topic_id", nil];
        
        NSLog(@"un Like the topic Request Body: %@", parametersDictionary);
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
            
            NSLog(@"un Like the topic Response Data: %@", responseObject);
            showProgress(NO);
            
            if([[responseObject objectForKey:@"status"] integerValue] == 1) {
                
                [self performSelector:@selector(fetchProfile) withObject:nil afterDelay:0.0f];
                
            }
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            showProgress(NO);
            NSLog(@"LIke Response error: %@", error);
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }];
    }
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
