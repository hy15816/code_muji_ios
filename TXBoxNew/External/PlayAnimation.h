//
//  PlayAnimation.h
//  TXBoxNew
//
//  Created by Naron on 15/6/24.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guides.h"

@protocol PlayAnimationDelegate <NSObject>
@optional
-(Guides *)getResource;
-(void)startAnimation;
-(void)stopAnimation;

@end

@interface PlayAnimation : UIView
{
    CAKeyframeAnimation *animation;
    Guides *gdss;
}

@property (assign,nonatomic) id<PlayAnimationDelegate> animationDelegate;

@end
