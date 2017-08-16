//
//  AppDelegate.m
//  XMusicPlayerDemo
//
//  Created by xzc on 2017/8/16.
//  Copyright © 2017年 xzc. All rights reserved.
//

#import "AppDelegate.h"
#import "XPlayMusicViewController.h"
#import "XMusicHandler.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
                
            case UIEventSubtypeRemoteControlStop:
                break;
            case UIEventSubtypeRemoteControlPause:
            case UIEventSubtypeRemoteControlPlay:
                [[XPlayMusicViewController shareSingleObj] didTouchMusicToggleButton:nil];
                break;
            case UIEventSubtypeRemoteControlTogglePlayPause:
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [[XPlayMusicViewController shareSingleObj] playNextMusic:nil];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [[XPlayMusicViewController shareSingleObj] playPreviousMusic:nil];
                break;
            default:
                break;
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    XPlayMusicViewController *PlayMusicVC = [XPlayMusicViewController shareSingleObj];
    if (PlayMusicVC.musicIsPlaying) {
        [XMusicHandler updatePlayingInfoCenter];
    }
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
