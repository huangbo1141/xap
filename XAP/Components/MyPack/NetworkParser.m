//
//  NetworkParser.m
//  SchoolApp
//
//  Created by TwinkleStar on 11/27/15.
//  Copyright © 2015 apple. All rights reserved.
//

#import "NetworkParser.h"
#import "AFNetworking.h"

#import "BaseModel.h"

@implementation NetworkParser

+ (instancetype)sharedManager
{
    static NetworkParser *sharedPhotoManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPhotoManager = [[NetworkParser alloc] init];
        
    });
    
    return sharedPhotoManager;
}
-(BOOL)checkResponse:(NSDictionary*)dict{
    @try {
        if ([dict objectForKey:@"response"] == nil) {
            return true;
        }else{
            NSNumber* code = [dict valueForKey:@"response"];
            if ([code intValue] == 200) {
                return true;
            }else{
                
                NSString*error = (NSString*)[dict objectForKey:@"res"];
                if (error != nil) {
                    //[CGlobal AlertMessage:error Title:nil];
                }
                
            }
            return false;
        }
        
    }
    @catch (NSException *exception) {
        return false;
    }
    @finally {
        
    }
    
}
-(void)callNetwork:(NSString*)serverurl Data:(NSMutableDictionary*)questionDict withCompletionBlock:(NetworkCompletionBlock)completionBlock method:(NSString*)method{
    //    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if ([[serverurl lowercaseString] hasPrefix:@"https://"]) {
        manager.securityPolicy.allowInvalidCertificates = YES; // not recommended for production
        [manager.securityPolicy setValidatesDomainName:NO];
    }
    
    
    
    //    serverurl = [serverurl stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    //    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    //    [manager.requestSerializer setValue:@"text/html" forHTTPHeaderField:@"Accept"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    if ([[method lowercaseString] isEqualToString:@"get"]) {
        [manager GET:serverurl parameters:questionDict progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            //        NSLog(@"JSON: %@", responseObject);
            if(completionBlock){
                if ([self checkResponse:responseObject] && completionBlock) {
                    completionBlock(responseObject,nil);
                }else{
                    completionBlock(responseObject,[[NSError alloc] init]);
                }
                
            }
            
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            //        NSLog(@"Error: %@", error);
            if(completionBlock) {
                completionBlock(nil,error);
            }
            
        }];
    }else{
        
        
        [manager POST:serverurl parameters:questionDict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if(completionBlock){
                //                NSData *jsonData = [myJsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSString* str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                //str = @"{\"result\":400}";
                //NSLog(str);
                NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
                id dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (dict!=nil && [self checkResponse:dict] && completionBlock) {
                    completionBlock(dict,nil);
                }else{
                    completionBlock(dict,[[NSError alloc] init]);
                }
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if(completionBlock) {
                completionBlock(nil,error);
            }
        }];
    }
}
@end










