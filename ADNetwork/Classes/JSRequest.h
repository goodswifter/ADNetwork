//
//  JSRequest.h
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/16.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import <YTKNetwork/YTKNetwork.h>
#import "JSError.h"
@class JSRequest;

NS_ASSUME_NONNULL_BEGIN

@protocol JSRequestDelegate <NSObject>

@optional
- (void)jsRequestCompleteWithModel:(JSRequest *)model;

- (void)jsRequestCancelledWithModel:(JSRequest *)model;

@end

@interface JSRequest : YTKRequest

@property (nonatomic, strong) id result;
@property (nonatomic, strong) JSError *jsError;
@property (nonatomic, weak) id<JSRequestDelegate> jsRequestDelegate;

/// 如果该接口需要登录，则返回YES；默认为NO；
- (BOOL)isNeedLogin;

/// 子类重载
- (NSString *)jsNetworkErrorMessage;

/// 子类重载 / 做数据解析
- (void)jsRequestSuccessFilter:(id)result
                         error:(JSError *)error;

/// 子类重载 / 做数据解析
- (void)jsRequestFailedFilter:(JSError *)error;

- (BOOL)isShowErrorToast;

- (void)startWithShowLoading;

@end

NS_ASSUME_NONNULL_END
