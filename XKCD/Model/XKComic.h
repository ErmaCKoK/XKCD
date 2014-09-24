//
//  XKComic.h
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XKComic : NSObject

@property (nonatomic, strong) NSNumber *comicID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *safeTitle;
@property (nonatomic, strong) NSString *transcript;
@property (nonatomic, strong) NSString *translate;
@property (nonatomic, strong) NSString *alt;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, strong) NSString *news;
@property (nonatomic, strong) NSDate *date;



+(instancetype)comicWithDictonary:(NSDictionary*)dic;

@end
