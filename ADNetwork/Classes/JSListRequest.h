//
//  JSListRequest.h
//  JSNetwork_Example
//
//  Created by zwb on 2019/12/19.
//  Copyright © 2019 zhaowenbingm@gmail.com. All rights reserved.
//

#import "JSRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface JSListRequest : JSRequest

/// 列表总条数
@property(nonatomic, assign) NSInteger totalCount;

/// 当前页数
@property (nonatomic, assign) NSUInteger currentPageIndex;

/// 列表头数据
@property (nonatomic, strong) id headerItem;

/// 返回的列表数据
@property (nonatomic, strong) NSMutableArray *itemList;

/// 是否还有数据, 只要有数据返回, 就认为还有下一页
@property (nonatomic, assign) BOOL moreData;

/// 刷新数据, 清空itemList, currentPage = 1
- (void)reload;

/// 请求下一页
- (void)loadMore;

/// 每页多少条数据, 默认10
- (NSInteger)pageSize;

/// 是否会给满一页, 有的接口可能不给满一页数据, 默认为 yes
- (BOOL)isWillFetchFullPage;

/// 子类处理请求的数据, 反序列化(json -> OC对象)
- (NSMutableArray *)constructDataArray:(id)result;

@end

NS_ASSUME_NONNULL_END
