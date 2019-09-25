//
//  ContractListHeader.m
//  gugu
//
//  Created by Mike Chen on 2019/3/5.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractListHeader.h"
@interface ContractListHeader()

@end

@implementation ContractListHeader

-(void)awakeFromNib{
    [super awakeFromNib];
    
    [self.view_newFriend az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"4c7be7"],[UIColor colorWithHexString:@"4b5cdc"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.view_myGroup az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"ed9d34"],[UIColor colorWithHexString:@"e1904e"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.view_myGroup addlayerRadius:10];
    [self.view_newFriend addlayerRadius:10];
    
    [self.view_search addlayerRadius:self.view_search.height/2];
    
    
}

- (IBAction)action_search:(UIButton *)sender {
    if (self.block_search) {
        self.block_search();
    }
}

- (IBAction)action_newfriend:(id)sender {
    if (self.block_new_friend) {
        self.block_new_friend();
    }
}
- (IBAction)action_myGroup:(id)sender {
    if (self.block_my_group) {
        self.block_my_group();
    }
}


@end
