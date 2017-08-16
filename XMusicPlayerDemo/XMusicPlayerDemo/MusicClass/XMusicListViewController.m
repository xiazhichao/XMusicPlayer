//
//  XMusicListViewController.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XMusicListViewController.h"
#import "XPlayMusicCell.h"
#import <AVFoundation/AVFoundation.h>
#import "XPlayMusicViewController.h"
@interface XMusicListViewController ()<UITableViewDataSource,UITableViewDelegate>
//tableView
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property NSInteger pageIndex;
@end

@implementation XMusicListViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.pageIndex = self.musicModels.count%15>0?self.musicModels.count/15+2:self.musicModels.count/15+1;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        
    });
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

}



- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableV registerNib:[UINib nibWithNibName:@"XPlayMusicCell" bundle:nil] forCellReuseIdentifier:@"XPlayMusicCell"];
}

- (void)updateCells:(NSInteger)currentIndex
{
    self.currentIndex = currentIndex;
    [self.tableV reloadData];
}

#pragma mark - 数据请求
-(void)loadData:(NSInteger)index
{
    
}


#pragma mark - UITableViewDelegate,UITableDataSOurce
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _musicModels.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XPlayMusicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"XPlayMusicCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell configContentWithModel:_musicModels[indexPath.row] widthIndexPath:indexPath widthIndex:self.currentIndex];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(updatePlayMusic:)]) {
        [_delegate updatePlayMusic:indexPath.row];
    }
    [self dismissAction:nil];
}

- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
