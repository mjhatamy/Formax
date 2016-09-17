//
//  SignupPageCViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignupPageCViewController.h"
#import "UITools.h"
#import "AppManager.h"

@interface SignupPageCViewController (){
    AppManager *appMngr;
}

@end

@implementation SignupPageCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(appMngr==nil) appMngr = [AppManager SharedInstance];
    
    if(appMngr.registrationProfileForRegistrationProcess == nil){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Something where wrong" andMessage:@"Information from previous window did not saved correctly !!! 1044" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_emailAddrTextField becomeFirstResponder];
}

- (IBAction)alreadyHaveAccountBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onTextChanged:(id)sender {
    UITextField *txt = (UITextField *)sender;
    if(txt.tag==104){
        [_emailAddrTextField setIsValid:[UITools validateEmailAddressByEmailAddress:_emailAddrTextField.text]];
    }else if(txt.tag == 105){
        _phoneNumberTextField.text = [UITools formatNumbersAsPhoneNumber:_phoneNumberTextField.text usformat:YES];
        [_phoneNumberTextField setIsValid:(_phoneNumberTextField.text.length==14)];
    }
    
    [_nextBtn setEnabled:_emailAddrTextField.isValid];
    [_continueBtn setEnabled:_phoneNumberTextField.isValid];
    
}

- (IBAction)onContinueBtnPressed:(id)sender {
    if(appMngr.AppConfiguration.InternationalModeEnabled.boolValue){
        appMngr.registrationProfileForRegistrationProcess.OwnerPhoneNumber = [NSString stringWithFormat:@"+1%@", [UITools stringToDigitsString:_phoneNumberTextField.text]];
    }else{
#pragma NEED TO BE FIXED
        appMngr.registrationProfileForRegistrationProcess.OwnerPhoneNumber = [NSString stringWithFormat:@"+1%@", [UITools stringToDigitsString:_phoneNumberTextField.text]];
    }
    
    appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr = _emailAddrTextField.text;
    
    [self performSegueWithIdentifier:@"gotoSignupPageDViewControllerSegue" sender:self];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_emailAddrTextField]){
        if(_emailAddrTextField.isValid){
            appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr = _emailAddrTextField.text;
            
            [_secondPartStackView setHidden:NO];
            [_phoneNumberTextField becomeFirstResponder];
            return YES;
        }
        
    }else if([textField isEqual:_phoneNumberTextField]){
        if(_phoneNumberTextField.isValid){
            appMngr.registrationProfileForRegistrationProcess.OwnerPhoneNumber = _phoneNumberTextField.text;
            
            [self onContinueBtnPressed:nil];
            return YES;
        }
        
    }
    return NO;
}

@end
