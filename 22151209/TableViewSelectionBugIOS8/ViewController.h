//
//  ViewController.h
//  TableViewSelectionBugIOS8
//
//  Created by pronebird on 8/5/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (weak) IBOutlet UITableView *tableView;
@property (weak) IBOutlet UIToolbar *accessory;

@property CGFloat adjustmentForKeyboard;

@end
