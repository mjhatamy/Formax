//
//  SignupPageDViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AbstractSessionViewController.h"
#import "FormaxTypeATextField.h"
#import "AppManager.h"

@interface SignupPageDViewController : AbstractSessionViewController 
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *passwordTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *confirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UIView *passwordStrengthView;
@property (weak, nonatomic) IBOutlet UIProgressView *passwordStrengthProgressView;
@property (weak, nonatomic) IBOutlet UILabel *passwordStrengthLabel;

@property (weak, nonatomic) IBOutlet UIButton *continueBtn;

@end
