//
//  SelectAProviderForSignViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/11/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"

@protocol SelectAProviderForSignViewControllerDelegate <NSObject>

-(void) onSelectAProviderForSignViewControllerClosedDelegate;
-(void) onSelectAProviderForSignViewControllerSelectedProvider:(NSNumber *)ProviderId;
@end



@interface SelectAProviderForSignViewController : UIViewController<UIBarPositioningDelegate, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate>

@property (nonatomic, assign) id delegate;
@property (weak, nonatomic) IBOutlet UITableView *providersListTableView;


@end
