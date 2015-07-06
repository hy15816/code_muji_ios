//
//  TXKeyView.h
//  TXBox
//
//  Created by william on 15/1/3.
//  Copyright (c) 2015年 com. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol KeyViewDelegate <NSObject>

-(void)inputTextLength:(NSString *)text;

@end

@interface TXKeyView : UIView


@property (strong,nonatomic) UISearchBar *textsearch;

@property (assign,nonatomic) id<KeyViewDelegate> keyDelegate;

@end
