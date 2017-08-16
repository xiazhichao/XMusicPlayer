//
//  XPlayMusicCell.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "XPlayMusicCell.h"

#import "UIImageView+WebCache.h"
@interface XPlayMusicCell ()
//主图
@property(nonatomic,weak) IBOutlet UIImageView *mainImageView;
//歌名
@property(nonatomic,weak) IBOutlet UILabel *musicTitleLab;
//歌手名
@property(nonatomic,strong) IBOutlet UILabel *singerLab;
@end
@implementation XPlayMusicCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)configContentWithModel:(XMusicModel *)model widthIndexPath:(NSIndexPath *)indexPath widthIndex:(NSInteger)playIndex
{
    [self.mainImageView sd_setImageWithURL:[NSURL URLWithString:model.audioImageUrlStr] placeholderImage:[UIImage imageNamed:@"music-placeholder"]];
    
    self.singerLab.text = model.audioArtistName;
    self.musicTitleLab.text = model.audioName;
    
    
    if (indexPath.row ==playIndex) {
        self.singerLab.textColor = [UIColor redColor];
        self.musicTitleLab.textColor = [UIColor redColor];
    }else
    {
        self.singerLab.textColor = [UIColor lightGrayColor];
        self.musicTitleLab.textColor = [UIColor lightGrayColor];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
