//
//  CB_GroupInfoController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_GroupInfoController.h"
#import "CB_GroupMemberView.h"
#import "CB_GroupInfoCell.h"
#import "CollectionlistController.h"
#import "MyUserInfoController.h"
#import "ContrractUserInfoController.h"
#import "CreateNewGroupController.h"
#import "CB_GroupRQController.h"

#define itemMargin 20

static NSString *cellId = @"CB_GroupInfoCell";

@interface CB_GroupInfoController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CB_GroupMemberView *memberView;
@property (nonatomic,strong) NSMutableDictionary *groupDict;
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSString *myNickName;

@end

@implementation CB_GroupInfoController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
   
    
}

-(void)initUI{
    [self.view addSubview:self._tableview];
    self.title = @"详细资料";
    if (@available(ios 11.0, *)) {
        self._tableview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initData{
    NSDictionary *para1 = @{@"Guid":self.groupId};
    [[NetWorkConnect manager] postDataWith:para1 withUrl:CHAT_GROUP_SHOW_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            self.groupDict = dict.mutableCopy;
            [self._tableview reloadData];
        }
    }];
    NSDictionary *para2 = @{@"GroupId":self.groupId};
    [[NetWorkConnect manager] postDataWith:para2 withUrl:CHAT_GROUP_SEARCHMENBER withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSArray *members = responseObject[@"list"];
            [self action_setupHeaderWith:members];
        }
    }];
}

-(void)action_setupHeaderWith:(NSArray *)items{
    
    NSMutableArray *m_arr = @[].mutableCopy;
    for (NSDictionary *dict in items) {
        CB_GroupModel *model = [CB_GroupModel modelWithDictionary:dict];
        if ([model.UserId isEqualToString:[UserModel shareInstance].Guid]) {
            self.myNickName = model.UserName;
        }
        [m_arr addObject:model];
    }
    
    CGFloat height = [CB_GroupMemberView heightOfMemberCount:items.count];
    self.memberView = [[CB_GroupMemberView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
    self.memberView._dataSource = m_arr.mutableCopy;
    self._tableview.tableHeaderView = self.memberView;
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40+50)];
    footer.backgroundColor = [UIColor clearColor];
    
    UIButton *btn_quit = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 50)];
    [btn_quit setTitle:@"删除并退出" forState:UIControlStateNormal];
    [btn_quit setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn_quit addTarget:self action:@selector(action_quit) forControlEvents:UIControlEventTouchUpInside];
    btn_quit.backgroundColor = [UIColor whiteColor];
    [footer addSubview:btn_quit];
    self._tableview.tableFooterView = footer;
    [self initAction];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.memberView.block_invite = ^{
        [weakSelf action_inviteperson];
    };
    self.memberView.block_clickUser = ^(CB_GroupModel * _Nonnull model) {
        [weakSelf action_seeUserinfo:model];
    };
}

-(void)setMyNickName:(NSString *)myNickName{
    _myNickName = myNickName;
    [self._tableview reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CB_GroupInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_GroupInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    [self action_configCell:cell];
    cell.lbl_right.hidden = YES;
    cell.view_switch.hidden = YES;
    cell.img_erweima.hidden = YES;
    
    cell.accessoryType =UITableViewCellAccessoryNone;
    
    NSArray *arr = self.dataSource[indexPath.section];
    NSDictionary *dict = arr[indexPath.row];
    NSString *title = dict[@"title"];
    cell.lbl_title.text = title;
    if ([title isEqualToString:@"群聊名称"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.lbl_right.hidden = NO;
        cell.lbl_right.text = [AppGeneral getSafeValueWith:self.groupDict[@"Name"]];
    }
    if ([title isEqualToString:@"我的本群昵称"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.lbl_right.text = self.myNickName;
        cell.lbl_right.hidden = NO;
    }
    if ([title isEqualToString:@"是否公开"]) {
        [cell.view_switch setOn:[self.groupDict[@"Openable"] boolValue]];
        cell.view_switch.hidden = NO;
    }
    if ([title isEqualToString:@"是否截屏"]) {
        [cell.view_switch setOn:[self.groupDict[@"ScreenshotsAble"] boolValue]];
        cell.view_switch.hidden = NO;
    }
    if ([title isEqualToString:@"群二维码"]) {
        cell.img_erweima.hidden = NO;
    }
    if ([title isEqualToString:@"群收藏"]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

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
    
    if ([title isEqualToString:@"群收藏"]) {
        [self action_goCollection];
    }
    if ([title isEqualToString:@"群二维码"]) {
        [self action_goQR];
    }
    if ([title containsString:@"昵称"]) {
        [self action_changeNameInGroup:YES];
    }
    if ([title containsString:@"群聊名"]) {
        [self action_changeNameInGroup:NO];
    }
}

#pragma mark - 事件
-(void)actin_publish:(BOOL)isPublish{
    
    
}

-(void)action_goQR{
    CB_GroupRQController *page = [ CB_GroupRQController new];
    page.groupDict = self.groupDict;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_changeNameInGroup:(BOOL)isMyName{
    NSString *title = @"修改我的本群昵称";
    if (!isMyName) {
        title = @"修改群聊名称";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    //增加取消按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    //增加确定按钮；
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取第1个输入框；
        UITextField *textField = alertController.textFields.firstObject;
        if (isMyName) {
            self.myNickName = textField.text;
            [self action_updateMyName];
        }else{
            [self.groupDict setValue:textField.text forKey:@"Name"];
            [self action_updateGroupInfo];
        }
        
    }]];
    //定义第一个输入框；
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        if (isMyName) {
            textField.text = self.myNickName;
        }else{
            textField.text = [AppGeneral getSafeValueWith:self.groupDict[@"Name"]];
        }
    }];
    
    [self presentViewController:alertController animated:true completion:nil];
}

-(void)action_inviteperson{
    CreateNewGroupController *page = [CreateNewGroupController new];
    page.groupId = self.groupId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_configCell:(CB_GroupInfoCell *)cell{
    __weak typeof(self) weakSelf = self;
    cell.block_switch = ^(BOOL isOpen) {
        [weakSelf.groupDict setValue:@(isOpen) forKey:@"Openable"];
        [weakSelf action_updateGroupInfo];
    };
}

-(void)action_updateMyName{
    NSDictionary *para = @{@"Guid":self.groupId,
                           @"GroupNickName":self.myNickName};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_GROUP_EDIT_NICKNAME withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"修改成功" andDealy:1];
        }
    }];
}

-(void)action_updateGroupInfo{
    [[NetWorkConnect manager] postDataWith:self.groupDict withUrl:CHAT_GROUP_EDIT_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"修改成功" andDealy:1];
            [self._tableview reloadData];
        }
    }];
}

-(void)action_goCollection{
    CollectionlistController *page = [CollectionlistController new];
    page.sendId = self.groupId;
    [self.navigationController pushViewController:page animated:YES];
}

-(void)action_seeUserinfo:(CB_GroupModel *)model{
    
    if ([model.UserId isEqualToString:[UserModel shareInstance].Guid]) {
        MyUserInfoController *page = [MyUserInfoController new];
        [self.navigationController pushViewController:page animated:YES];
    }else{
        ContrractUserInfoController *page = [ContrractUserInfoController new];
        CB_FriendModel *friendModel = [[CB_FriendModel alloc] init];
        friendModel.FriendId = model.UserId;
        page.friendModel = friendModel;
        [self.navigationController pushViewController:page animated:YES];
    }
}

-(void)action_quit{
    NSDictionary *para = @{@"Guid":self.groupId};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_GROUP_EQUIT_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            [AppGeneral showMessage:@"退出成功" andDealy:1];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
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
    }
    return __tableview;
}


-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@[@{@"img":@"",@"title":@"群聊名称"},
                          ],
                        @[@{@"img":@"",@"title":@"我的本群昵称"},
                          @{@"img":@"",@"title":@"是否公开"},
//                          @{@"img":@"",@"title":@"是否截屏"},
                          @{@"img":@"",@"title":@"群二维码"},
                          @{@"img":@"",@"title":@"群收藏"}
                          ],
                        ].mutableCopy;
    }
    return _dataSource;
}

@end
