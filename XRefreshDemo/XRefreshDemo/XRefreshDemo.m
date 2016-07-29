//
//  XRefreshDemo.m
//  XRefreshDemo
//
//  Created by XiaoJingYuan on 7/25/16.
//  Copyright © 2016 XiaoJingYuan. All rights reserved.
//

#import "XRefreshDemo.h"
#import "XRefresh.h"
@implementation XRefreshDemo
{
    
    NSInteger _row;
}
- (void)viewDidLoad
{
    
    self.tableView.rowHeight = 80;
    _row = 10;
    __weak UITableViewController * weakSelf = self;
    [self.tableView addPullDownRefreshViewAutomaticallyAdjustsScrollView:YES Block:^{
        _row +=5;
        
        [weakSelf.tableView reloadData];
        [weakSelf performSelector:@selector(refreshdelay) withObject:nil afterDelay:4];
    }];
    [self.tableView addPullUpRefreshView:^{
        _row +=1;
        [weakSelf performSelector:@selector(increasedelay) withObject:nil afterDelay:0.1];
    }];
}
- (void)refreshdelay
{
    [self.tableView stopRefresh];
}
- (void)increasedelay
{
    if (_row%2==0) {
        [self.tableView noIncrease];
    }
    [self.tableView reloadData];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _row;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"refreshcell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"==%@",@(indexPath.row)];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
@end
