//
//  FormThemesListViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/6/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "FormThemesListViewController.h"
#import "AppManager.h"

#import "FormThemeModelClass.h"
#import "FormThemeListTableViewCell.h"
#import "WaitingAnimationViewController.h"

@interface FormThemesListViewController ()<MOStoreButtonDelegate, UIToolbarDelegate, MGSwipeTableCellDelegate>
{
    AppManager* appMngr;
    NSMutableArray<FormThemeModelClass *>* formThemesList;
    float currentProgress;
    WaitingAnimationViewController* waitingAnimVC;
}

@end

@implementation FormThemesListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    appMngr = [AppManager SharedInstance];
    [self Refresh];
}

-(void) Refresh{
    [appMngr getAllThemesByForcedRefresh:NO CompletionHanlder:^(NSArray<FormThemeModelClass *> * _Nullable arr, BOOL Updated, BOOL Succeeded, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(formThemesList == nil) formThemesList = [[NSMutableArray alloc] init];
            else [formThemesList removeAllObjects];
            [formThemesList addObjectsFromArray:arr];
            [_themesTableView reloadData];
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



- (IBAction)onCloseBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(formThemesList == nil){
        return 0;
    }else{
        return formThemesList.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"FormThemeListTableViewCell";
    FormThemeListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    FormThemeModelClass *obj = [formThemesList objectAtIndex:indexPath.row];
    cell.ThemeId = obj.ThemeId;
    [cell.themeNameLabel setText:obj.Name];
    [cell.themeDescTextView setText: obj.Desc];
    
    if(obj.IsFavorite.boolValue){
        [cell.favBtnStackView setHidden:NO];
        [cell.favBtn setSelected:YES];
    }else{
        [cell.favBtn setSelected:NO];
        [cell.favBtnStackView setHidden:YES];
    }
    
    cell.previewBtn.layer.cornerRadius = 5;
    cell.previewBtn.layer.borderColor = [UITools colorFromHexString:@"#0080FC"].CGColor;
    cell.previewBtn.layer.borderWidth = 1.0f;
    cell.previewBtn.titleLabel.font = [UIFont fontWithName:@"SFUIText-Medium" size:14.0f];
    
    if(obj.IsInstalled.boolValue ||  ![UITools isNSStringNull:obj.TransactionId]){
        [cell.buyOrInstallBtnCoverView setHidden:YES];
        cell.setDefaultBtn.layer.cornerRadius = 8;
        cell.setDefaultBtn.layer.borderColor = [UITools colorFromHexString:@"#0080FC"].CGColor;
        cell.setDefaultBtn.layer.borderWidth = 0.5;
        if([obj.ThemeId compare:appMngr.AppConfig.DefaultThemeId]==NSOrderedSame){
            cell.setDefaultBtn.backgroundColor = [UITools colorFromHexString:@"#007AFF"];
            cell.setDefaultBtn.layer.borderWidth = 0.0;
            [cell.setDefaultBtn setEnabled:NO];
            //[cell.setDefaultBtn setTitle:NSLocalizedString(@"Default", @"Default") forState:UIControlStateNormal];
        }
    }else{
        [cell.setDefaultBtn setHidden:YES];
        //[cell.previewBtn setHidden:YES];
        [cell.buyOrInstallBtnCoverView setHidden:NO];
        
        if(cell.storeBtn == nil){
            cell.storeBtn = [[MOStoreButton alloc] initWithFrame:CGRectMake( 0, 0, cell.buyOrInstallBtnCoverView.frame.size.width, cell.buyOrInstallBtnCoverView.frame.size.height) andColor:[UITools colorFromHexString:@"#0080FC"]];
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
            
            [cell.buyOrInstallBtnCoverView addSubview:cell.storeBtn];
        }
    }
    
    MGSwipeButton *swipeLeftFavBtn = [MGSwipeButton buttonWithTitle:
                                      obj.IsFavorite.boolValue? NSLocalizedString(@"Unset as Favorite", @"UnSet_Favorite") :  NSLocalizedString(@"Set as Favorite", @"Set_Favorite") icon:[UIImage imageNamed:@"tagIcon"] backgroundColor:[UITools colorFromHexString:@"#FF3B30"]];
    
    MGSwipeButton *swipeRightSetAsDefaultBtn = [MGSwipeButton buttonWithTitle: NSLocalizedString(@"Set as Default", @"Set_Default") icon:[UIImage imageNamed:@"tagIcon"] backgroundColor:[UITools colorFromHexString:@"#FF9500"]];
    
    cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
    cell.delegate = self;
    cell.leftButtons = @[swipeLeftFavBtn];
    
    if(obj.IsInstalled.boolValue || ![UITools isNSStringNull:obj.TransactionId]){
        cell.rightButtons = @[swipeRightSetAsDefaultBtn];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    waitingAnimVC = [WaitingAnimationViewController InitializeWithParentViewController:self];
    
    FormThemeModelClass *obj =  [formThemesList objectAtIndex:indexPath.row];
    
    [appMngr makeThemeFileForThemeId:obj.ThemeId RegistrationProfile:[appMngr RegistrationProfile] CompletionHandler:^(BOOL Succeeded, NSURL * _Nullable ThemeFileUrlForWebView, NSString * _Nullable MsgToUI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"showThemeViewerViewControllerSegue" sender:self];
            [waitingAnimVC dismiss];
        });
        
    }];
}



-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    FormThemeListTableViewCell *pcell = (FormThemeListTableViewCell *)cell;
    if(direction==MGSwipeDirectionLeftToRight){
        if(index==0){
            NSIndexPath *indexPath = [_themesTableView indexPathForCell:pcell];
            FormThemeModelClass *obj = [formThemesList objectAtIndex:indexPath.row];
            obj.IsFavorite = [NSNumber numberWithBool:!obj.IsFavorite.boolValue];
            obj.ModificationDate = [NSNumber numberWithDouble:[NSDate date].timeIntervalSince1970];
            [formThemesList replaceObjectAtIndex:indexPath.row withObject:obj];
            
            [appMngr setFormThemeFavoriteForFormThemeModelClass:obj];
            
            [_themesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
        }
    }else if(direction == MGSwipeDirectionRightToLeft){
        if(index==0){
            NSIndexPath *indexPath = [_themesTableView indexPathForCell:pcell];
            FormThemeModelClass *obj = [formThemesList objectAtIndex:indexPath.row];
            [appMngr AppConfiguration];
            appMngr.AppConfig.DefaultThemeId = obj.ThemeId;
            [appMngr.mscs saveAppConfig:appMngr.AppConfig CompletionHandler:^(BOOL Success, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_themesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                });
            }];
        }
    }
    
    return YES;
}

-(void) onFavBtnPressed:(UIButton *)sender{
    CGPoint buttonOriginInTableView;
    if([sender isKindOfClass:[UIButton class]]){
        buttonOriginInTableView = [((UIButton *) sender) convertPoint:CGPointZero toView:_themesTableView];
    }else if([sender isKindOfClass:[UIGestureRecognizer class]]){
        buttonOriginInTableView = [((UIGestureRecognizer *)sender) locationOfTouch:0 inView:_themesTableView];
    }
    
    //= [sender convertPoint:CGPointZero toView:_providersListTableView];
    NSIndexPath *indexPath = [_themesTableView indexPathForRowAtPoint:buttonOriginInTableView];
    FormThemeModelClass *p = [formThemesList objectAtIndex:indexPath.row];
    
    p.IsFavorite = [NSNumber numberWithBool:!p.IsFavorite.boolValue];
    [appMngr setFormThemeFavoriteForFormThemeModelClass:p];
    
    [_themesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


-(void)updateProgress:(MOStoreButton*)button{
    if (currentProgress>=1) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        return;
    }
    
    currentProgress+=0.04f;
    //    NSLog(@"current progress is %f",currentProgress);
    [button setProgress:currentProgress animated:YES];
    [self performSelector:@selector(updateProgress:) withObject:button afterDelay:.04];
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
        
        [self onBuyButtonPressed:button];
        NSLog(@"buttonClickedSecondTime");
        // to mimic download operation
        //[self performSelector:@selector(startDownloading:) withObject:button afterDelay:2];
    }
}

-(void)onBuyButtonPressed:(id)sender{
    CGPoint buttonOriginInTableView;
    if([sender isKindOfClass:[MOStoreButton class]]){
        buttonOriginInTableView = [((MOStoreButton *) sender) convertPoint:CGPointZero toView:_themesTableView];
    }else if([sender isKindOfClass:[UIGestureRecognizer class]]){
        buttonOriginInTableView = [((UIGestureRecognizer *)sender) locationOfTouch:0 inView:_themesTableView];
    }
    
    NSIndexPath *indexPath = [_themesTableView indexPathForRowAtPoint:buttonOriginInTableView];
    FormThemeModelClass *ftm = [formThemesList objectAtIndex:indexPath.row];

    [self onInstallWithObj:ftm];
    [_themesTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[self onInstallFormForSourceFormObj:sfm];
    [self performSelector:@selector(startDownloading:) withObject:sender afterDelay:2];
}

-(void) onInstallWithObj:(FormThemeModelClass *)obj{
    obj.IsInstalled = [NSNumber numberWithBool: YES];
    obj.TransactionId = [NSString stringWithFormat:@"%f", [NSDate date].timeIntervalSince1970];
    obj.ModificationDate = [NSNumber numberWithDouble: [NSDate date].timeIntervalSince1970];
    obj.Username = [appMngr.mscs getCurrentUser].username;
    [appMngr updateTheme:obj];
    
    int i=0;
    for (FormThemeModelClass *p in formThemesList) {
        if([p.ThemeId compare:obj.ThemeId]==NSOrderedSame){
            [formThemesList replaceObjectAtIndex:i withObject:obj];
            break;
        }
        i++;
    }
}

     

@end
