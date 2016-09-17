//
//  OfficeRegistrationPDFPagesViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/5/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDFPlainView.h"

@interface PDFWithThemeRefPageViewViewController : UIViewController

@property (nonatomic, strong) id delegate;
@property (nonatomic) CGPDFPageRef  PdfPageRef;
@property (nonatomic) CGPDFPageRef  ThemePdfPageRef;

@property (nonatomic, assign) NSUInteger pageIndex;

@property (weak, nonatomic) IBOutlet PDFPlainView *PDFThemeView;
@property (weak, nonatomic) IBOutlet PDFPlainView *PDFView;
@property (weak, nonatomic) IBOutlet UIView *headerCoverView;

-(instancetype) initWithPDFPageRef:(CGPDFPageRef) pdfPageRef  ThemePageRef:(CGPDFPageRef)themePageRef;
-(void) flashHeaderCoverView;
@end
