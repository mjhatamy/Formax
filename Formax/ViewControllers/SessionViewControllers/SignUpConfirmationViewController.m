//
//  SigninConfirmationViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/4/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignUpConfirmationViewController.h"
#import "AppManager.h"

@interface SignUpConfirmationViewController (){
    AppManager* appMngr;
}

@property (nonatomic,strong) AWSTaskCompletionSource<NSString *>* mfaCodeCompletionSource;

@end

@implementation SignUpConfirmationViewController

- (instancetype)initWithUsername:(NSString *)UserName
{
    self = [super init];
    if (self) {
        _Username = UserName;
    }
    return self;
}

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
    [_verificationCodeTextField becomeFirstResponder];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)onVerifyBtnPressed:(id)sender {
    AWSCognitoIdentityUser* user = [appMngr.mscs getCurrentUser];
    if(user == nil || user.username == nil){
        user = [appMngr.mscs.identityPool getUser:_Username];
    }
    
    if(user == nil || user.username==nil){
        return;
    }
    ALog("Key :%@", _verificationCodeTextField.text);
    [[user confirmSignUp:_verificationCodeTextField.text forceAliasCreation:YES] continueWithBlock: ^id _Nullable(AWSTask<AWSCognitoIdentityUserConfirmSignUpResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                if(task.error){
                    [UITools ShowOkAlertDialogWithUIViewController:self Title:task.error.userInfo[@"__type"] andMessage:task.error.userInfo[@"message"]];
                }
            }else {
                //return to signin screen
                //((SignInViewController *)self.navigationController.viewControllers[0]).usernameText = self.user.username;
                //[self.navigationController popToRootViewControllerAnimated:YES];
                NSLog(@"%@ -- %@", _Username, _Password);
                [appMngr openSignInViewControllerAsRootViewControllerWithUsername:_Username Password:_Password];
                
            }
        });
        return nil;
    }];
}


-(void)getMultiFactorAuthenticationCode:(AWSCognitoIdentityMultifactorAuthenticationInput *)authenticationInput mfaCodeCompletionSource:(AWSTaskCompletionSource<NSString *> *)mfaCodeCompletionSource{
    self.mfaCodeCompletionSource = mfaCodeCompletionSource;
}

-(void)didCompleteMultifactorAuthenticationStepWithError:(NSError *)error{
    [UITools ShowOkAlertDialogWithUIViewController:self Title:error.userInfo[@"__type"] andMessage:error.userInfo[@"message"]];
}

- (IBAction)onResendConfirmationCodePressed:(id)sender {
    AWSCognitoIdentityUser* user = [appMngr.mscs getCurrentUser];
    if(user == nil || user.username == nil){
        user = [appMngr.mscs.identityPool getUser:_Username];
    }
    
    if(user == nil || user.username==nil){
        return;
    }
    
    [[user resendConfirmationCode] continueWithBlock:^id _Nullable(AWSTask<AWSCognitoIdentityUserResendConfirmationCodeResponse *> * _Nonnull task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(task.error){
                [UITools ShowOkAlertDialogWithUIViewController:self Title:task.error.userInfo[@"__type"] andMessage:task.error.userInfo[@"message"]];
            }else {
                [UITools ShowOkAlertDialogWithUIViewController:self Title:@"Code Resent" andMessage:[NSString stringWithFormat:@"Code resent to: %@", task.result.codeDeliveryDetails.destination]];
            }
        });
        return nil;
    }];
}

- (IBAction)editChanged:(id)sender {
    UITextField* txt = (UITextField *) sender;
    if(txt.tag == 108){
        [_verifyBtn setEnabled:(_verificationCodeTextField.text.length > 0)];
    }
}

- (IBAction)onCloseBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
@end
