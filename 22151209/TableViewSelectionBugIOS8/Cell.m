//
//  Cell.m
//  TableViewSelectionBugIOS8
//
//  Created by pronebird on 8/5/15.
//  Copyright (c) 2015 pronebird. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if([view isKindOfClass:[UITextField class]] && !self.selected) {
        return self;
    }
    
    return view;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    NSLog(@"setSelected : %d", selected);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    NSLog(@"setSelected : %d animated : %d", selected, animated);
}

@end
