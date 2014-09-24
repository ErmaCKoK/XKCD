//
//  XKCDManager.h
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadingSuccessBlock)(id object);
typedef void (^LoadingFailureBlock)(NSError *error);

@interface XKComicsManager : NSObject

+ (XKComicsManager *)sharedManager;

- (void)getCurrentComic:(LoadingSuccessBlock)success failure:(LoadingFailureBlock)failure;

- (void)getComicWithID:(NSNumber*)comicID success:(LoadingSuccessBlock)success failure:(LoadingFailureBlock)failure;

@end
