//
//  CB_NAviTypeChooseView.m
//  gugu
//
//  Created by Mike Chen on 2019/6/8.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_NAviTypeChooseView.h"

@implementation CB_NAviTypeChooseView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self.view_content addlayerRadius:10];
    [self.img_navi addlayerRadius:self.img_navi.height/2];
    [self.btn_guihua addlayerRadius:10];
    [self.btn_navi addlayerRadius:10];
    [self.btn_navi az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"429f58"],[UIColor colorWithHexString:@"51bc76"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.btn_guihua az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"2334bb"],[UIColor colorWithHexString:@"5765cd"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
}

- (IBAction)action_guihua:(id)sender {
    if (self.block_guihua) {
        self.block_guihua(self.model);
    }
}

- (IBAction)action_navi:(id)sender {
    if (self.block_zudui) {
        self.block_zudui(self.model);
    }
}

@end
