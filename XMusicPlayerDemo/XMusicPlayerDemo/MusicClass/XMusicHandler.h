//
//  XMusicHandler.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMusicModel.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XPlayMusicViewController.h"
#import "UIImageView+WebCache.h"
@interface XMusicHandler : NSObject
+ (void)configNowPlayingInfoCenter;
////更新锁频界面的音乐状态
+(void)updatePlayingInfoCenter;
@end
