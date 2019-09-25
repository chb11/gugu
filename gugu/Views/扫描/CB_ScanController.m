//
//  CB_ScanController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ScanController.h"
#import "WSLScanView.h"
#import "WSLNativeScanTool.h"
#import "ContrractUserInfoController.h"
#import "MyUserInfoController.h"
#import "CB_GroupScanResultController.h"

@interface CB_ScanController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong)  WSLNativeScanTool * scanTool;
@property (nonatomic, strong)  WSLScanView * scanView;

@end

@implementation CB_ScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描二维码";
    //输出流视图
    UIView *preview  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 0)];
    [self.view addSubview:preview];
    
    __weak typeof(self) weakSelf = self;
    
    //构建扫描样式视图
    _scanView = [[WSLScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 0)];
    _scanView.scanRetangleRect = CGRectMake(60, 120, (self.view.frame.size.width - 2 * 60),  (self.view.frame.size.width - 2 * 60));
    _scanView.colorAngle = [UIColor greenColor];
    _scanView.photoframeAngleW = 20;
    _scanView.photoframeAngleH = 20;
    _scanView.photoframeLineW = 2;
    _scanView.isNeedShowRetangle = YES;
    _scanView.colorRetangleLine = [UIColor whiteColor];
    _scanView.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    _scanView.animationImage = [UIImage imageNamed:@"scanLine"];
//    _scanView.myQRCodeBlock = ^{
//        // 获取指定的Storyboard，name填写Storyboard的文件名
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        // 从Storyboard上按照identifier获取指定的界面（VC），identifier必须是唯一的
//        WSLCreateQRCodeController *createQRCodeController = [storyboard instantiateViewControllerWithIdentifier:@"createQRCode"];
//        createQRCodeController.qrImage =  [WSLNativeScanTool createQRCodeImageWithString:@"https://www.jianshu.com/u/e15d1f644bea" andSize:CGSizeMake(250, 250) andBackColor:[UIColor whiteColor] andFrontColor:[UIColor orangeColor] andCenterImage:[UIImage imageNamed:@"piao"]];
//        createQRCodeController.qrString = @"https://www.jianshu.com/u/e15d1f644bea";
//        [weakSelf.navigationController pushViewController:createQRCodeController animated:YES];
//    };
    
    _scanView.flashSwitchBlock = ^(BOOL open) {
        [weakSelf.scanTool openFlashSwitch:open];
    };
    [self.view addSubview:_scanView];
    
    //初始化扫描工具
    _scanTool = [[WSLNativeScanTool alloc] initWithPreview:preview andScanFrame:_scanView.scanRetangleRect];
    _scanTool.scanFinishedBlock = ^(NSString *scanString) {
        NSLog(@"扫描结果 %@",scanString);
        if (scanString.length==0) {
            return ;
        }
        NSDictionary *resultDict = [AppGeneral dictionaryWithJsonString:scanString];
        if (![resultDict.allKeys containsObject:@"qrType"]) {
            return;
        }
        
        NSInteger qrType = [resultDict[@"qrType"] integerValue];
        if (qrType == 2) {//群组
            [weakSelf action_goGroupWithId:resultDict[@"groupId"]];
        }
        if (qrType == 1) {//个人详情
            [weakSelf action_goUserInfoWith:resultDict[@"userId"]];
        }
        
        [weakSelf.scanTool sessionStopRunning];
        [weakSelf.scanTool openFlashSwitch:NO];
    };
    _scanTool.monitorLightBlock = ^(float brightness) {
        NSLog(@"环境光感 ： %f",brightness);
        if (brightness < 0) {
            // 环境太暗，显示闪光灯开关按钮
            [weakSelf.scanView showFlashSwitch:YES];
        }else if(brightness > 0){
            // 环境亮度可以,且闪光灯处于关闭状态时，隐藏闪光灯开关
            if(!weakSelf.scanTool.flashOpen){
                [weakSelf.scanView showFlashSwitch:NO];
            }
        }
    };
    [_scanTool sessionStartRunning];
    [_scanView startScanAnimation];
}

-(void)action_goGroupWithId:(NSString *)groupId{
    CB_GroupScanResultController *page = [CB_GroupScanResultController new];
    page.groupId = groupId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_goUserInfoWith:(NSString *)userId{
    if ([userId isEqualToString:[UserModel shareInstance].Guid]) {
        MyUserInfoController *page = [MyUserInfoController new];
        [self.navigationController pushViewController:page animated:YES];
    }else{
        ContrractUserInfoController *page = [ContrractUserInfoController new];
        CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
        friendModel.FriendId = userId;
        page.friendModel = friendModel;
        [self.navigationController pushViewController:page animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [_scanView startScanAnimation];
    [_scanTool sessionStartRunning];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [_scanView stopScanAnimation];
    [_scanView finishedHandle];
    [_scanView showFlashSwitch:NO];
    [_scanTool sessionStopRunning];
}

#pragma mark -- Events Handle
- (void)photoBtnClicked{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        UIImagePickerController * _imagePickerController = [[UIImagePickerController alloc] init];
        _imagePickerController.delegate = self;
        _imagePickerController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _imagePickerController.allowsEditing = YES;
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:_imagePickerController animated:YES completion:nil];
    }else{
        NSLog(@"不支持访问相册");
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message handler:(void (^) (UIAlertAction *action))handler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:handler];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark UIImagePickerControllerDelegate
//该代理方法仅适用于只选取图片时
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
    //    NSLog(@"选择完毕----image:%@-----info:%@",image,editingInfo);
    [self dismissViewControllerAnimated:YES completion:nil];
    [_scanTool scanImageQRCode:image];
}

@end
