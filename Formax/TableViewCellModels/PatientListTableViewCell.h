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

@interface PatientListTableViewCell : MGSwipeTableCell


@property (weak, nonatomic) IBOutlet RoundableView *tagView;
@property (weak, nonatomic) NSNumber* PatientId;
@property (weak, nonatomic) IBOutlet UIImageView* patientPhotoImageView;
@property (weak, nonatomic) IBOutlet UIButton *viewBtn;

@property (weak, nonatomic) IBOutlet UILabel *patientFullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membersinceLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;

@end
