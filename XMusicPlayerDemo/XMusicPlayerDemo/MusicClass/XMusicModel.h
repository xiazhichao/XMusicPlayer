//
//  XMusicModel.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMusicModel : NSObject
@property (nonatomic, strong) NSString *audioURLStr;
@property (nonatomic, strong) NSString *audioName;
@property (nonatomic, strong) NSString *audioArtistName;
@property (nonatomic, strong) NSString *audioAlbumTitle;
@property (nonatomic, strong) NSString *audioImageUrlStr;
@property (nonatomic, strong) NSString *playId;
@property BOOL isPlaying;
@property BOOL isLoading;
@end
