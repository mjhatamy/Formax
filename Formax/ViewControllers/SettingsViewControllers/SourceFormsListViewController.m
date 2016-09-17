//
//  SourceFormsViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SourceFormsListViewController.h"
#import "AppManager.h"
#import "SourceFormListTableViewCell.h"
#import "FormCategoriesTableViewCell.h"
#import "CategoriesModelClass.h"
#import "SourceFormsModelClass.h"
#import "GixPDFViewController.h"


@interface SourceFormsListViewController ()<MOStoreButtonDelegate,MGSwipeTableCellDelegate, UIToolbarDelegate>
{
    AppManager* appMngr;
    NSArray<CategoriesModelClass *> * categoriesList;
    NSMutableArray<SourceFormsModelClass *>* sourceFormsList;
    float currentProgress;
    
    NSNumber *CategoryId;
    
    SelectAProviderForSignViewController* selectAProviderVC;
    
    NSNumber *PDFProviderId;
    SourceFormsModelClass* PDFSourceForm;
}

@end

@implementation SourceFormsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appMngr = [AppManager SharedInstance];
    CategoryId = nil;
    
    _categoriesTableCoverInnterView.layer.borderWidth = 0.5;
    _categoriesTableCoverInnterView.layer.borderColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f].CGColor;
    
    
    _sourceFormsListTableView.layer.cornerRadius = 5;
    
    if(sourceFormsList == nil)  sourceFormsList = [[NSMutableArray alloc] init];
    
    [appMngr getFormCategoriesWithCompletionHandler:^(NSArray<CategoriesModelClass *> * _Nullable arr, BOOL succeeded, NSError * _Nullable error) {
        if(arr!=nil && arr.count > 0){
            categoriesList = arr;
            dispatch_async(dispatch_get_main_queue(), ^{
                [_formCategoriesListTableView reloadData];
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                [_formCategoriesListTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                
                [self ReloadFormsList];
            });
        }else{
            ALog("No categories found");
        }
    }];
    PDFProviderId = nil;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}


-(void)ReloadFormsList
{
    [appMngr getSourceFormsFilterByCategoryId:CategoryId WithCompletionHandler:^(NSArray<SourceFormsModelClass *> * _Nullable arr, BOOL succeeded, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if(sourceFormsList == nil)  sourceFormsList = [[NSMutableArray alloc] init];
            [sourceFormsList removeAllObjects];
            [sourceFormsList addObjectsFromArray:arr];
            [_sourceFormsListTableView reloadData];
        });
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(BOOL)prefersStatusBarHidden{
    return NO; //Will cover Status bar
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if([tableView isEqual:_formCategoriesListTableView]){
        return categoriesList.count;
    }else if([tableView isEqual:_sourceFormsListTableView]){
        return sourceFormsList.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:_formCategoriesListTableView]){
        static NSString *cellIdentifier = @"FormCategoriesTableViewCell";
        FormCategoriesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        CategoriesModelClass *obj = [categoriesList objectAtIndex:indexPath.row];
        
        cell.CategoryId = obj.CategoryId;
        [cell.nameLabel setText:obj.Name];
        
        if(cell.highlighSelectView==nil) cell.highlighSelectView = [[UIView alloc] init];
        cell.highlighSelectView.backgroundColor = [UIColor blueColor];
        cell.selectedBackgroundView =  cell.highlighSelectView;
        
        return cell;
    }else if([tableView isEqual:_sourceFormsListTableView]){
        static NSString *cellIdentifier = @"SourceFormListTableViewCell";
        SourceFormListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        SourceFormsModelClass* obj = [sourceFormsList objectAtIndex:indexPath.row];
        
        cell.CategoryId = obj.CategoryId;
        cell.FormId = obj.FormId;
        [cell.nameLabel setText:obj.Name];
        [cell.descTextView setText:obj.Desc];
        //[cell.nameLabel setText:obj.Name];
        [cell.favBtn setSelected:obj.IsFavorite.boolValue];
        [cell.isFavBtnStackView setHidden:!obj.IsFavorite.boolValue];
        
        MGSwipeButton *swipeLeftTagBtn = [MGSwipeButton buttonWithTitle:
                                          obj.IsFavorite.boolValue? NSLocalizedString(@"Unset as Favorite", @"UnSet_Favorite") :  NSLocalizedString(@"Set as Favorite", @"Set_Favorite") icon:[UIImage imageNamed:@"tagIcon"] backgroundColor:[UITools colorFromHexString:@"#FF3B30"]];
        
        cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
        cell.delegate = self;
        
        if(cell.highlighSelectView==nil) cell.highlighSelectView = [[UIView alloc] init];
        cell.highlighSelectView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0.2f];
        cell.selectedBackgroundView =  cell.highlighSelectView;
        
        
        if(obj.IsBundled.boolValue || (![UITools isNSStringNull:obj.TransactionId])){
            [cell.signtBtn setHidden:NO];
            [cell.storeBtnCoverView setAlpha:0.0f];
            cell.leftButtons = @[swipeLeftTagBtn];
            
            if(cell.storeBtn != nil) [cell.storeBtn removeFromSuperview];
            
        }else{
            MGSwipeButton *swipeLeftPreviewBtn = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Preview", @"Preview_Action") icon:[UIImage imageNamed:@"tagIcon"] backgroundColor:[UITools colorFromHexString:@"#FF9500"]];
            cell.leftButtons = @[swipeLeftTagBtn, swipeLeftPreviewBtn];
            
            cell.backgroundColor = [UIColor colorWithRed:0.9f green:0 blue:0 alpha:.15f];
            
            [cell.storeBtnCoverView setAlpha:1.0f];

            if(cell.storeBtn == nil){
                cell.storeBtn = [[MOStoreButton alloc] initWithFrame:CGRectMake( 0, 0, cell.storeBtnCoverView.frame.size.width, cell.storeBtnCoverView.frame.size.height) andColor:[UITools colorFromHexString:@"#0080FC"]];
                //cell.storeBtn = [[MOStoreButton alloc] initWithFrame:cell.storeBtnCoverView.frame andColor:[UITools colorFromHexString:@"#0080FC"]];
                cell.storeBtn.buttonDelegate = self;
                UIFont *f = [UIFont fontWithName:@"SFUIText-Medium" size:14.0f];
                if(f==nil){ ALog("Font is nil"); }
                cell.storeBtn.titleLabel.font = f;
                cell.storeBtn.finishedDownloadingButtonTitle = @"View";
                if(obj.Price.intValue>0){
                    [cell.storeBtn setTitles:@[ [NSString stringWithFormat:@"$%0.2f", obj.Price.floatValue], @"BUY" ]];
                }else{
                    [cell.storeBtn setTitles:@[ @"FREE", @"INSTALL" ]];
                }
                
                [cell.storeBtnCoverView addSubview:cell.storeBtn];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                ALog("Redraw should be called");
                [cell.storeBtnCoverView setNeedsDisplay];
                [cell.storeBtn setNeedsDisplayInRect:cell.storeBtnCoverView.frame];
                [cell.storeBtn setNeedsDisplay];
                [cell setNeedsDisplay];
            });
            [cell.storeBtn setNeedsLayout];
            
            if(cell.storeBtn == nil){
                ALog("Store button nil");
            }
            //[cell.storeBtnCoverView setNeedsDisplay];
            //[cell.storeBtnCoverView setNeedsLayout];
            
        }
        return cell;
    }
    return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if([tableView isEqual:_formCategoriesListTableView]){
        
        FormCategoriesTableViewCell * cell  = (FormCategoriesTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        if(cell.CategoryId.intValue <=0) CategoryId = nil;
        else CategoryId = cell.CategoryId;
        
        [self ReloadFormsList];
    }else if([tableView isEqual:_sourceFormsListTableView]){
        //SourceFormListTableViewCell * cell  = (SourceFormListTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
        SourceFormsModelClass *p = [sourceFormsList objectAtIndex:indexPath.row];
        
        if(p.IsBundled.boolValue || ![UITools isNSStringNull:p.TransactionId]){
            [self onSignBtnPressedForSourceForm:p];
        }
        
    }
}


-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    SourceFormListTableViewCell *pcell = (SourceFormListTableViewCell *)cell;
    //0==Set Tag Action
    if(index==0){ //Open TagViewer for PatientId
        
        NSIndexPath* indexPath = [_sourceFormsListTableView indexPathForCell:pcell];
        [sourceFormsList objectAtIndex:indexPath.row].IsFavorite = [NSNumber numberWithBool:![sourceFormsList objectAtIndex:indexPath.row].IsFavorite.boolValue];
        SourceFormsModelClass *p = [sourceFormsList objectAtIndex:indexPath.row];
        
        ALog("Set tag %d   %d", [sourceFormsList objectAtIndex:indexPath.row].IsFavorite.intValue, p.IsFavorite.intValue);
        
        [appMngr setSourceFormIsFavorite:p.IsFavorite FormId:p.FormId];
        
        [_sourceFormsListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }if(index==1){
        ALog("Preview Clicked");
        NSIndexPath* indexPath = [_sourceFormsListTableView indexPathForCell:pcell];
        [sourceFormsList objectAtIndex:indexPath.row].IsFavorite = [NSNumber numberWithBool:![sourceFormsList objectAtIndex:indexPath.row].IsFavorite.boolValue];
        SourceFormsModelClass *p = [sourceFormsList objectAtIndex:indexPath.row];
        
        [self onSignBtnPressedForSourceForm:p];
    }
    
    return YES;
}


-(void)updateProgress:(MOStoreButton*)sender{
    if (currentProgress>=1) {
        CGPoint buttonOriginInTableView = [((MOStoreButton *) sender) convertPoint:CGPointZero toView:_sourceFormsListTableView];
        NSIndexPath *indexPath = [_sourceFormsListTableView indexPathForRowAtPoint:buttonOriginInTableView];
        [_sourceFormsListTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    
    currentProgress+=0.04f;
    //    NSLog(@"current progress is %f",currentProgress);
    [sender setProgress:currentProgress animated:YES];
    [self performSelector:@selector(updateProgress:) withObject:sender afterDelay:.04];
}

-(void)startDownloading:(MOStoreButton*)button{
    //    [storeButton performSelector:@selector(startDownloading) withObject:nil afterDelay:2];
    currentProgress=0;
    [self performSelector:@selector(updateProgress:) withObject:button afterDelay:2];
    
}
-(void)storeButtonFired:(MOStoreButton *)button{
    
    NSLog(@"click  %i",button.currentIndex);
    if (button.currentIndex ==-1){
        // Clicked after downloading the ' open' button
        NSLog(@"button Finish state clicked ");
        
    }
    else if (button.currentIndex ==0){
        NSLog(@"buttonClickedFirstTime");
        // to cancel downloading selector if exists
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        [NSObject cancelPreviousPerformRequestsWithTarget:button];
        currentProgress =0;
    }else if (button.currentIndex==1){

        NSLog(@"buttonClickedSecondTime");
        // to mimic download operation
        [self onBuyButtonPressed:button];
        
        //[self performSelector:@selector(startDownloading:) withObject:button afterDelay:2];
    }
}

-(void) onPreViewBtnPressedForSourceForm:(SourceFormsModelClass *)obj {
    
}


-(void)onBuyButtonPressed:(id)sender{
    CGPoint buttonOriginInTableView;
    if([sender isKindOfClass:[MOStoreButton class]]){
        buttonOriginInTableView = [((MOStoreButton *) sender) convertPoint:CGPointZero toView:_sourceFormsListTableView];
    }else if([sender isKindOfClass:[UIGestureRecognizer class]]){
        buttonOriginInTableView = [((UIGestureRecognizer *)sender) locationOfTouch:0 inView:_sourceFormsListTableView];
    }
    
    NSIndexPath *indexPath = [_sourceFormsListTableView indexPathForRowAtPoint:buttonOriginInTableView];
    SourceFormsModelClass *sfm = [sourceFormsList objectAtIndex:indexPath.row];
    
    ALog("%@", sfm.Name);
    [self onInstallFormForSourceFormObj:sfm];
    [self performSelector:@selector(startDownloading:) withObject:sender afterDelay:2];
}


-(void) onInstallFormForSourceFormObj:(SourceFormsModelClass *)obj{
    obj.IsInstalled = [NSNumber numberWithBool: YES];
    obj.TransactionId = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    obj.ModificationDate = [NSNumber numberWithDouble: [NSDate date].timeIntervalSince1970];
    obj.Username = [appMngr.mscs getCurrentUser].username;
    
    [appMngr updateSourceFormBySourceFormObj:obj];
    
    int i=0;
    for (SourceFormsModelClass *p in sourceFormsList) {
        
        if([p.FormId compare:obj.FormId]==NSOrderedSame){
            [sourceFormsList replaceObjectAtIndex:i withObject:obj];
            break;
        }
        i++;
    }
}



-(void) onSignBtnPressedForSourceForm:(SourceFormsModelClass *)obj{
    //if AppManager in Preview Mode , then Preview
    
    
    
    //If App Manager in SignForm
    
    //Select a Provider
    //[self performSegueWithIdentifier:@"gotoSelectAProviderForSignViewControllerSegue" sender:self];
    //OpenSignature View
    //[self performSegueWithIdentifier:@"gotoGixPDFViewControllerSegue" sender:self];
    PDFSourceForm = obj;
    
    if(selectAProviderVC == nil) selectAProviderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectAProviderForSignViewController"];
    selectAProviderVC.delegate = self;
    selectAProviderVC.modalPresentationStyle = UIModalPresentationPageSheet;
    selectAProviderVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:selectAProviderVC animated:YES completion:nil];
    
}

-(void)onSelectAProviderForSignViewControllerClosedDelegate{
    PDFProviderId = nil;
    [self openPDFViewer];
}

-(void)onSelectAProviderForSignViewControllerSelectedProvider:(NSNumber *)ProviderId{
    ALog("Provider ID:%d", ProviderId.intValue);
    PDFProviderId = ProviderId;
    [self openPDFViewer];
}


-(void)openPDFViewer{
    //Example
    _PatientId = [NSNumber numberWithInt:1001];
    
    //Refresh Registration Profile
    [appMngr RegistrationProfile];
    //Get all Forms
    [appMngr getAllThemesByForcedRefresh:NO CompletionHanlder:^(NSArray<FormThemeModelClass *> * _Nullable arr, BOOL Updated, BOOL Succeeded, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        [appMngr makeThemeFileForThemeId:appMngr.AppConfig.DefaultThemeId RegistrationProfile:appMngr.registrationProfile CompletionHandler:^(BOOL Succeeded, NSURL * _Nullable ThemeFileUrlForWebView, NSString * _Nullable MsgToUI) {
            ALog("MSG:%@", MsgToUI);
            if(Succeeded){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"gotoGixPDFViewControllerSegue" sender:self];
                });
            }
        }];
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"gotoGixPDFViewControllerSegue"]){
        GixPDFViewController* vc = [segue destinationViewController];
        
        NSString *FilePath;
        if(PDFSourceForm.FilePath == nil || PDFSourceForm.FilePath.length <=0){
            FilePath = [[NSBundle mainBundle] pathForResource:PDFSourceForm.FileName.stringByDeletingPathExtension ofType:PDFSourceForm.FileName.pathExtension];
        }
        
        [vc initializeSignPDFForPatientId:_PatientId FormId:PDFSourceForm.FormId CategoryId:PDFSourceForm.CategoryId SrcPDFFilePath:FilePath ProviderId:PDFProviderId];
    }
}

- (IBAction)onCloseToolbarBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
