//
//  CallInView.h
//  TXBoxNew
//
//  Created by Naron on 15/8/19.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CallInView <NSObject>

/**
 *接听或挂断
 */
-(void)answerOrHangUp:(UIButton *)btn;

/**
 *改变view的高度
 */
-(void)changedHeight;

@end

@interface CallInView : UIView

@property (strong,nonatomic) NSString *hisName;
@property (strong,nonatomic) NSString *hisNumber;
@property (strong,nonatomic) NSString *hisHome;

@property (assign,nonatomic) id<CallInView> delegate;
-(void)initViews;
-(void)hideAnswer;//hide 接听键
-(void)packUpView;//收起之后改变name位置
@end
