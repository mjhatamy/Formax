//
//  MainTabBarViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "MainTabBarViewController.h"
#import "AppManager.h"

@interface MainTabBarViewController (){
    AppManager* appMngr;
}

@end

@implementation MainTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appMngr = [AppManager SharedInstance];
    [self ProcessSubscription];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) ProcessSubscription{
    if( appMngr.activeSubscriptionRecord == nil || appMngr.activeSubscriptionRecord.isExpired){
        ALog("NO Subscription found");
        [[[[self tabBar] items] objectAtIndex:0] setEnabled:NO];
        [[[[self tabBar] items] objectAtIndex:1] setEnabled:NO];
        [[[[self tabBar] items] objectAtIndex:2] setEnabled:NO];
        [self setSelectedIndex:3];
    }else{
        [[[[self tabBar] items] objectAtIndex:0] setEnabled:YES];
        [[[[self tabBar] items] objectAtIndex:1] setEnabled:YES];
        [[[[self tabBar] items] objectAtIndex:2] setEnabled:YES];
    }
}

@end
