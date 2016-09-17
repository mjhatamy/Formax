//
//  OfficeRegistratonStepBViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormaxTypeATextField.h"

@interface OfficeRegistratonStepBViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeEmailAddressTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficePhonenumberTextField;

@end
