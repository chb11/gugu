//
//  MineViewController.m
//  gugu
//
//  Created by Mike Chen on 2019/2/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MineViewController.h"
#import "MineItemCell.h"
#import "MineUserHeaderView.h"
#import "MyUserInfoController.h"
#import "MineSettingController.h"
#import "UrgencyContactController.h"
#import "CB_LocationManager.h"
#import "CollectionlistController.h"
#import "MineCardPagkageController.h"

static NSString *cellId = @"MineItemCell";
static CGFloat itemMargin = 15;

@interface MineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) MineUserHeaderView *headerView;
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *topView;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self action_refresh];
}

-(void)initUI{
    self.view.clipsToBounds = YES;
    [self.view addSubview:self.topView];
    [self.view addSubview:self._tableview];
    self.view.backgroundColor = [UIColor colorWithHexString:@"f8f8f8"];
    [self.topView az_setGradientBackgroundWithColors:@[COLOR_MAIN_LEFT,COLOR_MAIN_RIGHT] locations:nil startPoint:CGPointMake(0, 0) endPoint:CGPointMake(1, 0)];
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self._tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf._tableview.mj_header endRefreshing];
            [weakSelf action_refresh];
        });
    }];
    self.headerView.block_clickHeader = ^{
        [weakSelf action_seeUserInfo];
    };
    self.headerView.block_goSetting = ^{
        [weakSelf action_jumpSetting];
    };
}

-(void)initData{
    
}

-(void)action_refresh{
    
    BOOL islogin = [[[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_STATE] boolValue];
    if (islogin) {
        NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USERMODEL];
        [[UserModel shareInstance] reloadModelWith: [UserModel modelWithDictionary:dict]];
        NSString *Guid = [UserModel shareInstance].Guid;
        [[NetWorkConnect manager] postDataWith:@{} withUrl:V_USER_CURRENTUSER withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                UserModel *model= [UserModel modelWithDictionary:responseObject];
                [[UserModel shareInstance] reloadModelWith:model];
                [[NSUserDefaults standardUserDefaults] setObject:[model dictionaryRepresentation] forKey:LOGIN_USERMODEL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.headerView.model = model;
                });
            }
        }];
    }else{
        self.headerView.model = nil;
    }
}

-(void)action_seeUserInfo{
    MyUserInfoController *userControl = [MyUserInfoController new];
    userControl.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userControl animated:YES];
}

-(void)action_baojing{
    __weak typeof(self) weakSelf = self;
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        if (formattedAddress.length==0) {
            [AppGeneral showMessage:@"获取位置失败" andDealy:1];
            return ;
        }
        NSDictionary *dic = @{@"AddressName":formattedAddress,@"Lat":@(location.coordinate.latitude),@"Lng":@(location.coordinate.longitude)};
        [weakSelf action_baojingOnNetWithDict:dic];
    }];
}

-(void)action_baojingOnNetWithDict:(NSDictionary *)para{
    
    [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_CALL_POLICE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"报警成功" andDealy:1];
        }
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MineItemCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[MineItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    cell.v_switch.hidden = YES;
    NSArray *arr = self.dataSource[indexPath.section];
    NSDictionary *dict = arr[indexPath.row];
    NSString *title = dict[@"title"];
    if ([title containsString:@"报警"]) {
        cell.accessoryType =UITableViewCellAccessoryNone;
    }else{
         cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.lbl_title.text = title;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return itemMargin;//section头部高度
}

//section头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, itemMargin)];
    view.backgroundColor = [UIColor clearColor];
    return view ;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

//section底部视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataSource[indexPath.section];
    NSDictionary *dict = arr[indexPath.row];
    NSString *title = dict[@"title"];
    if ([title containsString:@"设置"]) {
        [self action_jumpSetting];
    }
    if ([title containsString:@"报警"]) {
        [self action_baojing];
    }
    if ([title containsString:@"紧急联系人"]) {
        [self action_jumpContact];
    }
    if ([title containsString:@"收藏"]) {
        [self action_goCollection];
    }
    if ([title containsString:@"卡包"]) {
        [self action_myCardPackage];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat offsety = scrollView.contentOffset.y;
    if (offsety>0) {
        return;
    }
    NSLog(@"%.2f",offsety);
    CGFloat scale = (self.headerView.height-offsety*2)/self.headerView.height;
    NSLog(@"缩放 %.2f",scale);
    self.topView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, scale);
}

//我的卡包
-(void)action_myCardPackage{
    MineCardPagkageController *page = [MineCardPagkageController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_goCollection{
    CollectionlistController *page = [CollectionlistController new];
    page.sendUserId = [UserModel shareInstance].Guid;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_jumpSetting{
    MineSettingController *page = [MineSettingController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_jumpContact{
    UrgencyContactController *page = [UrgencyContactController new];
    page.isUrgencyList = YES;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

#pragma mark - 懒加载
-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-50-BottomPadding) style:UITableViewStyleGrouped];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.rowHeight = 50;
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        __tableview.tableHeaderView = self.headerView;
    }
    return __tableview;
}

-(MineUserHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"MineUserHeaderView" owner:self options:nil] lastObject];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 250);
    }
    return _headerView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.headerView.height)];
        _topView.backgroundColor = COLOR_APP_MAIN;
    }
    return _topView;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@[@{@"img":@"操作指南.png",@"title":@"我的收藏"},
                          @{@"img":@"操作指南.png",@"title":@"我的卡包"}
                          ],
                        @[@{@"img":@"操作指南.png",@"title":@"报警（求助信号）"},
                          @{@"img":@"操作指南.png",@"title":@"紧急联系人"}
                          ],
                        ].mutableCopy;
    }
    return _dataSource;
}

@end
