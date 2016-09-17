//
//  FirstViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 8/30/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "PatientListViewController.h"

#import "PatientProfileModelClass.h"
#import "UITools.h"
#import "AppManager.h"
#import "PopupTagSetterViewController.h"
#import "AuthorizationDialogClass.h"
#import "AddPatientProfileViewController.h"

@interface PatientListViewController (){
    NSMutableArray<PatientProfileModelClass *>* patientListArray;
    AppManager* appMngr;
    PopupTagSetterViewController *PopupTagSetterVC;
    
    PageViewMode PatientPageViewMode;
    NSNumber* PatientPagePatientId;
}

@end

@implementation PatientListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    patientListArray = nil;
    appMngr = [AppManager SharedInstance];
    
    //initial Setup
    PatientPagePatientId = nil;
    PatientPageViewMode = PageViewModeAddnew;
    
    patientListArray = [[NSMutableArray alloc] init];
    
    _patientListTableView.layer.cornerRadius = 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self Refresh];
}

-(void) Refresh{
    [appMngr getPatientProfileWithWaitingBlock:^(BOOL shouldWaitForCompletion) {
        
    } CompletionHandler:^(NSArray<PatientProfileModelClass *> * _Nullable PatientListArr, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        if(PatientListArr != nil){
            dispatch_async(dispatch_get_main_queue(), ^{
                //patientListArray = PatientListArr;
                
                [patientListArray removeAllObjects];
                [patientListArray addObjectsFromArray:PatientListArr];
                
                [_patientListTableView reloadData];
            });
        }
        
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(patientListArray != nil){
        return patientListArray.count;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"PatientListTableViewCell";
    PatientListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    PatientProfileModelClass *obj = [patientListArray objectAtIndex:indexPath.row];
    
    UITapGestureRecognizer *photoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handlePatientTapGestureRecognizer:)];
    photoTap.numberOfTapsRequired = 1;
    photoTap.numberOfTouchesRequired = 1;
    [cell addGestureRecognizer:photoTap];
    
    UILongPressGestureRecognizer *longPressTapGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onHandleLongPressOnPatientListItemGestureRecognizer:)];
    longPressTapGesture.minimumPressDuration = 0.6f;
    [cell addGestureRecognizer:longPressTapGesture];
    
    
    [cell.patientPhotoImageView setImage:[UIImage imageWithData:obj.PreviewImageData]];
    cell.patientPhotoImageView.layer.cornerRadius = 30;//cell.patientPhotoImageView.bounds.size.height/2;
    if(cell.patientPhotoImageView.image.size.width <= 0){
        [cell.patientPhotoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
        cell.patientPhotoImageView.layer.borderColor = [UITools colorFromHexString:@"#EEEEEE"].CGColor;
        cell.patientPhotoImageView.layer.borderWidth = 1;
    }else{
        cell.patientPhotoImageView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.patientPhotoImageView.layer.borderWidth = 0;
    }
    
    cell.PatientId  = obj.PatientId;
    
    cell.tagView.layer.cornerRadius = 6;
    cell.tagView.layer.borderWidth = TagLayerBorderWidth;
    if(obj.Tag.intValue == TagTypeNone){
        cell.tagView.layer.borderColor = TagBorderNoneColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundNoneColor;
    }else if( obj.Tag.intValue  == TagTypePink){
        cell.tagView.layer.borderColor = TagBorderPinkColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundPinkColor;
    }else if( obj.Tag.intValue  == TagTypeBlue){
        cell.tagView.layer.borderColor = TagBorderBlueColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundBlueColor;
    }else if(obj.Tag.intValue  == TagTypeGreen){
        cell.tagView.layer.borderColor = TagBorderGreenColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundGreenColor;
    }else if(obj.Tag.intValue  == TagTypeYellow){
        cell.tagView.layer.borderColor = TagBorderYellowColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundYellowColor;
    }else if(obj.Tag.intValue  == TagTypeOrange){
        cell.tagView.layer.borderColor = TagBorderOrangeColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundOrangeColor;
    }else if(obj.Tag.intValue  == TagTypeRed ){
        cell.tagView.layer.borderColor = TagBorderRedColor.CGColor;
        cell.tagView.roundableViewColor = TagBackgroundRedColor;
    }
    
    cell.tagView.layer.shadowOffset = CGSizeZero;
    cell.tagView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.tagView.layer.shadowOpacity = 0.5;
    cell.tagView.layer.shadowRadius = 3;
    [cell.tagView setNeedsLayout];
    
    if(appMngr.AppConfig.PatientNameDisplayReverse.boolValue){
        [cell.patientFullNameLabel setText:[NSString stringWithFormat:@"%@, %@", obj.LastName, obj.FirstName]];
    }else{
        [cell.patientFullNameLabel setText:[NSString stringWithFormat:@"%@ %@", obj.FirstName, obj.LastName]];
    }
    
    NSMutableString *desc= [[NSMutableString alloc] init];
    BOOL addrDetected;
    addrDetected = NO;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    else
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    
    if(obj.BirthDate != nil){
        [desc appendFormat:@"Birthdate: %@     ", [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:obj.BirthDate.doubleValue]]];
    }
    
    if(![UITools isNSStringNull:obj.StreetAddr]){
        addrDetected = YES;
        [desc appendFormat:@"Address: %@", obj.StreetAddr];
    }
    if(![UITools isNSStringNull:obj.UnitAddr]){
        if(!addrDetected){ [desc appendString:@"Address: "]; addrDetected=YES;}
        [desc appendFormat:@" %@", obj.UnitAddr];
    }
    
    if(![UITools isNSStringNull:obj.CityAddr]){
        if(!addrDetected){ [desc appendString:@"Address: "]; addrDetected=YES;}
        [desc appendFormat:@" %@", obj.CityAddr];
    }
    if(![UITools isNSStringNull:obj.StateAddr]){
        if(!addrDetected){ [desc appendString:@"Address: "]; addrDetected=YES;}
        [desc appendFormat:@" %@", obj.StateAddr];
    }
    if(![UITools isNSStringNull:obj.ZipCodeAddr]){
        if(!addrDetected){ [desc appendString:@"Address: "]; }//addrDetected=YES;}
        [desc appendFormat:@" %@", obj.ZipCodeAddr];
    }
    
    if(desc.length > 0){
        [cell.descriptionTextView setText:desc];
    }else{
        [cell.descriptionTextView setText:@""];
    }
    
    
    [cell.membersinceLabel setText:[NSString stringWithFormat:@"Created on %@",[dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:obj.CreationDate.doubleValue]] ]];
    
    
    MGSwipeButton *swipeLeftTagBtn = [MGSwipeButton buttonWithTitle:NSLocalizedString(@"Set Tag", @"Set_Tag") icon:[UIImage imageNamed:@"tagIcon"] backgroundColor:[UIColor grayColor]];
    cell.leftButtons = @[swipeLeftTagBtn];
    cell.leftSwipeSettings.transition = MGSwipeTransitionDrag;
    
    [cell layoutSubviews];
    return cell;
}

-(void)handlePatientTapGestureRecognizer:(UITapGestureRecognizer *)recognizer{
    
    CGPoint buttonOriginInTableView = [recognizer locationInView:_patientListTableView];
    NSIndexPath *indexPath = [_patientListTableView indexPathForRowAtPoint:buttonOriginInTableView];
    [self openAddPatientViewControllerByViewMode:PageViewModeView PatientId: [patientListArray objectAtIndex:indexPath.row].PatientId ];
}

-(void)onHandleLongPressOnPatientListItemGestureRecognizer:(UITapGestureRecognizer *)recognizer{
     CGPoint buttonOriginInTableView = [recognizer locationInView:_patientListTableView];
     NSIndexPath *indexPath = [_patientListTableView indexPathForRowAtPoint:buttonOriginInTableView];
    [self onPopupViewPatientViewControllerByViewMode:PageViewModePopupView PatientId: [patientListArray objectAtIndex:indexPath.row].PatientId];
}


-(void) tagBtnClicked:(MGSwipeButton *)sender{
    NSLog(@"Tag btn clicked for");
}


-(BOOL)swipeTableCell:(MGSwipeTableCell *)cell tappedButtonAtIndex:(NSInteger)index direction:(MGSwipeDirection)direction fromExpansion:(BOOL)fromExpansion{
    PatientListTableViewCell *pcell = (PatientListTableViewCell *)cell;
    //0==Set Tag Action
    if(index==0){ //Open TagViewer for PatientId
        PopupTagSetterVC = [PopupTagSetterViewController initWithTagNamesList:appMngr.AppConfig.PatientsTagNames sourceRect:CGRectMake( 0, 0, (pcell.patientPhotoImageView.frame.size.width*2)-30, (pcell.frame.size.height)) sourceView:pcell];
        
        [PopupTagSetterVC ProcessWithCompletionHandler:^(BOOL Success, TagType tagType) {
            if(Success){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [appMngr setPatientProfileTagByPatientID:pcell.PatientId tag:tagType Synced:[NSNumber numberWithBool:NO]];
                    
                    [patientListArray objectAtIndex:[_patientListTableView indexPathForCell:pcell].row].Tag = [NSNumber numberWithInt:tagType];
                    [_patientListTableView reloadRowsAtIndexPaths:@[[_patientListTableView indexPathForCell:pcell] ] withRowAnimation:UITableViewRowAnimationFade];
                });
            }else{
                ALog("Failed");
            }
        }];
        
        [self presentViewController:PopupTagSetterVC animated:YES completion:^{
            
        }];
    }
    
    return YES;
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar{
    return UIBarPositionTopAttached;
}

-(BOOL)prefersStatusBarHidden{
    return NO; //Will cover Status bar
}



- (IBAction)addPatientToolbarBtnPressed:(id)sender {
    [self openAddPatientViewControllerByViewMode:PageViewModeAddnew PatientId:nil];
}


- (IBAction)onSignOutToolbarBtnPressed:(id)sender {
    [[[[AppManager SharedInstance] mscs] getCurrentUser] signOut];
    [[[[AppManager SharedInstance] mscs] getCurrentUser] getDetails];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"gotoAddPatientViewControllerFromPatientListViewControllerSegue"]){
        AddPatientProfileViewController *vc = segue.destinationViewController;
        vc.ViewMode = PatientPageViewMode;
        vc.PatientId = PatientPagePatientId;
    }else if( [segue.identifier isEqualToString:@"popupAddPatientViewControllerFromPatientListViewControllerSegue"]){
        AddPatientProfileViewController *vc = segue.destinationViewController;
        vc.ViewMode = PatientPageViewMode;
        vc.PatientId = PatientPagePatientId;
        
        //If presending on IPad
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
            CGSize prefSize = CGSizeMake(self.view.frame.size.width-200, self.view.frame.size.height - 200);;
            vc.popoverPresentationController.sourceView = self.view;
            vc.preferredContentSize = prefSize;
            CGFloat srcY =  ( self.view.bounds.size.height - prefSize.height )/2.0f;
            vc.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, srcY, 0, 0);
            vc.popoverPresentationController.backgroundColor = [UIColor clearColor];
        }else {
            vc.preferredContentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height-20);
            vc.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width/2, 20, 0, 0);
        }
    }
}


-(void)openAddPatientViewControllerByViewMode:(PageViewMode)viewmode  PatientId:(NSNumber *)PatientId{
    PatientPagePatientId = PatientId;
    PatientPageViewMode = viewmode;
    if(appMngr.AppConfig.SettingsPageAuthReq.boolValue){
        
        AuthorizationDialogClass *adc = [[AuthorizationDialogClass alloc] initWithViewController:self AccessPin:appMngr.AppConfig.AccessPin];
        [adc AuthorizeOperationWithCompletionhandler:^(BOOL succeeded, NSString *msgToUI, NSError *error) {
            if(succeeded){
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Your code to run on the main queue/thr
                    [self performSegueWithIdentifier:@"gotoAddPatientViewControllerFromPatientListViewControllerSegue" sender:self];
                }];
                
                
            }else{
                if(msgToUI!=nil){
                    //Show Message on Screen using OK Dialog Box
                }
                
                return;
            }
        }];
        return;
    }
    [self performSegueWithIdentifier:@"gotoAddPatientViewControllerFromPatientListViewControllerSegue" sender:self];
}

-(void)onPopupViewPatientViewControllerByViewMode:(PageViewMode)viewmode  PatientId:(NSNumber *)PatientId{
    PatientPagePatientId = PatientId;
    PatientPageViewMode = viewmode;
    if(appMngr.AppConfig.SettingsPageAuthReq.boolValue){
        
        AuthorizationDialogClass *adc = [[AuthorizationDialogClass alloc] initWithViewController:self AccessPin:appMngr.AppConfig.AccessPin];
        [adc AuthorizeOperationWithCompletionhandler:^(BOOL succeeded, NSString *msgToUI, NSError *error) {
            if(succeeded){
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    // Your code to run on the main queue/thr
                    [self performSegueWithIdentifier:@"popupAddPatientViewControllerFromPatientListViewControllerSegue" sender:self];
                    return;
                }];
                
                
            }else{
                if(msgToUI!=nil){
                    //Show Message on Screen using OK Dialog Box
                }
                
                return;
            }
        }];
        return;
    }
    [self performSegueWithIdentifier:@"popupAddPatientViewControllerFromPatientListViewControllerSegue" sender:self];
}

//popupAddPatientViewControllerFromPatientListViewControllerSegue
@end
