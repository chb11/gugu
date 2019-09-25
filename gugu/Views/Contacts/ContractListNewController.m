//
//  ContractListNewController.m
//  gugu
//
//  Created by Mike Chen on 2019/4/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractListNewController.h"
#import "SearchContractController.h"
#import "ContrractUserInfoController.h"
#import "ContractNewFriendsController.h"
#import "MyGroupController.h"
#import "CreateNewGroupController.h"
#import "ContractAddFriendController.h"
#import "CB_UserContactCell.h"
#import "SSChatMapController.h"
#import "CB_ContractnewHeader.h"

static NSString *cellId = @"CB_UserContactCell";

@interface ContractListNewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;

@property (nonatomic,strong) NSMutableArray *sectionArray;

@property (nonatomic, strong) NSMutableArray *sectionTitlesArray;

@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) NSString *searchStr;

@property (nonatomic,strong) CB_ContractnewHeader *header;

/** 下拉菜单 */
@property (nonatomic, strong) FFDropDownMenuView *dropdownMenu;

@end

@implementation ContractListNewController

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)initUI{
    self.title = @"通讯录";
    [self.view addSubview:self.listView];
    
//    [self initRightBarItem];
//    /** 初始化下拉菜单 */
//    [self setupDropDownMenu];
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
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

//点击地图
-(void)mapClick{
    SSChatMapController *page = [SSChatMapController new];
    page.title = @"咕咕";
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = items.mutableCopy;
        [weakSelf.listView reloadData];
    };
    self.header.block_addFriend = ^{
        [weakSelf action_newFriend];
    };
    
    self.header.block_search = ^{
        [weakSelf action_go_search];
    };
    self.header.block_newFriend = ^{
        [weakSelf action_go_newFriend];
    };
    self.header.block_group = ^{
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
    [self setUpTableSection];
    [self.listView reloadData];
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
        //        [weakSelf action_newFriend];
    }];
    
    NSArray *menuModelArr = @[menuModel0, menuModel1,menuModel2];
    return menuModelArr;
}

-(void)action_more{
    [self.dropdownMenu showMenu];
}

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
        _listView.mj_header.tintColor = [UIColor whiteColor];
        _listView.mj_footer = nil;
        _listView.tableHeaderView = self.header;
        _listView.sectionIndexColor = [UIColor lightGrayColor];
        _listView.sectionIndexBackgroundColor = [UIColor clearColor];
        _listView.sectionHeaderHeight = 25;
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

- (void) setUpTableSection {
    
    NSMutableArray *m_arr = [NSMutableArray arrayWithCapacity:self.dataSource.count];
    for (int i = 0; i<self.dataSource.count; i++) {
        NSDictionary *dict = self.dataSource[i];
        CB_FriendModel *model= [CB_FriendModel modelWithDictionary:dict];
        [m_arr addObject:model];
    }
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //create a temp sectionArray
    NSUInteger numberOfSections = [[collation sectionTitles] count];
    NSMutableArray *newSectionArray =  [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index<numberOfSections; index++) {
        [newSectionArray addObject:[[NSMutableArray alloc]init]];
    }
    
    // insert Persons info into newSectionArray
    for (CB_FriendModel *model in m_arr) {
        NSUInteger sectionIndex = [collation sectionForObject:model collationStringSelector:@selector(FriendUserName)];
        [newSectionArray[sectionIndex] addObject:model];
    }
    
    //sort the person of each section
    for (NSUInteger index=0; index<numberOfSections; index++) {
        NSMutableArray *personsForSection = newSectionArray[index];
        NSArray *sortedPersonsForSection = [collation sortedArrayFromArray:personsForSection collationStringSelector:@selector(FriendUserName)];
        newSectionArray[index] = sortedPersonsForSection;
    }
    
    NSMutableArray *temp = [NSMutableArray new];
    self.sectionTitlesArray = [NSMutableArray new];
    
    [newSectionArray enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL *stop) {
        if (arr.count == 0) {
            [temp addObject:arr];
        } else {
            [self.sectionTitlesArray addObject:[collation sectionTitles][idx]];
        }
    }];
    
    [newSectionArray removeObjectsInArray:temp];
    
//    NSMutableArray *operrationModels = [NSMutableArray new];
//    NSArray *dicts = @[@{@"name" : @"我的朋友", @"imageName" : @"plugins_FriendNotify"},
//                       @{@"name" : @"我的群组", @"imageName" : @"add_friend_icon_addgroup"},
//                       ];
//    for (NSDictionary *dict in dicts) {
//        [operrationModels addObject:dict];
//    }
//
//    [newSectionArray insertObject:operrationModels atIndex:0];
//    [self.sectionTitlesArray insertObject:@"我的" atIndex:0];
    self.sectionArray = newSectionArray;
}

#pragma mark - tableview delegate and datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionTitlesArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionArray[section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CB_UserContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[CB_UserContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    
    NSUInteger section = indexPath.section;
    NSUInteger row = indexPath.row;
    id object = self.sectionArray[section][row];
//    if ([object isKindOfClass:[NSDictionary class]]) {
//        NSDictionary *dd = object;
//        cell.lbl_name.text = dd[@"name"];
//        cell.img_header.image = [UIImage imageNamed:dd[@"imageName"]];
//    }else{
//        CB_FriendModel *model =object;
//        cell.lbl_name.text = model.FriendUserName;
//        [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
//    }
    CB_FriendModel *model =object;
    cell.lbl_name.text = model.FriendUserName;
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [self.sectionTitlesArray objectAtIndex:section];
}


- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.sectionTitlesArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if (indexPath.section == 0) {
//        if (indexPath.row == 0) {
//            [self action_go_newFriend];
//        }
//
//        if (indexPath.row == 1) {
//            [self action_go_myGroup];
//        }
//        return;
//    }
    
    NSArray *arr = self.sectionArray[indexPath.section];
    CB_FriendModel *model = arr[indexPath.row];
//    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    
    ContrractUserInfoController *page = [ContrractUserInfoController new];
    page.friendModel = model;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}


-(CB_ContractnewHeader *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"CB_ContractnewHeader" owner:self options:nil] lastObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 220);
    }
    return _header;
}

@end
