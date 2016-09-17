//
//  FirstViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 8/30/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "PatientProfileModelClass.h"
#import "PatientListTableViewCell.h"

@interface PatientListViewController : UIViewController<UIBarPositioningDelegate, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *patientListTableView;


@end

