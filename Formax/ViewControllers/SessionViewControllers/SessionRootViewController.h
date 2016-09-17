//
//  SessionRootViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionRootViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *PageViewController;


@end
