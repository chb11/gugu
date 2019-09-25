//
//  ContractShareFriendHeader.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractShareFriendHeader.h"

@implementation ContractShareFriendHeader


- (IBAction)action_click:(id)sender {
    
    if (self.block_chooseGroup) {
        self.block_chooseGroup();
    }
}


@end
