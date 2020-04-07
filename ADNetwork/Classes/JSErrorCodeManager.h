//
//  JSErrorCodeManager.h
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/19.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSError.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSErrorCodeManager : NSObject

+ (JSError *)js_errorWithErrorCode:(NSInteger)errorCode errorMsg:(NSString *)errorMsg;

@end

NS_ASSUME_NONNULL_END
