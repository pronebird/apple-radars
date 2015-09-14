//
//  ViewController.m
//  TableViewSelectionBugIOS8
//
//  Created by pronebird on 8/5/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "ViewController.h"
#import "Cell.h"

@implementation ViewController {
    BOOL _didShowInstructions;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver:self
                           selector:@selector(_keyboardWillShow:)
                               name:UIKeyboardWillShowNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(_keyboardWillHide:)
                               name:UIKeyboardWillHideNotification
                             object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(!_didShowInstructions) {
        _didShowInstructions = YES;
        
        [self showAlertWithText:@"To reproduce the bug:\n1. Select first row in table view.\n2. Scroll table view to the bottom.\n3. Tap 'Done' button above keyboard.\nUnexpectedly previously selected cell will stay highlighted forever and indexPathForSelectedRow will report nil."];
    }
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = (Cell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    [cell.textField becomeFirstResponder];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textField.placeholder = [NSString stringWithFormat:@"Row %ld", (long)indexPath.row];
    cell.textField.inputAccessoryView = self.accessory;
    
    return cell;
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    NSIndexPath* selectedRow = [self.tableView indexPathForSelectedRow];
    if(selectedRow) {
        //
        // everything works if I swap deselect and endEditing! Bug?
        //
        
        [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
        [self.view endEditing:YES];
    }
    else {
        NSString *message = [NSString stringWithFormat:@"indexPathForSelectedRow = %@. It cannot be nil, check the state of cells in table view.", selectedRow];
        [self showAlertWithText:message];
    }
}

- (IBAction)showSelectedIndexPath:(id)sender {
    NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
    NSString *message = [NSString stringWithFormat:@"indexPathForSelectedRow = %@", selectedRow];
    [self showAlertWithText:message];
}

#pragma mark - Keyboard handling

- (void)_keyboardWillShow:(NSNotification *)note {
    NSLog(@"_keyboardWillShow");
    
    CGRect keyboardRect = [[note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSInteger animationCurve = [[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationOptions animationOptions = (animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    contentInset.bottom -= self.adjustmentForKeyboard;
    self.adjustmentForKeyboard = keyboardRect.size.height;
    contentInset.bottom += self.adjustmentForKeyboard;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         self.tableView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {
                     }];
}

- (void)_keyboardWillHide:(NSNotification *)note {
    NSLog(@"_keyboardWillHide");
    
    NSInteger animationCurve = [[note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    NSTimeInterval animationDuration = [[note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationOptions animationOptions = (animationCurve << 16) | UIViewAnimationOptionBeginFromCurrentState;
    UIEdgeInsets contentInset = self.tableView.contentInset;
    
    contentInset.bottom -= self.adjustmentForKeyboard;
    self.adjustmentForKeyboard = 0;
    
    [UIView animateWithDuration:animationDuration
                          delay:0
                        options:animationOptions
                     animations:^{
                         self.tableView.contentInset = contentInset;
                     }
                     completion:^(BOOL finished) {}];
}

#pragma mark - Private

- (void)showAlertWithText:(NSString *)text {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:text preferredStyle:UIAlertControllerStyleAlert];
    
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
