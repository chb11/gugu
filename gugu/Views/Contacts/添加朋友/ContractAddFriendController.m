//
//  ContractAddFriendController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContractAddFriendController.h"
#import "ChooseFriendSearchView.h"
#import "CB_UserContactCell.h"
#import "ContrractUserInfoController.h"
#import "MyUserInfoController.h"

static NSString *cellId = @"CB_UserContactCell";
@interface ContractAddFriendController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) ChooseFriendSearchView *header;

@property (nonatomic,strong) __block NSString *searchStr;
@end

@implementation ContractAddFriendController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchStr = @"";
    [self initUI];
    [self initData];
    [self initAction];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.header.txt_name becomeFirstResponder];
    
}

-(void)initUI{
    
    self.title = @"添加好友";
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    self.header.txt_name.placeholder = @"请输入用户名/手机号";
    [self.view addSubview:self.listView];
}

-(void)initData{

}

-(void)action_refresh{
    
    NSString *searchStr = @"%";
    searchStr = [searchStr stringByAppendingString:self.searchStr];
    NSDictionary *para = @{@"UserName":searchStr};
    [[NetWorkConnect manager] postDataWith:para withUrl:V_USER_LISTBYPAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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
    self.header.block_search = ^(NSString * _Nonnull text) {
        weakSelf.searchStr = text;
        
        if ([weakSelf.searchStr isEqualToString:@""]) {
            [weakSelf.header.txt_name becomeFirstResponder];
            [AppGeneral showMessage:@"请输入用户名或手机号" andDealy:1];
            return;
        }
        [weakSelf action_refresh];
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
    CB_UserContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_UserContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    UserModel *model = [UserModel newModelWithDict:dict];
    cell.lbl_name.text = model.UserName;
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.HeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSource[indexPath.row];
    UserModel *model = [UserModel newModelWithDict:dict];
    [self action_addnewFriend:model];
}

-(void)action_valiteIsmyFriend:(UserModel *)model{
//    NSDictionary *para = @{@"FriendId":model.Guid};
//    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_IS_MY_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
//        if (resultCode == 1) {
//            NSDictionary *dict = responseObject;
//            if (dict.allKeys.count>0) {//是好友
//                [AppGeneral showMessage:@"TA已经是您的好友了" andDealy:1];
//            }else{
//                [self action_addnewFriend:model];
//            }
//        }
//    }];
}

-(void)action_addnewFriend:(UserModel *)model{
    
    if ([model.Guid isEqualToString:[UserModel shareInstance].Guid]) {
        MyUserInfoController *page = [MyUserInfoController new];
        [self.navigationController pushViewController:page animated:YES];
        return;
    }
    
    ContrractUserInfoController *page = [ContrractUserInfoController new];
    CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
    friendModel.FriendId = model.Guid;
    page.friendModel = friendModel;
    [self.navigationController pushViewController:page animated:YES];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.header.txt_name resignFirstResponder];
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
        _listView.tableHeaderView = self.header;
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.tableFooterView = [[UIView alloc] init];
        _listView.mj_header.tintColor = [UIColor whiteColor];
        _listView.mj_footer = nil;
        _listView.mj_header = nil;
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

-(ChooseFriendSearchView *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"ChooseFriendSearchView" owner:self options:nil] firstObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    }
    return _header;
}
@end
