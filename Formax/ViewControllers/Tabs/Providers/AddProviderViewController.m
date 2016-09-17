//
//  AddProviderViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AddProviderViewController.h"
#import "AuthorizationDialogClass.h"
#import "PopupTagSetterViewController.h"
#import "AppManager.h"
#import "LocalDatabase.h"
#import "UITools.h"
#import "ProviderModelClass.h"
#import "SignatureViewController.h"

@interface AddProviderViewController ()<SignatureViewControllerDelegate>
{
    PopupTagSetterViewController* popupTagSetterVC;
    AppManager *appMngr;
    LocalDatabase *ldb;
    
    FaceCaptureViewController *faceCaptureCameraVC;
    ProviderModelClass* providerProfile;
    SignatureViewController *signatureVC;
    
    UIImage* currentSignature;
}

@end

@implementation AddProviderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    ldb = [LocalDatabase SharedInstance];
    _providerPhotoImageCoverView.layer.cornerRadius = 5;
    _providerPhotoImageView.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePatientPhotoTapGestureRecognizer:)];
    photoTap.numberOfTapsRequired = 1;
    photoTap.numberOfTouchesRequired = 1;
    [_providerPhotoImageView addGestureRecognizer:photoTap];
    
    
    _profileGroup1CoverView.layer.cornerRadius = 5;
    _profileGroup2CoverView.layer.cornerRadius = 5;
    _profileGroup3CoverView.layer.cornerRadius = 5;
    _profileGroup4CoverView.layer.cornerRadius = 5;
    _profileGroup5CoverView.layer.cornerRadius = 5;
    _profileGroup6CoverView.layer.cornerRadius = 5;
    
    //_ViewMode = PageViewModeView;
    //_ProviderId = [NSNumber numberWithInt:1000];
    
    [self setUpPage];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if([self.delegate conformsToProtocol:@protocol(AddProviderViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(onAddProviderViewControllerClosedDelegate)]){
        [self.delegate onAddProviderViewControllerClosedDelegate];
    }
}

-(void) handlePatientPhotoTapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    [self onOpenFaceDetectCamera];
}
- (IBAction)onCameraBtnPressed:(id)sender {
    [self onOpenFaceDetectCamera];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

- (IBAction)cancelToolbarBtnPressed:(id)sender {
    if(_ViewMode==PageViewModeEdit){
        _ViewMode = PageViewModeView;
        [self setUpPage];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}



- (IBAction)onTextChanged:(FormaxTypeATextField *)sender {
    BOOL error;
    if(sender.tag == 100){
        _providerIdTextField.text = [UITools stringToDigitsString: _providerIdTextField.text];
    }else if(sender.tag == 101 || sender.tag==102){
        _firstNameTextField.text = [UITools stringToAlphabetString:_firstNameTextField.text];
        _lastNameTextField.text = [UITools stringToAlphabetString:_lastNameTextField.text];
    }else if(sender.tag==103){
        _birthdateTextField.text = [UITools formatStringAsDate:_birthdateTextField.text usformat:!appMngr.AppConfig.InternationalModeEnabled.boolValue error: &error];
        [_birthdateTextField setIsValid:(_birthdateTextField.text.length==10)];
    }else if(sender.tag==104){
        _ssnTextField.text = [UITools formatNumbersAsSSN:_ssnTextField.text];
        [_ssnTextField setIsValid:(_ssnTextField.text.length==11)];
    }else if(sender.tag == 105){
        _primaryPhoneNumberTextField.text = [UITools formatNumbersAsPhoneNumber:_primaryPhoneNumberTextField.text usformat:YES];
        [_primaryPhoneNumberTextField setIsValid:(_primaryPhoneNumberTextField.text.length==14)];
    }else if(sender.tag == 106){
        [_emailAddrTextField setIsValid:[UITools validateEmailAddressByEmailAddress:_emailAddrTextField.text]];
    }else if(sender.tag == 113){
        _cityAddrTextField.text = [UITools stringToAlphabetString:_cityAddrTextField.text];
        if(_cityAddrTextField.text.length >= 4){
            NSArray *arr = [ldb getZipAndStateByCityName:_cityAddrTextField.text];
            
            if(arr != nil && arr.count>1){
                NSString *zip = [arr objectAtIndex:0];
                NSString *state = [arr objectAtIndex:1];
                _zipAddrTextField.text = zip;
                _stateAddrTextField.text = state;
            }
        }
    }else if(sender.tag == 112){
        _zipAddrTextField.text = [UITools stringToDigitsString:_zipAddrTextField.text];
        //if 5 digits, fill city and State
        if(_zipAddrTextField.text.length >= 5){
            NSArray *arr = [ldb getCityAndStateByZipCode:[NSNumber numberWithInt:_zipAddrTextField.text.intValue]];
            
            if(arr != nil && arr.count>1){
                NSString *city = [arr objectAtIndex:0];
                NSString *state = [arr objectAtIndex:1];
                _cityAddrTextField.text = city;
                _stateAddrTextField.text = state;
            }
            
        }
    }else if(sender.tag == 116 ) {
        [_passwordTextField setIsValid:(_passwordTextField.text.length > 3)];
        [_confirmPasswordTextField setEnabled:_passwordTextField.isValid];
    }else if(sender.tag == 117){
        if([_confirmPasswordTextField.text isEqualToString:_passwordTextField.text]){
            [_confirmPasswordTextField setIsValid:YES];
        }else{
            [_confirmPasswordTextField setIsValid:NO];
        }
    }
    
    //[self checkFieldsValidity];
}

-(void) onOpenFaceDetectCamera{
    NSLog(@"Openning Camera");
    faceCaptureCameraVC = [FaceCaptureViewController initWithCameraOnFront:YES];
    faceCaptureCameraVC.delegate = self;
    
    [self presentViewController:faceCaptureCameraVC animated:YES completion:^{
        
    }];
}

-(void)onFaceCaptureViewControllerSaveImage:(UIImage *)image{
    if(image!=nil){
        [_providerPhotoImageView setImage:image];
        if(_providerPhotoImageView.image.size.width <=0 ){
            [_providerPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
        }
    }
}

- (IBAction)saveToolbarBtnPressed:(id)sender {
    if(_ViewMode==PageViewModeView){
        _ViewMode = PageViewModeEdit;
        [self setUpPage];
        return;
    }else if(_ViewMode == PageViewModeEdit){
        [self saveProfileOrUpdate:YES];
    }else if(_ViewMode == PageViewModeAddnew){
        [self saveProfileOrUpdate:NO];
    }
}



-(void) setUpPage{
    if(_ViewMode == PageViewModeView){
        [self setUpPageForViewMode];
    }else if(_ViewMode == PageViewModeEdit){
        [self setUpPageForEditMode];
    }else if(_ViewMode == PageViewModeAddnew){
        [self setUpPageForAddnewMode];
    }
}


-(void) setUpPageForAddnewMode{
    _providerIdTextField.text = [NSString stringWithFormat:@"%d",appMngr.AppConfiguration.PatientIdCounter.intValue];
    _firstNameTextField.text = @"";
    _lastNameTextField.text = @"";
    _birthdateTextField.text = @"";
    _ssnTextField.text = @"";
    _primaryPhoneNumberTextField.text = @"";
    _emailAddrTextField.text = @"";
    _stateAddrTextField.text = @"";
    _deaLicenseNoTextField.text = @"";
    _streetAddrTextField.text = @"";
    _aptAddrTextField.text = @"";
    _zipAddrTextField.text = @"";
    _cityAddrTextField.text = @"";
    _stateAddrTextField.text = @"";
    _countryAddrTextField.text = @"USA";
    [_providerPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
    
    [_cancelToolbarBtn setTitle:@"Cancel"];
    [_saveToolbarBtn setTitle:@"Save"];
    [self setPageElements:YES];
    [_firstNameTextField becomeFirstResponder];
    [_addSignatureBtn setHidden:NO];
    [_viewSignatureBtn setHidden:YES];
}

-(void) setUpPageForEditMode{
    [_addSignatureBtn setHidden:YES];
    [_viewSignatureBtn setHidden:NO];
    
    [_cancelToolbarBtn setTitle:@"Cancel"];
    [_saveToolbarBtn setTitle:@"Save"];
    [self setPageElements:YES];
    [_firstNameTextField becomeFirstResponder];
}

-(void) setUpPageForViewMode{
    providerProfile = [ldb getProviderByProviderId:_ProviderId];
    
    _providerIdTextField.text = [NSString stringWithFormat:@"%d",providerProfile.ProviderId.intValue];
    _firstNameTextField.text = providerProfile.FirstName;
    _lastNameTextField.text = providerProfile.LastName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    else
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    _birthdateTextField.text = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:providerProfile.DOB.doubleValue]];
    
    _ssnTextField.text = providerProfile.SSN;
    _primaryPhoneNumberTextField.text = providerProfile.PrimaryContactNumber;
    _emailAddrTextField.text = providerProfile.EmailAddr;
    _stateLicenseNoTextField.text = providerProfile.StateLicenseNumber;
    _deaLicenseNoTextField.text = providerProfile.DEALicenseNumber;
    _streetAddrTextField.text = providerProfile.StreetAddr;
    _aptAddrTextField.text = providerProfile.AptAddr;
    _zipAddrTextField.text = providerProfile.ZipCodeAddr;
    _cityAddrTextField.text = providerProfile.CityAddr;
    _stateAddrTextField.text = providerProfile.StateAddr;
    _countryAddrTextField.text = providerProfile.CountryAddr;
    [_providerPhotoImageView setImage:[UIImage imageWithData:providerProfile.PhotoData]];
    if(_providerPhotoImageView.image.size.width <=0){
        [_providerPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
    }
    
    currentSignature = [UIImage imageWithData:providerProfile.SignatureData];
    ALog("Image Size:%f", currentSignature.size.width);
    
    _passwordTextField.text = providerProfile.Password;
    _confirmPasswordTextField.text = providerProfile.Password;
    
    [_addSignatureBtn setHidden:YES];
    [_viewSignatureBtn setHidden:NO];
    
    [_cancelToolbarBtn setTitle:@"Close"];
    [_saveToolbarBtn setTitle:@"Edit"];
    [self setPageElements:NO];
}



-(void) setPageElements:(BOOL) enabled{
    //Patient Id is only Editable in Add new mode
    [_providerIdTextField  setUserInteractionEnabled:( (_ViewMode==PageViewModeAddnew) && appMngr.AppConfig.ProviderIdEditable.boolValue) ];
    
    [_firstNameTextField setUserInteractionEnabled:enabled];
    [_lastNameTextField setUserInteractionEnabled:enabled];
    [_birthdateTextField  setUserInteractionEnabled:enabled];
    [_ssnTextField setUserInteractionEnabled:enabled];
    [_primaryPhoneNumberTextField  setUserInteractionEnabled:enabled];
    [_emailAddrTextField  setUserInteractionEnabled:enabled];
    [_stateLicenseNoTextField setUserInteractionEnabled:enabled];
    [_deaLicenseNoTextField setUserInteractionEnabled:enabled];
    [_streetAddrTextField  setUserInteractionEnabled:enabled];
    [_aptAddrTextField  setUserInteractionEnabled:enabled];
    [_zipAddrTextField  setUserInteractionEnabled:enabled];
    [_cityAddrTextField  setUserInteractionEnabled:enabled];
    [_stateAddrTextField  setUserInteractionEnabled:enabled];
    [_countryAddrTextField  setUserInteractionEnabled:enabled];
    [_passwordTextField setUserInteractionEnabled:enabled];
    [_confirmPasswordTextField setUserInteractionEnabled:enabled];
}



-(ProviderModelClass *)getProfileFieldsFromUI:(ProviderModelClass *)obj
{
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue){
        [dateformat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    }else{
        [dateformat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    }
    
    //Check Changes and compare to actual Values if same remove changed value
    if(obj==nil) obj = [[ProviderModelClass alloc] init];
    
    obj.ProviderId = [NSNumber numberWithInt:[_providerIdTextField text].intValue];
    obj.FirstName = [_firstNameTextField text] ;
    obj.LastName = [_lastNameTextField text];
    obj.SSN = [_ssnTextField text];
    obj.DOB = [NSNumber numberWithDouble:[dateformat dateFromString:_birthdateTextField.text].timeIntervalSince1970];
    
    obj.PrimaryContactNumber =  [UITools stringToDigitsString:[_primaryPhoneNumberTextField text]];
    obj.StreetAddr = _streetAddrTextField.text;
    obj.AptAddr = _aptAddrTextField.text ;
    obj.CityAddr = _cityAddrTextField.text ;
    obj.StateAddr = _stateAddrTextField.text ;
    obj.ZipCodeAddr = _zipAddrTextField.text ;
    obj.EmailAddr = _emailAddrTextField.text ;
    //obj.SecondaryContactNumber = _secondaryContactNumberTextField.text ;
    obj.CountryAddr = _countryAddrTextField.text;
    
    if(_providerPhotoImageView.image.size.width > 0){
        obj.PhotoData = UIImagePNGRepresentation(_providerPhotoImageView.image);
    }else{
        obj.PhotoData = nil;
    }
    
    obj.SignatureData = UIImagePNGRepresentation(currentSignature);
    obj.Password = _passwordTextField.text;
    obj.StateLicenseNumber = _stateLicenseNoTextField.text;
    obj.DEALicenseNumber = _deaLicenseNoTextField.text;
    
    //if(_maleCheckBox.isSelected) obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeMale];
    //else if(_femaleCheckBox.isSelected ) obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeFemale];
    //else obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeUnknown];
    
    return obj;
}

- (IBAction)onAddSignatureToolbatBtnPressed:(id)sender {
    
    if(_ViewMode == PageViewModeEdit || _ViewMode==PageViewModeView){
        AuthorizationDialogClass *adc = [[AuthorizationDialogClass alloc] initWithViewController:self AccessPin:appMngr.AppConfig.AccessPin];
        [adc AuthorizeOperationWithCompletionhandler:^(BOOL succeeded, NSString *msgToUI, NSError *error) {
            if(succeeded){
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if(signatureVC == nil) signatureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
                    
                    signatureVC.delegate = self;
                    signatureVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    signatureVC.modalPresentationStyle = UIModalPresentationFormSheet;
                    [self presentViewController:signatureVC animated:YES completion:^{
                        
                    }];
                }];
                
                
            }else{
                if(msgToUI!=nil){
                    //Show Message on Screen using OK Dialog Box
                }
            }
            
        }];
        return;
    }
    
    if(signatureVC == nil) signatureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
    
    signatureVC.delegate = self;
    signatureVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    signatureVC.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:signatureVC animated:YES completion:^{
        
    }];
}

- (IBAction)onViewSignatureToolbarBtnPressed:(id)sender {
    if(_ViewMode == PageViewModeEdit || _ViewMode==PageViewModeView){
        AuthorizationDialogClass *adc = [[AuthorizationDialogClass alloc] initWithViewController:self AccessPin:appMngr.AppConfig.AccessPin];
        [adc AuthorizeOperationWithCompletionhandler:^(BOOL succeeded, NSString *msgToUI, NSError *error) {
            if(succeeded){
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    if(signatureVC == nil) signatureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
                    
                    signatureVC.delegate = self;
                    signatureVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    signatureVC.modalPresentationStyle = UIModalPresentationFormSheet;
                    signatureVC.currentSignatureImage = currentSignature;
                    [self presentViewController:signatureVC animated:YES completion:^{
                        
                    }];
                }];
                
                
            }else{
                if(msgToUI!=nil){
                    //Show Message on Screen using OK Dialog Box
                }
            }
            
        }];
        return;
    }
    if(signatureVC == nil) signatureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignatureViewController"];
    
    signatureVC.delegate = self;
    signatureVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    signatureVC.modalPresentationStyle = UIModalPresentationFormSheet;
    signatureVC.signPadBgImageView.image = currentSignature;
    ALog("Image Size:%f", currentSignature.size.width);
    signatureVC.currentSignatureImage = currentSignature;
    [self presentViewController:signatureVC animated:YES completion:^{
        
    }];
}


- (void)saveProfileOrUpdate:(BOOL) Update {
    if(_ViewMode==PageViewModeAddnew){
        //validate data from UI
        if(![self validateProviderDataForViewMode:_ViewMode]){
            return;
        }
        //Save UI to disk and reload as View mode
        ProviderModelClass *obj;
        obj = [self getProfileFieldsFromUI:nil];
        obj.PatientsIdList = nil;
        obj.AppName = [UITools getAppName];
        obj.Username = [appMngr.mscs getCurrentUser].username;
        
        NSNumber *requestedProviderId = appMngr.AppConfiguration.ProviderIdCounter;
        if(requestedProviderId==nil){
            requestedProviderId = [NSNumber numberWithInt:MinimumProviderId]; //set default minimum Provider Id
            
            //Also Fix appConfig error. *Provider Counter should never be nil
            [appMngr.mscs saveAppConfig:appMngr.AppConfig CompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
                
            }];
        }
        
        //Generate Provider Id by App Manager
        NSNumber* calculatedProviderId = [ldb checkProviderIdValidityAndReturnValidProviderIdByProviderId:requestedProviderId SearchProviderIdStartOffset: requestedProviderId];
        
        if([requestedProviderId compare:calculatedProviderId]!=NSOrderedSame){
            ALog("Provider Ids are not equal.  calculated:%d  requested:%d", calculatedProviderId.intValue, requestedProviderId.intValue);
        }else{
            ALog("Provider Ids are equal.  calculated:%d  requested:%d", calculatedProviderId.intValue, requestedProviderId.intValue);
        }
        
        obj.CreationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
        obj.ModificationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
        obj.ProviderId = calculatedProviderId;
        NSNumber* result = [ldb addProviderRecordForObj:obj];
        
        //If failed
        if(result==nil){
            [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed to add" andMessage:@"Application Failed to add Provider to Database"];
            return;
        }
        
        obj = [ldb getProviderByProviderId:result];
        //If unable to load added Provider
        if(obj==nil){
            [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Failed to Load" andMessage:@"Application was unable to load recently added Provider from Database"];
            return;
        }
        
        _ProviderId = obj.ProviderId;
        _ViewMode = PageViewModeView;
        [self setUpPage];
        
    }else if(_ViewMode==PageViewModeEdit){
        //validate data from UI
        if(![self validateProviderDataForViewMode:_ViewMode]){
            return;
        }
        
        //update current Provider
        ProviderModelClass *obj = [ldb getProviderByProviderId:_ProviderId];
        obj = [self getProfileFieldsFromUI:obj];
        obj.ModificationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
        
        if(![ldb updateProvidersRecordForObj:obj] ){
            [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Update Failed" andMessage:@"Application was unable to Update Databse for Provider"];
            return;
        }
        
        //Make the View
        _ViewMode = PageViewModeView;
        [self setUpPage];
    }
}


-(BOOL) validateProviderDataForViewMode:(PageViewMode) viewMode
{
    if(_firstNameTextField.text.length <=1){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"First Name must not be empty" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_firstNameTextField becomeFirstResponder];
            });
        }];
        return NO;
    }
    
    if(_lastNameTextField.text.length <=1){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"Last Name must not be empty" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_lastNameTextField becomeFirstResponder];
            });
        }];
        return NO;
    }
    
    if(_birthdateTextField.text.length <=8){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"Date of birth must not be empty or incomplete" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_birthdateTextField becomeFirstResponder];
            });
        }];
        return NO;
    }
    
    
    if(viewMode==PageViewModeAddnew){
        if(!(currentSignature.size.width > 0)){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"Signature must not be empty" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onAddSignatureToolbatBtnPressed:nil];
                });
            }];
            return NO;
        }
    }else if(viewMode==PageViewModeEdit){
        if( !(currentSignature.size.width>0)){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"Signature must not be empty" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self onAddSignatureToolbatBtnPressed:nil];
                });
            }];
                return NO;
        }
    }
    
    //if( !_femaleCheckBox.isSelected && !_maleCheckBox.isSelected){
    //    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Error" andMessage:@"You must select male or female gender for current provider"];
    //    return NO;
    //}
    
    if(_passwordTextField.text.length <= 3){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Mandatory Requirement" andMessage:@"You must enter a password to access this provider. Password should containt at least 4 characters." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_passwordTextField becomeFirstResponder];
            });
        }];
        
        
        return NO;
    }
    
    if(_confirmPasswordTextField.text.length <=3 ){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Error" andMessage:@"You must confirm password to access this provider. Password should containt at least 4 characters." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_confirmPasswordTextField becomeFirstResponder];
            });
        }];
    }
    
    if(![_passwordTextField.text isEqualToString:_confirmPasswordTextField.text]){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Error" andMessage:@"Access Password and Confirmation Password should be equal" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_confirmPasswordTextField becomeFirstResponder];
            });
        }];
        
        return NO;
    }
    //Check for Signature
    
    return YES;
}


-(void)onSignatureViewControllerDoneDelegate:(UIImage *)image{
    //Set Btn As Image Available
    currentSignature = image;
}

-(void)onSignatureViewControllerCanceledDelegate{
    
}

- (IBAction)onCanceltoolbarBtnPressed:(id)sender {
    if(_ViewMode==PageViewModeView || _ViewMode==PageViewModeAddnew){
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        _ViewMode=PageViewModeView;
        [self setUpPage];
    }
}


@end
