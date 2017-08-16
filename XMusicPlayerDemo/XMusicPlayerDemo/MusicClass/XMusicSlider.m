//
//  XMusicSlider.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XMusicSlider.h"

@implementation XMusicSlider
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImage *thumbImage = [UIImage imageNamed:@"music_circle"];
    [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 10 ;
    rect.size.width = rect.size.width + 20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}
@end
