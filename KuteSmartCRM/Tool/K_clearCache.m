//
//  K_clearCache.m
//  KuteSmartCRM
//
//  Created by Fenly on 2018/5/22.
//  Copyright © 2018年 redcollar. All rights reserved.
//

#import "K_clearCache.h"

@implementation K_clearCache
/**
 *  计算单个文件大小
 */
+ (long long)fileSizeAtPath:(NSString *)filePath {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath :filePath error : nil ] fileSize];
    }
    return 0 ;
    
}

/**
 *  计算整个目录大小
 */
+ (float)folderSizeAtPath {
    
    NSString *folderPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0 ;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString * fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString *fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [ self fileSizeAtPath:fileAbsolutePath];
    }
    
    return folderSize/(1024.0 * 1024.0);
}

+ (void)clearCache:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    [[SDImageCache sharedImageCache] clearMemory];
}


/**
 *  清理缓存
 */
+(void)cleanCache:(cleanCacheBlock)block
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //文件路径
        NSString *directoryPath=[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
        NSString *path = NSHomeDirectory();
        NSArray *subpaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:directoryPath error:nil];
        
        for (NSString *subPath in subpaths) {
            NSString *filePath = [directoryPath stringByAppendingPathComponent:subPath];
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        }
        //返回主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    });
    
}

@end
