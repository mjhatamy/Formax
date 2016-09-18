//
//  OfficeRegistrationViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/5/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfficeRegistrationViewController : UIViewController<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (weak, nonatomic) IBOutlet UIView *pdfPageCoverView;
@property (weak, nonatomic) IBOutlet UIView *pdfPageInnerCoverView;

-(void)UpdateTheme;
-(void) showSampleForm;

@end
