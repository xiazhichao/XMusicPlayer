//
//  UIView+Animations.h
//  Ting
//
//  Created by Aufree on 11/23/15.
//  Copyright © 2015 Ting. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animations)
- (void)startTransitionAnimation;
-(void)configMakeRotation:(float)duration;
- (void)pauseRotationAnimation;
- (void)resumeRotationAnimation:(float)duration;

@end
