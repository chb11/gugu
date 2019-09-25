//
//  MineSettingController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MineSettingController.h"
#import "MineItemCell.h"

static NSString *cellId = @"MineItemCell";

@interface MineSettingController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UIButton *btn_logout;

@property (nonatomic,assign) BOOL isNoti;

@end

@implementation MineSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_check) name:NOTIFICATION_CHECK_SOCKET_STATE object:nil];
    [self initUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self action_check];
}

-(void)action_check{
    self.isNoti = YES;
    if (@available(iOS 10 , *))
    {
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            
            if (settings.authorizationStatus == UNAuthorizationStatusDenied)
            {
                // 没权限
                self.isNoti = NO;
                [self._tableview reloadData];
            }
            
        }];
    }
    else if (@available(iOS 8 , *))
    {
        UIUserNotificationSettings * setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        
        if (setting.types == UIUserNotificationTypeNone) {
            // 没权限
            self.isNoti = NO;
            [self._tableview reloadData];
        }
    }
    else
    {
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if (type == UIUserNotificationTypeNone)
        {
            self.isNoti = NO;
            [self._tableview reloadData];
        }
    }
    
}

-(void)initUI{
    self.title = @"设置";
    self.view.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
    [self.view addSubview:self._tableview];
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[MineItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.v_switch.hidden = YES;
    NSDictionary *dict = self.dataSource[indexPath.row];;
    NSString *title = dict[@"title"];
    NSString *imgName = dict[@"img"];
    cell.lbl_title.text = title;
    cell.img_left.image = [UIImage imageNamed:imgName];
    
    if ([title isEqualToString:@"消息提醒"]) {
        cell.v_switch.hidden = NO;
        [cell.v_switch setOn:self.isNoti animated:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else if ([title isEqualToString:@"清除缓存"]) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.lbl_subtitle.hidden = NO;
        
        NSInteger size = [[SDImageCache sharedImageCache] getSize];
        NSString *str = @"0KB";
        if (size>0) {
           str =[NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
        }
        cell.lbl_subtitle.text = str;
        
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.lbl_subtitle.hidden = YES;
    }
    
    __weak typeof(self) weakSelf = self;
    cell.block_switch = ^{
        [weakSelf action_goSetting];
    };
    
    return cell;
}

-(void)action_goSetting{
    
    [AppGeneral action_showAlertWithTitle:@"前往[设置]-[咕咕]中设置" andConfirmBlock:^{
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] openURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];;
    NSString *title = dict[@"title"];
    if ([title isEqualToString:@"关于"]) {
        
    }
    if ([title isEqualToString:@"版本"]) {
        
    }
    if ([title isEqualToString:@"清除缓存"]) {
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            [AppGeneral showMessage:@"清除成功" andDealy:1];
            [self._tableview reloadData];
        }];
    }
    
}

#pragma mark - 懒加载
-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50-BottomPadding) style:UITableViewStyleGrouped];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        footer.backgroundColor = [UIColor clearColor];
        [footer addSubview:self.btn_logout];
        __tableview.tableFooterView = footer;
    }
    return __tableview;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@{@"title":@"消息提醒",@"img":@"关于.png"},
//                        @{@"title":@"关于",@"img":@"关于.png"},
//                        @{@"title":@"版本",@"img":@"版本.png"},
                        @{@"title":@"清除缓存",@"img":@"清楚缓存.png"}].mutableCopy;
    }
    return _dataSource;
}

-(void)action_logout{
    [[NetWorkConnect manager] postDataWith:@{} withUrl:V_USER_LOGOUT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode ==1) {
            [AppGeneral showMessage:@"退出成功" andDealy:1];
            [NetWorkConnect clearCookies];
            [[UserModel shareInstance] reloadModelWith:nil];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:LOGIN_PSW];
            [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:LOGIN_STATE];
            [[NSUserDefaults standardUserDefaults] setValue:nil forKey:LOGIN_USERMODEL];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

-(UIButton *)btn_logout{
    if (!_btn_logout) {
        _btn_logout = [[UIButton alloc] initWithFrame:CGRectMake(30, 30, SCREEN_WIDTH-60, 40)];
        [_btn_logout setTitle:@"退出当前帐号" forState:UIControlStateNormal];
        _btn_logout.backgroundColor = COLOR_APP_MAIN;
        [_btn_logout addTarget:self action:@selector(action_logout) forControlEvents:UIControlEventTouchUpInside];
        [_btn_logout addlayerRadius:_btn_logout.height/2];
    }
    return _btn_logout;
}

@end
