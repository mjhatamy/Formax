//
//  MainTabBarViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainTabBarViewController : UITabBarController

@property (weak, nonatomic) IBOutlet UITabBar *tabbar;


-(void) ProcessSubscription;
@end
