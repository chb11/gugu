//
//  ContractShareFriendController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractShareFriendController.h"
#import "CB_UserContactCell.h"
#import "ContractShareFriendHeader.h"
#import "MyGroupController.h"

static NSString *cellId = @"CB_UserContactCell";

@interface ContractShareFriendController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) ContractShareFriendHeader *header;

@end

@implementation ContractShareFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    [self action_refresh];
}

-(void)initUI{
    
    self.title = @"选择";
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
    self.listView.refreshDic = @{@"KeyWord":@"%"};
}

-(void)action_refresh{
    NSString *searchStr = @"%";
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
    self.header.block_chooseGroup = ^{
        [weakSelf action_chooseGroup];
    };
}

-(void)action_chooseGroup{
    MyGroupController *page = [MyGroupController new];
    page.isChooseForShareCard = YES;
    page.friendInfoModel = self.friendInfoModel;
    [self.navigationController pushViewController:page animated:YES];
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
    [self action_shareToFriend:model];
}

-(void)action_shareToFriend:(CB_FriendModel *)model{
    
    NSDictionary *para = @{@"Guid":self.friendInfoModel.Guid,
                           @"ReceiveId":model.FriendId
                           };
    [AppGeneral action_showAlertWithTitle:@"是否分享名片?" andConfirmBlock:^{
        [[NetWorkConnect manager] postDataWith:para withUrl:CARD_SHARE_CARD withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"分享成功" andDealy:1];
            }
        }];
    }];
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 80;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.tableHeaderView = self.header;
        _listView.tableFooterView = [[UIView alloc] init];
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

-(ContractShareFriendHeader *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"ContractShareFriendHeader" owner:self options:nil] firstObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 90);
    }
    return _header;
}

@end
