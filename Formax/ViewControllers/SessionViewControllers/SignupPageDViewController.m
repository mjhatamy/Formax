//
//  SignupPageDViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignupPageDViewController.h"
#import "UITools.h"
#import "AppManager.h"
#import "WaitingAnimationViewController.h"
#import "SignUpConfirmationViewController.h"

@interface SignupPageDViewController (){
    AppManager *appMngr;
    WaitingAnimationViewController* waitingAnimationVC;
    SignUpConfirmationViewController* signupConfirmationVC;
}

@end

@implementation SignupPageDViewController

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
    [_passwordTextField becomeFirstResponder];
    
    
}

- (IBAction)alreadyHaveAccountBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)onTextChanged:(id)sender {
    UITextField *txt = (UITextField *)sender;
    if(txt.tag==106){
        CGFloat passPoint = [UITools ratePasswordStrengthForPassString:_passwordTextField.text];
        [_passwordStrengthProgressView setProgress:passPoint];
        if(passPoint < 0.4f){
            [_passwordStrengthProgressView setProgressTintColor:[UIColor redColor]];
            [_passwordStrengthLabel setText:@"Not good"];
            [_passwordTextField setIsValid:NO];
        }if(passPoint > 0.4f){
            [_passwordStrengthProgressView setProgressTintColor:[UIColor yellowColor]];
            [_passwordStrengthLabel setText:@"Good"];
            [_passwordTextField setIsValid:YES];
        }if(passPoint > 0.8f){
            [_passwordStrengthProgressView setProgressTintColor:[UIColor greenColor]];
            [_passwordStrengthLabel setText:@"Excelent"];
            [_passwordTextField setIsValid:YES];
        }
        [_passwordStrengthLabel setTextColor:_passwordStrengthProgressView.progressTintColor];
    }else if(txt.tag == 107){
        [_confirmPasswordTextField setIsValid: ([_passwordTextField.text isEqualToString:_confirmPasswordTextField.text])];
    }
    
    [_continueBtn setEnabled:_confirmPasswordTextField.isValid];
    
}

- (IBAction)onContinueBtnPressed:(id)sender {
    appMngr.registrationProfileForRegistrationProcess.OwnerPassword = _passwordTextField.text;
    
    if(waitingAnimationVC == nil) waitingAnimationVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
    
    //
    [appMngr SignupByRegistrationProfile:appMngr.registrationProfileForRegistrationProcess CompletionHandler:^(BOOL Succeeded, BOOL isUserAlreadyRegistered, BOOL isUserConfirmed, AWSCognitoIdentityProviderDeliveryMediumType DeliveryMediumType, NSString *Destination, NSString *MsgToUI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [waitingAnimationVC dismiss];
            ALog(@"Succeeded:%d  isUserAlreadyRegistered:%d  isUserConfirmed:%d DeliveryMediumType:%ld  Dest:%@  Msg:%@", Succeeded, isUserAlreadyRegistered, isUserConfirmed, (long)DeliveryMediumType, Destination, MsgToUI);
            if(Succeeded && !isUserConfirmed){
                [self openConfirmSigninViewcontroller];
            }else if(Succeeded && isUserConfirmed){
                //Go to SigninPage
                [appMngr openSignInViewControllerAsRootViewControllerWithUsername:appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr Password:appMngr.registrationProfileForRegistrationProcess.OwnerPassword];
            }
            
            if(!Succeeded){
                [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed" andMessage:MsgToUI];
            }
        });
        
    }];
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_passwordTextField]){
        if(_passwordTextField.isValid){
            
            if([UITools validatePasswordStrengthForPassString:_passwordTextField.text MinimumPasswordLen:8 LowerCaseRequired:YES UpperCaseRequired:YES DigitsRequired:YES SpecialCharactersRequired:NO]){
                
                [_confirmPasswordTextField setHidden:NO];
                [_confirmPasswordTextField setNeedsDisplay];
                
                [_confirmPasswordTextField becomeFirstResponder];
                return YES;
            }else{
                [_confirmPasswordTextField setHidden:YES];
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Password is not good" andMessage:@"Please Enter a Combination of at least eight numbers, letters and punctuation marks (like ! and &)" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_passwordTextField becomeFirstResponder];
                    });
                }];
            }
            return NO;
        }else{
            [_confirmPasswordTextField setHidden:YES];
            //Show Error Message that passwords are not equal
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Password is not good" andMessage:@"Please Enter a Combination of at least eight numbers, letters and punctuation marks (like ! and &)" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_passwordTextField becomeFirstResponder];
                });
            }];
        }
        
    }else if([textField isEqual:_confirmPasswordTextField]){
        if(_confirmPasswordTextField.isValid){
            
            [self onContinueBtnPressed:nil];
        }else{
            if(_passwordTextField.text.length <= 0){
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Password field can not be empty" andMessage:@"Please Enter a Combination of at least eight numbers, letters and punctuation marks (like ! and &)" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_passwordTextField becomeFirstResponder];
                    });
                }];
            }else{
                //Show Error Message that passwords are not equal
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Password does not matches" andMessage:@"" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_confirmPasswordTextField becomeFirstResponder];
                    });
                }];
            }
        }
        
    }
    return NO;
}

//set up mfa ui to retrieve mfa code from end user
-(id<AWSCognitoIdentityPasswordAuthentication>)startPasswordAuthentication{
    NSLog(@"Start startPasswordAuthentication");
    
    return nil;
}

-(id<AWSCognitoIdentityMultiFactorAuthentication>)startMultiFactorAuthentication{
    NSLog(@"Start startMultiFactorAuthentication");
    
    return nil;
}

-(void)openConfirmSigninViewcontroller{
    if(!signupConfirmationVC)
        signupConfirmationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpConfirmationViewController"];;
    signupConfirmationVC.Username = appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr;
    signupConfirmationVC.Password = appMngr.registrationProfileForRegistrationProcess.OwnerPassword;
    
    if(!(signupConfirmationVC.isViewLoaded && signupConfirmationVC.view.window))
    {
        signupConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        signupConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:signupConfirmationVC animated:YES completion:nil];
    }
}

@end
