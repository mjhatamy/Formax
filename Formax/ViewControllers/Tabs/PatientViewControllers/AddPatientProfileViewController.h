//
//  AddPatientProfileViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/2/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormaxTypeATextField.h"
#import "FaceCaptureViewController.h"
#import "CheckBoxTypeA.h"

@interface AddPatientProfileViewController : UIViewController<UIBarPositioningDelegate, FaceCaptureViewControllerDelegate>


@property (weak, nonatomic) IBOutlet UIView *patientPhotoImageCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *patientPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *patientPhotoBtn;


@property (nonatomic) PageViewMode ViewMode;
@property (nonatomic, copy) NSNumber* PatientId;
@property (weak, nonatomic) IBOutlet UIView *profileGroup1CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup2CoverView;

@property (weak, nonatomic) IBOutlet FormaxTypeATextField *patientIdTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *ssnTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *primaryPhoneNumberTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *emailAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *streetAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *aptAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *zipAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *cityAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *stateAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *countryAddrTextField;

@property (weak, nonatomic) IBOutlet UIToolbar *topToolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveToolbarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelToolbarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addFormToSignToolbarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *topTitleToolbarBtn;
@property (weak, nonatomic) IBOutlet UIView *signedFormsView;

@property (weak, nonatomic) IBOutlet CheckBoxTypeA *maleCheckBox;
@property (weak, nonatomic) IBOutlet CheckBoxTypeA *femaleCheckBox;


@end
