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
    
    [self.tableView addPullDownRefreshViewAutomaticallyAdjustsScrollView:NO Block:^{
        _row +=5;
        [self.tableView reloadData];
        [self performSelector:@selector(refreshdelay) withObject:nil afterDelay:4];
    }];
    [self.tableView addPullUpRefreshView:^{
        _row +=1;
        [self.tableView reloadData];
    }];
}
- (void)refreshdelay
{
    [self.tableView stopRefresh];
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
