//
//  SignatureViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/12/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SignatureViewController.h"
#import "UITools.h"
#import "AppManager.h"

@interface SignatureViewController ()

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _signPadView.layer.cornerRadius = 5;
    _signPadBgImageView.layer.cornerRadius = 5;
    //_signPadView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_signpad"]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(_currentSignatureImage!=nil){
        [_signPadBgImageView setImage:_currentSignatureImage];
    }
    [self setupSignatureField];
}

- (void)setupSignatureField {
    //self.signatureViewInternal = [[PPSSignatureView alloc] initWithFrame:self.signPadInnerView.frame context:nil];
    
    self.signatureViewInternal.signatureDelegate = self;
    _signPadInnerView.signatureDelegate = self;
    self.signatureViewInternal.backgroundColor = self.signPadInnerView.backgroundColor;
}

- (IBAction)onPenBtnClicked:(id)sender {
    [_signPadInnerView drawUsingPen];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [UITools replaceTopConstraintOnView:self.footerView dstView:self.indexFingerBtn withConstant:30];
        [UITools replaceTopConstraintOnView:self.footerView dstView:self.penBtn withConstant:10];
        [self.view layoutIfNeeded];
    }];
    _indexFingerBtn.layer.shadowOpacity = 0;
    _indexFingerBtn.imageView.layer.shadowOpacity = 0;
    _penBtn.imageView.layer.shadowOpacity = 0.5;
    _penBtn.layer.shadowOpacity = 1.0;
    
    ALog("Inner Pad Size w:%f h:%f", _signPadView.frame.size.width, _signPadView.frame.size.height);
}

- (IBAction)onIndexFingerBtnClicked:(id)sender {
    [_signPadInnerView drawUsingFinger];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        [UITools replaceTopConstraintOnView:self.footerView dstView:self.indexFingerBtn withConstant:10];
        [UITools replaceTopConstraintOnView:self.footerView dstView:self.penBtn withConstant:30];
        [self.view layoutIfNeeded];
        
    }];
    
    _indexFingerBtn.layer.shadowOpacity = 1;
    _indexFingerBtn.imageView.layer.shadowOpacity = 0.5;
    _penBtn.imageView.layer.shadowOpacity = 0;
    _penBtn.layer.shadowOpacity = 0;
}

- (IBAction)onDrawBlackBtnClicked:(id)sender {
    _drawBlueBtn.layer.shadowOpacity = 0;
    _drawBlackBtn.layer.shadowOpacity = 1;
    [_signPadInnerView setStrokeColor:[UIColor blackColor]];
    
}
- (IBAction)onDrawBlueBtnClicked:(id)sender {
    _drawBlueBtn.layer.shadowOpacity = 1;
    _drawBlackBtn.layer.shadowOpacity = 0;
    
    [_signPadInnerView setStrokeColor:[UIColor blueColor]];
}

-(UIImage *)signature {
    return [self.signPadInnerView signatureImage];
}

- (IBAction)onClearBtnClicked:(id)sender {
    _signPadBgImageView.image = nil;
    [_signPadInnerView erase];
}

- (void)signatureAvailable:(BOOL)signatureAvailable {
    if (signatureAvailable) {
        _signPadBgImageView.image = nil;
        //[self enableContinueAndClearButtons];
        _saveToolbarBtn.enabled = YES;
        _clearBtn.enabled = YES;
    } else {
        //[self disableContinueAndClearButtonsAnimated: YES];
        _saveToolbarBtn.enabled = NO;
        _clearBtn.enabled = NO;
    }
}


- (IBAction)onDoneBtnClicked:(id)sender {
    //[_signatureFooterTextLabel setHidden:YES];
    //AppManager *appMngr = [AppManager SharedInstance];
    //_coordinationLabel.text = [NSString stringWithFormat:@"Signed at Longitude:%+0.6f  Latitude:%+0.6f   Aprx:5m", appMngr.currentLocation.longitude, appMngr.currentLocation.latitude];
    
    //self.handleContinueBlock([self signature]);
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _signPadInnerView.frame.size.width, _signPadInnerView.frame.size.height)];
    //ALog("Image w:%f h:%f", imageview.frame.size.width, imageview.frame.size.height);
    //ALog("Inner Pad Size w:%f h:%f", _signPadView.frame.size.width, _signPadView.frame.size.height);
    [imageview setImage:[self signature]];
    [_signPadInnerView addSubview:imageview];
    UIImage *finalImage = [UITools imageWithView: _signPadInnerView];
    [imageview removeFromSuperview];
    
    
    if([self.delegate conformsToProtocol:@protocol(SignatureViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(onSignatureViewControllerDoneDelegate:)]) {
        [self.delegate onSignatureViewControllerDoneDelegate: finalImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onCancelBtnClicked:(id)sender {
    //self.handleCancelBlock();
    
    if([self.delegate conformsToProtocol:@protocol(SignatureViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(onSignatureViewControllerCanceledDelegate)]) {
        [self.delegate onSignatureViewControllerCanceledDelegate];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
