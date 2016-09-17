//
//  FormThemeViewerViewController.h
//  Formax
//
//  Created by Jid Hatami on 9/12/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormThemeViewerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (nonatomic,strong) UIPageViewController *PageViewController;
@property (weak, nonatomic) IBOutlet UIView *pdfPageCoverView;
@property (weak, nonatomic) IBOutlet UIView *pdfPageInnerCoverView;

@end
