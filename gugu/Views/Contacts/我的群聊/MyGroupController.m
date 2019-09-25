//
//  MyGroupController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MyGroupController.h"
#import "CB_UserContactCell.h"
#import "SSChatController.h"
#import "CreateNewGroupController.h"

static NSString *cellId = @"CB_UserContactCell";

@interface MyGroupController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation MyGroupController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    [self action_refresh];
}

-(void)initUI{
    
    if (self.isChooseForShareCard) {
        self.title = @"选择群";
    }else{
        self.title = @"我的群聊";
        [self addItemWithTitle:@"发起群聊" imageName:@"" selector:@selector(action_newGroup) left:NO];
    }
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    
    self.listView.refreshUrl = CHAT_GROUP_ALL_GROUP;
    self.listView.refreshDic = @{};
 
}

-(void)action_newGroup{
    CreateNewGroupController *page = [CreateNewGroupController new];
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}


-(void)action_refresh{
    NSDictionary *para = @{};
    [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_GROUP_ALL_GROUP withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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
    CB_UserContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_UserContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];

    CB_GroupModel *model = [CB_GroupModel modelWithDictionary:dict];
    cell.lbl_name.text = [model.GroupNickName isEqualToString:@""]?model.GroupName:model.GroupNickName;
    [cell.img_header sd_setImageWithURL:[NSURL URLWithString:model.GroupHeadPhotoURL] placeholderImage:HOME_DEFAULT_HEADER_IMAGE];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_GroupModel *model = [CB_GroupModel modelWithDictionary:dict];
    
    if (self.block_chooseConvertion) {
        self.block_chooseConvertion(model.GroupId, model);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    
    if (self.isChooseForShareCard) {
        
        if (self.annotation) {
            [self action_sendPositonto:model];
            return;
        }
        
        if (self.messageModel) {
            [self action_transMessage:model];
        }else{
            [self action_shareCardToGroup:model];
        }
        
    }else{
        [self action_jumpToChat:model];
    }
}

-(void)action_sendPositonto:(CB_GroupModel *)model{
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        NSString *position = [NSString stringWithFormat:@"latitude=%f,longitude=%f,%@",location.coordinate.latitude,location.coordinate.longitude,formattedAddress];
        NSMutableArray *para = @{@"Message":position,@"Type":@"Position"}.mutableCopy;
        [para setValue:model.GroupId forKey:@"ReceiveId"];
        [[NetWorkConnect manager] postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }];
}

-(void)action_transMessage:(CB_GroupModel *)model{
    NSLog(@"转发消息到群");
    NSDictionary *para = @{@"Guid":self.messageModel.Guid,
                           @"ReceiveId":model.GroupId};
    [AppGeneral action_showAlertWithTitle:@"是否转发至群聊?" andConfirmBlock:^{
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_TRANSMIT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
            }
        }];
    }];
}

-(void)action_jumpToChat:(CB_GroupModel *)model{
    
    SSChatController *page = [SSChatController new];
    page.chatType = SSChatConversationTypeGroupChat;
    page.sessionId = model.GroupId;
    page.SendId = model.GroupId;
    page.groupModel = model;
    page.titleString = (model.GroupNickName&&![model.GroupNickName isEqualToString:@""])?model.GroupNickName:model.GroupName;
    
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
    
}


-(void)action_shareCardToGroup:(CB_GroupModel *)groupModel{
    
    NSDictionary *para = @{@"Guid":self.friendInfoModel.Guid,
                           @"ReceiveId":groupModel.GroupId
                           };
    
    [AppGeneral action_showAlertWithTitle:@"是否分享名片至群聊?" andConfirmBlock:^{
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
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 80;
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
