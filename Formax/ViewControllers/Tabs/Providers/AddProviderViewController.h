//
//  AddProviderViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormaxTypeATextField.h"
#import "FaceCaptureViewController.h"

@protocol AddProviderViewControllerDelegate <NSObject>

-(void) onAddProviderViewControllerClosedDelegate;

@end

@interface AddProviderViewController : UIViewController<UIBarPositioningDelegate, FaceCaptureViewControllerDelegate, UITextFieldDelegate>
@property (nonatomic, assign) id delegate;

@property (weak, nonatomic) IBOutlet UIView *providerPhotoImageCoverView;
@property (weak, nonatomic) IBOutlet UIImageView *providerPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *providerPhotoBtn;


@property (nonatomic) PageViewMode ViewMode;
@property (nonatomic, copy) NSNumber* ProviderId;
@property (weak, nonatomic) IBOutlet UIView *profileGroup1CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup2CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup3CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup4CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup5CoverView;
@property (weak, nonatomic) IBOutlet UIView *profileGroup6CoverView;

@property (weak, nonatomic) IBOutlet FormaxTypeATextField *providerIdTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *birthdateTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *ssnTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *primaryPhoneNumberTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *emailAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *stateLicenseNoTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *deaLicenseNoTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *streetAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *aptAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *zipAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *cityAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *stateAddrTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *countryAddrTextField;

@property (weak, nonatomic) IBOutlet FormaxTypeATextField *passwordTextField;
@property (weak, nonatomic) IBOutlet FormaxTypeATextField *confirmPasswordTextField;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveToolbarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelToolbarBtn;

@property (weak, nonatomic) IBOutlet UIButton *addSignatureBtn;
@property (weak, nonatomic) IBOutlet UIButton *viewSignatureBtn;


@end
