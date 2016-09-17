//
//  OfficeRegistratonStepBViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistratonStepBViewController.h"
#import "AppManager.h"
#import "UITools.h"
#import "OfficeRegistrationViewController.h"

@interface OfficeRegistratonStepBViewController (){
    AppManager* appMngr;
}

@end

@implementation OfficeRegistratonStepBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appMngr = [AppManager SharedInstance];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_OfficeEmailAddressTextField becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_OfficeEmailAddressTextField]){
        if([UITools validateEmailAddressByEmailAddress:_OfficeEmailAddressTextField.text]){
            
            [_OfficePhonenumberTextField becomeFirstResponder];
            return YES;
        }
        
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid Email Address" andMessage:@"Enter a valid Email address" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_OfficeEmailAddressTextField becomeFirstResponder];
            });
        }];
        
    }else if([textField isEqual:_OfficePhonenumberTextField]){
        if(_OfficePhonenumberTextField.isValid){
            [self gotoNextViewController];
            return YES;
        }
        
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid Phone number" andMessage:@"Enter a valid Phone number" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_OfficePhonenumberTextField becomeFirstResponder];
            });
        }];
        
    }
    return NO;
}


- (IBAction)onTextChanged:(FormaxTypeATextField *)sender {
    if(sender.tag == 109){
        [_OfficeEmailAddressTextField setIsValid:[UITools validateEmailAddressByEmailAddress:_OfficeEmailAddressTextField.text]];
    }else if(sender.tag == 110){
        _OfficePhonenumberTextField.text = [UITools formatNumbersAsPhoneNumber:_OfficePhonenumberTextField.text usformat:!appMngr.AppConfig.InternationalModeEnabled.boolValue];
        
        [_OfficePhonenumberTextField setIsValid:(_OfficePhonenumberTextField.text.length==14)];
    }
}

-(void) gotoNextViewController{
    appMngr.registrationProfileForRegistrationProcess.OfficePhone1 = _OfficePhonenumberTextField.text;
    appMngr.registrationProfileForRegistrationProcess.OfficeEmail = _OfficeEmailAddressTextField.text;
    
    if([self.parentViewController.presentingViewController isKindOfClass:[OfficeRegistrationViewController class]]){
        //Update Theme
        [((OfficeRegistrationViewController *)self.parentViewController.presentingViewController) UpdateTheme];
    }
    
    [self performSegueWithIdentifier:@"gotoOfficeRegistrationStepCViewControllerSegue" sender:self];
    
}

- (IBAction)onAlreadyHaveRegisteredPracticeAccountBtnPressed:(id)sender {
    ALog("Signout");
    [[[[AppManager SharedInstance] mscs] getCurrentUser] signOut];
    [[[[AppManager SharedInstance] mscs] getCurrentUser] getDetails];
}

@end
