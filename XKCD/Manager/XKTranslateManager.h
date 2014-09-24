//
//  XKTranslateManager.h
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^LoadingSuccessBlock)(id object);

@class XKComic;

@interface XKTranslateManager : NSObject

+ (XKTranslateManager *)sharedManager;

- (void)translateComic:(XKComic*)comic success:(LoadingSuccessBlock)success;

@end
