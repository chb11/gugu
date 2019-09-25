//
//  CreateNewGroupController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/9.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CreateNewGroupController.h"
#import "ChooseFriendForGroupCell.h"
#import "ChooseFriendSearchView.h"

static NSString *cellId = @"ChooseFriendForGroupCell";

@interface CreateNewGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) NSMutableArray *m_chooseArray;
@property (nonatomic,strong) ChooseFriendSearchView *header;

@property (nonatomic,strong) __block NSString *searchStr;

@end

@implementation CreateNewGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchStr = @"";
    [self initUI];
    [self initData];
    [self initAction];
    [self action_refresh];
}

-(void)initUI{
    
    self.title = @"选择联系人";
    
    if (!self.messageModel&&!self.annotation) {
        [self addItemWithTitle:@"确定" imageName:@"" selector:@selector(action_confirm) left:NO];
    }
    
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
    NSString *searchStr = @"%";
    searchStr = [searchStr stringByAppendingString:self.searchStr];
    self.listView.refreshDic = @{@"KeyWord":searchStr};
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
    self.header.block_search = ^(NSString * _Nonnull text) {
        weakSelf.searchStr = text;
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
    ChooseFriendForGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[ChooseFriendForGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    cell.friendModel = model;
    
    if ([self.m_chooseArray containsObject:model.FriendId]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    
    if (self.block_chooseConvertion) {
        self.block_chooseConvertion(model.FriendId, model);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    //转发消息
    if (self.messageModel) {
        [self action_transMessageTo:model];
        return;
    }
    
    //分享位置
    if (self.annotation) {
        [self action_sendPositonto:model];
        return;
    }
    
    if ([self.m_chooseArray containsObject:model.FriendId]) {
        [self.m_chooseArray removeObject:model.FriendId];
    }else{
        [self.m_chooseArray addObject:model.FriendId];
    }
    [self.listView reloadData];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.header.txt_name resignFirstResponder];
}

-(void)action_sendPositonto:(CB_FriendModel *)model{
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        NSString *position = [NSString stringWithFormat:@"latitude=%f,longitude=%f,%@",location.coordinate.latitude,location.coordinate.longitude,formattedAddress];
        NSMutableArray *para = @{@"Message":position,@"Type":@"Position"}.mutableCopy;
        [para setValue:model.FriendId forKey:@"ReceiveId"];
        [[NetWorkConnect manager] postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}


-(void)action_invitetoGroup:(NSString *)friendIds{
    NSLog(@"邀请进群");
    NSDictionary *para = @{@"UserIds":friendIds,@"GroupId":self.groupId};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_GROUP_JOIN_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"发送邀请成功" andDealy:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

//消息转发
-(void)action_transMessageTo:(CB_FriendModel *)model{
    NSLog(@"消息转发");
    NSDictionary *para = @{@"Guid":self.messageModel.Guid,
                           @"ReceiveId":model.FriendId};
    [AppGeneral action_showAlertWithTitle:@"是否转发消息?" andConfirmBlock:^{
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_TRANSMIT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
            }
        }];
    }];
}

-(void)action_confirm{
    
    NSString *friendsStr = @"";
    for (int i = 0; i<self.m_chooseArray.count; i++) {
        NSString *friendid = self.m_chooseArray[i];
        
        NSString *appendStr = @"";
        if (i>=self.m_chooseArray.count-1) {
            appendStr = friendid;
        }else{
            appendStr = [NSString stringWithFormat:@"%@,",friendid];
        }
        friendsStr = [friendsStr stringByAppendingString:appendStr];
    }
    
    //邀请用户加入群聊
    if (self.groupId) {
        if (!(self.m_chooseArray.count>0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"至少选择1位好友" message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
            [alert show];
            return;
        }
        [self action_invitetoGroup:friendsStr];
        return;
    }
    
    if (!(self.m_chooseArray.count>1)) {//至少选择两个
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"至少选择2位好友才能创建群组" message:nil delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    NSDictionary *para = @{@"UserId":[UserModel shareInstance].Guid, @"FriendIds":friendsStr};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_GROUP_CREAT_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"创建群组成功" andDealy:1];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

-(NSMutableArray *)m_chooseArray{
    if (!_m_chooseArray) {
        _m_chooseArray = @[].mutableCopy;
    }
    return _m_chooseArray;
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 55;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.tableHeaderView = self.header;
        _listView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
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

-(ChooseFriendSearchView *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"ChooseFriendSearchView" owner:self options:nil] firstObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    }
    return _header;
}


@end
