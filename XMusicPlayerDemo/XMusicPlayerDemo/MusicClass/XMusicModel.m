//
//  XMusicModel.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XMusicModel.h"

@implementation XMusicModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.audioAlbumTitle = @"";
    }
    return self;
}
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
             @"audioURLStr":@"link",
             @"audioName":@"title",
             @"audioArtistName":@"singerName",
             @"audioImageUrlStr":@"icon"};
}
@end
