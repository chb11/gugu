//
//  UpdatePhoneController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "UpdatePhoneController.h"

@interface UpdatePhoneController ()


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toTop;

@property (weak, nonatomic) IBOutlet UITextField *txt_oldPhone;
@property (weak, nonatomic) IBOutlet UITextField *txt_newPhone;
@property (weak, nonatomic) IBOutlet UITextField *txt_code;

@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UIView *view_code;

@end

@implementation UpdatePhoneController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"修改手机号";
    self.constrain_toTop.constant = 10;
    [self.view_code addlayerRadius:self.view_code.height/2];
     [self addItemWithTitle:@"保存" imageName:@"" selector:@selector(action_save) left:NO];
}

- (IBAction)action_sendCode:(UIButton *)sender {
    
    if (![AppGeneral isValidPhone:self.txt_newPhone.text]) {
        [AppGeneral showMessage:@"请输入正确的手机号" andDealy:1];
        [self.txt_newPhone becomeFirstResponder];
        return;
    }
    
    [self action_validIsBinded];
    
}

-(void)action_validIsBinded{
    
    NSDictionary *para = @{@"Phone":self.txt_newPhone.text};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_ISREGISTEROTHERPHONE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [self action_sendCode];
        }
    }];
}

-(void)action_sendCode{
    
    [self hlds_startTimer];
    NSDictionary *para = @{@"UserInput":self.txt_newPhone.text};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_ADDVERIFICATIONCODE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"验证码已发送" andDealy:1];
            [self.txt_code becomeFirstResponder];
        }
    }];
}

-(void)action_save{
    if (![AppGeneral isValidPhone:self.txt_newPhone.text]) {
        [AppGeneral showMessage:@"请输入正确的手机号" andDealy:1];
        [self.txt_newPhone becomeFirstResponder];
        return;
    }
    if (!self.txt_code.text||[self.txt_code.text isEqualToString:@""]) {
        [AppGeneral showMessage:@"请输入验证码" andDealy:1];
        return ;
    }
    
    NSDictionary *para = @{@"Phone":self.txt_newPhone.text,@"ValideCode":self.txt_code.text};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_EDITPHONE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"修改成功" andDealy:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

#pragma mark - 开始倒计时

-(void)hlds_startTimer{
    
    __weak typeof(self) weakSelf = self;
    __block NSInteger second = 60;
    //全局队列    默认优先级
    dispatch_queue_t quene = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //定时器模式  事件源
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quene);
    //NSEC_PER_SEC是秒，＊1是每秒
    dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), NSEC_PER_SEC * 1, 0);
    //设置响应dispatch源事件的block，在dispatch源指定的队列上运行
    dispatch_source_set_event_handler(timer, ^{
        //回调主线程，在主线程中操作UI
        dispatch_async(dispatch_get_main_queue(), ^{
            if (second >= 0) {
                weakSelf.btn_send.hidden = YES;
                weakSelf.lbl_timer.hidden = NO;
                
                self.lbl_timer.text = [NSString stringWithFormat:@"重新获取(%ld)",second];
                second--;
            }
            else
            {
                //这句话必须写否则会出问题
                dispatch_source_cancel(timer);
                weakSelf.btn_send.hidden = NO;
                weakSelf.lbl_timer.hidden = YES;
            }
        });
    });
    //启动源
    dispatch_resume(timer);
}


@end
