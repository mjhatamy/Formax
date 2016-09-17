//
//  FormThemesListViewController.h
//  Formax
//
//  Created by Majid Hatami Aghdam on 9/6/16.
//  Copyright © 2016 Majid Hatami Aghdam. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormThemesListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *themesTableView;

@end
