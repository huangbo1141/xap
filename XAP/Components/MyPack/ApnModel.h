//
//  ApnModel.h
//  SchoolApp
//
//  Created by Twinklestar on 4/25/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApnModel : NSObject


@property(copy,nonatomic) NSString* result;
@property(copy,nonatomic) NSString* detail;
@property(copy,nonatomic) NSString* error;

-(instancetype)initWithDictionary:(NSDictionary*) dict;

@end
