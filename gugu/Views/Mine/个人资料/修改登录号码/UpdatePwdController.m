//
//  UpdatePwdController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "UpdatePwdController.h"

@interface UpdatePwdController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toTop;
@property (weak, nonatomic) IBOutlet UITextField *txt_old_pwd;
@property (weak, nonatomic) IBOutlet UITextField *txt_new_pwd;
@property (weak, nonatomic) IBOutlet UITextField *txt_re_pwd;

@end

@implementation UpdatePwdController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.title = @"修改登录密码";
    self.constrain_toTop.constant = 10;
    [self addItemWithTitle:@"保存" imageName:@"" selector:@selector(action_save) left:NO];
}

-(void)action_save{
    NSString *oldPwd = [[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_PSW];
    if (![self.txt_old_pwd.text isEqualToString:oldPwd]) {
        [AppGeneral showMessage:@"原密码错误" andDealy:1];
        [self.txt_old_pwd becomeFirstResponder];
        return;
    }
    if (![AppGeneral isValidPassWord:self.txt_new_pwd.text]) {
        [AppGeneral showMessage:@"请输入6-16位数字字母或符号" andDealy:1];
        [self.txt_new_pwd becomeFirstResponder];
        return;
    }
    if (![self.txt_new_pwd.text isEqualToString:self.txt_re_pwd.text]) {
        [AppGeneral showMessage:@"两次密码不一致" andDealy:1];
        [self.txt_re_pwd becomeFirstResponder];
        return;
    }
    [[NetWorkConnect manager] postDataWith:@{} withUrl:V_GETPUBLICKEY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
       NSString *publicKey = responseObject[@"PublicKey"];
            
            NSDictionary *para = @{@"Password":[self.txt_new_pwd.text RSAEncrypt:publicKey],
                                   @"OldPassword":[self.txt_old_pwd.text RSAEncrypt:publicKey],
                                   };
            [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_CHANGEPWD withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
                if (resultCode == 1) {
                    [AppGeneral showMessage:@"修改成功" andDealy:1];
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }];
        }
        
    }];
    
    
}


@end
