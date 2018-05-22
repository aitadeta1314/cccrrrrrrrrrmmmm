//
//  K_clearCache.h
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/22.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^cleanCacheBlock)();

@interface K_clearCache : NSObject

/**
 *  计算整个目录大小
 */
+ (float)folderSizeAtPath;

/**
 *  清理缓存
 */
+ (void)cleanCache:(cleanCacheBlock)block;

@end
