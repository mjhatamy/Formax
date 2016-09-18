//
//  PatientListTableViewCell.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 8/31/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "RoundableView.h"

@interface ProviderListTableViewCell : MGSwipeTableCell


@property (weak, nonatomic) IBOutlet RoundableView *tagView;
@property (weak, nonatomic) NSNumber* ProviderId;
@property (weak, nonatomic) IBOutlet UIImageView* photoImageView;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersinceLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
