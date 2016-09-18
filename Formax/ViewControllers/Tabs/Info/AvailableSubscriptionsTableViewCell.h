//
//  AvailableSubscriptionsTableViewCell.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 8/1/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MOStoreButton.h"

@interface AvailableSubscriptionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *planNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *planDescriptionTextView;

@property (weak, nonatomic) IBOutlet UIView *buyBtnView;
@property (strong, nonatomic)  MOStoreButton*buyBtn;

@end
