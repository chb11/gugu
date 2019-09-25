//
//  CB_SerachAroundResultView.m
//  gugu
//
//  Created by Mike Chen on 2019/4/2.
//  Copyright © 2019 Mike Chen. All rights reserved.
//

#import "CB_SerachAroundResultView.h"
#import "CB_SearchAroundResultCell.h"

static NSString *cellId = @"CB_SearchAroundResultCell";

@interface CB_SerachAroundResultView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *_tableview;
@property (nonatomic,strong) UIView *hlds_view_empty;

@end

@implementation CB_SerachAroundResultView


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
    CB_SearchAroundResultCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    if (!cell) {
        cellId = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] lastObject];
    }
    AMapPOI *poi = self.dataSource[indexPath.row];
    cell.lbl_title.text = poi.name;
    if (poi.images.count>0) {
        [cell.img sd_setImageWithURL:[NSURL URLWithString:poi.images[0].url]];
    }
    cell.lbl_address.text = poi.address;
    cell.lbl_phone.text = poi.tel;
    cell.lbl_rect.text = poi.businessArea;
    if (poi.extensionInfo.rating>0) {
        cell.lbl_point.attributedText = [self pointStrWithPoint:poi.extensionInfo.rating];
        cell.lbl_point.hidden = NO;
    }else{
        cell.lbl_point.hidden = YES;
    }
    
    cell.lbl_distance.text = [NSString stringWithFormat:@"%ld米",(long)poi.distance];
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMapPOI *poi = self.dataSource[indexPath.row];
    if (self.block_selectPOI) {
        self.block_selectPOI(indexPath.row, poi);
    }
}

-(UITableView *)_tableview{
    if (!__tableview) {
        __tableview = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        [__tableview registerNib:[UINib nibWithNibName:cellId bundle:nil] forCellReuseIdentifier:cellId];
        __tableview.tableFooterView = [[UIView alloc] init];
        __tableview.backgroundColor = [UIColor clearColor];
        __tableview.rowHeight = 90;
        __tableview.delegate = self;
        __tableview.dataSource = self;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        __tableview.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        __tableview.contentInset = UIEdgeInsetsMake(0, 0, BottomPadding, 0);
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

-(NSAttributedString *)pointStrWithPoint:(CGFloat)point{
    NSString *pointStr =  [NSString stringWithFormat:@"%.f分",point];
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithString:pointStr];
    [attrStr addAttribute: NSForegroundColorAttributeName value: [UIColor redColor] range: NSMakeRange(0, attrStr.length-1)];
    
    return attrStr;
}

@end
