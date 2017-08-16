//
//  ViewController.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "ViewController.h"
#import "YYModel.h"
#import "XMusicModel.h"
#import "XPlayMusicViewController.h"
@interface ViewController ()
@property(strong,nonatomic)NSMutableArray *musicListDataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.musicListDataArray = [NSMutableArray array];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"json" ofType:@"txt"];
    NSString *dataFile = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *responseDic = [ViewController dictionaryWithJsonString:dataFile];
    NSArray *resultArr = responseDic[@"result"];
    for (NSInteger index = 0; index < resultArr.count; index++) {
        XMusicModel *model = [XMusicModel yy_modelWithDictionary:resultArr[index]];
        [self.musicListDataArray addObject:model];
    }
    // Do any additional setup after loading the view, typically from a nib.
}


+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}
- (IBAction)pushMudicPlayerAction:(id)sender {
    XPlayMusicViewController *playMuscic = [XPlayMusicViewController shareSingleObj];
    playMuscic.musicModels = self.musicListDataArray;
    [self.navigationController pushViewController:playMuscic animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
