//
//  SignupPageCViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AbstractSessionViewController.h"
#import "FormaxTypeATextField.h"

@interface SignupPageCViewController : AbstractSessionViewController<UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet FormaxTypeATextField *emailAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIStackView *secondPartStackView;


@end
