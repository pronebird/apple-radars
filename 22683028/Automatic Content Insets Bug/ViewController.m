//
//  ViewController.m
//  Automatic Content Insets Bug
//
//  Created by pronebird on 9/14/15.
//  Copyright © 2015 pronebird. All rights reserved.
//

#import "ViewController.h"

static NSString * const kCellIdentifier = @"Cell";

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    
    NSLog(@"view.subviews = %@", self.view.subviews);
    
    // Use insertSubview instead of addSubview because self.view.subviews contains _UILayoutGuide
    // that apparently break something in how UIKit automatically adjusts content insets for table views.
    // [self.view insertSubview:self.tableView atIndex:0];

    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"As you can see table view  content insets are not automatically adjusted when we use view.addSubview(table). However if we use view.insertSubview(table, atIndex:0) then content inset is properly adjusted. Looking at view.subviews on viewDidLoad I can spot two _UILayoutGuide objects. This is a regression on iOS 9.0 GM, this would not matter on iOS 8.0." preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Row %ld", indexPath.row];
    
    return cell;
}

@end
