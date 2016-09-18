//
//  OfficeRegistrationSampleFormDisplayViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/17/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistrationSampleFormDisplayViewController.h"
#import "OfficeRegistrationViewController.h"

@interface OfficeRegistrationSampleFormDisplayViewController ()

@end

@implementation OfficeRegistrationSampleFormDisplayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    UIViewController *vc = self;
    while (vc != nil) {
        NSLog(@"%@", [vc class]);
        if( [vc isKindOfClass:[UINavigationController class]]){
            vc = self.presentingViewController;
        }else
            vc = self.parentViewController;
        
        if([vc isKindOfClass:[OfficeRegistrationViewController class]]){
            break;
        }
    }
    
    
    if(vc != nil && [vc isKindOfClass:[OfficeRegistrationViewController class]]){
        //Run display Form PDF Viewer with default Theme and Registration Profile of "Your Practice Name"
        NSLog(@"Display now");
        [((OfficeRegistrationViewController *) vc) showSampleForm];
    }
}

@end
