//
//  OfficeRegistratonStepCViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistratonStepCViewController.h"
#import "AppManager.h"
#import "UITools.h"
#import "LocationService.h"
#import "WaitingAnimationViewController.h"

@interface OfficeRegistratonStepCViewController (){
    AppManager* appMngr;
    LocationService* lsrv;
    WaitingAnimationViewController *waitingAnimViewController;
    BOOL continueRegistration;
    BOOL registrationCompletedRemotely;
    NSString *MessageToUI;
}

@end

@implementation OfficeRegistratonStepCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    lsrv = [LocationService SharedInstance];
    //[AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onAlreadyHaveRegisteredPracticeAccountBtnPressed:(id)sender {
    ALog("Signout");
    [[[[AppManager SharedInstance] mscs] getCurrentUser] signOut];
    [[[[AppManager SharedInstance] mscs] getCurrentUser] getDetails];
}

- (IBAction)onCompleteRegistrationBtnPressed:(id)sender {
    dispatch_queue_t mConcurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //Get Current
    [lsrv startService];
    [lsrv requestLocation];
    appMngr.registrationProfileForRegistrationProcess.RegistrarDeviceUUID = [UITools getUUID];
    appMngr.registrationProfileForRegistrationProcess.RegistrarLongitude = [NSNumber numberWithFloat:appMngr.currentLocation.longitude];
    appMngr.registrationProfileForRegistrationProcess.RegistrarLatitude = [NSNumber numberWithFloat:appMngr.currentLocation.latitude];
    
    ALog("Long:%0.f  Lat:%f", appMngr.registrationProfileForRegistrationProcess.RegistrarLongitude.floatValue, appMngr.registrationProfileForRegistrationProcess.RegistrarLatitude.floatValue);
    
    appMngr.registrationProfileForRegistrationProcess.CreationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
    appMngr.registrationProfileForRegistrationProcess.ModificationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
    appMngr.registrationProfileForRegistrationProcess.AppName = [UITools getAppName];
    appMngr.registrationProfileForRegistrationProcess.OwnerPassword = nil;
    appMngr.registrationProfileForRegistrationProcess.OwnerMasterAccessPin = nil;
    
    
    
    [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:NSLocalizedString(@"Confirmation Required", @"Confirmation Required") andMessage:@"This is one-time setup.\n You are about to register your Practice information statically.\n If you are not sure, Please Press Cancel and double check all fields." WithOkButtonEnabled:YES OkButtonTitle:NSLocalizedString(@"Register", @"Register action") WithCancelButtonEnabled:YES CancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel action") CompletionHandler:^(BOOL OKorCancel)
     {
         
         dispatch_async(dispatch_get_main_queue(), ^{
             waitingAnimViewController = [WaitingAnimationViewController InitializeWithParentViewController:self];
             //dispatch_semaphore_signal(sem);
         });
         
         if(OKorCancel){
             //Register
             dispatch_async(mConcurrentQueue, ^{
                 [self registerNow];
             });
             
         }else{
             dispatch_async(dispatch_get_main_queue(), ^{
                 [waitingAnimViewController EndWaitingFinishedWithMessage:@"Canceling Registration Process" ResultType:WaitingAnimationResultTypeSucceeded EndingDuration:1 Completion:^{}];
             });
         }
         
     }];
}


-(void) registerNow{
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    ALog("HERE");
    registrationCompletedRemotely = NO;
    [appMngr.mscs setRegistrationProfile:appMngr.registrationProfileForRegistrationProcess CompletionHandler:^(BOOL Success, NSError *error, NSString *MsgToUI) {
        ALog("HERE");
        dispatch_async(dispatch_get_main_queue(), ^{
            if(Success){
                registrationCompletedRemotely = YES;
            }else{
                MessageToUI = MsgToUI;
                registrationCompletedRemotely = NO;
            }
            dispatch_semaphore_signal(sem);
        });
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    ALog("HERE");
    if(!registrationCompletedRemotely){
        dispatch_async(dispatch_get_main_queue(), ^{
            [waitingAnimViewController EndWaitingFinishedWithMessage:MessageToUI ResultType:WaitingAnimationResultTypeSucceeded EndingDuration:2 Completion:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Check Registration
                    [waitingAnimViewController EndWaitingFinishedWithMessage:@"Registration Process Failed" ResultType:WaitingAnimationResultTypeSucceeded EndingDuration:2 Completion:^{
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //Check Registration
                            [UITools ShowOkAlertDialogWithUIViewController:self Title:@"Registration Process Failed" andMessage:MessageToUI];
                        });
                        
                    }];
                });
                
            }];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [waitingAnimViewController updateMessage:@"Information statically Registered" WithResultType:WaitingAnimationResultTypeSucceeded];
    });
    [self loadRegistration];
    
}

-(void) loadRegistration{
    sleep(1);
    dispatch_async(dispatch_get_main_queue(), ^{
        [waitingAnimViewController updateMessage:@"Initializing Registered Profile ..." WithResultType:WaitingAnimationResultTypeSucceeded];
    });
    sleep(1);
    //Load Registration
    [appMngr RegistrationProfile];
    
    if(![[appMngr registrationProfile] isRegistered]){
        dispatch_async(dispatch_get_main_queue(), ^{
            ALog("Loading Failed");
            [waitingAnimViewController EndWaitingFinishedWithMessage:@"Registration Process Failed" ResultType:WaitingAnimationResultTypeSucceeded EndingDuration:1 Completion:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Check Registration
                    [UITools ShowOkAlertDialogWithUIViewController:self Title:@"Initializing Registered Profile Failed" andMessage:MessageToUI];
                    // Retry
                });
                
            }];
        });
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [waitingAnimViewController EndWaitingFinishedWithMessage:@"Registration Processed" ResultType:WaitingAnimationResultTypeSucceeded EndingDuration:1 Completion:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                // Go to Subscription Page
                //ALog("Go to Subscriptions Page");
                //Restart Application
                [appMngr openSignInViewControllerAsRootViewControllerWithUsername:nil Password:nil];
                
            });
        }];
    });
    
    
}



@end
