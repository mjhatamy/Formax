//
//  OfficeRegistrationViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/5/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "OfficeRegistrationViewController.h"
#import "PDFWithThemeRefPageViewViewController.h"
#import "AppManager.h"
#import "PDFWithThemeRefPageViewViewController.h"
#import "FormThemesListViewController.h"

@interface OfficeRegistrationViewController (){
    CGPDFDocumentRef pdfDoc;
    CGPDFDocumentRef pdfThemeDoc;
    CGPDFDocumentRef pdfThemeDocPage2;
    NSInteger numPages;
    AppManager* appMngr;
    FormThemesListViewController* formsThemesListVC;
}

@end

@implementation OfficeRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    NSString *pdfFilePath = [[NSBundle mainBundle] pathForResource:@"InformedConsentDiscussionForImplantPlacement" ofType:@"pdf"];
    NSURL *PdfFileUrlOnDevice = [NSURL fileURLWithPath:pdfFilePath];
    pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef) PdfFileUrlOnDevice );
    
    pdfThemeDoc = [appMngr getDefaultFormThemePDFDocumentForPageNum:1];
    pdfThemeDocPage2 = [appMngr getDefaultFormThemePDFDocumentForPageNum:2];
    if(pdfThemeDoc == nil){
        ALog("PDF Theme Doc not found");
    }
    
    numPages = 0;
    if(pdfDoc != nil){
        numPages = CGPDFDocumentGetNumberOfPages(pdfDoc);
    }
    
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"OfficeRegistrationPDFViewPageViewController"];
    self.PageViewController.dataSource = self;
    self.PageViewController.delegate = self;
    
    _pdfPageInnerCoverView.layer.cornerRadius = 6;
    [self.parentViewController.view setAlpha:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIStatusBarStyle)preferredStatusBarStyle{
    return YES;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.PageViewController.view.frame = _pdfPageInnerCoverView.frame;
    
    NSArray *viewControllers;
    if(self.PageViewController.spineLocation==UIPageViewControllerSpineLocationMid){
        PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:0];
        PDFWithThemeRefPageViewViewController *vc1 = [self viewControllerAtIndex:1];
        viewControllers = @[vc, vc1];
    }else{
        PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:0];
        viewControllers = @[vc];
    }
    
    [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    // Change the size of page view controller
    self.PageViewController.view.frame = CGRectMake(0, 0, _pdfPageInnerCoverView.frame.size.width, _pdfPageInnerCoverView.frame.size.height);
    [self addChildViewController:_PageViewController];
    [_pdfPageInnerCoverView addSubview:_PageViewController.view];
    [self.PageViewController didMoveToParentViewController:self];
    //[self performSegueWithIdentifier:@"showRegisterationInputViewControllerSegue" sender:self];
    
    [UIView animateWithDuration:1 animations:^{
        [self.parentViewController.view setAlpha:1.0f];
    }];
    
    //int i;
    //for(i=0; i < numPages; i++) [self performSelector:@selector(changePageToEnd) withObject:self afterDelay:i+2];
    //Bring to Frong and Show Modal View
    //[self performSegueWithIdentifier:@"gotoOfficeRegistrationNavigationViewControllerSegue" sender:self];
}

-(void) changePageToEnd{
    [self scrollToNext];
}

- (void)scrollToNext
{
    PDFWithThemeRefPageViewViewController *current = self.PageViewController.viewControllers[0];
    NSInteger currentIndex = current.pageIndex;
    UIViewController *nextController  = [self viewControllerAtIndex:currentIndex+1];
    if (nextController) {
        NSArray *viewControllers = @[nextController];
        [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:^(BOOL finished) {
        }];
    }else{
        int i;
        for(i=0; i < numPages; i++)
            [self performSelector:@selector(scrollToPrevious) withObject:self afterDelay:(i/2.0f)];
    }
}

- (void)scrollToPrevious
{
    PDFWithThemeRefPageViewViewController *current = self.PageViewController.viewControllers[0];
    NSInteger currentIndex = current.pageIndex;
    UIViewController *nextController  = [self viewControllerAtIndex:currentIndex-1];
    if (nextController) {
        NSArray *viewControllers = @[nextController];
        [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:^(BOOL finished) {
        }];
    }else{
        //Start Registration from here
        [self performSelector:@selector(gotoOfficeRegistrationNavigationViewController) withObject:self afterDelay:3.0f];
    }
}


-(void) gotoOfficeRegistrationNavigationViewController{
    [self performSegueWithIdentifier:@"gotoOfficeRegistrationNavigationViewControllerSegue" sender:self];
}

- (PDFWithThemeRefPageViewViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if(index < numPages){
        //CGPDFDocumentGetPage( pdfDoc, index+1);
        PDFWithThemeRefPageViewViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"PDFWithThemeRefPageViewViewController"];
        
        vc.PdfPageRef = (pdfDoc != nil) ? CGPDFDocumentGetPage( pdfDoc, index+1) : nil;
        
        if(index<=0){
            vc.ThemePdfPageRef = (pdfThemeDoc!= nil) ? CGPDFDocumentGetPage(pdfThemeDoc, 1) : nil;
        }
        else{
            vc.ThemePdfPageRef = (pdfThemeDocPage2!= nil) ? CGPDFDocumentGetPage(pdfThemeDocPage2, 1) : nil;
        }
        
        vc.pageIndex = index;
        
        //[[OfficeRegistrationPDFPagesViewController alloc] initWithPDFPageRef:CGPDFDocumentGetPage( pdfDoc, index+1) ThemePageRef:nil];
        //SignInViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInViewController"];
        //vc.pageIndex = index;
        return vc;
    }
    
    return nil;
}

-(NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController{
    return numPages;
}

-(NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController{
    return 0;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSUInteger index = ((PDFWithThemeRefPageViewViewController*) viewController).pageIndex;
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSUInteger index = ((PDFWithThemeRefPageViewViewController*) viewController).pageIndex;
    if (index == NSNotFound)
    {
        return nil;
    }
    index++;
    if(index > numPages) return nil;
    
    
    return [self viewControllerAtIndex:index];
}

- (IBAction)onOpenThemesListBtnPressed:(id)sender {
    formsThemesListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FormThemesListViewController"];
    [self presentViewController:formsThemesListVC animated:YES completion:^{
        
    }];
}

-(void)UpdateTheme{
    ALog("Theme update");
    [appMngr makeThemeFileForThemeId:appMngr.AppConfig.DefaultThemeId RegistrationProfile:appMngr.registrationProfileForRegistrationProcess CompletionHandler:^(BOOL Succeeded, NSURL * _Nullable ThemeFileUrlForWebView, NSString * _Nullable MsgToUI) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //Refresh
            pdfThemeDoc = [appMngr getDefaultFormThemePDFDocumentForPageNum:1];
            pdfThemeDocPage2 = [appMngr getDefaultFormThemePDFDocumentForPageNum:2];
            
            PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:0];
            NSArray *viewControllers = @[vc];
            [self.PageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        });
        
    }];
}


-(UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation{
    if(orientation == UIInterfaceOrientationLandscapeRight || orientation == UIInterfaceOrientationLandscapeLeft){
        PDFWithThemeRefPageViewViewController* first = self.PageViewController.viewControllers.firstObject;
        
        
        PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:first.pageIndex];
        PDFWithThemeRefPageViewViewController *vc1 = [self viewControllerAtIndex:first.pageIndex+1];
        [self.PageViewController setViewControllers:@[vc, vc1] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        
        return UIPageViewControllerSpineLocationMid;
    }else{
        PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:0];
    [self.PageViewController setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        return UIPageViewControllerSpineLocationMin;
    }
}

@end
