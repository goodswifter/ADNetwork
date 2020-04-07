//
//  JSError.h
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/16.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JSError : NSObject
/// 错误码
@property (nonatomic, assign) NSInteger error_code;
/// 错误信息
@property (nonatomic, copy) NSString *error_msg;
@end

NS_ASSUME_NONNULL_END
