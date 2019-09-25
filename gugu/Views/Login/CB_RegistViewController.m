//
//  CB_RegistViewController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/1.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_RegistViewController.h"

@interface CB_RegistViewController ()

@property (nonatomic,strong) ZYKeyboardUtil *keybordUtil;

@property (weak, nonatomic) IBOutlet UIView *view_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toTOp;
@property (weak, nonatomic) IBOutlet UIButton *btn_back;

@property (weak, nonatomic) IBOutlet UITextField *txt_phone;
@property (weak, nonatomic) IBOutlet UITextField *txt_code;
@property (weak, nonatomic) IBOutlet UITextField *txt_pwd;
@property (weak, nonatomic) IBOutlet UITextField *txt_repwd;

@property (weak, nonatomic) IBOutlet UIButton *btn_register;

@property (weak, nonatomic) IBOutlet UIButton *btn_send;
@property (weak, nonatomic) IBOutlet UILabel *lbl_timer;
@property (weak, nonatomic) IBOutlet UILabel *lbl_title;


@property (nonatomic,strong) NSString *currCode;


@end

@implementation CB_RegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initAction];
}

-(void)initUI{
    [self.view_top az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.btn_register az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"f8f8f8"],[UIColor colorWithHexString:@"f8f8f8"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    self.btn_register.userInteractionEnabled = NO;
    [self.btn_register addlayerRadius:self.btn_register.height/2];
    self.constrain_toTOp.constant = StatusBarHeight + 10;
        self.btn_back.imageEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
    
    if (self.submitType == SUBMIT_TYPE_REGIST) {
        self.lbl_title.text = @"注册";
        [self.btn_register setTitle:@"注册" forState:UIControlStateNormal];
    }
    if (self.submitType == SUBMIT_TYPE_FORGETPWD) {
        self.lbl_title.text = @"找回密码";
        [self.btn_register setTitle:@"提交" forState:UIControlStateNormal];
    }
    
    self.keybordUtil = [[ZYKeyboardUtil alloc] initWithKeyboardTopMargin:10];
    __weak typeof(self) weakSelf = self;
#pragma explain - 全自动键盘弹出/收起处理 (需调用keyboardUtil 的 adaptiveViewHandleWithController:adaptiveView:)
#pragma explain - use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearAutomaticAnimBlock will be invalid.
    [self.keybordUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.txt_phone,weakSelf.txt_pwd,weakSelf.txt_pwd,weakSelf.txt_repwd, nil];
    }];
}

-(void)initAction{
    [self.txt_code addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txt_phone addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txt_pwd addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txt_repwd addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tap];
}

-(void)textFieldTextChange:(UITextField *)textField{
    
    BOOL isValud = YES;
    if (![AppGeneral isValidPhone:self.txt_phone.text]) {
        isValud = NO;
    }
    if (!self.txt_code.text||[self.txt_code.text isEqualToString:@""]) {
        isValud = NO;
    }
    if (![AppGeneral isValidPassWord:self.txt_pwd.text]) {
        isValud = NO;
    }
    if (![self.txt_pwd.text isEqualToString:self.txt_repwd.text]) {
        isValud = NO;
    }
    if (isValud) {
        [self.btn_register az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
        self.btn_register.userInteractionEnabled = YES;
    }else{
        [self.btn_register az_setGradientBackgroundWithColors:@[[UIColor colorWithHexString:@"f8f8f8"],[UIColor colorWithHexString:@"f8f8f8"]] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
        self.btn_register.userInteractionEnabled = NO;
    }
}

- (IBAction)action_sendCode:(UIButton *)sender {
    
    if (![AppGeneral isValidPhone:self.txt_phone.text]) {
        [AppGeneral showMessage:@"请输入正确的手机号" andDealy:1];
        return;
    }
    
    [self hlds_startTimer];
    
    NSDictionary *para = @{@"UserInput":self.txt_phone.text};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_ADDVERIFICATIONCODE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"验证码已发送" andDealy:1];
            [self.txt_code becomeFirstResponder];
        }
    }];
}

- (IBAction)action_register:(UIButton *)sender {
    if (![AppGeneral isValidPhone:self.txt_phone.text]) {
        [AppGeneral showMessage:@"请输入正确的手机号" andDealy:1];
        return;
    }
    if (!self.txt_code.text||[self.txt_code.text isEqualToString:@""]) {
        [AppGeneral showMessage:@"请输入验证码" andDealy:1];
        return ;
    }
    if (![AppGeneral isValidPassWord:self.txt_pwd.text]) {
        [AppGeneral showMessage:@"密码为6-16位，数字字母或符号" andDealy:1];
        return;
    }
    if (![self.txt_pwd.text isEqualToString:self.txt_repwd.text]) {
        [AppGeneral showMessage:@"两次密码不一致" andDealy:1];
        return;
    }
    
    [[NetWorkConnect manager] postDataWith:@{} withUrl:V_GETPUBLICKEY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        
        if (resultCode == 1) {
            NSString *publicKey = responseObject[@"PublicKey"];
            
            NSDictionary *para = @{@"ValideCode":self.txt_code.text,
                                   @"UserName":self.txt_phone.text,
                                   @"Password":[self.txt_pwd.text RSAEncrypt:publicKey]
                                   };
            
            NSString *url = V_USER_REGISTER;
            if (self.submitType == SUBMIT_TYPE_FORGETPWD) {
                url = V_USER_FINDPASSWORD;
            }
            
            [[NetWorkConnect manager] postDataWith:para withUrl:url withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
                if (resultCode == 1) {
                    UserModel *mdel = [UserModel modelWithDictionary:responseObject];
                    mdel.Password = self.txt_pwd.text;
                    [[UserModel shareInstance] reloadModelWith:mdel];
                    [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:LOGIN_USERMODEL];
                    [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:LOGIN_STATE];
                    
                    if (self.submitType == SUBMIT_TYPE_REGIST) {
                        [AppGeneral showMessage:@"注册成功" andDealy:1];
                        [self.navigationController dismissViewControllerAnimated:NO completion:nil];
                    }else if (self.submitType == SUBMIT_TYPE_FORGETPWD) {
                        [AppGeneral showMessage:@"密码修改成功" andDealy:1];
                        [self.navigationController popViewControllerAnimated:NO];
                    }
                }
            }];
        }
    }];
}

-(void)closeKeyboard{
    [self.txt_code resignFirstResponder];
    [self.txt_phone resignFirstResponder];
    [self.txt_pwd resignFirstResponder];
    [self.txt_repwd resignFirstResponder];
}

- (IBAction)action_back:(UIButton *)sender {
    [self closeKeyboard];
     [self.navigationController popViewControllerAnimated:YES];
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
