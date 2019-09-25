//
//  MineCardPagkageController.m
//  gugu
//
//  Created by Mike Chen on 2019/5/3.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "MineCardPagkageController.h"
#import "CB_MyCardCell.h"
#import "CB_EditCardController.h"

static NSString *cellId = @"CB_MyCardCell";

@interface MineCardPagkageController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) __block NSMutableArray *dataSource;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation MineCardPagkageController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
    [self initAction];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self action_refresh];
}

-(void)initUI{
    self.title = @"我的卡包";
    [self.view addSubview:self.listView];
    [self addItemWithTitle:@"新增" imageName:@"" selector:@selector(action_addCard) left:NO];
    if (@available(ios 11.0, *)) {
        self.listView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)initData{
    self.listView.refreshUrl = COMPANY_LIST_COMPANY_CARD;
    self.listView.refreshDic = @{};
    [self action_refresh];
}

-(void)action_refresh{

    [[NetWorkConnect manager] postDataWith:@{} withUrl:COMPANY_LIST_COMPANY_CARD withResult:^(NSInteger resultCode, id responseObject, NSError *error) {
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

-(void)action_addCard{
    CB_EditCardController *page = [CB_EditCardController new];
    [self.navigationController pushViewController:page animated:YES];
}

#pragma mark - uitableview 代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_MyCardCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[CB_MyCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    NSString *url = dict[@"PhotoUrl"];
    if (![url containsString:@"http"]) {
        url = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,url];
    }
    [cell.img sd_setImageWithURL:[NSURL URLWithString:url]];
    cell.lbl_gongsiname.text = dict[@"Company"][@"Name"];
    NSString *compUrl = dict[@"Company"][@"PhotoUrl"];
    if (![compUrl containsString:@"http"]) {
        compUrl = [NSString stringWithFormat:@"%@%@",NET_MAIN_URL,compUrl];
    }
    [cell.img_gongsiHeader sd_setImageWithURL:[NSURL URLWithString:compUrl]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = self.dataSource[indexPath.row];
    //    CB_FriendModel *model = [CB_FriendModel modelWithDictionary:dict];
    CB_EditCardController *page = [CB_EditCardController new];
    page.dict = dict;
    [self.navigationController pushViewController:page animated:YES];
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
        _listView.rowHeight = 140;
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
