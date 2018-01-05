//
//  NetworkParser.h
//  SchoolApp
//
//  Created by TwinkleStar on 11/27/15.
//  Copyright © 2015 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^NetworkCompletionBlock)(NSDictionary*dict, NSError* error);


@interface NetworkParser : NSObject
+ (instancetype)sharedManager;

-(void)callNetwork:(NSString*)serverurl Data:(NSMutableDictionary*)questionDict withCompletionBlock:(NetworkCompletionBlock)completionBlock method:(NSString*)method;

@end
