//
//  InfoViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/10/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *RegistrationInfoTableView;
@property (weak, nonatomic) IBOutlet UITableView *practiceInfoTableView;

@property (weak, nonatomic) IBOutlet UITableView *availableSubscriptionsTableViewe;
@property (weak, nonatomic) IBOutlet UITableView *availableFeatureSubscriptionsTableView;

-(void)refreshSubscriptions;

@end
