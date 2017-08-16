//
//  XTrack.h
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"
@interface XTrack : NSObject<DOUAudioFile>
@property (nonatomic, strong) NSURL *audioFileURL;

@end
