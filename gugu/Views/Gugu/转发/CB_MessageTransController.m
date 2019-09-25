//
//  CB_MessageTransController.m
//  gugu
//
//  Created by Mike Chen on 2019/4/30.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_MessageTransController.h"
#import "CB_MessageTransHeader.h"
#import "GuguMessageCell.h"
#import "CreateNewGroupController.h"
#import "MyGroupController.h"

static NSString *cellId = @"GuguMessageCell";

@interface CB_MessageTransController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CB_MessageTransHeader *header;
@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation CB_MessageTransController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    [self addItemWithTitle:nil imageName:@"back.png" selector:@selector(action_back) left:YES];
}


-(void)initUI{
    
    self.title = @"历史记录";
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
//    self.listView.refreshUrl = CHAT_FRIEND_ALL_FRIEND;
//    self.listView.refreshDic = @{@"KeyWord":@"%"};
    NSArray *arr = [CB_MessageManager action_findLastedMessage];
    self.dataSource = arr.mutableCopy;
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    
    self.header.block_chooseGroup = ^{
        [weakSelf action_chooseGroup];
    };
    self.header.block_chooseFriend = ^{
        [weakSelf action_chooseFriend];
    };
}

-(void)action_back{
    if (self.navigationController.viewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)action_chooseGroup{
    
    MyGroupController *page = [MyGroupController new];
    page.isChooseForShareCard = YES;
    page.annotation = self.annotation;
    page.messageModel = self.model;
    page.block_chooseConvertion = self.block_chooseConvertion;
    [self.navigationController pushViewController:page animated:YES];
    
}

-(void)action_chooseFriend{
    CreateNewGroupController *page = [CreateNewGroupController new];
    page.annotation = self.annotation;
    page.messageModel = self.model;
    page.block_chooseConvertion = self.block_chooseConvertion;
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
    CB_MessageModel *model = self.dataSource[indexPath.row];
    
    if (self.block_chooseConvertion) {
        self.block_chooseConvertion(model.SendId, model);
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if (self.annotation) {
        [AppGeneral action_showAlertWithTitle:@"是否发送位置" andConfirmBlock:^{
            [self action_sendPositonto:model];
        }];
        return;
    }
    [self action_shareWithMessage:model];
}

-(void)action_shareWithMessage:(CB_MessageModel *)model{
    NSDictionary *para = @{@"Guid":self.model.Guid,
                           @"ReceiveId":model.SendId};
    [AppGeneral action_showAlertWithTitle:@"是否转发消息?" andConfirmBlock:^{
        [[NetWorkConnect manager] postDataWith:para withUrl:CHAT_MESSAGE_TRANSMIT withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
            }
        }];
    }];
}

-(void)action_sendPositonto:(CB_MessageModel *)model{
    
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        NSString *position = [NSString stringWithFormat:@"latitude=%f,longitude=%f,%@",location.coordinate.latitude,location.coordinate.longitude,formattedAddress];
        NSMutableArray *para = @{@"Message":position,@"Type":@"Position"}.mutableCopy;
        [para setValue:model.SendId forKey:@"ReceiveId"];
        [[NetWorkConnect manager] postDataWith:para.copy withUrl:CHAT_MESSAGE_SEND_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
            if (resultCode == 1) {
                [AppGeneral showMessage:@"发送成功" andDealy:1];
                [self.navigationController popViewControllerAnimated:YES];
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
        _listView.mj_header = nil;
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

-(CB_MessageTransHeader *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"CB_MessageTransHeader" owner:self options:nil] firstObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 150);
    }
    return _header;
}


@end
