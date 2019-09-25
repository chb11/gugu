//
//  MyQrController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MyQrController.h"

@interface MyQrController ()
@property (weak, nonatomic) IBOutlet UIImageView *img_header;
@property (weak, nonatomic) IBOutlet UILabel *lbl_name;
@property (weak, nonatomic) IBOutlet UILabel *lbl_guguNum;
@property (weak, nonatomic) IBOutlet UIView *view_cont;
@property (weak, nonatomic) IBOutlet UIImageView *img_qr;

@end

@implementation MyQrController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的名片";
    [self.img_header addlayerRadius:self.img_header.height/2];
    [self.img_header sd_setImageWithURL:[NSURL URLWithString:[UserModel shareInstance].HeadPhotoURL]];
    self.lbl_name.text = [UserModel shareInstance].UserName;
    self.lbl_guguNum.text = [NSString stringWithFormat:@"咕咕号:%@",[UserModel shareInstance].GuNum];
    
    NSDictionary *dict = @{@"qrType":@(1),@"userId":[UserModel shareInstance].Guid};
    
    self.img_qr.image = [WSLNativeScanTool createQRCodeImageWithString:[dict modelToJSONString] andSize:CGSizeMake(200, 200) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor blackColor] andCenterImage:nil];
    
}




@end
