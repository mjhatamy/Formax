//
//  AfterLoginProcessorViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/5/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AfterLoginProcessorViewController.h"
#import "AppManager.h"
#import "UITools.h"
#import "WaitingAnimationViewController.h"

@interface AfterLoginProcessorViewController (){
    AppManager* appMngr;
    
     NSArray* _formThemes;
    BOOL stepSucceeded;
    NSString* MessageToUI;
    WaitingAnimationViewController* waitingAnimVC;
}

@property (nonatomic,strong) AWSCognitoIdentityUserGetDetailsResponse * response;

@end

@implementation AfterLoginProcessorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    waitingAnimVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self ProcessStepA];

}


-(void) ProcessStepA {
    //If app is not initialized
    if( ![appMngr.AppConfiguration isInstalled]){
        ALog("App Configuration not Found");
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:NSLocalizedString(@"Failed to initialized Configuration.", @"Failed_to_initialized_Configuration")  andMessage:NSLocalizedString(@"Critical error. Failed to initialize application configuration. Please delete and reinstall app.", @"Failed_to_initialized_Configuration_Message") WithOkButtonEnabled:YES OkButtonTitle:@"Return" WithCancelButtonEnabled:NO CancelButtonTitle:@"Cancel" CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[appMngr.mscs getCurrentUser] signOut];
                [self dismissViewControllerAnimated:YES completion:nil];
                return ;
            });
        }];
        return;
    }
    
    //Check if Registration Profile is inatalled
    if([[appMngr RegistrationProfile] isRegistered]){
        ALog("App Registration Profile found");
        //Check Subscriptions
        
        [appMngr ProcessSubscriptionsWithCompletionHandler:^(UserSubscriptionClass * _Nullable activeSubscription, SubscriptionFeaturesClass * _Nullable Features, BOOL newSubscriptionAcivated, BOOL isExpired) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //Go to Main App
                [appMngr openMainViewControllerAsRootViewController];
            });
        }];
        
        
        
        return;
    }
    
    ALog("No Registration Profile Found. Starting Registration Process");
    //Get User Details
    [[[appMngr.mscs getCurrentUser] getDetails] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserGetDetailsResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error ){
                if(task.error.code == kCFURLErrorNotConnectedToInternet){
                    //[self ProcessRegistrationProfile];
                    ALog("NO INTERNET Connection Error");
                    //If registered continue else show error message
                    if([[appMngr RegistrationProfile] isRegistered]){
                        //Show Everything based on Registration Profile
                        [self ProcessStepB];

                        return ;
                    }else{ //Show Error Message and Make Next Btn to Retry
                        //Show Error Message and Hide all fields
                        
                        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:NSLocalizedString(@"No network connection", @"No network connection")  andMessage:NSLocalizedString(@"In order to continue, You must connect to the internet and press retry button.", @"Network Connection is required and Retry") WithOkButtonEnabled:YES OkButtonTitle:@"Retry" WithCancelButtonEnabled:YES CancelButtonTitle:@"Cancel" CompletionHandler:^(BOOL OKorCancel) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                if(!OKorCancel){
                                    [[appMngr.mscs getCurrentUser] signOut];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                    return ;
                                }else{
                                    
                                    [self ProcessStepA];
                                    return;
                                }
                            });
                        }];
                        return;
                    }
                }else {
                    [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:NSLocalizedString(@"Unknown Error", @"Unknown")  andMessage:task.error.localizedDescription WithOkButtonEnabled:YES OkButtonTitle:@"Retry" WithCancelButtonEnabled:YES CancelButtonTitle:@"Cancel" CompletionHandler:^(BOOL OKorCancel) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!OKorCancel){
                                [[appMngr.mscs getCurrentUser] signOut];
                                [self dismissViewControllerAnimated:YES completion:nil];
                                return ;
                            }else{
                                
                                [self ProcessStepA];
                                return;
                            }
                        });
                    }];

                }
                
                return ;
            }
            
            self.response = task.result;

            ALog("Prepare for Registration Process by getting User details for username:%@", self.response.username);
            
            
            
            if(appMngr.registrationProfileForRegistrationProcess==nil)
                appMngr.registrationProfileForRegistrationProcess = [[RegistrationProfileClass alloc] init];
            
            
            appMngr.registrationProfileForRegistrationProcess.Username = self.response.username;
            
            NSDateFormatter *formater = [[NSDateFormatter alloc] init];
            [formater setDateFormat:[NSString stringWithFormat:@"%s", DateFormat]];
            
            for (AWSCognitoIdentityProviderAttributeType *userAttribute in self.response.userAttributes) {
                if([userAttribute.name isEqualToString:@"sub"]){
                    //_uniqueIdTextField.text = userAttribute.value;
                    //NSLog(@"-->%@", userAttribute.value);
                }
                if([userAttribute.name isEqualToString:@"birthdate"]){
                    //_birthdateTextField.text = userAttribute.value;
                    //NSLog(@"-->%@", userAttribute.value);
                    appMngr.registrationProfileForRegistrationProcess.OwnerBirthdate = [NSNumber numberWithDouble:[formater dateFromString:userAttribute.value].timeIntervalSince1970];
                }
                if([userAttribute.name isEqualToString:@"email_verified"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    //_emailVerificationStatusTextField.text = ( [userAttribute.value isEqualToString:@"true"] ? @"Verified" : @"Not verified");
                    appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr = userAttribute.value;
                }
                if([userAttribute.name isEqualToString:@"phone_number_verified"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    
                    //_phoneNumberVerificationStatusTextField.text = ( [userAttribute.value isEqualToString:@"true"] ? @"Verified" : @"Not verified");
                }
                if([userAttribute.name isEqualToString:@"phone_number"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    appMngr.registrationProfileForRegistrationProcess.OwnerPhoneNumber = userAttribute.value;
                    //_phoneNumberTextField.text = userAttribute.value;
                }
                if([userAttribute.name isEqualToString:@"given_name"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    appMngr.registrationProfileForRegistrationProcess.OwnerFirstName = userAttribute.value;
                    //_firstNameTextField.text = userAttribute.value;
                }
                if([userAttribute.name isEqualToString:@"family_name"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    //_lastNameTextField.text = userAttribute.value;
                    appMngr.registrationProfileForRegistrationProcess.OwnerLastName = userAttribute.value;
                }
                if([userAttribute.name isEqualToString:@"email"]){
                    //NSLog(@"-->%@", userAttribute.value);
                    //_emailAddrTextField.text = userAttribute.value;
                    appMngr.registrationProfileForRegistrationProcess.OwnerEmailAddr = userAttribute.value;
                }
                
                //[self setVisibilityOfUserProfileHidden:NO];
            }

            [self RegistationPreparationStepA];
            
            return;
            
        });
        return nil;
    }];
}

//If Registration Profile is available, Goto Step B
-(void)ProcessStepB{
    
}


-(void)ProcessThemes{
    [appMngr getAllThemesByForcedRefresh:NO CompletionHanlder:^(NSArray<FormThemeModelClass *> * _Nullable arr, BOOL Updated, BOOL Succeeded, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //formThemesList = arr;
            //[_themesTableView reloadData];
        });
        
    }];
}


-(void)RegistationPreparationStepA{
    dispatch_queue_t dqsem = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(dqsem, ^{
       
        dispatch_semaphore_t sem = dispatch_semaphore_create(0);
        
        //Get all Forms
        [appMngr getAllThemesByForcedRefresh:NO CompletionHanlder:^(NSArray<FormThemeModelClass *> * _Nullable arr, BOOL Updated, BOOL Succeeded, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
            _formThemes = arr;
            stepSucceeded = Succeeded;
            MessageToUI = MsgToUI;
            dispatch_semaphore_signal(sem);
        }];
        dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        
        //if getting Themes failed, show error for retry or return.
        if(!stepSucceeded){
            dispatch_async(dispatch_get_main_queue(), ^{
                [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Getting Forms Themes Failed" andMessage:MessageToUI WithOkButtonEnabled:YES OkButtonTitle:@"Retry" WithCancelButtonEnabled:YES CancelButtonTitle:@"Cancel" CompletionHandler:^(BOOL OKorCancel) {
                    if(OKorCancel){
                        [self RegistationPreparationStepA];
                        return;
                    }
                    return;
                }];
            });
            return ;
        }
        
        
        ALog("Getting Forms Succeeded");
        //if Succeeded. Make Default Theme
        
        [appMngr makeThemeFileForThemeId:appMngr.AppConfig.DefaultThemeId RegistrationProfile:nil CompletionHandler:^(BOOL Succeeded, NSURL * _Nullable ThemeFileUrlForWebView, NSString * _Nullable MsgToUI) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"gotoRegisterOfficeViewControllerSegue" sender:self];
            });
            
        }];
        
        //FormThemeModelClass *ftm = [[LocalDatabase SharedInstance] getThemeByThemeId:appMngr.AppConfig.DefaultThemeId];
        //[[LocalDatabase SharedInstance] getFormThemeFileUrlForThemeId:appMngr.AppConfig.DefaultThemeId ThemeFileName:ftm.FileName];
        
    });
    //Goto Office Registration Page
    //[self performSegueWithIdentifier:@"gotoRegisterOfficeViewControllerSegue" sender:self];
}

@end
