//
//  CB_RouteTypeView.m
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_RouteTypeView.h"

@implementation CB_RouteTypeView
-(void)awakeFromNib{
    [super awakeFromNib];
    
}

- (IBAction)action_click:(UIButton *)sender {
    
    for (UIButton *btn in self.subviews) {
        [btn setTitleColor:[UIColor colorWithHexString:@"363636"] forState:UIControlStateNormal];
    }
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if (self.block_routeType) {
        self.block_routeType(sender.tag-100);
    }
}


@end
