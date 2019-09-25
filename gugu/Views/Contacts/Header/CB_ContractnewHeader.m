//
//  CB_ContractnewHeader.m
//  gugu
//
//  Created by Mike Chen on 2019/6/10.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ContractnewHeader.h"

@implementation CB_ContractnewHeader

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.view_top az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.view_content addlayerRadius:6];
    self.view_content.layer.masksToBounds = YES;
    self.view_content.superview.layer.masksToBounds = NO;
    self.view_content.superview.layer.shadowColor=COLOR_MAIN_LEFT.CGColor;
    self.view_content.superview.layer.shadowOffset=CGSizeMake(2, 3);
    self.view_content.superview.layer.shadowOpacity=0.2;
    self.view_content.superview.layer.shadowRadius=4;
    
}

- (IBAction)action_newFriend:(id)sender {
    if (self.block_newFriend) {
        self.block_newFriend();
    }
}

- (IBAction)action_group:(id)sender {
    if (self.block_group) {
        self.block_group();
    }
}

- (IBAction)action_addFriend:(id)sender {
    if (self.block_addFriend) {
        self.block_addFriend();
    }
}

- (IBAction)action_search:(id)sender {
    if (self.block_search) {
        self.block_search();
    }
}

@end
