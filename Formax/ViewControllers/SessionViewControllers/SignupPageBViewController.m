//
//  SignupPageBViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignupPageBViewController.h"
#import "UITools.h"
#import "AppManager.h"

@interface SignupPageBViewController (){
    AppManager *appMngr;
}

@end

@implementation SignupPageBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(appMngr==nil) appMngr = [AppManager SharedInstance];
    
    if(appMngr.registrationProfileForRegistrationProcess == nil){
        appMngr.registrationProfileForRegistrationProcess = [[RegistrationProfileClass alloc] init];
    }
    
    [_firstNameTextField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)alreadyHaveAccountBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onNextBtnPressed:(id)sender {
    [_secondPartStackView setHidden:NO];
    [_birthdateTextField becomeFirstResponder];
}

- (IBAction)onContinueBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"gotoSignupPageCViewControllerSegue" sender:self];
}

- (IBAction)onTextChanged:(id)sender {
    UITextField *txt = (UITextField *)sender;
    BOOL  error;
    error = NO;
    if(txt.tag==101){
        _firstNameTextField.text = [UITools stringToAlphabetString:_firstNameTextField.text];
    }else if(txt.tag == 102){
        _lastNameTextField.text = [UITools stringToAlphabetString:_lastNameTextField.text];
    }else if(txt.tag == 103){
        _birthdateTextField.text = [UITools formatStringAsDate:_birthdateTextField.text usformat:YES error:&error];
        [_birthdateTextField setIsValid: (_birthdateTextField.text.length == 10)];
        [_continueBtn setEnabled:_birthdateTextField.isValid];
    }
    
    if(_firstNameTextField.text.length > 1 && _lastNameTextField.text.length > 1){
        [_nextBtn setEnabled:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_firstNameTextField]){
        appMngr.registrationProfileForRegistrationProcess.OwnerFirstName = _firstNameTextField.text;
        [_lastNameTextField becomeFirstResponder];
        return YES;
        
    }else if([textField isEqual:_lastNameTextField]){
        if(_firstNameTextField.text.length > 1 && _lastNameTextField.text.length > 1){
            appMngr.registrationProfileForRegistrationProcess.OwnerLastName = _lastNameTextField.text;
            [_secondPartStackView setHidden:NO];
            [_birthdateTextField becomeFirstResponder];
            return YES;
        }
        
    }else if([textField isEqual:_birthdateTextField]){
        if(_birthdateTextField.isValid){
            NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
            if(appMngr.AppConfiguration.InternationalModeEnabled.boolValue){
                [dateformatter setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
            }else{
                [dateformatter setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
            }
            
            NSDate *cdate = [dateformatter dateFromString:_birthdateTextField.text];
            if(cdate != nil){
                appMngr.registrationProfileForRegistrationProcess.OwnerBirthdate = [NSNumber numberWithDouble:cdate.timeIntervalSince1970];
                [self onContinueBtnPressed:nil];
                return YES;
            }else{
                
                NSString *message;
                if(appMngr.AppConfiguration.InternationalModeEnabled.boolValue){
                    message = [NSString stringWithFormat:@"Correct Birthdate format is: %s", INTDateFormat];
                }else{
                    message = [NSString stringWithFormat:@"Correct Birthdate format is: %s", USDateFormat];
                }
                
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Birth date format is not correct" andMessage:message WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_birthdateTextField becomeFirstResponder];
                    });
                }];
            }
            
        }
        
    }
    return YES;
}


@end
