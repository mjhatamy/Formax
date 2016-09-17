//
//  UserSubscriptionsTableViewCell.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundableView.h"

@interface UserSubscriptionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet RoundableView *tagView;
@property (weak, nonatomic) IBOutlet UILabel *planNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *planStatusLabel;

@end
