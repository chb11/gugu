//
//  UpdateNickNameController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "UpdateNickNameController.h"

@interface UpdateNickNameController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constrain_toTop;

@property (weak, nonatomic) IBOutlet UITextField *txt_field;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ziCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_brief;

@end

@implementation UpdateNickNameController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

-(void)initUI{
    self.constrain_toTop.constant = 10;
    [self addItemWithTitle:@"保存" imageName:@"" selector:@selector(action_save) left:NO];
    [self.txt_field addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    self.txt_field.delegate = self;
    
    if (self.updateType == USERINFO_UPDATETYPE_NICKNAME) {
        self.lbl_ziCount.text = [NSString stringWithFormat:@"%lu/20",20-(unsigned long)[UserModel shareInstance].UserName.length];
        self.title = @"修改昵称";
        self.lbl_brief.hidden = YES;
        self.txt_field.text =[UserModel shareInstance].UserName;
    }else{
        self.lbl_ziCount.text = [NSString stringWithFormat:@"%lu/20",20-(unsigned long)[UserModel shareInstance].GuNum.length];
        self.title = @"修改咕咕号";
        self.lbl_brief.hidden = NO;
        self.txt_field.text =[UserModel shareInstance].GuNum;
    }
}

-(void)action_save{
    if ( !self.txt_field.text|| [self.txt_field.text isEqualToString:@""]) {
        if (self.updateType == USERINFO_UPDATETYPE_NICKNAME) {
            [AppGeneral showMessage:@"请输入昵称" andDealy:1];
        }
        if (self.updateType == USERINFO_UPDATETYPE_GUNUM) {
            [AppGeneral showMessage:@"请输入咕咕号" andDealy:1];
        }
        [self.txt_field becomeFirstResponder];
        return;
    }
    
    if (self.updateType == USERINFO_UPDATETYPE_GUNUM) {
        //咕咕号 是否为1-20位的字母和数字
        if (![AppGeneral inputShouldLetterOrNum:self.txt_field.text]) {
            [AppGeneral showMessage:@"请输入1-20位的字母和数字" andDealy:1];
            return;
        }
        
    }
    
    if (self.updateType == USERINFO_UPDATETYPE_NICKNAME) {
        [self action_submit];
    }
    if (self.updateType == USERINFO_UPDATETYPE_GUNUM) {
        [self action_validguNum];
    }
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; {
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if (self.txt_field.text.length>=20) {
        return NO;
    }
    if ([AppGeneral isContainsTwoEmoji:string]) {
        return NO;
    }
    return YES;
}

-(void)textFieldTextChange:(UITextField *)textField{
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            self.lbl_ziCount.text = [NSString stringWithFormat:@"%d/20",@(20-self.txt_field.text.length).intValue];
        }
        // 有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        self.lbl_ziCount.text = [NSString stringWithFormat:@"%d/20",@(20-self.txt_field.text.length).intValue];
    }
    
  
    
    
}

-(void)action_validguNum{
    NSDictionary *para = @{@"GuNum":self.txt_field.text};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_GUGU_ONLY withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [self action_submit];
        }
    }];
}

-(void)action_submit{
    NSString *url = @"";
    NSMutableDictionary *para = @{@"Guid":[UserModel shareInstance].Guid}.mutableCopy;
    if (self.updateType == USERINFO_UPDATETYPE_NICKNAME) {
        url = V_USER_EDITUSERNAME;
        [para setValue:self.txt_field.text forKey:@"UserName"];
    }
    if (self.updateType == USERINFO_UPDATETYPE_GUNUM) {
        
        
        url = V_USER_EDITGUNUM;
        [para setValue:self.txt_field.text forKey:@"GuNum"];
    }
    [[NetWorkConnect manager] postDataWith:para withUrl:url withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"修改成功" andDealy:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
