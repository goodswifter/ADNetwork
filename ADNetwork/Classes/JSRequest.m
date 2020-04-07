//
//  JSRequest.m
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/16.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import "JSRequest.h"
#import "AFNetworkReachabilityManager.h"
#import "JSErrorCodeManager.h"
#import "ADProgressHUD.h"

@implementation JSRequest

- (NSString *)baseUrl{
    NSString *baseurl = @"http://gateway.dev.jingshonline.net";
    return baseurl;
}

- (BOOL)isNeedLogin {
    return NO;
}

- (BOOL)isShowErrorToast {
    return YES;
}

- (YTKRequestMethod)requestMethod {
    return YTKRequestMethodGET;
}

- (YTKRequestSerializerType)requestSerializerType {
    return YTKRequestSerializerTypeJSON;
}

// 配置请求头，判断登录
- (NSDictionary *)requestHeaderFieldValueDictionary {
    //    NSString* version = [MAGlobal appVersion];//1.0.3
    //    NSString* versionCode = [MAGlobal appVersionCode];//103
    //    NSDate* date = [NSDate date];
    NSMutableDictionary *headerDic = [NSMutableDictionary
                                      dictionaryWithDictionary:
                                      @{}];
    [headerDic setValue:@"IosApp" forKey:@"x-terminal"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *tokenString = [defaults objectForKey:@"Authtoken"];
    [headerDic setValue:[NSString stringWithFormat:@"%@",tokenString] forKey:@"Authorization"];
    //    if ([JSLoginService sharedLoginSrevice].loginInfo) {
    ////        NSString* token = [JSLoginService sharedLoginSrevice].loginInfo.access_token;
    ////        [headerDic setValue:[NSString stringWithFormat:@"bearer %@",token] forKey:@"Authorization"];
    //    } else if ([self isNeedLogin]){
    //        self.isCancelled = YES;
    //        [self stop];
    ////        [AKPublicFunction hideLoading];
    ////        [[JSLoginService sharedLoginSrevice] actionToLoginVC];
    //    } else {
    ////        [headerDic setValue:@"" forKey:@"Cookie"];
    //    }
    return headerDic;
}

- (void)startWithShowLoading {
    [ADProgressHUD showActivityMessage:@"正在加载中..."];
    [self start];
}

- (void)start {
    if ([self isNeedLogin]) {
        [self continueStart];
    } else {
        [self continueStart];
    }
}

- (void)continueStart {
    if ([self isExecuting]) {
        [self stop];
    }
    
    __weak typeof(self) weakSelf = self;
    [super start];
    [self setCompletionBlockWithSuccess:^(__kindof YTKBaseRequest *request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.jsRequestDelegate && [weakSelf.jsRequestDelegate respondsToSelector:@selector(jsRequestCompleteWithModel:)] && !weakSelf.isCancelled) {
                [weakSelf.jsRequestDelegate jsRequestCompleteWithModel:weakSelf];
                [ADProgressHUD hideHUD];
            }
        });
    } failure:^(__kindof YTKBaseRequest *request) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf.jsRequestDelegate && [weakSelf.jsRequestDelegate respondsToSelector:@selector(jsRequestCancelledWithModel:)] && !weakSelf.isCancelled) {
                [weakSelf.jsRequestDelegate jsRequestCancelledWithModel:weakSelf];
                [ADProgressHUD hideHUD];
            }
        });
    }];
}

- (void)requestCompleteFilter {
    if (self.isCancelled) {
        if (self.jsRequestDelegate && [self.jsRequestDelegate respondsToSelector:@selector(jsRequestDelegate)]) {
            [self.jsRequestDelegate jsRequestCancelledWithModel:self];
        }
        return;
    }
    
    if ([self cacheTimeInSeconds] > 0) {
        [self cacheToFile];
    }
    
    id result;
    if ([self responseSerializerType] == YTKResponseSerializerTypeHTTP) {
        NSData *jsonData = [self.responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        result = dic;
    } else {
        result = self.responseJSONObject;
    }
    JSError *aError = nil;
    if (!([result[@"isSucceed"] boolValue])) {
        NSInteger error_Code = [[result valueForKey:@"statusCode"] integerValue];
        NSString *error_Msg = [result valueForKey:@"message"];
        aError = [JSErrorCodeManager js_errorWithErrorCode:error_Code errorMsg:error_Msg];
    }
    if (aError) {
        // 服务器有错误代码toast
        NSLog(@"%@", aError.error_msg);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:aError.error_msg preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
            // 响应事件
            NSLog(@"action = %@", action);
        }];
        
        [alert addAction:defaultAction];
        [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    }
    self.result = result;
    self.jsError = aError;
    id data = [result valueForKey:@"data"];
    if (data) {
        [self jsRequestSuccessFilter:data error:aError];
    } else {
        [self jsRequestSuccessFilter:result error:aError];
    }
}

- (void)requestFailedFilter {
    if (self.isCancelled) {
        if (self.jsRequestDelegate && [self.jsRequestDelegate respondsToSelector:@selector(jsRequestCancelledWithModel:)]) {
            [self.jsRequestDelegate jsRequestCancelledWithModel:self];
        }
        return;
    }
    
    // 网络状态判断
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        if ([self jsNetworkErrorMessage].length > 0) {
            [ADProgressHUD showError:[self jsNetworkErrorMessage]];
        }
        JSError *error = [JSError new];
        error.error_msg = [self jsNetworkErrorMessage];
        error.error_code = 404;
        self.jsError = error;
        [self jsRequestFailedFilter:error];
        if (self.jsRequestDelegate &&
            [self.jsRequestDelegate respondsToSelector:@selector(jsRequestCompleteWithModel:)]) {
            [self.jsRequestDelegate jsRequestCompleteWithModel:self];
        }
        return;
    }
    if (self.response) {
        JSError *error = [JSError new];
        if ([self.responseObject isKindOfClass:[NSDictionary class]]) {
            error.error_msg = self.responseObject[@"error_description"];
        }
        error.error_code = self.response.statusCode;
        self.jsError = error;
        if (error.error_code == 401) {
            [ADProgressHUD showMessage:@"登录信息过期，请重新登录！"];
    //            [[JSLoginService sharedLoginSrevice] logout];
        }
        [self jsRequestFailedFilter:error];
        if (self.jsRequestDelegate && [self.jsRequestDelegate respondsToSelector:@selector(jsRequestCancelledWithModel:)]) {
            [self.jsRequestDelegate jsRequestCancelledWithModel:self];
        }
        return;
    }
    if (self.response.statusCode != 200) {
        [ADProgressHUD showMessage:@"服务器错误请重试！"];
        if (self.jsRequestDelegate && [self.jsRequestDelegate respondsToSelector:@selector(jsRequestCancelledWithModel:)]) {
            [self.jsRequestDelegate jsRequestCancelledWithModel:self];
        }
    }
}

// 子类重载/做数据解析
- (void)jsRequestSuccessFilter:(id)result
                         error:(JSError *)error{}

// 子类重载/做数据解析
- (void)jsRequestFailedFilter:(JSError *)error{}

// 子类重载
- (NSString *)jsNetworkErrorMessage {
    return @"";
}

// 构建缓存时间Key
- (NSString *)cacheTimeKey {
    return [NSString stringWithFormat:@"CacheAPI_%@", [self requestUrl]];
}

- (void)cacheToFile {
    NSNumber *cacheTime = [NSNumber numberWithInteger:[self cacheTimeInSeconds]];
    [self.responseHeaders valueForKey:@"Cache_Control"];
    [[NSUserDefaults standardUserDefaults] setValue:cacheTime forKey:[self cacheTimeKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (cacheTime && cacheTime.integerValue > 0) {
        [self saveResponseDataToCacheFile:self.responseJSONObject];
    }
}

@end
