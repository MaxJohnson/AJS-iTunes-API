//
//  AJSITunesHTTPClient.m
//  AJSITunesAPI
//
//  Created by Andy Smart on 06/09/2013.
//  Copyright (c) 2013 Rocket Town Ltd. All rights reserved.
//

#import "AJSITunesClient.h"
#import "AJSITunesResult.h"

#define BASE_URL @"http://itunes.apple.com/"

@implementation AJSITunesClient

+ (AJSITunesClient *)sharedClient
{
    static AJSITunesClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *url = [NSURL URLWithString:BASE_URL];
        _sharedClient = [[self alloc] initWithBaseURL:url];
        _sharedClient.responseSerializer = [AFJSONSerializer serializer];
    });
    
    return _sharedClient;
}

#pragma mark - Convenience

- (id) searchMedia:(NSString *)keywords completion:(AJSITunesCompletionBlock)completion
{
    return [self searchMediaWithType:AJSITunesMediaTypeAll keywords:keywords country:@"US" limit:50 completion:completion];
}

- (id) searchMediaWithType:(NSString *)type
                  keywords:(NSString *)keywords
                   country:(NSString *)countryCode
                     limit:(NSUInteger)limit
                completion:(AJSITunesCompletionBlock)completion
{
    if (!type) {
        type = AJSITunesMediaTypeAll;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:keywords forKey:@"term"];
    [params setObject:type forKey:@"media"];
    
    if (countryCode) {
        [params setObject:countryCode forKey:@"country"];
    }
    
    [params setObject:@(limit) forKey:@"limit"];
    
    return [self GET:@"search" parameters:params success:^(NSHTTPURLResponse *response, id responseObject) {
        
            NSArray *results = responseObject[@"results"];
            NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[results count]];
        
            for (NSDictionary *hash in results) {
                NSError *error = nil;
                AJSITunesResult *object = [MTLJSONAdapter modelOfClass:[AJSITunesResult class] fromJSONDictionary:hash error:&error];
            
                if (object && !error) {
                    [objects addObject:object];
                } else {
                    NSLog(@"Error processing object with hash: %@", hash);
                }
            }
        
            if (completion) completion(objects, nil);
        
        } failure:^(NSError *error) {
            if (completion) completion(nil, error);
        }];
}

@end
