//
//  ContractNewFriendsController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractNewFriendsController.h"
#import "NewFriendsCell.h"

static NSString *cellId = @"NewFriendsCell";

@interface ContractNewFriendsController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation ContractNewFriendsController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    
    [self action_refresh];
}

-(void)initUI{
    
    self.title = @"新的朋友";
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    
    self.listView.refreshUrl = CHAT_FRIEND_MY_APPLY_FRIEND;
    self.listView.refreshDic = @{};
    
}

-(void)action_refresh{
    NSDictionary *para = @{};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_MY_APPLY_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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
    NewFriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[NewFriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_newFriendModel *model = [CB_newFriendModel modelWithDictionary:dict];
    cell.model = model;
    [self configCell:cell];
    return cell;
}

-(void)configCell:(NewFriendsCell *)cell{
    __weak typeof(self) weakSelf = self;
    cell.block_regist = ^(CB_newFriendModel * _Nonnull model) {
        [weakSelf action_handle:model with:NO];
    };
    cell.block_accept = ^(CB_newFriendModel * _Nonnull model) {
        [weakSelf action_handle:model with:YES];
    };
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)action_handle:(CB_newFriendModel *)model with:(BOOL)isaccept{
    NSInteger result = isaccept?2:0;
    
    NSDictionary *para = @{@"Guid":model.Guid,@"Result":@(result)};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_RECEIVE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            
            if (isaccept) {
                [AppGeneral showMessage:@"已接受好友请求" andDealy:1];
            }else{
                [AppGeneral showMessage:@"已拒绝好友请求" andDealy:1];
            }
            [self action_refresh];
        }
    }];
}

#pragma mark - 懒加载

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 75;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
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
