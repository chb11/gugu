//
//  CB_MessageTransHeader.m
//  gugu
//
//  Created by Mike Chen on 2019/4/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MessageTransHeader.h"

@interface CB_MessageTransHeader ()

@end

@implementation CB_MessageTransHeader

- (IBAction)action_chooseGroup:(UIButton *)sender {
    if (self.block_chooseGroup) {
        self.block_chooseGroup();
    }
}

- (IBAction)action_chooseList:(UIButton *)sender {
    if (self.block_chooseFriend) {
        self.block_chooseFriend();
    }
}

@end
