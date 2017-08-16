//
//  XMusicListViewController.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMusicModel.h"
@protocol XMusicListViewControllerDelegate <NSObject>
@optional
- (void)updatePlayMusic:(NSInteger)index;
@end
@interface XMusicListViewController : UIViewController
@property (nonatomic, weak) id<XMusicListViewControllerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *musicModels;
@property(nonatomic,strong)XMusicModel *playingModel;
@property(nonatomic)NSInteger currentIndex;
- (void)updateCells:(NSInteger)currentIndex;
@end
