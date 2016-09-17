//
//  BuyNewAddOnServicesViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "BuyNewAddOnServicesViewController.h"
#import "AppManager.h"
#import "AvailableSubscriptionsTableViewCell.h"

@interface BuyNewAddOnServicesViewController ()<MOStoreButtonDelegate>
{
    AppManager* appMngr;
    NSArray<SubscriptionClass *> *subscriptionsList;
    float currentProgress;
}

@end

@implementation BuyNewAddOnServicesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    [appMngr getAllAvailableSubscriptionsByType:SubscriptionTypeAddon CompletionHandler:^(NSArray<SubscriptionClass *> * _Nullable objArr, NSError * _Nullable error, NSString * _Nullable msgToUI) {
        subscriptionsList = objArr;
        if(objArr!= nil && objArr.count > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                [_availableSubscriptionsTableView reloadData];
            });
        }else{
            ALog("NO Subscription found");
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)onCloseToolbarBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return subscriptionsList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"AvailableAddonSubscriptionsTableViewCell";
    AvailableSubscriptionsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(128.0/256.0) green:(128.0/256.0) blue:(128.0/256.0) alpha:0.05f];
    
    SubscriptionClass *obj = [subscriptionsList objectAtIndex:indexPath.row];
    
    [cell.planNameLabel setText:obj.PlanName];
    [cell.planDescriptionTextView setText:obj.PlanDescription];
    
    if(cell.buyBtn == nil){
        cell.buyBtn =[[MOStoreButton alloc]initWithFrame:CGRectMake(0, 0, cell.buyBtnView.bounds.size.width, cell.buyBtnView.bounds.size.height) andColor:[UITools colorFromHexString:@"#0080FC"]];
        cell.buyBtn.buttonDelegate = self;
        UIFont *f = [UIFont fontWithName:@"SFUIText-Semibold" size:12.0f];
        if(f==nil){
            ALog("Font is nil");
        }
        
        cell.buyBtn.titleLabel.font =f;
        cell.buyBtn.finishedDownloadingButtonTitle =@"INSTALLED";
        [cell.buyBtn setTitles: ((obj.Price.intValue <= 0) ? @[@"GET",@"INSTALL"] : @[[ NSString stringWithFormat:@"$%0.2f", obj.Price.floatValue],@"BUY"]) ];
        cell.buyBtn.isInTestingMode = NO;
        [cell.buyBtnView addSubview:cell.buyBtn ];
    }
    return cell;
}


-(void)updateProgress:(MOStoreButton*)button{
    if (currentProgress>=1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    
    currentProgress+=0.04f;
    //    NSLog(@"current progress is %f",currentProgress);
    [button setProgress:currentProgress animated:YES];
    [self performSelector:@selector(updateProgress:) withObject:button afterDelay:.04];
}

-(void)startDownloading:(MOStoreButton*)button{
    //    [storeButton performSelector:@selector(startDownloading) withObject:nil afterDelay:2];
    currentProgress=0;
    [self performSelector:@selector(updateProgress:) withObject:button afterDelay:2];
    
}
-(void)storeButtonFired:(MOStoreButton *)button{
    
    NSLog(@"click  %i",button.currentIndex);
    if (button.currentIndex ==-1){
        // Clicked after downloading the ' open' button
        NSLog(@"button Finish state clicked ");
        
    }
    else if (button.currentIndex ==0){
        NSLog(@"buttonClickedFirstTime");
        // to cancel downloading selector if exists
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:button];
        currentProgress =0;
    }else if (button.currentIndex==1){
        
        NSLog(@"buttonClickedSecondTime");
        // to mimic download operation
        [self performSelector:@selector(startDownloading:) withObject:button afterDelay:2];
    }
}


@end
