//
//  CollectionlistController.m
//  gugu
//
//  Created by Mike Chen on 2019/3/7.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CollectionlistController.h"
#import "CollectionListHeader.h"
#import "CB_NewTagView.h"
#import "CB_CollectionListCell.h"
#import "XLPhotoBrowser.h"
#import "CB_MapRouteController.h"
#import "UUAVAudioPlayer.h"


static NSString *cellId = @"CB_CollectionListCell";

@interface CollectionlistController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@property (nonatomic,strong) CollectionListHeader *header;
@property (nonatomic,assign) __block SSChatMessageType messageType;
@property (nonatomic,strong) __block NSMutableArray *typeListArray;

@end

@implementation CollectionlistController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NetWorkConnect manager] postDataWith:@{} withUrl:COLLECT_LIST_TYPE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
        if (resultCode == 1) {
            NSDictionary *dict = responseObject;
            NSArray *arr = dict[@"list"];
            self.typeListArray = arr.mutableCopy;
            [self action_refreshTypeHeader];
        }
    }];
    
    self.messageType = -1;
    [self initUI];
    [self initData];
    [self initAction];
    [self action_refresh];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[UUAVAudioPlayer sharedInstance] stopSound];
    
}

-(void)initUI{
    self.title = @"我的收藏";
    [self.view addSubview:self.listView];
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initData{
    self.listView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
        [self.listView.mj_header endRefreshing];
        [self action_refresh];
    }];
    
}

-(void)action_refresh{
    
    NSMutableDictionary *para = @{}.mutableCopy;
    if (self.sendUserId) {
        [para setValue:self.sendUserId forKey:@"SendUserId"];
    }
    if (self.sendId) {
        [para setValue:self.sendId forKey:@"SendId"];
    }
    if (self.messageType>=0) {
        [para setValue:@(self.messageType) forKey:@"MessageType"];
    }
    
    [[NetWorkConnect manager] postDataWith:para withUrl:COLLECT_LIST_MESSAGE withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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

#pragma mark - 事件

-(void)action_refreshTypeHeader{
    
    NSMutableArray *remarks = @[@"全部"].mutableCopy;
    
    for (NSDictionary *dict in self.typeListArray) {
        NSString *title = dict[@"Remrk"];
        [remarks addObject:title];
    }
    
    for (UIView *subView in self.header.subviews) {
        [subView removeFromSuperview];
    }
    
    CB_NewTagView *tagv = [[CB_NewTagView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 20)];
    tagv.itemMargin = 10;
    tagv.itemRadio = 5;
    tagv.itemHeight = 30;
    tagv.itemWidth = 60;
    tagv.itemFont = 16;
    tagv.itemBorderColorArray = @[@"363636"];
    tagv.itemTitleColorArray = @[@"363636"];
    tagv.types = remarks;
    
    
    __weak typeof(self) weakSelf = self;
    tagv.block_select = ^(NSString *title) {
        if ([title isEqualToString:@"全部"]) {
            weakSelf.messageType = -1;
        }
        if ([title isEqualToString:@"文本"]) {
            weakSelf.messageType = 0;
        }
        if ([title isEqualToString:@"位置"]) {
            weakSelf.messageType = 1;
        }
        if ([title isEqualToString:@"图片"]) {
            weakSelf.messageType = 2;
        }
        if ([title isEqualToString:@"音频"]) {
            weakSelf.messageType = 3;
        }
        if ([title isEqualToString:@"名片"]) {
            weakSelf.messageType = 11;
        }
        [weakSelf action_refresh];
    };
    
    CGFloat height = [CB_NewTagView heightWithTags:remarks withFont:16 withitemHeight:30 withWidth:SCREEN_WIDTH-30];
    self.header.frame = CGRectMake(0, 0, SCREEN_WIDTH, height+30);
    
    UILabel *lbl_line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.header.height-1, SCREEN_WIDTH, 1)];
    lbl_line.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    [self.header addSubview:lbl_line];
    [self.header addSubview:tagv];
}

#pragma mark - uitableview 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_CollectionListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_CollectionListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_MessageModel *model = [CB_MessageModel modelWithDictionary:dict];
    cell.model = model;

    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    CB_MessageModel *model = [CB_MessageModel modelWithDictionary:dict];
    if (model.MessageType == SSChatMessageTypeImage) {
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithImages:@[model.FileUrlURL] currentImageIndex:0];
        browser.browserStyle = XLPhotoBrowserStyleIndexLabel;
    }else if(model.MessageType == SSChatMessageTypeMap){
        [self action_MapWith:model];
    }else if(model.MessageType == SSChatMessageTypeVoice){
        [[UUAVAudioPlayer sharedInstance] stopSound];
        [[UUAVAudioPlayer sharedInstance] playSongWithUrl:model.FileUrlURL];
    }
    
}

-(void)action_MapWith:(CB_MessageModel *)model{
    [[CB_LocationManager shareInstance] locateWithCompleted:^(NSString * _Nonnull formattedAddress, CLLocation * _Nonnull location) {
        CB_MapRouteController *route = [CB_MapRouteController new];
        route.startCoordinate = location.coordinate;
        NSString *msgStr = model.Message;
        NSArray *strArr = [msgStr componentsSeparatedByString:@","];
        CGFloat latitude = [[[strArr[0] componentsSeparatedByString:@"="] lastObject] floatValue];
        CGFloat longitude = [[[strArr[1] componentsSeparatedByString:@"="] lastObject] floatValue];
        route.endCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
        [self.navigationController pushViewController:route animated:YES];
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
        _listView.rowHeight = 110;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
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

-(CollectionListHeader *)header{
    if (!_header) {
        _header = [[CollectionListHeader alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        _header.backgroundColor = [UIColor whiteColor];
    }
    return _header;
}

@end
