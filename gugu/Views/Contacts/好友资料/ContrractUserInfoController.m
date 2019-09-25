//
//  ContrractUserInfoController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/6.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "ContrractUserInfoController.h"
#import "ContractInfoCell.h"
#import "ContractAddressCell.h"
#import "ContractUserInfoHeader.h"
#import "CollectionlistController.h"
#import "ContractShareFriendController.h"
#import "SSChatController.h"
#import "CB_MapRouteController.h"
#import "CB_ReportController.h"

static NSString *cellId = @"ContractInfoCell";
static NSString *addressCellId = @"ContractAddressCell";

@interface ContrractUserInfoController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *addressArr;
@property (nonatomic,strong) UIButton *btn_sendMsg;

@property (nonatomic,strong) ContractUserInfoHeader *headerView;
@property (nonatomic,strong) CB_FriendInfoModel *model;

@property (nonatomic,assign) __block BOOL isFriend;

@end

@implementation ContrractUserInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self initUI];
    
    [self action_valiedIsFriend];
    [self initAction];
    
}

-(void)initUI{
    self.title = @"好友资料";
    [self addItemWithTitle:@"" imageName:@"更多.png" selector:@selector(action_more) left:NO];
    
    [self.view addSubview:self._tableview];
    [self.view addSubview:self.btn_sendMsg];
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initData{
    
    [self action_refreshHeader];
    //刷新地址列表
    NSDictionary *addpara = @{@"ConsumerId":self.friendModel.FriendId};
    [[NetWorkConnect manager] postDataWith:addpara withUrl:CARD_SEARCH_CARD_ADDRESS withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSArray *arr = responseObject[@"list"];
            self.addressArr = arr.mutableCopy;
            
            if (arr.count == 0) {
                UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 50)];
                lbl.font = [UIFont systemFontOfSize:14];
                lbl.text = @"TA还没有添加地址";
                lbl.textColor = [UIColor lightGrayColor];
                self._tableview.tableFooterView = lbl;
            }else{
                self._tableview.tableFooterView = [[UIView alloc] init];
            }
            
            [self._tableview reloadData];
        }
    }];
}

-(void)action_valiedIsFriend{
    NSDictionary *para = @{@"FriendId":self.friendModel.FriendId};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_IS_MY_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            if (dict.allKeys.count>0) {//是好友
                [self action_showIsFriend:YES];
            }else{
                [self action_showIsFriend:NO];
            }
            [self initData];
        }
    }];
}

-(void)action_refreshHeader{
    //刷新用户信息
    NSDictionary *para = @{@"FriendId":self.friendModel.FriendId};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_USER_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            self.model = [CB_FriendInfoModel modelWithDictionary:responseObject];
        }
    }];
}


-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self._tableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf._tableview.mj_header endRefreshing];
            [weakSelf initData];
        });
    }];
    self.headerView.block_call = ^{
        [weakSelf action_phoneCall];
    };
}

-(void)setModel:(CB_FriendInfoModel *)model{
    _model = model;
    self.headerView.model = model;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.dataSource.count;
    }
    return self.addressArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        ContractInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        if (!cell) {
            cell = [[ContractInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        NSString *title = self.dataSource[indexPath.row];
        cell.lbl_title.text = title;
        
        return cell;
    }
    
    ContractAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:addressCellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[ContractAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressCellId];
    }
    
    NSDictionary *dict = self.addressArr[indexPath.row];
    cell.lbl_title.text = [APPGENERAL getSafeValueWith:dict[@"Tag"]];
    cell.lbl_subtitle.text = [APPGENERAL getSafeValueWith:dict[@"Name"]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 50;//section头部高度
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section ==0) {
        return 50;
    }
    return 70;
}

//section头部视图
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        view.backgroundColor = [UIColor clearColor];

        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 120, 30)];
        lbl.text = @"TA的地址";
        lbl.tag = 202;
        lbl.textColor = [UIColor lightGrayColor];
        [view addSubview:lbl];
        
        return view ;
    }
    
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

//section底部视图
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section ==0) {
        NSString *title = self.dataSource[indexPath.row];
        if ([title isEqualToString:@"设置备注"]) {
            [self action_setBeizhu];
        }
        if ([title isEqualToString:@"收藏列表"]) {
            [self action_goCollection];
        }
        return;
    }
    //点击地址
    if (indexPath.section == 1) {
        NSDictionary *dict = self.addressArr[indexPath.row];
        [self action_MapWith:dict];
    }
    
}

-(void)action_MapWith:(NSDictionary *)addressDict{
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        CB_MapRouteController *route = [CB_MapRouteController new];
        route.startCoordinate = location.coordinate;

        CGFloat latitude = [addressDict[@"Lat"] floatValue];
        CGFloat longitude = [addressDict[@"Lng"] floatValue];
        route.endCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [self.navigationController pushViewController:route animated:YES];
    }];
}


-(void)action_more{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"分享名片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self action_sendCard];
    }]];
    if (self.isFriend) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self actoion_report];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [self action_net_delete];
        }]];

    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action){
        
    }]];
    
    [self.navigationController presentViewController:alertController
                                            animated:YES
                                          completion:nil];
}

//发送名片
-(void)action_sendCard{
    ContractShareFriendController *page = [ContractShareFriendController new];
    page.friendInfoModel = self.model;
    [self.navigationController pushViewController:page animated:YES];
    
}

-(void)actoion_report{
    CB_ReportController *page = [CB_ReportController new];

    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_sendMsg:(UIButton *)button{
    if ([button.title isEqualToString:@"发消息"]) {
        
        //从单聊界面进来，直接返回
        if (self.isFromChatSignal) {
            [self.navigationController popViewControllerAnimated:NO];
            return;
        }
        //从群聊/通讯录进来
        SSChatController *page = [SSChatController new];
        page.chatType = SSChatConversationTypeChat;
        page.sessionId = self.model.Guid;
        page.SendId = self.model.Guid;
        page.friendModel = self.model;
        page.titleString = ![self.model.MemoName isEqualToString:@""]?self.model.MemoName:self.model.NickName;
        page.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:page animated:YES];
        
    }else{
        //添加好友
        NSDictionary *para = @{@"FriendId":self.model.Guid};
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_ADD_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode ==1) {
                [AppGeneral showMessage:@"已发送好友请求" andDealy:1];
            }
        }];
    }
}

-(void)action_net_delete{
    
    [AppGeneral action_showAlertWithTitle:@"是否删除好友" andConfirmBlock:^{
        NSDictionary *para = @{@"Guid":self.model.FriendId};
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_FRIEND_DELETE_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode ==1) {
                [AppGeneral showMessage:@"删除成功" andDealy:1];
                [self action_showIsFriend:NO];
                [self initData];
                [self._tableview reloadData];
            }
        }];
    }];
}

-(void)action_setBeizhu{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"修改备注" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *textField = alertController.textFields.firstObject;
        [self action_net_beizhu:textField.text];
        NSLog(@"支付密码 = %@",textField.text);
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入备注";
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
    
}

-(void)action_net_beizhu:(NSString *)beizhuStr{

    if ([beizhuStr isEqualToString:@""]) {
        [AppGeneral showMessage:@"备注不能为空" andDealy:1];
        return;
    }
    if ([AppGeneral isContainsTwoEmoji:beizhuStr]) {
        [AppGeneral showMessage:@"备注不能含有表情符号" andDealy:1];
        return;
    }
    NSDictionary *page = @{@"Guid":self.model.FriendId,@"NickName":beizhuStr};
    [[NetWorkConnect manager] postDataWith:page withUrl:CHAT_FRIEND_EDIT_FRIEND withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode ==1) {
            [AppGeneral showMessage:@"修改备注成功" andDealy:1];
            [self action_refreshHeader];
        }
    }];
}

-(void)action_goCollection{
    CollectionlistController *page = [CollectionlistController new];
    page.sendUserId = self.model.FriendId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_phoneCall{
    NSString *phone = [NSString stringWithFormat:@"tel:%@",self.model.Phone];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:phone]]];
    [self.view addSubview:callWebview];
    
}

-(void)action_showIsFriend:(BOOL)isFriend{
    self.btn_sendMsg.hidden = NO;
    self.isFriend = isFriend;
    if (isFriend) {
        self.dataSource = @[@"设置备注",@"收藏列表"].mutableCopy;
        [self.btn_sendMsg setTitle:@"发消息" forState:UIControlStateNormal];
    }else{
        self.dataSource = @[@"收藏列表"].mutableCopy;
        [self.btn_sendMsg setTitle:@"添加到通讯录" forState:UIControlStateNormal];
    }
    
}

#pragma mark - 懒加载

-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-BottomPadding-NavBarHeight) style:UITableViewStyleGrouped];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        [__tableview registerNib:[UINib nibWithNibName:addressCellId bundle:nil] forCellReuseIdentifier:addressCellId];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        __tableview.tableHeaderView = self.headerView;
        __tableview.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding+90, 0);
    }
    return __tableview;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@"收藏列表"].mutableCopy;
    }
    return _dataSource;
}

-(NSMutableArray *)addressArr{
    if (!_addressArr) {
        _addressArr = @[].mutableCopy;
    }
    return _addressArr;
}


-(UIButton *)btn_sendMsg{
    if (!_btn_sendMsg) {
        _btn_sendMsg = [[UIButton alloc] initWithFrame:CGRectMake(30, SCREEN_HEIGHT-NavBarHeight-BottomPadding-70, SCREEN_WIDTH-60, 45)];
        [_btn_sendMsg setTitle:@"发消息" forState:UIControlStateNormal];
        [_btn_sendMsg setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn_sendMsg.backgroundColor = [UIColor colorWithHexString:@"1296db"];
        [_btn_sendMsg addTarget:self action:@selector(action_sendMsg:) forControlEvents:UIControlEventTouchUpInside];
        [_btn_sendMsg addlayerRadius:_btn_sendMsg.height/2];
        _btn_sendMsg.hidden = YES;
    }
    return _btn_sendMsg;
}

-(ContractUserInfoHeader *)headerView{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle] loadNibNamed:@"ContractUserInfoHeader" owner:self options:nil] lastObject];
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 175);
    }
    return _headerView;
}


@end
