//
//  SelectAProviderForSignViewController.m
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import "SelectAProviderForSignViewController.h"
#import "ProviderModelClass.h"
#import "AppManager.h"
#import "ProviderListTableViewCell.h"
#import "AddProviderViewController.h"

@interface SelectAProviderForSignViewController ()<AddProviderViewControllerDelegate>
{
    NSArray<ProviderModelClass *>* providersList;
    AppManager* appMngr;
}

@end

@implementation SelectAProviderForSignViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    appMngr = [AppManager SharedInstance];
    
    [self Refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"Appear");
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"Disapear");
}


-(void)Refresh{
    [appMngr getAllProvidersByForcedRefresh:NO CompletionHanlder:^(NSArray<ProviderModelClass *> * _Nullable arr, BOOL Updated, BOOL Succeeded, NSError * _Nullable error, NSString * _Nullable MsgToUI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            providersList = arr;
            ALog("Number Of Providers %ld", providersList.count);
            [_providersListTableView reloadData];
        });
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(providersList != nil) return providersList.count;
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"ProviderListTableViewCellInPDF";
    ProviderListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    ProviderModelClass *obj = [providersList objectAtIndex:indexPath.row];
    
    [cell.photoImageView setImage:[UIImage imageWithData:obj.PhotoData]];
    cell.photoImageView.layer.cornerRadius = cell.photoImageView.bounds.size.height/2;
    if(cell.photoImageView.image.size.width <= 0){
        [cell.photoImageView setImage:[UIImage imageNamed:@"unknown_contact_140x140"]];
        cell.photoImageView.layer.borderColor = [UITools colorFromHexString:@"#EEEEEE"].CGColor;
        cell.photoImageView.layer.borderWidth = 1;
    }else{
        cell.photoImageView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.photoImageView.layer.borderWidth = 0;
    }
    
    cell.ProviderId  = obj.ProviderId;
    cell.tagView.layer.cornerRadius = 6;
    cell.tagView.layer.borderWidth = TagLayerBorderWidth;
    if(obj.Tag.intValue == TagTypeNone){
        cell.tagView.layer.borderColor = TagBackgroundNoneColor.CGColor;
        cell.tagView.backgroundColor = TagBorderNoneColor;
    }else if( obj.Tag.intValue  == TagTypePink){
        cell.tagView.layer.borderColor = TagBorderPinkColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundPinkColor;
    }else if( obj.Tag.intValue  == TagTypeBlue){
        cell.tagView.layer.borderColor = TagBorderBlueColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundBlueColor;
    }else if(obj.Tag.intValue  == TagTypeGreen){
        cell.tagView.layer.borderColor = TagBorderGreenColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundGreenColor;
    }else if(obj.Tag.intValue  == TagTypeYellow){
        cell.tagView.layer.borderColor = TagBorderYellowColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundYellowColor;
    }else if(obj.Tag.intValue  == TagTypeOrange){
        cell.tagView.layer.borderColor = TagBorderOrangeColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundOrangeColor;
    }else if(obj.Tag.intValue  == TagTypeRed ){
        cell.tagView.layer.borderColor = TagBorderRedColor.CGColor;
        cell.tagView.backgroundColor = TagBackgroundRedColor;
    }
    [cell.tagView setNeedsLayout];
    
    if(appMngr.AppConfig.PatientNameDisplayReverse.boolValue){
        [cell.fullNameLabel setText:[NSString stringWithFormat:@"%@, %@", obj.LastName, obj.FirstName]];
    }else{
        [cell.fullNameLabel setText:[NSString stringWithFormat:@"%@ %@", obj.FirstName, obj.LastName]];
    }
    
    NSMutableString *desc= [[NSMutableString alloc] init];
    BOOL addrDetected;
    addrDetected = NO;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    if(appMngr.AppConfig.InternationalModeEnabled.boolValue)
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", INTDateFormat]];
    else
        [dateFormat setDateFormat:[NSString stringWithFormat:@"%s", USDateFormat]];
    
    if(obj.DOB != nil){
        [desc appendFormat:@"Birthdate: %@\n", [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:obj.DOB.doubleValue]]];
    }
    
    if(![UITools isNSStringNull:obj.StreetAddr]){
        addrDetected = YES;
        [desc appendFormat:@"Address: %@", obj.StreetAddr];
    }
    if(![UITools isNSStringNull:obj.AptAddr]){
        if(!addrDetected){ [desc appendString:@"Address: "]; addrDetected=YES;}
        [desc appendFormat:@" %@", obj.AptAddr];
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
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProviderModelClass *pmc = [providersList objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate conformsToProtocol:@protocol(SelectAProviderForSignViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(onSelectAProviderForSignViewControllerSelectedProvider:)]){
            [self.delegate onSelectAProviderForSignViewControllerSelectedProvider:pmc.ProviderId];
        }
    }];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"gotoAddProviderFromSelectAProviderForSignViewControllerSegue"]){
        AddProviderViewController* vc = [segue destinationViewController];
        vc.delegate = self;
        vc.ProviderId = nil;
        vc.ViewMode = PageViewModeAddnew;
    }
}

-(void)onAddProviderViewControllerClosedDelegate{
    [self Refresh];
}

- (IBAction)onContinueToolbarBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if([self.delegate conformsToProtocol:@protocol(SelectAProviderForSignViewControllerDelegate)] && [self.delegate respondsToSelector:@selector(onSelectAProviderForSignViewControllerClosedDelegate)]){
            [self.delegate onSelectAProviderForSignViewControllerClosedDelegate];
        }
    }];
}

@end
