//
//  CB_LoginViewController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/1.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_LoginViewController.h"
#import "CB_RegistViewController.h"
#import "CB_ForgetPwdViewController.h"
#import "AgreementViewController.h"

static CB_LoginViewController * shareLogIn;

@interface CB_LoginViewController ()

@property (nonatomic,strong) ZYKeyboardUtil *keybordUtil;

@property (weak, nonatomic) IBOutlet UIView *view_top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toTOp;
@property (weak, nonatomic) IBOutlet UITextField *txt_phone;
@property (weak, nonatomic) IBOutlet UITextField *txt_pwd;
@property (weak, nonatomic) IBOutlet UIButton *btn_login;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toBottom;

@end

@implementation CB_LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self initUI];
    [self initAction];
}

-(void)initUI{
    [self.view_top az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    self.constrain_toTOp.constant = StatusBarHeight + 30;
    [self.btn_login az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    [self.btn_login addlayerRadius:self.btn_login.height/2];
    self.constrain_toBottom.constant = BottomPadding+40;
}

-(void)initAction{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    self.keybordUtil = [[ZYKeyboardUtil alloc] initWithKeyboardTopMargin:10];
    __weak typeof(self) weakSelf = self;
#pragma explain - 全自动键盘弹出/收起处理 (需调用keyboardUtil 的 adaptiveViewHandleWithController:adaptiveView:)
#pragma explain - use animateWhenKeyboardAppearBlock, animateWhenKeyboardAppearAutomaticAnimBlock will be invalid.
    [self.keybordUtil setAnimateWhenKeyboardAppearAutomaticAnimBlock:^(ZYKeyboardUtil *keyboardUtil) {
        [keyboardUtil adaptiveViewHandleWithController:weakSelf adaptiveView:weakSelf.txt_phone,weakSelf.txt_pwd, nil];
    }];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}


//是否已经登录校验
+(void)LogInStateCheckWithCtrl:(UIViewController *)viewCtr LogInSucess:(LogInState)logState
{
    BOOL isNeed= (![[[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_STATE] boolValue]);
    
    [CB_LoginViewController shareInstance].logState = logState;
    if (isNeed) {
        [CB_LoginViewController action_showLogin];
    }else {
        NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USERMODEL];
        if (!userDict) {
            [CB_LoginViewController action_showLogin];
            [SVProgressHUD showErrorWithStatus:@"身份信息失效，请重新登录"];
            [SVProgressHUD dismissWithDelay:1];
            return;
        }
        UserModel *model = [UserModel modelWithDictionary:userDict];
        [[UserModel shareInstance] reloadModelWith:model];
        [[NetWorkConnect manager] postDataWith:@{} withUrl:V_USER_CURRENTUSER withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                if ([responseObject allKeys].count>0) {
                    UserModel *mdel = [UserModel modelWithDictionary:responseObject];
                    mdel.Password = model.Password;
                    [[UserModel shareInstance] reloadModelWith:mdel];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (shareLogIn.logState) {
                            shareLogIn.logState(YES);
                        }
                    });
                    [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:LOGIN_USERMODEL];
                }else{
                    [CB_LoginViewController action_showLogin];
                    [SVProgressHUD showErrorWithStatus:@"身份信息失效，请重新登录"];
                    [SVProgressHUD dismissWithDelay:1];
                }
            }
        }];
    }
}

+(void)action_showLogin{
    if ([[AppGeneral getPresentedViewController] isKindOfClass:[CB_LoginViewController class]]) {
        return;
    }
    CB_LoginViewController * ctrl = [[CB_LoginViewController alloc]init];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:ctrl];
    [nav.navigationBar setHidden:YES];
    [[AppGeneral getPresentedViewController] presentViewController:nav animated:YES completion:nil];
    
}

-(void)close{
    [self action_back:nil];
}

//返回
- (IBAction)action_back:(UIButton *)sender {
    [self closeKeyboard];
    [self.navigationController dismissViewControllerAnimated:NO completion:nil];
}

//注册
- (IBAction)action_register:(UIButton *)sender {
    [self closeKeyboard];
    CB_RegistViewController *regist = [CB_RegistViewController new];
    regist.submitType = SUBMIT_TYPE_REGIST;
    [self.navigationController pushViewController:regist animated:YES];
}

//忘记密码
- (IBAction)action_findpwd:(UIButton *)sender {
    [self closeKeyboard];
    CB_RegistViewController *regist = [CB_RegistViewController new];
    regist.submitType = SUBMIT_TYPE_FORGETPWD;
    [self.navigationController pushViewController:regist animated:YES];
}

//登录
- (IBAction)action_login:(UIButton *)sender {
    if (![AppGeneral isValidPhone:self.txt_phone.text]) {
        [AppGeneral showMessage:@"请输入正确的手机号" andDealy:1.5];
        return;
    }

    if (![AppGeneral isValidPassWord:self.txt_pwd.text]) {
        [AppGeneral showMessage:@"密码为6-16位，数字字母或符号" andDealy:1.5];
        return;
    }
    [self closeKeyboard];
    
    [self action_login];
}
- (IBAction)action_agreement:(id)sender {
    AgreementViewController *page = [AgreementViewController new];
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_login{
    [[NetWorkConnect manager] postDataWith:@{} withUrl:V_GETPUBLICKEY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSString *publicKey = responseObject[@"PublicKey"];
            
            NSDictionary *para = @{@"UserName":self.txt_phone.text,@"Password":[self.txt_pwd.text RSAEncrypt:publicKey]};
            [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_LOGIN withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
                if (resultCode == 1) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UserModel *mdel = [UserModel modelWithDictionary:responseObject];
                        mdel.Password = self.txt_pwd.text;
                        [[UserModel shareInstance] reloadModelWith:mdel];
                        [AppGeneral showMessage:@"登录成功" andDealy:1];
                        [CB_MessageManager action_initTable];
                        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:LOGIN_USERMODEL];
                        [[NSUserDefaults standardUserDefaults] setObject:self.txt_pwd.text forKey:LOGIN_PSW];
                        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:LOGIN_STATE];
                        [self close];
                    });
                    
                }
            }];
        }
    }];
}

-(void)closeKeyboard{
    [self.txt_pwd resignFirstResponder];
    [self.txt_phone resignFirstResponder];
}

//唯一 指示框
+ (CB_LoginViewController *)shareInstance
{
    if (shareLogIn==nil) {
        shareLogIn = [[CB_LoginViewController alloc]init];
    }
    return shareLogIn;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter ] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
