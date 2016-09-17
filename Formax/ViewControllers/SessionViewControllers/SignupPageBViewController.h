//
//  SignupPageBViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/3/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AbstractSessionViewController.h"
#import "FormaxTypeATextField.h"

@interface SignupPageBViewController : AbstractSessionViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet UIButton *continueBtn;
@property (weak, nonatomic) IBOutlet UIStackView *secondPartStackView;

@end
