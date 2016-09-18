//
//  OfficeRegistratonStepAViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistratonStepAViewController.h"
#import "UITools.h"
#import "AppManager.h"
#import "OfficeRegistrationViewController.h"

@interface OfficeRegistratonStepAViewController (){
    AppManager* appMngr;
}

@end

@implementation OfficeRegistratonStepAViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    [_OfficeAddressStackView setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_OfficeNameTextField becomeFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_OfficeNameTextField]){
        if(_OfficeNameTextField.text.length < 3){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid Practice name" andMessage:@"Please Enter a valid Practice name and continue." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   [_OfficeNameTextField becomeFirstResponder];
               });
            }];
            return NO;
        }else{
            
            [UIView transitionWithView:_OfficeAddressStackView duration:0.5f options:UIViewAnimationOptionCurveEaseIn animations:^{
                [_OfficeAddressStackView setHidden:NO];
            } completion:^(BOOL finished) {
                [_OfficeStreetAddrTextField becomeFirstResponder];
            }];
            return YES;
        }
    }else if( [textField isEqual:_OfficeStreetAddrTextField]){
        ALog("Office Address");
        [_OfficeUnitAddrTextField becomeFirstResponder];
        return (_OfficeStreetAddrTextField.text.length > 5);
    }else if( [textField isEqual:_OfficeUnitAddrTextField]){
        [_OfficeZipAddrTextField becomeFirstResponder];
        return YES;
    }
    
    else if( [textField isEqual:_OfficeZipAddrTextField]){
        if(_OfficeZipAddrTextField.text.length < 5){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid Zip Code" andMessage:@"Please Enter a valid Zip code." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_OfficeZipAddrTextField becomeFirstResponder];
                });
            }];
            return NO;
        }
        
        [_OfficeCityAddrTextField becomeFirstResponder];
        return (_OfficeZipAddrTextField.text.length == 5);
    }
    
    else if( [textField isEqual:_OfficeCityAddrTextField]){
        if(_OfficeCityAddrTextField.text.length < 4){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid City name" andMessage:@"Please Enter a valid city name." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_OfficeCityAddrTextField becomeFirstResponder];
                });
            }];
            return NO;
        }
        
        [_OfficeStateTextField becomeFirstResponder];
        return (_OfficeCityAddrTextField.text.length > 5);
    }
    
    else if( [textField isEqual:_OfficeStateTextField]){
        if(_OfficeStateTextField.text.length < 2){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Invalid State" andMessage:@"Please Enter a valid state name." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_OfficeStateTextField becomeFirstResponder];
                });
            }];
            return NO;
        }
        
        //go to next Page
        [self gotoNextViewController];
        return (_OfficeStateTextField.text.length > 1);
    }

    return NO;
}


- (IBAction)onTextChanged:(FormaxTypeATextField *)sender {
    if(sender.tag==103){ //Unit Addr
        _OfficeUnitAddrTextField.text = [UITools stringToDigitsString:_OfficeUnitAddrTextField.text];
    }else if(sender.tag==104){
        _OfficeZipAddrTextField.text = [UITools stringToDigitsString:_OfficeZipAddrTextField.text];
        if(_OfficeZipAddrTextField.text.length >= 5){
            NSArray *arr = [[LocalDatabase SharedInstance] getCityAndStateByZipCode:[NSNumber numberWithInt:_OfficeZipAddrTextField.text.intValue]];
            
            if(arr != nil && arr.count>1){
                NSString *city = [arr objectAtIndex:0];
                NSString *state = [arr objectAtIndex:1];
                _OfficeCityAddrTextField.text = city;
                _OfficeStateTextField.text = state;
            }
            
        }
    }else if(sender.tag == 105){
        _OfficeCityAddrTextField.text = [UITools stringToAlphabetString:_OfficeCityAddrTextField.text];
        if(_OfficeCityAddrTextField.text.length >= 4){
            NSArray *arr = [[LocalDatabase SharedInstance] getZipAndStateByCityName:_OfficeCityAddrTextField.text];
            
            if(arr != nil && arr.count>1){
                NSString *zip = [arr objectAtIndex:0];
                NSString *state = [arr objectAtIndex:1];
                _OfficeZipAddrTextField.text = zip;
                _OfficeStateTextField.text = state;
            }
        }
    }else if(sender.tag == 106){
        _OfficeStateTextField.text = [UITools stringToAlphabetString:_OfficeStateTextField.text];
    }
}


- (IBAction)onAlreadyHaveRegisteredPracticeAccountBtnPressed:(id)sender {
    [[[[AppManager SharedInstance] mscs] getCurrentUser] signOut];
    [[[[AppManager SharedInstance] mscs] getCurrentUser] getDetails];
}

-(void) gotoNextViewController{
    appMngr.registrationProfileForRegistrationProcess.OfficeName = _OfficeNameTextField.text;
    appMngr.registrationProfileForRegistrationProcess.OfficeStreetAddr = _OfficeStreetAddrTextField.text;
    appMngr.registrationProfileForRegistrationProcess.OfficeAptNoAddr = (_OfficeUnitAddrTextField.text.length > 0) ? _OfficeUnitAddrTextField.text : nil;
    appMngr.registrationProfileForRegistrationProcess.OfficeZipAddr = [NSNumber numberWithInt:_OfficeZipAddrTextField.text.intValue];
    appMngr.registrationProfileForRegistrationProcess.OfficeCityAddr = _OfficeCityAddrTextField.text;
    appMngr.registrationProfileForRegistrationProcess.OfficeStateAddr = _OfficeStateTextField.text;
    
    if([self.parentViewController.presentingViewController isKindOfClass:[OfficeRegistrationViewController class]]){ //Update Theme
        [((OfficeRegistrationViewController *)self.parentViewController.presentingViewController) UpdateTheme];
    }
    
    [self performSegueWithIdentifier:@"gotoOfficeRegistrationStepBViewControllerSegue" sender:self];
    
}


@end
