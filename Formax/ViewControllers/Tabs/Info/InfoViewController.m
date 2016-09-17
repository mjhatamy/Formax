//
//  InfoViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "InfoViewController.h"
#import "PracticeTableViewCell.h"
#import "RegistrationTableViewCell.h"
#import "AppManager.h"
#import "UITools.h"
#import "AvailableFeatureSubscriptionsTableViewCell.h"
#import "AvailableSubscriptionsTableViewCell.h"
#import "UserSubscriptionsTableViewCell.h"
#import "UserFeatureSubscriptionsTableViewCell.h"
#import "MainTabBarViewController.h"

@interface InfoViewController (){
    AppManager* appMngr;
}

@end

@implementation InfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    _RegistrationInfoTableView.layer.cornerRadius = 5;
    _practiceInfoTableView.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self refreshSubscriptions];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:_RegistrationInfoTableView]){
        return 3;
    }else if([tableView isEqual:_practiceInfoTableView]){
        return 5;
    }else if([tableView isEqual:_availableSubscriptionsTableViewe]){
        int i;
        if( appMngr.UserSubscriptions == nil || appMngr.UserSubscriptions.count ==0 ) return 0;
        
        i=0;
        for (UserSubscriptionClass *usc in appMngr.UserSubscriptions) {
            if(usc.isSubscriptionType) i++;
        }
        return i;
        
    }else if([tableView isEqual:_availableFeatureSubscriptionsTableView]){
        int i;
        if( appMngr.UserSubscriptions == nil || appMngr.UserSubscriptions.count ==0 ) return 0;
        
        i=0;
        for (UserSubscriptionClass *usc in appMngr.UserSubscriptions) {
            if(usc.isAddonType) i++;
        }
        
        return i;
    }
    
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:_RegistrationInfoTableView]){
        static NSString *cellIdentifier = @"RegistrationTableViewCell";
        RegistrationTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(indexPath.row==0){
            [cell.titleLabel setText:@"Registrar Full Name"];
            if(appMngr.AppConfig.PatientNameDisplayReverse.boolValue)
                [cell.infoLabel setText:[NSString stringWithFormat:@"%@, %@", appMngr.registrationProfile.OwnerLastName, appMngr.registrationProfile.OwnerFirstName]];
            else
                [cell.infoLabel setText:[NSString stringWithFormat:@"%@ %@", appMngr.registrationProfile.OwnerFirstName, appMngr.registrationProfile.OwnerLastName]];
        }else if(indexPath.row==1){
            [cell.titleLabel setText:@"Email Address"];
            [cell.infoLabel setText:appMngr.registrationProfile.OwnerEmailAddr];
        }else if(indexPath.row==2){
            [cell.titleLabel setText:@"Phone Number"];
            [cell.infoLabel setText:appMngr.registrationProfile.OwnerPhoneNumber];
        }
        return cell;
    }else if([tableView isEqual:_practiceInfoTableView]){
        static NSString *cellIdentifier = @"PracticeTableViewCell";
        PracticeTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if(indexPath.row==0){
            [cell.titleLabel setText:@"Practice Name"];
            [cell.infoLabel setText:appMngr.registrationProfile.OfficeName];
        }else if(indexPath.row==1){
            [cell.titleLabel setText:@"Practice Address"];
            NSMutableString *addrStr = [[NSMutableString alloc] init];
            if(![UITools isNSStringNull:appMngr.registrationProfile.OfficeStreetAddr]){
                [addrStr appendFormat:@"%@ ", appMngr.registrationProfile.OfficeStreetAddr ];
            }
            if(![UITools isNSStringNull:appMngr.registrationProfile.OfficeAptNoAddr]){
                [addrStr appendFormat:@"%@ ", appMngr.registrationProfile.OfficeAptNoAddr ];
            }
            if(![UITools isNSStringNull:appMngr.registrationProfile.OfficeCityAddr]){
                [addrStr appendFormat:@"%@ ", appMngr.registrationProfile.OfficeCityAddr ];
            }
            if(![UITools isNSStringNull:appMngr.registrationProfile.OfficeStateAddr]){
                [addrStr appendFormat:@", %@ ", appMngr.registrationProfile.OfficeStateAddr ];
            }
            if(appMngr.registrationProfile.OfficeZipAddr!= nil){
                [addrStr appendFormat:@"%d", appMngr.registrationProfile.OfficeZipAddr.intValue ];
            }
            
            [cell.infoLabel setText:addrStr];
        }else if(indexPath.row==2){
            [cell.titleLabel setText:@"Practice Email"];
            [cell.infoLabel setText:appMngr.registrationProfile.OfficeEmail];
        }else if(indexPath.row==3){
            [cell.titleLabel setText:@"Practice Phone"];
            [cell.infoLabel setText:appMngr.registrationProfile.OfficePhone1];
        }else if(indexPath.row==4){
            [cell.titleLabel setText:@"Regisetred By Device"];
            [cell.infoLabel setText:appMngr.registrationProfile.RegistrarDeviceUUID];
        }
        return cell;
    }else if([tableView isEqual:_availableSubscriptionsTableViewe]){
        static NSString *cellIdentifier = @"UserSubscriptionsTableViewCell";
        UserSubscriptionsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        int i;
        i=0;
        UserSubscriptionClass *obj;
        for (UserSubscriptionClass *usc in appMngr.UserSubscriptions) {
            if(usc.isSubscriptionType){
                if( i == indexPath.row){
                    obj = usc;
                    break;
                }else
                    i++;
            }
        }
        
        if(obj != nil){
            [cell.planNameLabel setText:obj.PlanName];
            
            if(obj.isExpired){
                [cell.planStatusLabel setText:@"Expired"];
                [cell.tagView setRoundableViewColor:[UIColor redColor]];
            }else if(obj.isNotUsed){
                [cell.planStatusLabel setText:@"Reserved"];
                [cell.tagView setRoundableViewColor:[UIColor grayColor]];
            }else{
                NSDate *expiresOn = [NSDate dateWithTimeIntervalSince1970:obj.SubscriptionStartDate.doubleValue + obj.SubscriptionPeriod.doubleValue];
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
                    [format setDateFormat:[NSString stringWithFormat:@"%s", INTDateTimeFormat]];
                else
                    [format setDateFormat:[NSString stringWithFormat:@"%s", USDateTimeFormat]];
                
                [cell.planStatusLabel setText:[NSString stringWithFormat:@"Expires on %@", [format stringFromDate:expiresOn]]];
                [cell.tagView setRoundableViewColor:[UIColor blueColor]];
            }
            
        }
        
        
        return cell;
    }else if([tableView isEqual:_availableFeatureSubscriptionsTableView]){
        static NSString *cellIdentifier = @"UserFeatureSubscriptionsTableViewCell";
        UserSubscriptionsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        int i;
        i=0;
        UserSubscriptionClass *obj;
        for (UserSubscriptionClass *usc in appMngr.UserSubscriptions) {
            if(usc.isAddonType){
                if( i == indexPath.row){
                    obj = usc;
                    break;
                }else
                    i++;
            }
        }
        
        if(obj != nil){
            [cell.planNameLabel setText:obj.PlanName];
            
            if(obj.isExpired){
                [cell.planStatusLabel setText:@"Expired"];
                [cell.tagView setRoundableViewColor:[UIColor redColor]];
            }else if(obj.isNotUsed){
                [cell.planStatusLabel setText:@"Reserved"];
                [cell.tagView setRoundableViewColor:[UIColor grayColor]];
            }else{
                NSDate *expiresOn = [NSDate dateWithTimeIntervalSince1970:obj.SubscriptionStartDate.doubleValue + obj.SubscriptionPeriod.doubleValue];
                NSDateFormatter *format = [[NSDateFormatter alloc] init];
                if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
                    [format setDateFormat:[NSString stringWithFormat:@"%s", INTDateTimeFormat]];
                else
                    [format setDateFormat:[NSString stringWithFormat:@"%s", USDateTimeFormat]];
                
                [cell.planStatusLabel setText:[NSString stringWithFormat:@"Expires on %@", [format stringFromDate:expiresOn]]];
                [cell.tagView setRoundableViewColor:[UIColor blueColor]];
            }
            
        }

        
        return cell;
    }
    ALog("");
    
    return [UITableViewCell new];
}

-(void)refreshSubscriptions{
    
    
    [appMngr ProcessSubscriptionsWithCompletionHandler:^(UserSubscriptionClass * _Nullable activeSubscription, SubscriptionFeaturesClass * _Nullable Features, BOOL newSubscriptionAcivated, BOOL isExpired) {
        
        if(appMngr.UserSubscriptions!= nil && appMngr.UserSubscriptions.count > 0){
            dispatch_async(dispatch_get_main_queue(), ^{
                ALog("Reload Tables");
                [((MainTabBarViewController *)self.parentViewController) ProcessSubscription];
                [_availableSubscriptionsTableViewe reloadData];
                [_availableFeatureSubscriptionsTableView reloadData];
            });
        }
        
        
        if(activeSubscription == nil || isExpired){
            ALog("No Active subscription");
            dispatch_async(dispatch_get_main_queue(), ^{
                //Show Message that it is expired or no active subscription
                NSString* title, *Message;
                
                if(appMngr.UserSubscriptions ==nil || appMngr.UserSubscriptions.count==0){
                    title = @"No Subscription found";
                    Message = @"Get a subscription to start using Formax";
                }else{
                    title = @"License Expired";
                    Message = @"Renew your subscription to continue using the application";
                }
                
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:title andMessage:Message WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [((MainTabBarViewController *)self.parentViewController) ProcessSubscription];
                        [self performSegueWithIdentifier:@"gotoBuyNewSubscriptionViewControllerSegue" sender:self];
                    });
                }];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [((MainTabBarViewController *)self.parentViewController) ProcessSubscription];
            });
        }
        if(Features == nil) ALog("No Feature available");
    }];
}


@end
