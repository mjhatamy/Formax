//
//  OfficeRegistrationGetStartedViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/18/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistrationGetStartedViewController.h"
#import "AppManager.h"

@interface OfficeRegistrationGetStartedViewController ()

@end

@implementation OfficeRegistrationGetStartedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onAlreadyHaveRegisteredBtnPressed:(id)sender {
    [[[[AppManager SharedInstance] mscs] getCurrentUser] signOut];
    [[[[AppManager SharedInstance] mscs] getCurrentUser] getDetails];
}

@end
