//
//  CB_ReportController.m
//  xhs
//
//  Created by Mike on 2019/8/26.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_ReportController.h"
#import "CB_ReportCell.h"
#import "CB_ReportHeader.h"

static NSString *cellId = @"CB_ReportCell";

@interface CB_ReportController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) CB_ReportHeader *header;
@property (nonatomic,strong) NSMutableArray *datasource;
@property (nonatomic,strong) HLDS_BaseListView *listview;
@property (nonatomic,assign) NSInteger selectIndex;

@end

@implementation CB_ReportController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"举报";
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.listview];

    [self addItemWithTitle:@"确定" imageName:@"" selector:@selector(action_confirm) left:NO];

    self.selectIndex = -1;

    if (@available(ios 11.0, *)) {
        self.listview.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets =NO;
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)action_back{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)action_confirm{
    if (self.selectIndex <0) {
        [AppGeneral showMessage:@"请选择举报原因" andDealy:1];
        return;
    }
    [AppGeneral showMessage:@"举报成功,等待管理员审核" andDealy:1] ;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)confitRightButton{


}

#pragma mark - uitableview代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    CB_ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] lastObject];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *str = self.datasource[indexPath.row];
    cell.lbl_title.text = str;
    if (self.selectIndex == indexPath.row) {
        cell.lbl_title.backgroundColor = COLOR_APP_MAIN;
    }else{
        cell.lbl_title.backgroundColor = [UIColor colorWithHexString:@"edeff0"];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.selectIndex = indexPath.row;
    [self.listview reloadData];
}


#pragma mark - 懒加载

-(HLDS_BaseListView *)listview{
    if (!_listview) {
        _listview = [[HLDS_BaseListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-StatusBarHeight-BottomPadding) style:UITableViewStylePlain];
        _listview.dataSource = self;
        _listview.delegate = self;
        _listview.tableFooterView = [[UIView alloc] init];
        _listview.backgroundColor = [UIColor clearColor];
        [_listview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        _listview.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listview.rowHeight = 60;
        _listview.mj_header = nil;
        _listview.mj_footer = nil;
        _listview.shouldRecognize = NO;
        _listview.tableHeaderView = self.header;
    }
    return _listview;
}

-(NSMutableArray *)datasource{
    if (!_datasource) {
        _datasource = @[@"骚扰广告",
                        @"诈骗 / 托",
                        @"色情低俗",
                        @"违法言论",
                        @"恶意骚扰"].mutableCopy;
    }
    return _datasource;
}

-(CB_ReportHeader *)header{
    if (!_header) {
        _header = [[[NSBundle mainBundle] loadNibNamed:@"CB_ReportHeader" owner:self options:nil] lastObject];
        _header.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
    }
    return _header;
}


@end
