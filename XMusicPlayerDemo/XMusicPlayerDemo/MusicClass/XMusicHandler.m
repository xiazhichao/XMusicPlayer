//
//  XMusicHandler.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XMusicHandler.h"

#define kScreenW  [UIScreen mainScreen].bounds.size.width
#define kScreenH  [UIScreen mainScreen].bounds.size.height
@implementation XMusicHandler

+ (void)configNowPlayingInfoCenter {
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state == UIApplicationStateBackground);
    XPlayMusicViewController *playVC = [XPlayMusicViewController shareSingleObj];
    XMusicModel *model = [playVC currentPlayingMusic];
    
    //防止卡顿，在前台的时候异步调用，后台的时候直接调用
    if (result) {
        
        [self configBackGroundPlayingInfoCenter:model withImage:nil];
    }else
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self configBackGroundPlayingInfoCenter:model withImage:nil];
        });
    
    
}

//同步锁频界面的音乐状态
+ (void)configBackGroundPlayingInfoCenter:(XMusicModel *)model withImage:(UIImage *)image
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    AVURLAsset *audioAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:model.audioURLStr] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds = CMTimeGetSeconds(audioDuration);
    
    [dict setObject:model.audioName forKey:MPMediaItemPropertyTitle];
    [dict setObject:model.audioArtistName forKey:MPMediaItemPropertyArtist];
    [dict setObject:model.audioAlbumTitle forKey:MPMediaItemPropertyAlbumTitle];
    [dict setObject:@(audioDurationSeconds) forKey:MPMediaItemPropertyPlaybackDuration];//总时间
    //        [dict setObject:@(audioDurationSeconds) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];//已经播放的时间
    CGFloat playerAlbumWidth = (kScreenW - 16) * 2;
    UIImageView *playerAlbum = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playerAlbumWidth, playerAlbumWidth)];
    [playerAlbum sd_setImageWithURL:[NSURL URLWithString:model.audioImageUrlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        MPMediaItemArtwork *artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        playerAlbum.contentMode = UIViewContentModeScaleAspectFill;
        [dict setObject:artwork forKey:MPMediaItemPropertyArtwork];
        //回调或者说是通知主线程刷新，
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }] ;
}

////更新锁频界面的音乐状态
+(void)updatePlayingInfoCenter
{
    XPlayMusicViewController *playVC = [XPlayMusicViewController shareSingleObj];
    UILabel *startTimeLabel = [playVC valueForKey:@"beginTimeLabel"];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[[MPNowPlayingInfoCenter defaultCenter] nowPlayingInfo]];//已经播放的时间
    [dict setObject:@([self getSeconds:startTimeLabel.text]) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
}

//获取一共有多少秒
+(NSInteger)getSeconds:(NSString *)timeStr
{
    NSString *strTime = timeStr;
    NSArray *array = [strTime componentsSeparatedByString:@":"]; //从字符A中分隔成2个元素的数组
    NSString *HH = nil;
    NSString *MM = nil;
    NSString *ss = nil;
    if (array.count>2) {
        HH = array[0];
        MM= array[1];
        ss = array[2];
    }else if (array.count>1) {
        MM= array[0];
        ss = array[1];
    }else if (array.count>0) {
        ss = array[0];
    }
    NSInteger h = [HH integerValue];
    NSInteger m = [MM integerValue];
    NSInteger s = [ss integerValue];
    NSInteger zonghms = h*3600 + m*60 +s;
    
    return zonghms;
}
@end
