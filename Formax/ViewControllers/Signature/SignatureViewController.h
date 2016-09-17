//
//  SignatureViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/12/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPSSignatureView.h"

@protocol SignatureViewControllerDelegate <NSObject>

-(void) onSignatureViewControllerCanceledDelegate;
-(void) onSignatureViewControllerDoneDelegate:(UIImage *)image;

@end

typedef void (^SignatureViewControllerContinue)(UIImage *signatureImage);
typedef void (^SignatureViewControllerCancel)();



@interface SignatureViewController : UIViewController<PPSSignatureViewDelegate>

@property (nonatomic, assign) id delegate;

@property (nonatomic, strong) PPSSignatureView *signatureViewInternal;
@property (weak, nonatomic) IBOutlet UIView *signPadView;
@property (weak, nonatomic) IBOutlet PPSSignatureView *signPadInnerView;
@property (weak, nonatomic) IBOutlet UIImageView *signPadBgImageView;
@property (weak, nonatomic) IBOutlet UIImage* currentSignatureImage;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UIButton *penBtn;
@property (weak, nonatomic) IBOutlet UIButton *indexFingerBtn;
@property (weak, nonatomic) IBOutlet UIButton *drawBlueBtn;
@property (weak, nonatomic) IBOutlet UIButton *drawBlackBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveToolbarBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelToolbarBtn;

@property (weak, nonatomic) IBOutlet UILabel *signatureDotLineLabel;
@end
