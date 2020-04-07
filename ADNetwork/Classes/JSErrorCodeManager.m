//
//  JSErrorCodeManager.m
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/19.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import "JSErrorCodeManager.h"

@implementation JSErrorCodeManager

+ (JSError *)js_errorWithErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg {
    // 请求成功
    if (errorCode == 200) return nil;
    
    // 请求失败
    JSError *error = [JSError new];
    error.error_code = errorCode;
    if (errorMsg.length) {
        error.error_msg = errorMsg;
        return error;
    } else {
        NSString *msg = [self getMsgWithErrorCode:errorCode];
        error.error_msg = msg;
        return error;
    }
}

+ (NSString *)getMsgWithErrorCode:(NSInteger)errorCode {
    NSString *errorMsg = @"服务器异常";
    // 根据errorCode做提示
    return errorMsg;
}

@end
