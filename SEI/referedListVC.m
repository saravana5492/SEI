//
//  referedListVC.m
//  SEI
//
//  Created by Apple on 25/05/17.
//  Copyright © 2017 smitiv. All rights reserved.
//

#import "referedListVC.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import "newReferVC.h"
#import "referListCell.h"
#import "withdrawVC.h"

@interface referedListVC ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *referralListArray;
    NSString *totalAmount;
}
@end

@implementation referedListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // UI Design ***
    _profileImgCont.layer.cornerRadius = 60.0f;
    _profileImgView.layer.masksToBounds = YES;
    [_profileImgView layoutIfNeeded];
    _profileImgView.layer.cornerRadius = 58.0f;
    _withDrawBtn.layer.cornerRadius = 3.0f;
    
    _referralsListTV.separatorColor = [UIColor clearColor];
    
    [_profileImgView sd_setImageWithURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"UserProfilePic"]
                   placeholderImage:[UIImage imageNamed:@"profilePlaceholder"]];
    
    _userNameLbl.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFullName"];

    
    [self performSelector:@selector(fetchReferralList) withObject:nil afterDelay:0.2f];

    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    //[self.view addGestureRecognizer:tap];

    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self performSelector:@selector(fetchReferralList) withObject:nil afterDelay:0.2f];
}

-(void)fetchReferralList {
    
    
    
    showProgress(YES);
    NSString *url = [NSString stringWithFormat:@"http://www.rgmobiles.com/seithi_webservices/referred_friend_list.php"];
    
    NSDictionary * parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                           [[NSUserDefaults standardUserDefaults] valueForKey:@"UserFbID"], @"fb_id", nil];
    
    NSLog(@"referral list Request Body: %@", parametersDictionary);
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:url parameters:parametersDictionary progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        
        NSLog(@"referral list Response Data: %@", responseObject);
        showProgress(NO);
        
        if([[responseObject objectForKey:@"status"] integerValue] == 1) {
            
            referralListArray = [responseObject valueForKey:@"referred_friend_list"];
            
            _referedMoneyLbl.text =[NSString stringWithFormat:@"$%@", [responseObject valueForKey:@"total_referred_amount"]];
            
            totalAmount = [responseObject valueForKey:@"total_referred_amount"];
            
            [_referralsListTV reloadData];
            
        } else {
            totalAmount = @"0";
            _referedMoneyLbl.text = @"0$";

            /*UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:[responseObject valueForKey:@"msg"] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
            [alertController addAction:ok];
            
            [self presentViewController:alertController animated:YES completion:nil];*/
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        showProgress(NO);
        NSLog(@"referral list error: %@", error);
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"Please check your internet connection" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }];
}

- (IBAction)refereFriendPageAction:(id)sender {
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
    newReferVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"newReferVC"];
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    
    [self.view.window.layer addAnimation:transition forKey:nil];
    [self presentViewController:UIVC animated:NO completion:nil];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return referralListArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    referListCell *cell = (referListCell *)[tableView dequeueReusableCellWithIdentifier:@"referCell" forIndexPath:indexPath];
    
    NSDictionary *dataDict = [referralListArray objectAtIndex:indexPath.row];
    
    NSLog(@"Refer topics: %@", dataDict);
    
    cell.profileName.text = [dataDict valueForKey:@"refer_friend_name"];
    cell.refersCount.text = [NSString stringWithFormat:@"Refers: %@", [dataDict valueForKey:@"refer_to_refer_friend_count"]];
    cell.referAmount.text = [NSString stringWithFormat:@"$%@", [dataDict valueForKey:@"refer_to_refer_amount"]];
    
    [cell.profileImgView sd_setImageWithURL:[NSURL URLWithString:[dataDict valueForKey:@"refer_friend_image"]] placeholderImage:[UIImage imageNamed:@"profilePlaceholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
    }];
    
    cell.profileImgCont.layer.cornerRadius = 38.5f;
    cell.profileImgView.layer.masksToBounds = YES;
    [cell.profileImgView layoutIfNeeded];
    cell.profileImgView.layer.cornerRadius = 36.5f;
    cell.referAmount.layer.borderColor = [UIColor colorWithRed:44/255.0 green:74/255.0 blue:102/255.0 alpha:1.0].CGColor;
    cell.referAmount.layer.cornerRadius = 3.0f;
    
    return cell;
    
}


- (IBAction)withDrawAction:(id)sender {
    
    if ([totalAmount integerValue] == 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Sorry" message:@"You don't have amount to withdraw" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:ok];
        
        [self presentViewController:alertController animated:YES completion:nil];

    } else {
        [[NSUserDefaults standardUserDefaults] setObject:totalAmount forKey:@"totalAmount"];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: [NSBundle mainBundle]];
        withdrawVC * UIVC = [storyboard instantiateViewControllerWithIdentifier:@"withdrawVC"];
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



- (IBAction)backBtnAction:(id)sender {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [self.view.window.layer addAnimation:transition forKey:nil];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
