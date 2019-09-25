//
//  PackageGroupOpetationView.m
//  VoicePackage
//
//  Created by douyinbao on 2018/10/12.
//  Copyright © 2018年 douyinbao. All rights reserved.
//

#import "PackageGroupOpetationView.h"
#import "HLDS_BaseListView.h"

static NSString *cellId = @"UITableviewCell";

@interface PackageGroupOpetationView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UILabel *lbl_title;
@property (nonatomic,strong) UIButton *btn_cancel;
@property (nonatomic,strong) UIButton *btn_SelectAll;
@property (nonatomic,strong) HLDS_BaseListView *listView;
@property (nonatomic,strong) UIView *hlds_view_empty;
@property (nonatomic,assign) NSInteger currIndex;

@end

@implementation PackageGroupOpetationView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
        [self initData];
        self.currIndex = -1;
        [self initAction];
        [self addCornerRadius:15 cithCorners:UIRectCornerTopLeft|UIRectCornerTopRight];
    }
    return self;
}

-(void)initUI{
    self.backgroundColor = [UIColor whiteColor];
    self.btn_cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 15, 70, 30)];
    [self.btn_cancel setTitle:@"取消" forState:UIControlStateNormal];
    [self.btn_cancel setTitleColor:[UIColor colorWithHexString:@"5d5d5d"] forState:UIControlStateNormal];
    [self.btn_cancel addTarget:self action:@selector(action_close) forControlEvents:UIControlEventTouchUpInside];
    self.btn_cancel.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.btn_cancel];
    
    self.btn_SelectAll = [[UIButton alloc] initWithFrame:CGRectMake(self.width-70, 15, 70, 30)];
    [self.btn_SelectAll setTitle:@"确定" forState:UIControlStateNormal];
    
    [self.btn_SelectAll setTitleColor:[UIColor colorWithHexString:@"5d5d5d"] forState:UIControlStateNormal];
    
    [self.btn_SelectAll addTarget:self action:@selector(action_selectAll) forControlEvents:UIControlEventTouchUpInside];
    self.btn_SelectAll.titleLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:self.btn_SelectAll];
    
    self.lbl_title = [[UILabel alloc] initWithFrame:CGRectMake((self.width-100)/2, 15, 100, 30)];
    self.lbl_title.text = @"选择公司";
    self.lbl_title.textAlignment = NSTextAlignmentCenter;
    self.lbl_title.font = [UIFont boldSystemFontOfSize:17];
    self.lbl_title.textColor = [UIColor blackColor];
    [self addSubview:self.lbl_title];
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 59, self.width, 1)];
    line.backgroundColor = [UIColor colorWithHexString:@"eeeeef"];
    [self addSubview:line];
    
    [self addSubview:self.listView];
}

-(void)initData{
    self.listView.refreshUrl = COMPANY_LIST_COMPANY;
    self.listView.refreshDic = @{};
    [self.listView hlds_action_refresh];
}

-(void)initAction{
    __weak typeof(self) weakSelf = self;
    self.listView.hlds_block_refresh = ^(NSDictionary *result) {
        NSArray *items = result[@"list"];
        weakSelf.dataSource = items.copy;
    };
}

-(void)action_close{
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformIdentity;
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(void)setDataSource:(NSArray *)dataSource{
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
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    NSDictionary *dict = self.dataSource[indexPath.row];
    cell.textLabel.text = dict[@"Name"];
    if (self.currIndex == indexPath.row) {
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.currIndex = indexPath.row;
    [self.listView reloadData];
    
}

-(void)action_selectAll{
    if (self.currIndex<0) {
        [AppGeneral showMessage:@"请选择公司" andDealy:1];
        return;
    }
    //确定
    NSDictionary *dict = self.dataSource[self.currIndex];
    if (self.block_chooseGongsi) {
        self.block_chooseGongsi(dict);
    }
    [self action_close];
}

-(HLDS_BaseListView *)listView{
    if (!_listView) {
        _listView = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 60, self.width, self.height-60-50-BottomPadding) style:UITableViewStylePlain];
        _listView.delegate = self;
        _listView.dataSource = self;
        _listView.rowHeight = 70;
        _listView.mj_footer = nil;
        _listView.backgroundColor = [UIColor clearColor];
        _listView.tableFooterView = [[UIView alloc] init];
        [_listView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellId];
    }
    return _listView;
}

-(UIView *)hlds_view_empty{
    if (!_hlds_view_empty) {
        _hlds_view_empty = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _hlds_view_empty.backgroundColor = [UIColor whiteColor];
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((_hlds_view_empty.width-100)/2, (_hlds_view_empty.height-120)/2, 100, 120)];
        img.image = [UIImage imageNamed:@"yuyinbaol_sousuo_yybno_"];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [_hlds_view_empty addSubview:img];
    }
    return _hlds_view_empty;
}

@end
