//
//  CB_SearchAroundByText.m
//  gugu
//
//  Created by Mike Chen on 2019/3/31.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SearchAroundByText.h"
#import "CB_SearchKeywordCell.h"

static NSString *cellId = @"CB_SearchKeywordCell";

@interface CB_SearchAroundByText()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation CB_SearchAroundByText

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self._tableview];
    }
    return self;
}

-(void)setDataSource:(NSMutableArray *)dataSource{
    _dataSource = dataSource;
    [self._tableview reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CB_SearchKeywordCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cellId = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] lastObject];
    }
    AMapPOI *poi = self.dataSource[indexPath.row];
    cell.lbl_title.text = poi.name;
    cell.lbl_discribe.text = poi.address;
    cell.lbl_distance.text = [NSString stringWithFormat:@"%ld米",poi.distance];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poi = self.dataSource[indexPath.row];
    if (self.block_selectPoi) {
        self.block_selectPoi(poi);
    }
}

-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.rowHeight = 60;
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return __tableview;
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
