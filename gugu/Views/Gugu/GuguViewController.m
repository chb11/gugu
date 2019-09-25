//
//  GuguViewController.m
//  gugu
//
//  Created by Mike Chen on 2019/2/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "GuguViewController.h"
#import "SSChatController.h"
#import "ContractAddFriendController.h"
#import "CreateNewGroupController.h"
#import "CB_ScanController.h"
#import "GuguMessageCell.h"

static NSString *cellId = @"GuguMessageCell";

@interface GuguViewController ()<UITableViewDelegate,UITableViewDataSource>

/** 下拉菜单 */
@property (nonatomic, strong) FFDropDownMenuView *dropdownMenu;

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;


@end

@implementation GuguViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    [self initData];
    [self initAction];
    
    [self action_refresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(action_loadMessageFormLocal) name:NOTIFICATION_SOCKET_MESSAGE_RECEIVED object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self initData];
}

-(void)initUI{
    self.title = @"消息";
    [self.view addSubview:self.listView];

    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    [self initRightBarItem];
    /** 初始化下拉菜单 */
    [self setupDropDownMenu];
}

-(void)initRightBarItem{
    
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [mapBtn addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
    
    if (@available(iOS 9.0, *)) {
        [mapBtn setFrame:CGRectMake(0,0,24,24)];
        [mapBtn.widthAnchor constraintEqualToConstant:24].active = YES;
        [mapBtn.heightAnchor constraintEqualToConstant:24].active = YES;
    } else {
        [mapBtn setFrame:CGRectMake(0,0,24,24)];
        mapBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    [mapBtn setImage:[UIImage imageNamed:@"bar_ditu.png"] forState:UIControlStateNormal];
    UIBarButtonItem *mapItem = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    
    UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [moreBtn addTarget:self action:@selector(action_more) forControlEvents:UIControlEventTouchUpInside];
    [moreBtn setImage:[UIImage imageNamed:@"更多.png"] forState:UIControlStateNormal];
    if (@available(iOS 9.0, *)) {
        [moreBtn setFrame:CGRectMake(0,0,24,24)];
        [moreBtn.widthAnchor constraintEqualToConstant:24].active = YES;
        [moreBtn.heightAnchor constraintEqualToConstant:24].active = YES;
    } else {
        [moreBtn setFrame:CGRectMake(0,0,24,24)];
        moreBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
    }
    UIBarButtonItem *moreItem = [[UIBarButtonItem alloc] initWithCustomView:moreBtn];
    
    self.navigationItem.rightBarButtonItems  = @[moreItem,mapItem];
    
}

-(void)initData{

    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_STATE] boolValue];
    if (!isLogin) {
        return;
    }

    NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid};
    self.listView.refreshUrl = CHAT_MESSAGE_NOT_READ;
    self.listView.refreshDic = para;
    
    NSArray *items = [CB_MessageManager action_findLastedMessage];
 
    self.dataSource = items.mutableCopy;
    [self.listView reloadData];

}

-(void)action_refresh{
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] valueForKey:LOGIN_STATE] boolValue];
    if (!isLogin) {
        return;
    }
    NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_NOT_READ withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            NSArray *arr = dict[@"list"];
            self.dataSource = [self groupBySessionWith:arr].mutableCopy;
        }
    }];
}

-(void)action_loadMessageFormLocal{
    NSArray *items = [CB_MessageManager action_findLastedMessage];
    self.dataSource = items.mutableCopy;
    [self.listView reloadData];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = [weakSelf groupBySessionWith:items].mutableCopy;
    };
}

-(NSArray *)groupBySessionWith:(NSArray *)items{

    NSArray *sortedArr = [self sortedArrayFrom:items];
    for (NSDictionary *dict in sortedArr) {
        CB_MessageModel *model = [CB_MessageModel modelWithDictionary:dict];
        [CB_MessageManager action_saveAction:model];
    }
    
    NSArray *arr = [CB_MessageManager action_findLastedMessage];
    
    return arr;
}

-(NSArray *)sortedArrayFrom:(NSArray *)items{
    NSArray *newArr =  [items sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString *postdate1 = @"";
        NSString *postdate2 = @"";
        if ( [obj1 isKindOfClass:[CB_MessageModel class]]) {
            CB_MessageModel *model1 = obj1;
            postdate1 = model1.PostDate;
        }else if([obj1 isKindOfClass:[NSDictionary class]]){
            postdate1 = obj1[@"PostDate"];
        }
        if ( [obj2 isKindOfClass:[CB_MessageModel class]]) {
            CB_MessageModel *model2 = obj2;
            postdate2 = model2.PostDate;
        }else if([obj2 isKindOfClass:[NSDictionary class]]){
            postdate2 = obj2[@"PostDate"];
        }
        
        if (![AppGeneral compareDate:postdate1 andDate:postdate2]) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
        return NSOrderedSame; //降序
    }];
    return newArr;
}


- (void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource  = dataSource;
    if (dataSource.count>0) {
        self.listView.tableFooterView = [[UIView alloc] init];
    }else{
        self.listView.tableFooterView = self.hlds_view_empty;
    }
    
    NSInteger unreadCount = 0;
    for (int i = 0; i<dataSource.count; i++) {
        CB_MessageModel *model = dataSource[i];
        unreadCount += model.NoReadNum;
    }
    [AppGeneral action_updateBarItemBadgeWith:unreadCount];
    [self.listView reloadData];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    GuguMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[GuguMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    CB_MessageModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_MessageModel *model = self.dataSource[indexPath.row];
    
    SSChatController *page = [SSChatController new];
    page.chatType = SSChatConversationTypeChat;
    page.sessionId = model.SendId;
    page.SendId = model.SendId;
    page.model = model;
    page.titleString = [model.GroupName isEqualToString:@""]?model.SendName:model.GroupName;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// 定义编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

// 进入编辑模式，按下出现的编辑按钮后,进行删除操作
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        CB_MessageModel *model = self.dataSource[indexPath.row];
        [CB_MessageManager action_deleteAction:model];
        [self action_refresh];
    }
}

// 修改编辑按钮文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}

/** 初始化下拉菜单 */
- (void)setupDropDownMenu {
    NSArray *modelsArray = [self getMenuModelsArray];
    self.dropdownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray menuWidth:FFDefaultFloat eachItemHeight:FFDefaultFloat menuRightMargin:FFDefaultFloat triangleRightMargin:18];
    //如果有需要，可以设置代理（非必须）
    self.dropdownMenu.ifShouldScroll = NO;
    [self.dropdownMenu setup];
}

/** 获取菜单模型数组 */
- (NSArray *)getMenuModelsArray {
    __weak typeof(self) weakSelf = self;
    
    //菜单模型0
    FFDropDownMenuModel *menuModel0 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"发起群聊" menuItemIconName:@"发起群聊"  menuBlock:^{
        [weakSelf action_newGroup];
    }];
    
    //菜单模型1
    FFDropDownMenuModel *menuModel1 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"添加朋友" menuItemIconName:@"添加朋友" menuBlock:^{
        [weakSelf action_newFriend];
    }];
    //菜单模型1
    FFDropDownMenuModel *menuModel2 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"扫一扫" menuItemIconName:@"二维码" menuBlock:^{
        [weakSelf action_goScan];
    }];
    
    NSArray *menuModelArr = @[menuModel0, menuModel1,menuModel2];
    return menuModelArr;
}
//点击地图
-(void)mapClick{
    SSChatMapController *page = [SSChatMapController new];
    page.title = @"咕咕";
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}

-(void)action_more{
    [self.dropdownMenu showMenu];
}

-(void)action_newFriend{
    ContractAddFriendController *page = [ContractAddFriendController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_goScan{
    
    CB_ScanController *page = [CB_ScanController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_newGroup{
    CreateNewGroupController *page = [CreateNewGroupController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}

#pragma mark - 懒加载

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight-49) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 65;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _listView.separatorInset =UIEdgeInsetsMake(0, 0, 0, 0);
        _listView.mj_header.tintColor = [UIColor whiteColor];
        _listView.mj_footer = nil;
    }
    return _listView;
}
-(UIView *)hlds_view_empty{
    if (!_hlds_view_empty) {
        _hlds_view_empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _hlds_view_empty.backgroundColor = [UIColor clearColor];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, (_hlds_view_empty.height-100)/2-20, 100, 100)];
        img.image = [UIImage imageNamed:@"empty.png"];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [_hlds_view_empty addSubview:img];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, img.mj_y+img.height+10, 100, 30)];
        lbl.textColor = [UIColor colorWithHexString:@"bfbfbf"];
        lbl.text = @"暂无内容";
        lbl.textAlignment = NSTextAlignmentCenter;
        [_hlds_view_empty addSubview:lbl];
    }
    return _hlds_view_empty;
}

@end
