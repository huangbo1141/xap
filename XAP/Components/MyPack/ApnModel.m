//
//  ApnModel.m
//  SchoolApp
//
//  Created by Twinklestar on 4/25/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "ApnModel.h"
#import "BaseModel.h"

@implementation ApnModel
-(instancetype)initWithDictionary:(NSDictionary*) dict{
    self = [super init];
    if(self){
        [BaseModel parseResponse:self Dict:dict];
    }
    return self;
}
@end
