//
//  AppDelegate.h
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVOSCloud/AVOSCloud.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSUserDefaults *usDefaults;
    UIImageView *enterbgView;
}
@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundUpdateTask;

@end

