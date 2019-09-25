//
//  CB_GroupInfoCell.m
//  gugu
//
//  Created by Mike Chen on 2019/5/4.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupInfoCell.h"

@implementation CB_GroupInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.view_switch addTarget:self action:@selector(action_switchChange:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

-(void)action_switchChange:(UISwitch *)v_switch{
    if (self.block_switch) {
        self.block_switch(v_switch.isOn);
    }
}
@end
