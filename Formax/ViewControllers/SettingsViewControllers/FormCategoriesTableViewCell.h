//
//  FormCategoriesTableViewCell.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormCategoriesTableViewCell : UITableViewCell

@property (nonatomic, copy) NSNumber* CategoryId;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UIView *highlighSelectView;
@end
