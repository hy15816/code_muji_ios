//
//  GuideController.h
//  TXBoxNew
//
//  Created by Naron on 15/6/24.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Guides.h"

@protocol GuideViewDelegate <NSObject>

/**
 *  返回一个Gudies，包括imags，
 *  @return Guides
 */
-(Guides *)getInfo;

@end

@interface GuideView : UIView

@property(assign,nonatomic) id<GuideViewDelegate> guideDelegate;

@end
