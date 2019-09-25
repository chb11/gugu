//
//  MyUserInfoController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MyUserInfoController.h"
#import "MyUserInfocell.h"
#import "PerMissonManager.h"
#import "UpdateNickNameController.h"
#import "UpdatePwdController.h"
#import "UpdatePhoneController.h"
#import "CB_MyAddressController.h"
#import "MyQrController.h"

static NSString *cellId = @"MyUserInfocell";

@interface MyUserInfoController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
}
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic, weak) UIImagePickerController * imgPicker;

@end

@implementation MyUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self action_refresh];
}

-(void)initUI{
    self.title = @"个人资料";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self._tableview];
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initData{
    
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self._tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf._tableview.mj_header endRefreshing];
            [weakSelf action_refresh];
        });
    }];
}

-(void)action_refresh{
    [[NetWorkConnect manager] postDataWith:@{} withUrl:V_USER_CURRENTUSER withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            UserModel *model= [UserModel modelWithDictionary:responseObject];
            [[UserModel shareInstance] reloadModelWith:model];
            [[NSUserDefaults standardUserDefaults] setObject:[model dictionaryRepresentation] forKey:LOGIN_USERMODEL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self._tableview reloadData];
            });
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.dataSource[indexPath.row];
    if ([title isEqualToString:@"头像"]) {
        return 80;
    }
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MyUserInfocell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[MyUserInfocell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSString *title = self.dataSource[indexPath.row];
    cell.lbl_title.text = title;
    if ([title isEqualToString:@"头像"]) {
        cell.lbl_subtitle.hidden = YES;
        cell.img_header.hidden = NO;
        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:[UserModel shareInstance].HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    }else{
        cell.img_header.hidden = YES;
        cell.lbl_subtitle.hidden = NO;
        cell.lbl_subtitle.text = @"";
        if ([title isEqualToString:@"昵称"]) {
            cell.lbl_subtitle.text = [UserModel shareInstance].UserName;
        }
        if ([title isEqualToString:@"咕咕号"]) {
            cell.lbl_subtitle.text = [UserModel shareInstance].GuNum;
        }
        if ([title isEqualToString:@"手机号码"]) {
            NSString *showNum = [[UserModel shareInstance].Phone stringByReplacingCharactersInRange:NSMakeRange(3, 5) withString:@"*****"];
            cell.lbl_subtitle.text = showNum;
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *title = self.dataSource[indexPath.row];
    if ([title isEqualToString:@"头像"]) {
        [self action_choosePhoto];
    }
    if ([title isEqualToString:@"昵称"]) {
        UpdateNickNameController *page = [UpdateNickNameController new];
        page.updateType = USERINFO_UPDATETYPE_NICKNAME;
        [self.navigationController pushViewController:page animated:YES];
    }
    if ([title isEqualToString:@"咕咕号"]) {
        UpdateNickNameController *page = [UpdateNickNameController new];
        page.updateType = USERINFO_UPDATETYPE_GUNUM;
        [self.navigationController pushViewController:page animated:YES];
    }
    if ([title containsString:@"登录密码"]) {
        UpdatePwdController *page = [UpdatePwdController new];
        [self.navigationController pushViewController:page animated:YES];
    }
    if ([title isEqualToString:@"手机号码"]) {
        UpdatePhoneController *page = [UpdatePhoneController new];
        [self.navigationController pushViewController:page animated:YES];
    }
    if ([title isEqualToString:@"名片"]) {
        MyQrController *page = [MyQrController new];
        [self.navigationController pushViewController:page animated:YES];
    }
    if ([title isEqualToString:@"地址"]) {
        CB_MyAddressController *page = [CB_MyAddressController new];
        [self.navigationController pushViewController:page animated:YES];
    }
}

#pragma mark - 懒加载
-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50-BottomPadding) style:UITableViewStylePlain];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        
    }
    return __tableview;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@"头像",@"昵称",@"咕咕号",@"修改登录密码",@"手机号码",@"名片",@"地址"].mutableCopy;
    }
    return _dataSource;
}

#pragma mark - 修改地址
-(void)action_updateAddress{
    
}

#pragma mark - 修改头像
-(void)action_choosePhoto{
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"使用相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf presentCameraSingle];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"选择图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        [weakSelf presentPhotoPickerViewController];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];

}

-(void)presentCameraSingle
{
    if ([PerMissonManager isOpenCamera]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIImagePickerController*  _picker = [[UIImagePickerController alloc] init] ;
            _picker.delegate = self;
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            _picker.allowsEditing = YES ;
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
            self.imgPicker = _picker;
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
            {
                __weak typeof(self) weakSelf = self;
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakSelf presentViewController:_picker animated:YES completion:^{
                        
                    }];
                }];
                
            }else {
                [self presentViewController:_picker animated:YES completion:^{
                    
                }];
            }
        }
    }
    
}

-(void)presentPhotoPickerViewController
{
    if ([PerMissonManager isOpenAlbum]) {
        
        UIImagePickerController*  _picker = [[UIImagePickerController alloc] init] ;
        _picker.delegate = self;
        _picker.allowsEditing = YES;
        _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            __weak typeof(self) weakSelf = self;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [weakSelf presentViewController:_picker animated:YES completion:^{
                    
                }];
            }];
        }else {
            [self presentViewController:_picker animated:YES completion:^{
                
            }];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    UIImage *yourImage;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
        yourImage=[UIImage imageWithData:UIImageJPEGRepresentation(image, 0.6)];
        [self action_uploadImage:yourImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)action_uploadImage:(UIImage *)image{
    NSData  * data = UIImageJPEGRepresentation(image, 0.4);
    
    NSDictionary *para = @{@"Guid":[UserModel shareInstance].Guid};
    [[NetWorkConnect manager] postImageWith:data postDataWith:para withUrl:V_USER_UPLOADHEADPHOTO withFileName:@"Photo" withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [self._tableview reloadData];
        }
    }];
//    [[NetWorkConnect manager] postImageWith:data postDataWith:[NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"image_type",[NSNumber numberWithInteger:_makeKind],@"make_kind", nil] withUrl:NET_UPLOADHEADIMAGE withFileName:@"file" withResult:^(NSInteger returnCode,id responseObject, NSError *error) {
//        [HYActivityIndicator stopActivityAnimation];
//        if ([responseObject[@"result"] integerValue]==1) {
//            [self savePersonInfoWithKey:@"头像" AndValue:responseObject[@"value" ] OtherValue:responseObject[@"path"]];
//        }
//    }];
}


@end
