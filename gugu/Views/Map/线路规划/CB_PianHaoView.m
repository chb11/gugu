//
//  CB_PianHaoView.m
//  gugu
//
//  Created by Mike Chen on 2019/4/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_PianHaoView.h"

@interface CB_PianHaoView()

@property (weak, nonatomic) IBOutlet UIButton *btn_yongdu;
@property (weak, nonatomic) IBOutlet UIButton *btn_shoufei;
@property (weak, nonatomic) IBOutlet UIButton *btn_nogaosu;
@property (weak, nonatomic) IBOutlet UIButton *btn_gaosu;
@property (weak, nonatomic) IBOutlet UIButton *btn_confirm;

@end

@implementation CB_PianHaoView
- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self.btn_yongdu addborderColor:[UIColor lightGrayColor] borderWith:1 layerRadius:5];
    [self.btn_shoufei addborderColor:[UIColor lightGrayColor] borderWith:1 layerRadius:5];
    [self.btn_nogaosu addborderColor:[UIColor lightGrayColor] borderWith:1 layerRadius:5];
    [self.btn_gaosu addborderColor:[UIColor lightGrayColor] borderWith:1 layerRadius:5];
    
    [self.btn_confirm addlayerRadius:self.btn_confirm.height/2];
    [self.btn_confirm az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
}


- (IBAction)action_click:(UIButton *)sender {
    
    if (sender.tag == 101) {
        [self changeButtonState:sender selected:!sender.selected];
    }
    if (sender.tag == 102) {
        [self changeButtonState:[self viewWithTag:104] selected:NO];
        [self changeButtonState:sender selected:!sender.selected];
    }
    if (sender.tag == 103) {
        [self changeButtonState: [self viewWithTag:104] selected:NO];
        [self changeButtonState:sender selected:!sender.selected];
    }
    if (sender.tag == 104) {
        [self changeButtonState:sender selected:!sender.selected];
        [self changeButtonState:[self viewWithTag:102] selected:NO];
        [self changeButtonState:[self viewWithTag:103] selected:NO];
    }
}

- (IBAction)action_confirm:(UIButton *)sender {
    if (self.block_choosePianHao) {
        self.block_choosePianHao([self strategyWithIsMultiple:YES]);
    }
}

- (void)changeButtonState:(UIButton *)button selected:(BOOL)selected
{
    button.selected = selected;
    UIColor *color = button.selected?[UIColor colorWithHexString:@"1782D2"]:[UIColor colorWithHexString:@"363636"];
    button.layer.borderColor = color.CGColor;
}

- (AMapNaviDrivingStrategy)strategyWithIsMultiple:(BOOL)isMultiple
{
    return ConvertDrivingPreferenceToDrivingStrategy(isMultiple,
                                                     self.btn_yongdu.selected,
                                                     self.btn_nogaosu.selected,
                                                     self.btn_shoufei.selected,
                                                     self.btn_gaosu.selected);
}

@end
