//
//  RMMemoryCache.m
//
// Copyright (c) 2008-2009, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMMemoryCache.h"
#import "RMTileImage.h"

@implementation RMMemoryCache
{
    NSCache *_memoryCache;
    dispatch_queue_t _memoryCacheQueue;
    NSUInteger _memoryCacheCapacity;
}

- (id)initWithCapacity:(NSUInteger)aCapacity
{
    if (!(self = [super init]))
        return nil;
    
    _memoryCacheQueue = dispatch_queue_create("routeme.memoryCacheQueue", DISPATCH_QUEUE_CONCURRENT);

    if (aCapacity < 1)
        aCapacity = 1;

    _memoryCacheCapacity = aCapacity;
    
    _memoryCache = [[NSCache alloc] init];
    _memoryCache.countLimit = aCapacity;

    return self;
}

- (id)init
{
	return [self initWithCapacity:32];
}

- (void)dealloc
{
    // This shit is not needed and causes a crash.
//    dispatch_barrier_sync(_memoryCacheQueue, ^{
//        [_memoryCache removeAllObjects];
//        _memoryCache = nil;
//    });
    dispatch_release(_memoryCacheQueue);
}

- (void)didReceiveMemoryWarning
{
	LogMethod();

    dispatch_barrier_async(_memoryCacheQueue, ^{
        [_memoryCache removeAllObjects];
    });
}

- (void)removeTile:(RMTile)tile
{
    dispatch_barrier_async(_memoryCacheQueue, ^{
        [_memoryCache removeObjectForKey:[RMTileCache tileHash:tile]];
    });
}

- (UIImage *)cachedImage:(RMTile)tile withCacheKey:(NSString *)aCacheKey
{
//    RMLog(@"Memory cache check  tile %d %d %d (%@)", tile.x, tile.y, tile.zoom, [RMTileCache tileHash:tile]);

    __block RMCacheObject *cachedObject = nil;
    NSNumber *tileHash = [RMTileCache tileHash:tile];

    dispatch_sync(_memoryCacheQueue, ^{

        cachedObject = [_memoryCache objectForKey:tileHash];

        if (cachedObject)
        {
            if ([[cachedObject cacheKey] isEqualToString:aCacheKey])
            {
                [cachedObject touch];
            }
            else
            {
                dispatch_barrier_async(_memoryCacheQueue, ^{
                    [_memoryCache removeObjectForKey:tileHash];
                });

                cachedObject = nil;
            }
        }

    });

//    RMLog(@"Memory cache hit    tile %d %d %d (%@)", tile.x, tile.y, tile.zoom, [RMTileCache tileHash:tile]);

    return [cachedObject cachedObject];
}

- (NSUInteger)capacity
{
    return _memoryCacheCapacity;
}

- (void)addImage:(UIImage *)image withData:(NSData *)data forTile:(RMTile)tile withCacheKey:(NSString *)aCacheKey
{
//    RMLog(@"Memory cache insert tile %d %d %d (%@)", tile.x, tile.y, tile.zoom, [RMTileCache tileHash:tile]);

    dispatch_barrier_async(_memoryCacheQueue, ^{
        [_memoryCache setObject:[RMCacheObject cacheObject:image forTile:tile withCacheKey:aCacheKey] forKey:[RMTileCache tileHash:tile]];
    });
}

- (void)removeAllCachedImages
{
    LogMethod();

    dispatch_barrier_async(_memoryCacheQueue, ^{
        [_memoryCache removeAllObjects];
    });
}

- (void)removeAllCachedImagesForCacheKey:(NSString *)cacheKey
{
//    dispatch_barrier_async(_memoryCacheQueue, ^{
//
//        NSMutableArray *keysToRemove = [NSMutableArray array];        
//        [_memoryCache enumerateKeysAndObjectsUsingBlock:^(id key, RMCacheObject *cachedObject, BOOL *stop) {
//            if ([[cachedObject cacheKey] isEqualToString:cacheKey])
//                [keysToRemove addObject:key];
//        }];
//
//        [_memoryCache removeObjectsForKeys:keysToRemove];
//
//    });
}

@end
