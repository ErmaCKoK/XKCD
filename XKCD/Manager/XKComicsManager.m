//
//  XKCDManager.m
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import "XKComicsManager.h"
#import "XKComic.h"
#import "XKTranslateManager.h"

NSString *const kContentAPIAddress = @"http://xkcd.com";

@implementation XKComicsManager

+ (XKComicsManager *)sharedManager
{
    static dispatch_once_t predicate;
    static XKComicsManager *instance = nil;
    dispatch_once(&predicate, ^{instance = [[self alloc] init];});
    return instance;
}

- (void)getCurrentComic:(LoadingSuccessBlock)success failure:(LoadingFailureBlock)failure
{
    [self getComicWithID:nil success:success failure:failure];
}

- (void)getComicWithID:(NSNumber *)comicID success:(LoadingSuccessBlock)success failure:(LoadingFailureBlock)failure
{
    NSString *comicParametr = @"";
    if (comicID != nil) {
        comicParametr = [NSString stringWithFormat:@"/%@",comicID];
    }

    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/info.0.json",kContentAPIAddress,comicParametr]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    [self sendAsynchronousRequest:request
                          success:^(NSDictionary *object){

                              XKComic *comic = [XKComic comicWithDictonary:object];

                              [[XKTranslateManager sharedManager] translateComic:comic success:success];
                          }
                          failure:failure];
}

-(void)sendAsynchronousRequest:(NSURLRequest*)request success:(LoadingSuccessBlock)success failure:(LoadingFailureBlock)failure
{
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (data)
                               {
                                   
                                   NSError *errorParse = nil;
                                   NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorParse];
                                   if (errorParse)
                                   {
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (failure) failure(errorParse);
                                       });
                                   } else
                                   {
                                           
                                       dispatch_async(dispatch_get_main_queue(), ^{
                                           if (success) success(dictionary);
                                       });
                                   }
                                   
                               } else
                               {
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       if (failure) failure(error);
                                   });
                               }
                           }];
}

@end
