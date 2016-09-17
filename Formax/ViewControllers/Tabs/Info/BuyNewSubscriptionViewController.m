//
//  BuyNewSubscriptionViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "BuyNewSubscriptionViewController.h"
#import "AppManager.h"
#import "AvailableSubscriptionsTableViewCell.h"
#import "UserSubscriptionClass.h"
#import "WaitingAnimationViewController.h"
#import "InfoViewController.h"

@interface BuyNewSubscriptionViewController ()<MOStoreButtonDelegate>
{
    AppManager* appMngr;
    NSMutableArray<SubscriptionClass *> *subscriptionsList;
    float currentProgress;
    dispatch_queue_t dqSem;
    dispatch_semaphore_t sem;
    WaitingAnimationViewController* waitingAnimVC;
    BOOL writeSuccess;
    NSString *MessageToUI;
    NSError *blError;
}

@end

@implementation BuyNewSubscriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    dqSem = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(dqSem, ^{
        [self getTrialSubscriptions];
    });
    
    
    
}

-(void) getTrialSubscriptions{
    BOOL trialFound;
    trialFound = NO;
    
    for (UserSubscriptionClass *usc in appMngr.UserSubscriptions) {
        if(usc.isTrialType){
            trialFound = YES;
            break;
        }
    }
    
    if(trialFound){
        [self getSubscriptions];
        return;
    }
    
    sem = dispatch_semaphore_create(0);
    [appMngr getAllAvailableSubscriptionsByType:SubscriptionTypeTrial CompletionHandler:^(NSArray<SubscriptionClass *> * _Nullable objArr, NSError * _Nullable error, NSString * _Nullable msgToUI) {
        if(objArr!= nil && objArr.count > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                if(subscriptionsList == nil) subscriptionsList = [[NSMutableArray alloc] init];
                [subscriptionsList addObjectsFromArray:objArr];
                dispatch_semaphore_signal(sem);
                [_availableSubscriptionsTableView reloadData];
            });
        }else{
            ALog("NO Subscription found");
            dispatch_semaphore_signal(sem);
        }
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    
    [self getSubscriptions];
}

-(void) getSubscriptions{
    [appMngr getAllAvailableSubscriptionsByType:SubscriptionTypeSubscription CompletionHandler:^(NSArray<SubscriptionClass *> * _Nullable objArr, NSError * _Nullable error, NSString * _Nullable msgToUI) {
        if(objArr!= nil && objArr.count > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                ALog("Subscriptions Found");
                if(subscriptionsList == nil) subscriptionsList = [[NSMutableArray alloc] init];
                [subscriptionsList addObjectsFromArray:objArr];
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
    [self dismissWithDelegate:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return subscriptionsList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"AvailableSubscriptionsTableViewCell";
    AvailableSubscriptionsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(128.0/256.0) green:(128.0/256.0) blue:(128.0/256.0) alpha:0.05f];
    
    SubscriptionClass *obj= [subscriptionsList objectAtIndex:indexPath.row];
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
        [cell.buyBtn setTitles: ((obj.Price.floatValue <= 0) ? @[@"GET",@"INSTALL"] : @[[ NSString stringWithFormat:@"$%0.2f", obj.Price.floatValue],@"BUY"]) ];
        ALog("Price:%f", obj.Price.floatValue);
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
    [self performSelector:@selector(updateProgress:) withObject:button afterDelay:0.5];
    
}
-(void)storeButtonFired:(MOStoreButton *)button{
    CGPoint buttonOriginInTableView = [button convertPoint:CGPointZero toView:_availableSubscriptionsTableView];
    NSIndexPath *indexPath = [_availableSubscriptionsTableView indexPathForRowAtPoint:buttonOriginInTableView];
    
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
        [self InitializeSubscription:[subscriptionsList objectAtIndex:indexPath.row] storeButton:button CellIndexPath:indexPath];
        
        //[self performSelector:@selector(startDownloading:) withObject:button afterDelay:1];
    }
}


-(void)InitializeSubscription:(SubscriptionClass *)asc storeButton:(MOStoreButton *)storeButton  CellIndexPath:(NSIndexPath *)CellIndexPath
{
    [appMngr ProcessSubscriptionsWithCompletionHandler:^(UserSubscriptionClass * _Nullable activeSubscription, SubscriptionFeaturesClass * _Nullable Features, BOOL newSubscriptionAcivated, BOOL isExpired) {
        
        if(asc.isTrialType){
            if(activeSubscription.isTrialType && asc.isTrialType){
                //Show Error , You cannot have Two
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideWaitingAnimation];
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Trial Limit" andMessage:@"You have already subscribed to trial subscription.\n"];
                    
                    [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
                return;
            }
            
            for (UserSubscriptionClass *sc in appMngr.UserSubscriptions) {
                if(sc.isTrialType){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self hideWaitingAnimation];
                        [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Trial Limit" andMessage:@"You have already subscribed to trial subscription.\nYour previous trial subscription is now expired."];
                        [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    });
                    return;
                }
            }
        }

        //Add an other Official account to Official  !!!
        if(activeSubscription != nil  && !activeSubscription.isExpired && !activeSubscription.isTrialType
           && asc.isSubscriptionType && !asc.isTrialType){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideWaitingAnimation];
                [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Subscription Status" andMessage:@"Your current Subscription is valid and you donot need new subscription. If you want to extend application features, please try to add Features."];
                ALog("Your current Subscription is valid and you donot need new subscription. If you want to extend application features, please try to add Features.");
                [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            currentProgress+=0.24f;
            [storeButton setProgress:currentProgress animated:YES];
        });;
        
        //Add a Trial account to an Official Account
        if(activeSubscription != nil  && !activeSubscription.isExpired  && !activeSubscription.isTrialType && asc.isTrialType){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideWaitingAnimation];
                [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Subscription Status" andMessage:@"Your cannot move to Trial subscription from a valid official subscription."];
                [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            });
            return;
        }
        
        //If current subscription is Trial and want to add official subscription
        if(activeSubscription != nil && activeSubscription.isTrialType && !asc.isTrialType && asc.isSubscriptionType){
            [self AddSubscribtion:asc ActivateNow:YES storeButton:storeButton CellIndexPath:CellIndexPath];
            return;
        }
        
        
        //Add New Subscription
        if(activeSubscription == nil || isExpired){
            if(asc.isAddonType){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideWaitingAnimation];
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Subscription Status" andMessage:@"Your license is expired. Please Renew or add new subscription and then you can add more featurs to your application."];
                    [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
                return;
            }
            
            //subscribe now
            if(asc.isTrialType || asc.isSubscriptionType){
                
                [self AddSubscribtion:asc ActivateNow:YES storeButton:storeButton CellIndexPath:CellIndexPath];
                return;
            }
        }
        
        //Add Addon Type
        if(!activeSubscription.isExpired && !isExpired && asc.isAddonType){
            //If trying to buy Add on in Trial mode
            if(activeSubscription.isTrialType){
                [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Subscription Status" andMessage:@"You are in Trial mode. To add extra services, first get one of the Subscriptions."];
                [self hideWaitingAnimation];
                [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                return;
            }
            
            [self AddSubscribtion:asc ActivateNow:YES storeButton:storeButton CellIndexPath:CellIndexPath];
            return;
        }
        
        ALog(@"Unknown Condition");
        
    }];
}


-(void)AddSubscribtion:(SubscriptionClass *)asc ActivateNow:(BOOL)ActivateNow storeButton:(MOStoreButton *)storeButton CellIndexPath:(NSIndexPath *)CellIndexPath
{
    ALog("HERE");
    
    dispatch_semaphore_t psem = dispatch_semaphore_create(0);
    
    [appMngr addUserSubscriptionFrom:asc ActivateNow:ActivateNow CompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        
        writeSuccess = Success;
        blError = error;
        MessageToUI = MsgToUI;
        
        dispatch_semaphore_signal(psem);
    }];
    
    dispatch_semaphore_wait(psem, DISPATCH_TIME_FOREVER);
    
    if(!writeSuccess){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideWaitingAnimation];
            [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed" andMessage:MessageToUI];
            [_availableSubscriptionsTableView reloadRowsAtIndexPaths:@[CellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        });
        return;
    }
    
    //try to refresh by reloading all Subscriptions
    [appMngr ProcessSubscriptionsWithCompletionHandler:^(UserSubscriptionClass * _Nullable activeSubscription, SubscriptionFeaturesClass * _Nullable Features, BOOL newSubscriptionAcivated, BOOL isExpired) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideWaitingAnimation];
            // Return Back to View who Called it for refresh
            [self dismissWithDelegate:YES];
            return;
            
        });
        
    }];
    
    [self performSelector:@selector(startDownloading:) withObject:storeButton afterDelay:0];
    ALog(@"Write Success !!!");
}

-(void)showWaitingAnimation{
    if(waitingAnimVC == nil)
        waitingAnimVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
}

-(void)hideWaitingAnimation{
    //[_waitingCoverView setHidden:YES];
    //[self.animImageView stopAnimating];
    [waitingAnimVC dismiss];
}

-(void) dismissWithDelegate:(BOOL)shouldUpdate
{
    
    UITabBarController *tvc = (UITabBarController *)self.presentingViewController;
    //if( )
    if([[tvc selectedViewController] isKindOfClass:[InfoViewController class]]){
        [((InfoViewController*)[tvc selectedViewController]) refreshSubscriptions];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
