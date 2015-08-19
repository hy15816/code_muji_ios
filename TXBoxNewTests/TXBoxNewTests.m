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
#import "BLEHelper.h"
#import "BLEmanager.h"

@interface TXBoxNewTests : XCTestCase

@end

@implementation TXBoxNewTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    /*
    HanyuPinyinOutputFormat *outputFormat =[[HanyuPinyinOutputFormat alloc] init];
    [outputFormat setToneType:ToneTypeWithoutTone];//声调
    [outputFormat setVCharType:VCharTypeWithV];//特殊拼音的显示格式如 ü
    [outputFormat setCaseType:CaseTypeLowercase];//大小(Lowercase)写

    NSString *str = @"啊";
    NSArray *Array = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0] withHanyuPinyinOutputFormat:outputFormat];
     NSMutableArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinStringArrayWithChar:[str characterAtIndex:0 ] withHanyuPinyinOutputFormat:outputFormat];
    //NSArray *allPY4CurrentHZ = [PinyinHelper toHanyuPinyinString
    NSLog(@"allPY4CurrentHZ=%@",allPY4CurrentHZ);
     */
    
    BLEmanager *ble = [BLEmanager sharedInstance];
    Messages *m =[[Messages alloc] init];
    m.number = @"A13713807497";
    m.content = @"这是一条短信，内容不知道有多长";
    [[BLEHelper shareHelper] requestTransmit:m withBLE:ble];
    [[BLEHelper shareHelper] sendDataWithMessage:m withBLE:ble];
    
   
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


/**
 *  字符串转换为十六进制
 *  @param string string
 *  @return hexString
 */
-(NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];//16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
@end
