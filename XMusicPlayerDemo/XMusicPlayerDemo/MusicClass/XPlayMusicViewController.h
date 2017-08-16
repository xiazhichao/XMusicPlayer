//
//  XPlayMusicViewController.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMusicModel.h"
#import "DOUAudioStreamer.h"
//音乐循环播放类型
typedef NS_ENUM(NSUInteger, DDMusicCycleType) {
    DD_MusicCycleTypeLoopAll = 0,      //全部循环播放
    DD_MusicCycleTypeLoopSingle,       //单曲循环
    DD_MusicCycleTypeShuffle ,          //随机播放
};
@interface XPlayMusicViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *musicModels;
@property (nonatomic, strong) DOUAudioStreamer *streamer;
@property (nonatomic) BOOL musicIsPlaying;
@property (nonatomic, assign) DDMusicCycleType musicCycleType;
- (XMusicModel *)currentPlayingMusic;
- (IBAction)didTouchMusicToggleButton:(id)sender;
- (IBAction)playPreviousMusic:(id)sender;
- (IBAction)playNextMusic:(id)sender;
+(instancetype)shareSingleObj;
@end
