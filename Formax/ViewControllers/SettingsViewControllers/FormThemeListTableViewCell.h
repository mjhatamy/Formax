//
//  FormThemeListTableViewCell.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/6/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MOStoreButton.h"
#import "RoundableView.h"

@interface FormThemeListTableViewCell : MGSwipeTableCell

@property (nonatomic, strong) MOStoreButton *storeBtn;
@property (nonatomic, copy) NSNumber*   ThemeId;

@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (weak, nonatomic) IBOutlet UIStackView *favBtnStackView;
@property (weak, nonatomic) IBOutlet UILabel *themeNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *themeDescTextView;

@property (weak, nonatomic) IBOutlet UIView *buyOrInstallBtnCoverView;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultBtn;

@end
