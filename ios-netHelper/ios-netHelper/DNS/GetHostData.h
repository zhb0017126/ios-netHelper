//
//  GetHostData.h
//  ios-netHelper
//
//  Created by 赵泓博 on 2020/9/15.
//  Copyright © 2020 zhaohongbo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GetHostData : NSObject
+(NSMutableArray *)getDataFromHost:(NSString *)host port:(NSString *)port;
@end

NS_ASSUME_NONNULL_END
