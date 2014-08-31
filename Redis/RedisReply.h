//
//  RedisReply.h
//  Redis
//
//  Created by Axel Etcheverry on 31/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedisReply : NSObject

@property int type;
@property NSString* string;
@property NSNumber* integer;
@property (nonatomic) NSMutableArray* elements;

- (instancetype)init;

- (instancetype)initWithReply:(void*)reply;

- (void)addObject:(RedisReply*)item;

- (NSDictionary*)dictionary;

- (NSArray*)array;

- (id)value;

- (BOOL)isError;

- (BOOL)isNil;

- (BOOL)isStatus;

- (BOOL)isString;

- (BOOL)isInteger;

- (BOOL)isArray;

- (NSString *)description;

@end
