//
//  main.m
//  TXBoxNew
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        //leanCloud 服务器
        [AVOSCloud setApplicationId:@"85m0pvb0vv1iluti5sk0xsou1mkftzn06a3f1ompvza9xc7z" clientKey:@"orluh89ufnpvl773b68w5gcdk4dxfrahzwaahz7c46ettn44"];

        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
