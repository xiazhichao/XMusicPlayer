//
//  UIView+Animations.m
//  Ting
//
//  Created by Aufree on 11/23/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import "UIView+Animations.h"

@implementation UIView (Animations)

//渐变
- (void)startTransitionAnimation {
    @try {
        [self.layer removeAnimationForKey:@"TransitionAnimation"];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [self.layer addAnimation:transition forKey:@"TransitionAnimation"];
}

//旋转
-(void)configMakeRotation:(float)duration
{
    @try {
        [self.layer removeAnimationForKey:@"rotationAnimation"];
    } @catch (NSException *exception) {

    } @finally {

    }

    //默认是按Z轴旋转
    CABasicAnimation *basic = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    //2.设置动画属性
    [basic setToValue:@(2*M_PI)];  //2*M_PI 旋转一周
    [basic setDuration:duration];
    basic.removedOnCompletion = NO;
    //动画完成后，是否从CALayer上移除动画对象
    //    [basic setRemovedOnCompletion:YES];
    //设置重复次数，HUGE_VALF是一个非常大的浮点数
    [basic setRepeatCount:HUGE_VALF];
    
    //动画根据锚点旋转的
    //修改锚点
//    [self.layer setAnchorPoint:CGPointMake(0, 0)];
    
    
    //3.添加动画
    [self.layer addAnimation:basic forKey:@"rotationAnimation"];
}

//暂停动画
- (void)pauseRotationAnimation {
    
    //（0-5）
    //开始时间：0
    //    myView.layer.beginTime
    //1.取出当前时间，转成动画暂停的时间
    CFTimeInterval pauseTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    
    //2.设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
    self.layer.timeOffset = pauseTime;
    
    //3.将动画的运行速度设置为0， 默认的运行速度是1.0
    self.layer.speed = 0;
    
}

//恢复动画
- (void)resumeRotationAnimation:(float)duration {
    
    //1.将动画的时间偏移量作为暂停的时间点
    CFTimeInterval pauseTime = self.layer.timeOffset;
    
    //2.计算出开始时间
    CFTimeInterval begin = CACurrentMediaTime() - pauseTime;
    
    [self.layer setTimeOffset:0];
    [self.layer setBeginTime:begin];
    
    self.layer.speed = 1;
}

@end
