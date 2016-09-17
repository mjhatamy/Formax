//
//  OfficeRegistrationPDFPagesViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/5/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "PDFWithThemeRefPageViewViewController.h"

@interface PDFWithThemeRefPageViewViewController ()

@end

@implementation PDFWithThemeRefPageViewViewController

-(instancetype) initWithPDFPageRef:(CGPDFPageRef) pdfPageRef  ThemePageRef:(CGPDFPageRef)themePageRef{
    self = [super init];
    if(self){
        _PdfPageRef = pdfPageRef;
        _ThemePdfPageRef = themePageRef;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    if(_PdfPageRef != nil) [_PDFView setPage:_PdfPageRef forFrame:_PDFView.frame];
    else NSLog(@"---- nil");
    
    if(_ThemePdfPageRef != nil) [_PDFThemeView setPage:_ThemePdfPageRef forFrame:_PDFThemeView.frame];
    else NSLog(@"---- nil");
    
    _headerCoverView.layer.cornerRadius = 10;
    _headerCoverView.layer.borderColor = [UIColor grayColor].CGColor;
    _headerCoverView.layer.borderWidth = 2;
    _headerCoverView.layer.shadowOffset = CGSizeZero;
    _headerCoverView.layer.shadowColor = [UIColor blackColor].CGColor;
    _headerCoverView.layer.shadowOpacity = 1.0f;
    _headerCoverView.layer.shadowRadius = 5;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //int i=0;
    //for(i=0; i < 4; i++)
    //[self performSelector:@selector(flashHeaderCoverView) withObject:self afterDelay:1.0 + (i)];
}

-(void) flashHeaderCoverView{
    [UIView animateWithDuration:0.5 animations:^{
        [_headerCoverView setAlpha:1.0f];
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [_headerCoverView setAlpha:0.0f];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }];
    
    
}

@end
