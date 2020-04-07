//
//  JSListRequest.m
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/19.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import "JSListRequest.h"
#import "JSError.h"

@implementation JSListRequest

- (id)init {
    self = [super init];
    if (self) {
        self.currentPageIndex = 1;
    }
    return self;
}

- (NSInteger)pageSize {
    return 10;
}

- (BOOL)isWillFetchFullPage {
    return YES;
}

- (id)requestArgument {
    return @{
        @"pageIndex" : [NSString stringWithFormat:@"%ld", self.currentPageIndex],
        @"pageCount" : [NSString stringWithFormat:@"%ld", self.pageSize]
    };
}

- (void)reload {
    self.currentPageIndex = 1;
    [self start];
}

- (void)loadMore {
    if (self.moreData) {
        [self start];
    }
}

- (NSMutableArray *)itemList {
    if (!_itemList) {
        _itemList = [NSMutableArray array];
    }
    return _itemList;
}

- (void)jsRequestSuccessFilter:(id)result
                         error:(JSError *)error {
    
    if (!result || error) {
        return;
    }
    
    if (self.currentPageIndex == 1) {
        [self.itemList removeAllObjects];
    }
    
    NSMutableArray *array = [self constructDataArray:result];
    self.moreData = NO;
    if ([result isKindOfClass:[NSDictionary class]]){
        self.totalCount = [result[@"totalCount"] integerValue];
    }
    
    if (array.count) {
        [self.itemList addObjectsFromArray:array];
        self.moreData = self.totalCount != self.itemList.count;
        self.currentPageIndex++;
    }
}

- (void)jsRequestFailedFilter:(JSError *)error {
    if (self.itemList.count > 0) {
        self.moreData = YES;
//        self.jsError = nil;
    }
}

/// 子类重载, 解析字典
- (NSMutableArray *)constructDataArray:(id)result {
    return nil;
}

@end
