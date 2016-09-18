//
//  OfficeRegistratonStepAViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormaxTypeATextField.h"

@interface OfficeRegistratonStepAViewController : UIViewController <UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeNameTextField;


@property (weak, nonatomic) IBOutlet UIStackView *OfficeAddressStackView;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeStreetAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeUnitAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeZipAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeCityAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *OfficeStateTextField;


@end
