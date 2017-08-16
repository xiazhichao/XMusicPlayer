//
//  XPlayMusicCell.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMusicModel.h"
@interface XPlayMusicCell : UITableViewCell
-(void)configContentWithModel:(XMusicModel *)model widthIndexPath:(NSIndexPath *)indexPath widthIndex:(NSInteger)playIndex;
@end
