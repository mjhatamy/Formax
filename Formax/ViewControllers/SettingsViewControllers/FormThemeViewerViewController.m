//
//  FormThemeViewerViewController.m
//  Formax
//
//  Created by Jid Hatami on 9/12/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "FormThemeViewerViewController.h"
#import "PDFWithThemeRefPageViewViewController.h"
#import "AppManager.h"
#import "WaitingAnimationViewController.h"

@interface FormThemeViewerViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIToolbarDelegate>
{
    CGPDFDocumentRef pdfDoc;
    CGPDFDocumentRef pdfThemeDoc;
    CGPDFDocumentRef pdfThemeDocPage2;
    NSInteger numPages;
    AppManager* appMngr;
    WaitingAnimationViewController* waitingAnimVC;
    NSTimer *toolbarShowHideTimer;
}

@end

@implementation FormThemeViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    NSString *pdfFilePath = [[NSBundle mainBundle] pathForResource:@"release_ca" ofType:@"pdf"];
    NSURL *PdfFileUrlOnDevice = [NSURL fileURLWithPath:pdfFilePath];
    pdfDoc = CGPDFDocumentCreateWithURL((CFURLRef) PdfFileUrlOnDevice );
    
    pdfThemeDoc = [appMngr getDefaultFormThemePDFDocumentForPageNum:1];
    pdfThemeDocPage2 = [appMngr getDefaultFormThemePDFDocumentForPageNum:2];
    if(pdfThemeDoc == nil || pdfThemeDocPage2 == nil){
        ALog("Error....");
    }
    
    
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
    
    UITapGestureRecognizer *pageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleShowHideToolbar)];
    pageTap.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:pageTap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.PageViewController.view.frame = _pdfPageInnerCoverView.frame;
    PDFWithThemeRefPageViewViewController *vc = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[vc];
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
    //for(i=0; i < numPages; i++)
        //[self performSelector:@selector(changePageToEnd) withObject:self afterDelay:i+2];
    //Bring to Frong and Show Modal View
    //[self performSegueWithIdentifier:@"gotoOfficeRegistrationNavigationViewControllerSegue" sender:self];
    
    //waitingAnimVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
    ALog("Done");
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
        if(index<=0){ vc.ThemePdfPageRef = (pdfThemeDoc!= nil) ? CGPDFDocumentGetPage(pdfThemeDoc, 1) : nil; }
        else{ vc.ThemePdfPageRef = (pdfThemeDocPage2!= nil) ? CGPDFDocumentGetPage(pdfThemeDocPage2, 1) : nil; }
        vc.pageIndex = index;
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

- (IBAction)onCloseToolbarBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void) toggleShowHideToolbar{
    if([_topToolbar isHidden]){
        [UIView transitionWithView:_topToolbar duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_topToolbar setHidden:NO];
        } completion:nil];
        
        toolbarShowHideTimer = [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(toggleShowHideToolbar) userInfo:nil repeats:NO];
    }else{
        if(toolbarShowHideTimer != nil) [toolbarShowHideTimer invalidate];
        [UIView transitionWithView:_topToolbar duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [_topToolbar setHidden:YES];
        } completion:nil];
    }
}

@end
