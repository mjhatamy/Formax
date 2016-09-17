//
//  SigninConfirmationViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/4/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AbstractSessionViewController.h"
#import "FormaxTypeATextField.h"
#import "AppManager.h"

@interface SignUpConfirmationViewController : AbstractSessionViewController<AWSCognitoIdentityMultiFactorAuthentication>


@property (weak, nonatomic) IBOutlet UILabel *smsVerificationLabel;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *verifyBtn;
@property (nonatomic, copy) NSString* Username;
@property (nonatomic, copy) NSString* Password;


- (instancetype)initWithUsername:(NSString *)UserName;

@end
