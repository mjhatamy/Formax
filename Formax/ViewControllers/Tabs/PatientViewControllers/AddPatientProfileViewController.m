//
//  AddPatientProfileViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/2/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "AddPatientProfileViewController.h"
#import "PopupTagSetterViewController.h"
#import "AppManager.h"
#import "LocalDatabase.h"
#import "UITools.h"
#import "PatientProfileModelClass.h"


@interface AddPatientProfileViewController (){
    PopupTagSetterViewController* popupTagSetterVC;
    AppManager *appMngr;
    LocalDatabase *ldb;
    
    FaceCaptureViewController *faceCaptureCameraVC;
    PatientProfileModelClass *patientProfile;
}

@end

@implementation AddPatientProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    ldb = [LocalDatabase SharedInstance];
    _patientPhotoImageCoverView.layer.cornerRadius = 5;
    
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePatientPhotoTapGestureRecognizer:)];
    photoTap.numberOfTapsRequired = 1;
    photoTap.numberOfTouchesRequired = 1;
    [_patientPhotoImageView addGestureRecognizer:photoTap];
    
    
    _profileGroup1CoverView.layer.cornerRadius = 5;
    _profileGroup2CoverView.layer.cornerRadius = 5;
    _signedFormsView.layer.cornerRadius = 5;
    
    
    if(_ViewMode == PageViewModePopupView){
        
    }
    
    [self setUpPage];
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
        _patientIdTextField.text = [UITools stringToDigitsString: _patientIdTextField.text];
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
        [_patientPhotoImageView setImage:image];
        if(_patientPhotoImageView.image.size.width <=0 ){
            [_patientPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
        }
    }
}

- (IBAction)saveToolbarBtnPressed:(id)sender {
    if(_ViewMode==PageViewModeView){
        _ViewMode = PageViewModeEdit;
        [self setUpPage];
        return;
    }else if(_ViewMode == PageViewModeEdit){
        [self savePatientProfileOrUpdate:YES];
    }else if(_ViewMode == PageViewModeAddnew){
        [self savePatientProfileOrUpdate:NO];
    }
}



-(void) setUpPage{
    if(_ViewMode == PageViewModeView){
        [self setUpPageForViewMode];
    }if(_ViewMode == PageViewModePopupView){
        [_saveToolbarBtn setEnabled:NO];
        [_addFormToSignToolbarBtn setEnabled:NO];
        ALog("ViewView mode");
        //[_topToolbar setHidden:YES];
        [self setUpPageForViewMode];
    }else if(_ViewMode == PageViewModeEdit){
        [self setUpPageForEditMode];
    }else if(_ViewMode == PageViewModeAddnew){
        [self setUpPageForAddnewMode];
    }
}


-(void) setUpPageForAddnewMode{
    _patientIdTextField.text = [NSString stringWithFormat:@"%d",appMngr.AppConfiguration.PatientIdCounter.intValue];
    _firstNameTextField.text = @"";
    _lastNameTextField.text = @"";
    _birthdateTextField.text = @"";
    _ssnTextField.text = @"";
    _primaryPhoneNumberTextField.text = @"";
    _emailAddrTextField.text = @"";
    _streetAddrTextField.text = @"";
    _aptAddrTextField.text = @"";
    _zipAddrTextField.text = @"";
    _cityAddrTextField.text = @"";
    _stateAddrTextField.text = @"";
    _countryAddrTextField.text = @"";
    [_patientPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
    
    [self setMaleCheckBox:_maleCheckBox]; 
    
    [_cancelToolbarBtn setTitle:@"Cancel"];
    [_saveToolbarBtn setTitle:@"Save"];
    [_topTitleToolbarBtn setTitle:@"Add Patient`s Profile"];
    [self setPageElements:YES];
}

-(void) setUpPageForEditMode{
    
    [_cancelToolbarBtn setTitle:@"Cancel"];
    [_saveToolbarBtn setTitle:@"Save"];
    [_topTitleToolbarBtn setTitle:@"Edit Patient`s Profile"];
    [self setPageElements:YES];
}

-(void) setUpPageForViewMode{
    patientProfile = [appMngr getPatientProfileByPatientId:_PatientId];
    
    _patientIdTextField.text = [NSString stringWithFormat:@"%d",patientProfile.PatientId.intValue];
    _firstNameTextField.text = patientProfile.FirstName;
    _lastNameTextField.text = patientProfile.LastName;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    else
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    _birthdateTextField.text = [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:patientProfile.BirthDate.doubleValue]];
    
    _ssnTextField.text = patientProfile.SSN;
    _primaryPhoneNumberTextField.text = patientProfile.PrimaryContactNumber;
    _emailAddrTextField.text = patientProfile.EmailAddr;
    _streetAddrTextField.text = patientProfile.StreetAddr;
    _aptAddrTextField.text = patientProfile.UnitAddr;
    _zipAddrTextField.text = patientProfile.ZipCodeAddr;
    _cityAddrTextField.text = patientProfile.CityAddr;
    _stateAddrTextField.text = patientProfile.StateAddr;
    _countryAddrTextField.text = patientProfile.CountryAddr;
    [_patientPhotoImageView setImage:[UIImage imageWithData:patientProfile.PreviewImageData]];
    if(_patientPhotoImageView.image.size.width <=0){
        [_patientPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
    }
    
    [_cancelToolbarBtn setTitle:@"Close"];
    [_saveToolbarBtn setTitle:@"Edit"];
    [_topTitleToolbarBtn setTitle:@"View Patient`s Profile"];
    [self setPageElements:NO];
}



-(void) setPageElements:(BOOL) enabled{
    //Patient Id is only Editable in Add new mode
    [_patientIdTextField  setUserInteractionEnabled:( (_ViewMode==PageViewModeAddnew) && appMngr.AppConfig.PatientIdEditable.boolValue) ];
    
    [_firstNameTextField setUserInteractionEnabled:enabled];
    [_lastNameTextField setUserInteractionEnabled:enabled];
    [_birthdateTextField  setUserInteractionEnabled:enabled];
    [_ssnTextField setUserInteractionEnabled:enabled];
    [_primaryPhoneNumberTextField  setUserInteractionEnabled:enabled];
    [_emailAddrTextField  setUserInteractionEnabled:enabled];
    [_streetAddrTextField  setUserInteractionEnabled:enabled];
    [_aptAddrTextField  setUserInteractionEnabled:enabled];
    [_zipAddrTextField  setUserInteractionEnabled:enabled];
    [_cityAddrTextField  setUserInteractionEnabled:enabled];
    [_stateAddrTextField  setUserInteractionEnabled:enabled];
    [_countryAddrTextField  setUserInteractionEnabled:enabled];
}



-(PatientProfileModelClass *)getPatientProfileFieldsFromUI
{
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue){
        [dateformat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    }else{
        [dateformat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    }
    
    //Check Changes and compare to actual Values if same remove changed value
    PatientProfileModelClass *obj = [[PatientProfileModelClass alloc] init];
    
    obj.PatientId = [NSNumber numberWithInt:[_patientIdTextField text].intValue];
    obj.FirstName = [_firstNameTextField text] ;
    obj.LastName = [_lastNameTextField text];
    obj.SSN = [_ssnTextField text];
    obj.BirthDate = [NSNumber numberWithDouble:[dateformat dateFromString:_birthdateTextField.text].timeIntervalSince1970];
    
    obj.PrimaryContactNumber =  [UITools stringToDigitsString:[_primaryPhoneNumberTextField text]];
    obj.StreetAddr = _streetAddrTextField.text;
    obj.UnitAddr = _aptAddrTextField.text ;
    obj.CityAddr = _cityAddrTextField.text ;
    obj.StateAddr = _stateAddrTextField.text ;
    obj.ZipCodeAddr = _zipAddrTextField.text ;
    obj.EmailAddr = _emailAddrTextField.text ;
    //obj.SecondaryContactNumber = _secondaryContactNumberTextField.text ;
    obj.CountryAddr = _countryAddrTextField.text;
    
    if(_patientPhotoImageView.image.size.width > 0){
        obj.PreviewImageData = UIImagePNGRepresentation(_patientPhotoImageView.image);
    }else{
        obj.PreviewImageData = nil;
    }
    
    //if(_maleCheckBox.isSelected) obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeMale];
    //else if(_femaleCheckBox.isSelected ) obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeFemale];
    //else obj.Gender = [NSNumber numberWithInt:PatientProfileGenderTypeUnknown];
    
    return obj;
}


- (void)savePatientProfileOrUpdate:(BOOL) Update{
    PatientProfileModelClass *obj = [self getPatientProfileFieldsFromUI];
    
    //CheckPatientProfile Fields Validity
    //Check First name and last name
    if(_firstNameTextField.text.length < 1){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"First Name must be valid" andMessage:@"Please enter a valid first name" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
           dispatch_async(dispatch_get_main_queue(), ^{
               [_firstNameTextField becomeFirstResponder];
           });
        }];
        return;
    }
    if(_lastNameTextField.text.length < 1){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Last Name must be valid" andMessage:@"Please enter a valid Last name" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_lastNameTextField becomeFirstResponder];
            });
        }];
        return;
    }
    
    if(_birthdateTextField.text.length < 1){
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Date of Birth must be valid" andMessage:@"Please enter a valid date of Birth" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [_lastNameTextField becomeFirstResponder];
            });
        }];
        return;
    }
    
    
    //Check for duplicate SSN
    if(_ssnTextField.text.length < 1){
        //[self showErrorModalViewWithTitle:@"Social Security number must be valid" text:@"Please enter a valid social security number" sourceRect:_ssnTextField.bounds sourceView:_ssnTextField];
        //return;
    }
    
    
    
    //Check if the patient is already registered with an other Id
    NSDateFormatter *dateformat=[[NSDateFormatter alloc]init];
    [dateformat setDateFormat:[NSString stringWithFormat:@"%s", DateFormat]];
    
    
    //NSArray<PatientProfileModelClass *> *result = [ldb getPatientProfileListFilterByFirstName:obj.FirstName lastname:obj.LastName ssn:obj.SSN birthDate:obj.BirthDate primaryContact:nil zipCode:nil gender:nil limit:nil];
    
    
    NSArray<PatientProfileModelClass *> *result = [ldb getPatientProfileByFirstName:obj.FirstName lastname:obj.LastName ssn:obj.SSN birthDate:obj.BirthDate patientId:nil];
    
    if(Update){
        if(result.count > 1){
            //ERROR !!!!
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Duplicate Patient Profile" andMessage:@"A Patient with similar specification already exist in database." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_firstNameTextField becomeFirstResponder];
                });
            }];
            return;
        }
        
        //Update and return
        [appMngr updatePatientProfileByPatientId:obj.PatientId PatientProfileObj:obj andCompletionHandler:^(BOOL success, NSString * _Nullable msgToUI) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success){
                    [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Updated" andMessage:@"Patient Profile update completed" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            _ViewMode = PageViewModeView;
                            
                            [self setUpPage];
                        });
                    }];
                }else{
                    [UITools ShowErrorOkAlertDialogWithUIViewController:self Title:@"Updating Patient Profile failed" andMessage:msgToUI];
                }
            });
        }];
        return;
        
    }else{
        if(result!=nil || result.count>0){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Duplicate Patient Profile" andMessage:@"A Patient with similar specification already exist in database. Please check current registered patient." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_lastNameTextField becomeFirstResponder];
                });
            }];
            return;
        }
    }
    
    //Check Patient Id Validity, If PatientIdEditable==True, then Get Patient Id by
    if(appMngr.AppConfiguration.PatientIdEditable.boolValue){
        
        //Check if Partient Id is set and value is in range
        if(obj.PatientId ==nil || obj.PatientId.intValue < MinimumPatientId){
            NSNumber *suggestedPatientId = [appMngr getNextPatientId];
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:[NSString stringWithFormat:@"PatientId '%d' is invalid", obj.PatientId.intValue]  andMessage:[NSString stringWithFormat:@"Patient Id is invalid and it must be greater than or equal %d. \nBased on configurations, Application recommeneds you to use Patient Id '%d'", MinimumPatientId, suggestedPatientId.intValue] WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_patientIdTextField becomeFirstResponder];
                });
            }];
        }
        
        //validate Patient Id Value
        NSNumber *validatedPatientId = [appMngr validateNewPatientId:obj.PatientId];
        
        if( [obj.PatientId compare:validatedPatientId]!= NSOrderedSame){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:[NSString stringWithFormat:@"PatientId '%d' already in use", obj.PatientId.intValue] andMessage:[NSString stringWithFormat:@"Patient Id '%d' belongs to another Patient Profile. Meanwhile, System recommends you to use PatientId '%d'.", obj.PatientId.intValue, validatedPatientId.intValue] WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _patientIdTextField.text = [NSString stringWithFormat:@"%d", validatedPatientId.intValue];
                    [_patientIdTextField becomeFirstResponder];
                });
            }];
            return;
        }
        
    }else{
        //find a valid Patient Id for user
        NSNumber* generatedPatientId = [appMngr getNextPatientId];
        if(generatedPatientId==nil){
            [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Failed" andMessage:@"Application failed to find a valid patient Id for this new Profile." WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_patientIdTextField becomeFirstResponder];
                });
            }];
            return;
        }
        
        obj.PatientId = generatedPatientId;
    }
    
    
    NSNumber *addedPatientId = [appMngr addPatientProfileByObj:obj];
    if(addedPatientId.intValue < 0){
        //Show error Screen
        [UITools ShowOkAlertDialogWithUIViewController:self Title:@"Unable to save this Patient" andMessage:[NSString stringWithFormat:@"Application was unable to add patient to database"]];
        return;
    }
    
    
    patientProfile.PatientId = addedPatientId;
    
    //Get patientProfile by SqlRowId now
    PatientProfileModelClass *p = [appMngr getPatientProfileByPatientId:addedPatientId];
    if(p != nil){
        appMngr.lastPatientId = p.PatientId;
        NSNumber *newId = [ldb checkPatientIdValidityAndReturnValidPatientIdByPatientId:p.PatientId SearchPatientIdStartOffset:appMngr.AppConfig.PatientIdCounter];
        //if(![ldb UpdateAppConfigurationForColumnName:@"PatientIdCounter" NumberValue:newId SqlId:appMngr.AppConfig.SqlId]){
            ALog("Unable to update System PatientId counter");
        //}else{
            appMngr.AppConfig.PatientIdCounter = newId;
        [appMngr.mscs saveAppConfig:appMngr.AppConfig CompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
            
        }];
        
        self.PatientId = p.PatientId;
        _ViewMode = PageViewModeView;
        
        
        
        //Update and return
        [UITools ShowOkCancelAlertDialogWithUIViewController:self Title:@"Updated" andMessage:@"Patient Profile update completed" WithOkButtonEnabled:YES OkButtonTitle:@"OK" WithCancelButtonEnabled:NO CancelButtonTitle:nil CompletionHandler:^(BOOL OKorCancel) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setUpPage];
            });
        }];
        return;
    }else{
        [UITools ShowOkAlertDialogWithUIViewController:self Title:@"Unable to Locate Patient" andMessage:[NSString stringWithFormat:@"Application was unable to find newly added patient automatically"]];
    }
}

- (IBAction)onMaleCheckBoxClicked:(id)sender {
    [_maleCheckBox setSelected:YES];
    if([_femaleCheckBox isSelected]){
        [_femaleCheckBox setSelected:NO];
    }
    //[self checkFieldsValidity];
}
- (IBAction)onFemaleCheckBoxClicked:(id)sender {
    [_femaleCheckBox setSelected:YES];
    if([_maleCheckBox isSelected]){
        [_maleCheckBox setSelected:NO];
    }
    //[self checkFieldsValidity];
}


@end
