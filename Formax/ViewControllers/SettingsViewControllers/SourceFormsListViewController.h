//
//  SourceFormsViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectAProviderForSignViewController.h"

@interface SourceFormsListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource, SelectAProviderForSignViewControllerDelegate>

@property (nonatomic, copy) NSNumber* PatientId;
@property (weak, nonatomic) IBOutlet UITableView *sourceFormsListTableView;
@property (weak, nonatomic) IBOutlet UITableView *formCategoriesListTableView;

@property (weak, nonatomic) IBOutlet UIView *categoriesTableCoverView;
@property (weak, nonatomic) IBOutlet UIView *categoriesTableCoverInnterView;


@end
