//
//  CB_EditAddressController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_EditAddressController.h"
#import "SSChatLocationController.h"

@interface CB_EditAddressController ()

@property (weak, nonatomic) IBOutlet UITextField *lbl_miaoshu;
@property (weak, nonatomic) IBOutlet UITextField *lbl_address;

@property (weak, nonatomic) IBOutlet UITextField *lbl_sort;

@property (nonatomic,strong) __block MAPointAnnotation *annotation;
@property (nonatomic,strong) NSMutableDictionary *para;
@property (weak, nonatomic) IBOutlet UIButton *btn_submit;

@end

@implementation CB_EditAddressController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"地址编辑";
    
    if (self.dict) {
        self.para = self.dict.mutableCopy;
        self.lbl_sort.text = [AppGeneral getSafeValueWith:self.dict[@"Idx"]];
        self.lbl_miaoshu.text = [AppGeneral getSafeValueWith:self.dict[@"Tag"]];
        self.lbl_address.text = [AppGeneral getSafeValueWith:self.dict[@"Name"]];
    }
    [self.btn_submit addlayerRadius:self.btn_submit.height/2];
}

- (IBAction)action_chooseAddress:(id)sender {
    SSChatLocationController *vc = [SSChatLocationController new];
    vc.locationBlock = ^(MAPointAnnotation *annotation) {
        self.lbl_address.text = annotation.title;
        self.annotation = annotation;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)action_submit:(id)sender {
    if (self.lbl_miaoshu.text.length==0) {
        [AppGeneral showMessage:@"请输入地址描述" andDealy:1];
        return;
    }
    if (self.lbl_address.text.length == 0) {
        [AppGeneral showMessage:@"请选择地址" andDealy:1];
        return;
    }
    if (!self.dict) {
        self.para = @{}.mutableCopy;
    }
    [self.para setValue:self.lbl_address.text forKey:@"Name"];
    [self.para setValue:[UserModel shareInstance].Guid forKey:@"ConsumerId"];
    [self.para setValue:@(self.lbl_sort.text.integerValue) forKey:@"Idx"];
    [self.para setValue:self.lbl_miaoshu.text forKey:@"Tag"];
    if (self.annotation) {
        [self.para setValue:@(self.annotation.coordinate.latitude) forKey:@"Lat"];
        [self.para setValue:@(self.annotation.coordinate.longitude) forKey:@"Lng"];
    }
    
    
    [[NetWorkConnect manager] postDataWith:self.para withUrl:CARD_EDIT_CARD_ADDRESS withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"编辑成功" andDealy:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}


@end
