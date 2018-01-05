//
//  BaseModel.h
//  Hospice
//
//  Created by Twinklestar on 1/26/16.
//  Copyright © 2016 Hospice. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject

@property (copy, nonatomic) NSString* create_datetime;
@property (copy, nonatomic) NSString* modify_datetime;
@property (copy, nonatomic) NSString* sqlmode;
@property (copy, nonatomic) NSString* sql;

@property (copy, nonatomic) NSString* response;
@property (copy, nonatomic) NSString* error;


-(instancetype)initWithDictionary:(NSDictionary*) dict;
+(NSMutableDictionary*)getQuestionDict:(id)targetClass;
+(void)parseResponse:(id)targetClass Dict:(NSDictionary*)dict;
+(id)getDuplicate:(id)targetClass;

+(NSData*)buildJsonData:(id)targetClass;
+(NSString*)getInsertSql:(id)targetClass TableName:(NSString*)tableName Exceptions:(NSMutableArray*)exceptions;
@end
