//
//  SignInViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AbstractSessionViewController.h"
#import "AppManager.h"

@interface SignInViewController : AbstractSessionViewController<UITextFieldDelegate, AWSCognitoIdentityPasswordAuthentication, AWSCognitoIdentityInteractiveAuthenticationDelegate>

@property (weak, nonatomic) IBOutlet UIView *userpassView;
@property (weak, nonatomic) IBOutlet UITextField *emailAddrTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signinBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordBtn;
@property ( nonatomic) BOOL AutoLogin;
@property (weak, nonatomic) IBOutlet UIImageView *signLogoAnimImageView;

@end
