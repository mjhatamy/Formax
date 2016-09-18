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

@interface SourceFormListTableViewCell : MGSwipeTableCell


@property (nonatomic, copy) NSNumber* CategoryId;
@property (nonatomic, copy) NSNumber* FormId;

@property (nonatomic, strong) MOStoreButton *storeBtn;

@property (weak, nonatomic) IBOutlet RoundableView *tagView;
@property (weak, nonatomic) IBOutlet UIButton *favBtn;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *descTextView;

@property (weak, nonatomic) IBOutlet UIView *storeBtnCoverView;
@property (weak, nonatomic) IBOutlet UIButton *signtBtn;
@property (weak, nonatomic) IBOutlet UIStackView *isFavBtnStackView;


@property (nonatomic) UIView *highlighSelectView;

@end
