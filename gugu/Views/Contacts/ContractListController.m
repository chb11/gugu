//
//  ContractListController.m
//  gugu
//  通讯录
//  Created by Mike Chen on 2019/2/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractListController.h"
#import "CB_UserContactCell.h"
#import "ContractListHeader.h"
#import "SearchContractController.h"
#import "ContrractUserInfoController.h"
#import "ContractNewFriendsController.h"
#import "MyGroupController.h"
#import "CreateNewGroupController.h"
#import "ContractAddFriendController.h"

static NSString *cellId = @"CB_UserContactCell";

@interface ContractListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) ContractListHeader *header;
@property (nonatomic,strong) NSString *searchStr;

/** 下拉菜单 */
//@property (nonatomic, strong) FFDropDownMenuView *dropdownMenu;

@end

@implementation ContractListController

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
    self.title = @"通讯录";
    [self.view addSubview:self.listView];
   
//    [self initRightBarItem];
    /** 初始化下拉菜单 */
//    [self setupDropDownMenu];
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
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
    NSDictionary *para = @{@"KeyWord":@"%"};
    self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
    self.listView.refreshDic = para;
    self.searchStr = @"";
    [self action_refresh];
}

-(void)action_refresh{
    NSString *searchStr = @"%";
    searchStr = [searchStr stringByAppendingString:self.searchStr];
    NSDictionary *para = @{@"KeyWord":searchStr};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_ALL_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            NSArray *arr = dict[@"list"];
            self.dataSource = arr.mutableCopy;
        }
    }];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = items.mutableCopy;
        [weakSelf.listView reloadData];
    };
    
    self.header.block_search = ^{
        [weakSelf action_go_search];
    };
    self.header.block_new_friend = ^{
        [weakSelf action_go_newFriend];
    };
    self.header.block_my_group = ^{
        [weakSelf action_go_myGroup];
    };
}


-(void)action_loadMoreWith:(NSArray *)items{
    if (items.count>0) {
        NSMutableArray *m_arr = self.dataSource;
        [m_arr addObjectsFromArray:items];
        self.dataSource = m_arr;
    }
}

- (void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource  = dataSource;
    if (dataSource.count>0) {
        self.listView.tableFooterView = [[UIView alloc] init];
    }else{
        self.listView.tableFooterView = self.hlds_view_empty;
    }
    
    [self.listView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_UserContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_UserContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    cell.lbl_name.text = model.FriendUserName;
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];

    ContrractUserInfoController *page = [ContrractUserInfoController new];
    page.friendModel = model;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}

-(void)action_go_search{
    SearchContractController *page = [SearchContractController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:NO];
}

-(void)action_go_newFriend{
    ContractNewFriendsController *page = [ContractNewFriendsController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_go_myGroup{
    MyGroupController *page = [MyGroupController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

///** 初始化下拉菜单 */
//- (void)setupDropDownMenu {
//    NSArray *modelsArray = [self getMenuModelsArray];
//    self.dropdownMenu = [FFDropDownMenuView ff_DefaultStyleDropDownMenuWithMenuModelsArray:modelsArray menuWidth:FFDefaultFloat eachItemHeight:FFDefaultFloat menuRightMargin:FFDefaultFloat triangleRightMargin:18];
//    //如果有需要，可以设置代理（非必须）
//    self.dropdownMenu.ifShouldScroll = NO;
//    [self.dropdownMenu setup];
//}
//
///** 获取菜单模型数组 */
//- (NSArray *)getMenuModelsArray {
//    __weak typeof(self) weakSelf = self;
//
//    //菜单模型0
//    FFDropDownMenuModel *menuModel0 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"发起群聊" menuItemIconName:@"发起群聊"  menuBlock:^{
//        [weakSelf action_newGroup];
//    }];
//
//    //菜单模型1
//    FFDropDownMenuModel *menuModel1 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"添加朋友" menuItemIconName:@"添加朋友" menuBlock:^{
//        [weakSelf action_newFriend];
//    }];
//    //菜单模型1
//    FFDropDownMenuModel *menuModel2 = [FFDropDownMenuModel ff_DropDownMenuModelWithMenuItemTitle:@"扫一扫" menuItemIconName:@"二维码" menuBlock:^{
//        //        [weakSelf action_newFriend];
//    }];
//
//    NSArray *menuModelArr = @[menuModel0, menuModel1,menuModel2];
//    return menuModelArr;
//}
//
//-(void)action_more{
//    [self.dropdownMenu showMenu];
//}

-(void)action_newFriend{
    ContractAddFriendController *page = [ContractAddFriendController new];
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
        _listView.rowHeight = 80;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.tableHeaderView = self.header;
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

-(ContractListHeader *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"ContractListHeader" owner:self options:nil] firstObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 110);
    }
    return _header;
}

@end
