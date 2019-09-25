//
//  CB_SearchOpenView.m
//  gugu
//
//  Created by Mike Chen on 2019/3/31.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SearchOpenView.h"

@implementation CB_SearchOpenView


-(void)setIsOpen:(BOOL)isOpen{
    _isOpen = isOpen;
    if (isOpen) {
        [self.btn_open setTitle:@"关闭" forState:UIControlStateNormal];
    }else{
        [self.btn_open setTitle:@"展开" forState:UIControlStateNormal];
    }
}

- (IBAction)action_open:(UIButton *)sender {
    self.isOpen = !self.isOpen;
    if (self.block_open) {
        self.block_open(self.isOpen);
    }
}

@end
