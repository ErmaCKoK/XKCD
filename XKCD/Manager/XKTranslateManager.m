//
//  XKTranslateManager.m
//  XKCD
//
//  Created by Andrii Kurshyn on 9/23/14.
//  Copyright (c) 2014 Inamana. All rights reserved.
//

#import "XKTranslateManager.h"
#import "XKComic.h"

NSString *const kMSClientID = @"XKCD_Comics";
NSString *const kMSClientSecret = @"xfzWUyCmGDXPkXVP1ZlkuSecC9PHlQu1EPXi/hC8Poc=";

@interface XKTranslateManager ()
{

}

@property (nonatomic, strong) NSString *accessToken;
@property (nonatomic, strong) NSString *expiresToken;
@property (nonatomic, strong) NSDate *dateToken;

@end

@implementation XKTranslateManager

+ (XKTranslateManager *)sharedManager
{
    static dispatch_once_t predicate;
    static XKTranslateManager *instance = nil;
    dispatch_once(&predicate, ^{instance = [[self alloc] init];});
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
        self.expiresToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"expiresToken"];
        self.dateToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"dateToken"];
    }
    
    return self;
}

- (void)translateComic:(XKComic *)comic success:(LoadingSuccessBlock)success
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
    comic.translate = @"";
        
    if (self.accessToken == nil || ABS([self.dateToken timeIntervalSinceNow]) > [self.expiresToken integerValue]) {

        if (![self updateAccestToken])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) success(comic);
            });
            
            return;
        }
    }
    
    NSString *appId = [self urlEncodedUTF8String:[NSString stringWithFormat:@"Bearer %@",self.accessToken]];

    NSString *url = [NSString stringWithFormat:@"http://api.microsofttranslator.com/v2/Http.svc/Translate?appId=%@&text=%@&from=en&to=%@",appId,[comic.transcript stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[NSLocale preferredLanguages] firstObject]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];//?text=Hello&from=en&to=ru

    NSURLResponse* response;
    NSError* error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error: &error];
    
    if (data != nil) {
        
        NSString *received_txt = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        comic.translate = @"";
        if (received_txt != nil)
        {
            NSArray *parts = [received_txt componentsSeparatedByString:@"/Serialization/\">"];

            if (parts.count >= 2)
            {
                NSString *toReturn = [parts objectAtIndex:1];
                comic.translate = [toReturn stringByReplacingOccurrencesOfString:@"</string>" withString:@""];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(comic);
        });
        
    } else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) success(comic);
        });
    }
        
    });
}

- (BOOL)updateAccestToken
{

    NSMutableString* authHeader = [NSMutableString stringWithString:@"client_id="];
    [authHeader appendString:kMSClientID];
    [authHeader appendString:@"&client_secret="];
    [authHeader appendString:[self urlEncodedUTF8String:kMSClientSecret]];
    [authHeader appendString:@"&grant_type=client_credentials&scope=http://api.microsofttranslator.com"];
    
    
    
    NSMutableURLRequest *request =[NSMutableURLRequest
                                   requestWithURL:[NSURL URLWithString:@"https://datamarket.accesscontrol.windows.net/v2/OAuth2-13"]
                                   cachePolicy:NSURLRequestUseProtocolCachePolicy
                                   timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded"
   forHTTPHeaderField:@"Content-Type"];
    
    const char *bytes = [authHeader UTF8String];
    [request setHTTPBody:[NSData dataWithBytes:bytes length:strlen(bytes)]];
    
    NSURLResponse* response;
    NSError* error;
    
    NSData* data = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
    
    if (data != nil) {
        NSError *errorParse = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorParse];
        if (errorParse == nil) {
            self.accessToken = dictionary[@"access_token"];
            self.expiresToken = dictionary[@"expires_in"];
            self.dateToken = [NSDate date];
            
            [[NSUserDefaults standardUserDefaults] setObject:self.accessToken forKey:@"accessToken"];
            [[NSUserDefaults standardUserDefaults] setObject:self.expiresToken forKey:@"expiresToken"];
            [[NSUserDefaults standardUserDefaults] setObject:self.dateToken forKey:@"dateToken"];
            
            return YES;
        }
    }
    
    return NO;
}

- (NSString *)urlEncodedUTF8String:(NSString*)string
{
    return (__bridge id)CFURLCreateStringByAddingPercentEscapes(0, (CFStringRef)string, 0,
                                                                (CFStringRef)@";/?:@&=$+{}<>,", kCFStringEncodingUTF8);
}

@end
