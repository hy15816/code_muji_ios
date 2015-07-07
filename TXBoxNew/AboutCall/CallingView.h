//
//  CallingView.h
//  TXBoxNew
//
//  Created by Naron on 15/7/2.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CallingDelegate <NSObject>
@optional
/**
 *  改变window的位置
 */
-(void)changeWindowfram;

/**
 *  收起view
 */
-(void)packUpCallingView;

/**
 *  展开view
 */
-(void)disMissCallingView;

@end
@interface CallingView : UIView

@property (strong,nonatomic) UIImageView *imgv;
@property (strong,nonatomic) UIImageView *topView;

@property (strong,nonatomic) NSString *hisNames;    //姓名
@property (strong,nonatomic) NSString *hisNumbers;  //号码


@property (assign,nonatomic) id<CallingDelegate> delegateCalling;
-(void)startTimeLengthTimer;
@end
