//
//  XKComic.m
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import "XKComic.h"
#import "NSDate+Utils.h"

//{"month": "9", "num": 1424, "link": "", "year": "2014", "news": "", "safe_title": "En Garde", "transcript": "", "alt": "'Touch!' 'Nope, I sighed and stared at you with resignation, so I regained emotional right-of-way.'", "img": "http:\/\/imgs.xkcd.com\/comics\/en_garde.png", "title": "En Garde", "day": "22"}

@implementation XKComic

+ (instancetype)comicWithDictonary:(NSDictionary *)dic
{
    XKComic *comic = [[XKComic alloc] init];
    
    comic.comicID = dic[@"num"];
    comic.news = dic[@"news"];
    comic.safeTitle = dic[@"safe_title"];
    comic.transcript = dic[@"transcript"];
    comic.alt = dic[@"alt"];
    comic.imageURL = [NSURL URLWithString:dic[@"img"]];
    comic.title = dic[@"title"];
    
    comic.date = [NSDate dateWithYear:[dic[@"year"] integerValue] month:[dic[@"month"] integerValue] day:[dic[@"day"] integerValue]];
    
    
    return comic;
}

@end
