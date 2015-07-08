//
//  TextViewInput.h
//  BLETest
//
//  Created by Naron on 15/7/8.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextInputDelegate <NSObject>

-(CGFloat)getKeyBoradHeight;
-(void)changedFrame:(CGRect)rect;
-(void)rightButtonClick:(UIButton *)button;

@end

@interface TextViewInput : UIView<UITextViewDelegate>

@property (strong,nonatomic) UITextView *textview;  //textView
@property (assign,nonatomic) CGFloat maxHeight;     //可拉伸的最大高度

@property (strong,nonatomic) NSString *rigBtnTitle;//右边按钮title

@property (assign,nonatomic) id<TextInputDelegate> inputDelegate;
/**
 *  取消第一响应
 */
-(void)resignFirstResponders;
@end
