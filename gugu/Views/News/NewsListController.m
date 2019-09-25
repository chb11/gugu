//
//  NewsListController.m
//  gugu
//
//  Created by Mike Chen on 2019/2/28.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "NewsListController.h"
#import "NewsListCell.h"
#import "NewsListModel.h"
#import "NewsDetailController.h"

static NSString *cellId = @"NewsListCell";

@interface NewsListController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,strong) NSMutableArray *dataSource;
@end

@implementation NewsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.dataSource.count == 0) {
        [self action_refresh];
    }
}

-(void)initUI{
    self.title = @"资讯";
    
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
    
    [self.view addSubview:self.listView];
}

-(void)initData{
    self.listView.refreshUrl = OTHER_NEWS_LIST_NEWS;
    self.listView.isNormalPage = YES;
    self.listView.refreshDic = @{};
}

-(void)action_refresh{
    NSDictionary *para = @{};
    [[NetWorkConnect manager] postDataWith:para withUrl:OTHER_NEWS_LIST_NEWS withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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
    self.listView.hlds_block_loadMore = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        [weakSelf action_loadMoreWith:items];
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
    [self.listView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NewsListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[NewsListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    NewsListModel *model = [NewsListModel modelWithDictionary:dict];
    cell.lbl_time.text = [AppGeneral timeAgo:model.PushTime];
    cell.lbl_keywords.text = model.Digest;
    cell.lbl_title.text = model.Title;
    [cell.img_cover sd_setImageWithURL:[NSURL URLWithString:model.Imgsrc]];
    cell.lbl_from.text = model.Source;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = self.dataSource[indexPath.row];
    NewsListModel *model = [NewsListModel modelWithDictionary:dict];
    
    NewsDetailController *page = [NewsDetailController new];
    page.model = model;
    page.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:page animated:YES];
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NavBarHeight-50) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listView.rowHeight = 100;
        _listView.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.mj_header.tintColor = [UIColor whiteColor];
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
