//
//  GuideController.m
//  TXBoxNew
//
//  Created by Naron on 15/6/24.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#import "GuideView.h"
#import <ImageIO/ImageIO.h>

@interface GuideView ()

@property (strong,nonatomic) Guides *guides;
@property (strong,nonatomic) UIPageControl *pageControl;

@end

@implementation GuideView

-(void)drawRect:(CGRect)rect
{
    self.backgroundColor = [UIColor whiteColor];
    _guides = [[Guides alloc] init];
    [self getInfo];
}

-(void)initGuideWithImages:(NSArray *)imagesArray
{
    NSInteger views = imagesArray.count;
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
    [scrollView setContentSize:CGSizeMake(DEVICE_WIDTH * views, 0)];
    [scrollView setPagingEnabled:YES];  //视图整页显示
    [scrollView setBounces:NO]; //避免弹跳效果,避免把根视图露出来
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake(0,DEVICE_HEIGHT-50 ,DEVICE_WIDTH, 21)];
    _pageControl.backgroundColor=[UIColor clearColor];
    _pageControl.numberOfPages=views;
    _pageControl.currentPage=0;
    
    
    
    
    UIView *view =[[UIView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH-30)/2+40, DEVICE_HEIGHT-355, 30, 30)];
    UITapGestureRecognizer *tapGR=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchDownInimage)];
    
    for (int i=0; i<views; i++) {

        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(DEVICE_WIDTH*i, 0, DEVICE_WIDTH, DEVICE_HEIGHT)];
        [imageview setImage:[UIImage imageNamed:imagesArray[i]]];
        
        if (i == views-1) {
            imageview.userInteractionEnabled = YES;
            //[imageview addSubview:button];
            [imageview addSubview:view];
            [self initAnimatedWithFileName:@"line" andType:@"gif" view:view];
            [imageview addGestureRecognizer:tapGR];
            
        }
        [scrollView addSubview:imageview];
    }

    [self addSubview:scrollView];
    //[self addSubview:_pageControl];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self touchDownInimage];
    });
    
}

-(void)getInfo
{
    _guides =  [self.guideDelegate getInfo];
    
    [self initGuideWithImages:_guides.imageArray];
}

//隐藏
- (void)touchDownInimage
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionOverrideInheritedCurve animations:^{
        self.alpha = 0;
        
    } completion:^(BOOL finished){
        VCLog(@"finished");
    }];
    
}

#pragma mark -- 加载gif图片
-(void)initAnimatedWithFileName :(NSString *)fileName andType:(NSString *)type view:(UIView *)vview
{
    //解码图片
    NSString *imagePath =[[NSBundle mainBundle] pathForResource:fileName ofType:type];
    CGImageSourceRef  cImageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)[NSURL fileURLWithPath:imagePath], NULL);
    //读取动画的每一帧
    size_t imageCount = CGImageSourceGetCount(cImageSource);
    NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *times = [[NSMutableArray alloc] initWithCapacity:imageCount];
    NSMutableArray *keyTimes = [[NSMutableArray alloc] initWithCapacity:imageCount];
    
    //显示时间
    float totalTime = 0;
    CGSize size;
    for (size_t i = 0; i < imageCount; i++) {
        CGImageRef cgimage= CGImageSourceCreateImageAtIndex(cImageSource, i, NULL);
        [images addObject:(__bridge id)cgimage];
        CGImageRelease(cgimage);
        
        NSDictionary *properties = (__bridge NSDictionary *)CGImageSourceCopyPropertiesAtIndex(cImageSource, i, NULL);
        NSDictionary *gifProperties = [properties valueForKey:(__bridge NSString *)kCGImagePropertyGIFDictionary];
        NSString *gifDelayTime = [gifProperties valueForKey:(__bridge NSString* )kCGImagePropertyGIFDelayTime];
        [times addObject:gifDelayTime];
        totalTime += [gifDelayTime floatValue];
        
        size.width = [[properties valueForKey:(NSString*)kCGImagePropertyPixelWidth] floatValue];
        size.height = [[properties valueForKey:(NSString*)kCGImagePropertyPixelHeight] floatValue];
    }
    
    float currentTime = 0;
    for (size_t i = 0; i < times.count; i++) {
        float keyTime = currentTime / totalTime;
        [keyTimes addObject:[NSNumber numberWithFloat:keyTime]];
        currentTime += [[times objectAtIndex:i] floatValue];
    }
    
    //执行CAKeyFrameAnimation动画
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]];
    [animation setValues:images];
    [animation setKeyTimes:keyTimes];
    animation.duration = totalTime;
    animation.repeatCount = HUGE_VALF;
    
    [vview.layer addAnimation:animation forKey:@"gifAnimation"];
 
}


@end
