/**
 *	Created by kimziv on 13-9-14.
 */
#ifndef _HanyuPinyinOutputFormat_H_
#define _HanyuPinyinOutputFormat_H_

typedef enum {
  ToneTypeWithToneNumber,   //数字声调
  ToneTypeWithoutTone,      //无声调
  ToneTypeWithToneMark      //标记声调
}ToneType;

typedef enum {
    CaseTypeUppercase,      //大写
    CaseTypeLowercase       //小写
}CaseType;

/*
 *  设置特殊拼音的显示格式如 u->ü
 */
typedef enum {
    VCharTypeWithUAndColon, //
    VCharTypeWithV,
    VCharTypeWithUUnicode
}VCharType;


@interface HanyuPinyinOutputFormat : NSObject

@property(nonatomic, assign) VCharType vCharType;
@property(nonatomic, assign) CaseType caseType;
@property(nonatomic, assign) ToneType toneType;

- (id)init;
- (void)restoreDefault;
@end

#endif // _HanyuPinyinOutputFormat_H_
