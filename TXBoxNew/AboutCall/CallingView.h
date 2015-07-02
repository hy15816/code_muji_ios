//
//  CallingView.h
//  TXBoxNew
//
//  Created by Naron on 15/7/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CallingDelegate <NSObject>

/**
 *  获取当前界面的高度
 *  @param height 当前界面的高度
 *
 */
-(void)tabBarOrginHeight:(CGFloat)height;

-(void)changedTopViewHeight:(CGFloat)height;


@end
@interface CallingView : UIView
@property (assign,nonatomic) id<CallingDelegate> delegateCalling;
-(void)addCallingView;
@end
