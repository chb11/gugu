//
//  MineItemCell.m
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MineItemCell.h"

@implementation MineItemCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.v_switch addTarget:self action:@selector(switchAction) forControlEvents:UIControlEventValueChanged];
    
}

-(void)switchAction{
    if (self.block_switch) {
        self.block_switch();
    }
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
