//
//  SessionRootViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SessionRootViewController.h"
#import "AbstractSessionViewController.h"
#import "SignInViewController.h"
#import "SignupViewController.h"

@interface SessionRootViewController ()

@end

@implementation SessionRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view
    
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SessionPageViewController"];
    self.PageViewController.dataSource = self;
    self.PageViewController.delegate = self;
    AbstractSessionViewController *vc = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[vc];
    [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    // Change the size of page view controller
    self.PageViewController.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 30);
    [self addChildViewController:_PageViewController];
    [self.view addSubview:_PageViewController.view];
    [self.PageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((AbstractSessionViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSLog(@"CALLED");
    NSUInteger index = ((AbstractSessionViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if(index > 2) return nil;
    
    
    return [self viewControllerAtIndex:index];
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return 2;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}


- (AbstractSessionViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if(index==0){
        SignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
        vc.pageIndex = index;
        return vc;
    }else if (index==1){
        SignupViewController*vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignupViewController"];
        vc.pageIndex = index;
        return vc;
    }
 
    return nil;
}

@end
