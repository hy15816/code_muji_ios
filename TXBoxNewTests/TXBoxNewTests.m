//
//  TXBoxNewTests.m
//  TXBoxNewTests
//
//  Created by Naron on 15/4/13.
//  Copyright (c) 2015年 playtime. All rights reserved.
//

#define userd [NSUserDefaults standardUserDefaults]

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "PinYin4Objc.h"

@interface TXBoxNewTests : XCTestCase

@end

@implementation TXBoxNewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小(Lowercase)写

    // Put teardown code here. This method is called after the invocation of each test method in the class.
    NSString *str = @"啊";
//    NSArray *Array = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0] withHanyuPinyinOutputFormat:outputFormat];
     NSMutableArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0 ] withHanyuPinyinOutputFormat:outputFormat];
    //NSArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinString
    NSLog(@"allPY4CurrentHZ=%@",allPY4CurrentHZ);
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    //[self tearDown];
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.


    }];
}

@end
