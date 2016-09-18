//
//  SignInViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignInViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#import "Config.h"
#import "WaitingAnimationViewcontroller.h"
#import "AppManager.h"
#import "SignUpConfirmationViewController.h"

@interface SignInViewController ()<CAAnimationDelegate>
{
    UIImageView *blurryView;
    WaitingAnimationViewController* waitingAnimVC;
    AppManager* appMngr;
    SignUpConfirmationViewController* signupConfirmationVC;
}

@property (nonatomic, strong) AWSCognitoIdentityUserPool * pool;
@property (nonatomic, strong) AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails*>* passwordAuthenticationCompletion;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    _userpassView.layer.cornerRadius = 14;
    _userpassView.layer.borderColor = [UIColor colorWithRed:(217.0f/255.0f) green:(217.0f/255.0f) blue:(217.0f/255.0f) alpha:1.0f].CGColor;
    _userpassView.layer.borderWidth = 1;

    [self appDelegateNotification];
}

-(void)viewDidDisappear:(BOOL)animated{
    [appMngr.mscs getDelegateOwnership];
    
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self showSignAnimation];
    
    [self performSelector:@selector(removeBlurry) withObject:self afterDelay:0.3];
    
    if(_emailAddrTextField.text.length > 0 && _passwordTextField.text.length > 0 && _AutoLogin){
        [self signinNow];
        return;
    }
    if([appMngr.mscs getCurrentUser].username != nil){
        _emailAddrTextField.text = [appMngr.mscs getCurrentUser].username;
    }

    
    if([appMngr.mscs getCurrentUser].isSignedIn){
        ALog("Auto Login because saved session is available");
        [appMngr.mscs getCurrntUserDetailWithCompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
            dispatch_async(dispatch_get_main_queue(), ^{
                ALog("SEGUE gotoAfterLoginProcessorViewSegue");
                [self performSegueWithIdentifier:@"gotoAfterLoginProcessorViewSegue" sender:self];
            });
        }];
        
    }else{
        ALog("User not logged in");
    }
    
    
    
}

-(void) showSignAnimation{
    NSMutableArray *imageListNames = [[NSMutableArray alloc] init];
    for(int i=57; i > 0; i--){
        [imageListNames addObject:[NSString stringWithFormat:@"SignAnim_%d", i]];
    }
    NSMutableArray *animImages = [[NSMutableArray alloc] init];
    for(int i=0; i < imageListNames.count; i++){
        [animImages addObject:(id)[UIImage imageNamed:[imageListNames objectAtIndex:i]].CGImage ];
    }
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    animation.calculationMode = kCAAnimationDiscrete;
    animation.duration = 57 / 25.0; // 24 frames per second
    animation.values = animImages;
    animation.repeatCount = 1;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    [self.signLogoAnimImageView.layer addAnimation:animation forKey:@"animation"];
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.signLogoAnimImageView.image = [UIImage imageNamed:@"SignAnim_1.png"];
}


-(void) removeBlurry{
    [blurryView removeFromSuperview];
}
-(void) addBlurry{
    //Get a UIImage from the UIView
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //Blur the UIImage with a CIFilter
    CIImage *imageToBlur = [CIImage imageWithCGImage:viewImage.CGImage];
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName: @"CIGaussianBlur"];
    [gaussianBlurFilter setValue:imageToBlur forKey: @"inputImage"];
    [gaussianBlurFilter setValue:[NSNumber numberWithFloat: 10] forKey: @"inputRadius"];
    CIImage *resultImage = [gaussianBlurFilter valueForKey: @"outputImage"];
    UIImage *endImage = [[UIImage alloc] initWithCIImage:resultImage];
    
    //Place the UIImage in a UIImageView
    blurryView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    blurryView.image = endImage;
    [self.view addSubview:blurryView];
}


- (void) appDelegateNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResign) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) applicationWillResign{
    NSLog(@"applicationWillResign");
    [self addBlurry];
}

- (void) applicationDidBecomeActive{
    NSLog(@"applicationDidBecomeActive");
    [self  removeBlurry];
}



- (IBAction)editChanged:(id)sender {
}


- (IBAction)onSignBtnPressed:(id)sender {
    if(![UITools validateEmailAddressByEmailAddress:_emailAddrTextField.text]){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Email Address is invalid" andMessage:@"Please check entered email address format and try again" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_emailAddrTextField becomeFirstResponder];
            });
            
        }];
        return;
    }
    
    if(_passwordTextField.text.length < 7){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Password not valid" andMessage:@"Enter a Combination of at least eight numbers, letters and punctuation marks (like ! and &)" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [_passwordTextField becomeFirstResponder];
            });
            
        }];
        return;
    }
    
    if(waitingAnimVC == nil){
        waitingAnimVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
    }
    
    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/payment_success.caf"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
    
    [self signinNow];
}

-(void) openMainViewcontroller{
    [self performSegueWithIdentifier:@"gotoMainViewControllerSegue" sender:self];
}


- (IBAction)onForgotPassBtnPressed:(id)sender {
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if([textField isEqual:_emailAddrTextField]){
        [_passwordTextField becomeFirstResponder];
    }else if([textField isEqual:_passwordTextField]){
        [self onSignBtnPressed:nil];
    }
    
    return NO;
}

-(void) signinNow{
    
    if(self.passwordAuthenticationCompletion==nil || self.passwordAuthenticationCompletion.task.isCompleted){
        [[[appMngr.mscs.identityPool getUser:_emailAddrTextField.text] getSession:_emailAddrTextField.text  password:_passwordTextField.text validationData:nil] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserSession *> * _Nonnull task) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [waitingAnimVC dismiss];
                if(task.error.code == AWSCognitoIdentityProviderErrorUserNotConfirmed){
                    ALog(@"User not confirmed open confirmation window");
                    [self openConfirmSigninViewcontroller];
                    //[self showConfirmSignUpViewController:_emailaddressTextField.text destination:nil];
                }else if(task.error.code == AWSCognitoIdentityProviderErrorUserNotFound || task.error.code == AWSCognitoIdentityProviderErrorResourceNotFound){
                    [waitingAnimVC dismiss];
                    ALog(@"%@", task.error.userInfo[@"message"]);
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Uknown Email Address" andMessage:task.error.userInfo[@"message"]];
                    
                }else if(task.error.code == AWSCognitoIdentityProviderErrorNotAuthorized) {
                    ALog(@"%@", task.error.userInfo[@"message"]);
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Sign in Failed" andMessage:task.error.userInfo[@"message"]];
                    
                }else if(task.error.code == AWSCognitoIdentityErrorResourceNotFound){
                    ALog(@"%@", task.error.userInfo[@"message"]);
                    [[appMngr.mscs.identityPool currentUser] signOutAndClearLastKnownUser];
                    [appMngr.mscs.identityPool token];
                }else if(task.error.code == kCFURLErrorNotConnectedToInternet){
                    ALog("NOT CONNECTED");
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Network connection required" andMessage:task.error.localizedDescription];
                }
                else if (task.error==nil){
                    ALog("\n\n\nLogged in");
                    [self performSegueWithIdentifier:@"gotoAfterLoginProcessorViewSegue" sender:self];
                }
                else{
                    ALog(@"%@", task.error.userInfo[@"message"]);
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed" andMessage:task.error.localizedDescription];
                    //[self performSegueWithIdentifier:@"showUserProfilePageViewcontrollerSegue" sender:self];
                }
             
            });

            return nil;
        }] ;
        return;
    }else{
        ALog("It is not nil -->Username:%@  password:%@", _emailAddrTextField.text, _passwordTextField.text);
        self.passwordAuthenticationCompletion.result = [[AWSCognitoIdentityPasswordAuthenticationDetails alloc] initWithUsername:_emailAddrTextField.text password:_passwordTextField.text];
    }
}


-(void)getPasswordAuthenticationDetails:(AWSCognitoIdentityPasswordAuthenticationInput *)authenticationInput passwordAuthenticationCompletionSource:(AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails *> *)passwordAuthenticationCompletionSource{
    ALog("getPasswordAuthenticationDetails");
    self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource;
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.emailAddrTextField.text.length <= 0)
            self.emailAddrTextField.text = authenticationInput.lastKnownUsername;
    });
}

-(void)didCompletePasswordAuthenticationStepWithError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [waitingAnimVC dismiss];

        if(error != nil){
            if(error.code == AWSCognitoIdentityProviderErrorUserNotConfirmed){
                ALog("Not Confirmed User");
                [self openConfirmSigninViewcontroller];
                return;
            }
            
            [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed" andMessage:error.userInfo[@"message"]];
            return;
        }
        
        
        //NO Error.. Signin complete Go to Processor
        [self performSegueWithIdentifier:@"gotoAfterLoginProcessorViewSegue" sender:self];
    });
    
    ALog("didCompletePasswordAuthenticationStepWithError-->%@\n%@", error.localizedDescription, error.userInfo[@"message"]);
}

-(id<AWSCognitoIdentityMultiFactorAuthentication>)startMultiFactorAuthentication{
    ALog(@"Start startMultiFactorAuthentication");
    signupConfirmationVC  = [[SignUpConfirmationViewController alloc] initWithUsername:_emailAddrTextField.text];
    
    return signupConfirmationVC;
}

-(void)openConfirmSigninViewcontroller{
    if(!signupConfirmationVC)
        signupConfirmationVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SignUpConfirmationViewController"];;
    signupConfirmationVC.Username = _emailAddrTextField.text;
    signupConfirmationVC.Password = _passwordTextField.text;
    
    if(!(signupConfirmationVC.isViewLoaded && signupConfirmationVC.view.window))
    {
        signupConfirmationVC.modalPresentationStyle = UIModalPresentationFormSheet;
        signupConfirmationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:signupConfirmationVC animated:YES completion:nil];
    }
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

@end
