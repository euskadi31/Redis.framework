//
//  RedisReply.m
//  Redis
//
//  Created by Axel Etcheverry on 31/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import "RedisReply.h"
#import "hiredis.h"

@implementation RedisReply

@synthesize type        = _type;
@synthesize string      = _string;
@synthesize integer     = _integer;
@synthesize elements    = _elements;

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _type       = REDIS_REPLY_NIL;
        _string     = @"";
        _integer    = 0;
        _elements   = [[NSMutableArray alloc] init];
        
        return self;
    } else {
        return nil;
    }
}

- (instancetype)initWithReply:(void*)reply
{
    if ((self = [super init])) {
        
        redisReply* r = (redisReply*)reply;
        
        _type       = r->type;
        _string     = @"";
        _integer    = 0;
        _elements   = [[NSMutableArray alloc] init];
        
        switch (r->type) {
            case REDIS_REPLY_INTEGER:
                _integer = [[NSNumber alloc] initWithLongLong:r->integer];
                break;
            case REDIS_REPLY_ERROR:
            case REDIS_REPLY_STRING:
            case REDIS_REPLY_STATUS:
                _string = [[NSString alloc] initWithUTF8String: r->str];
                //NSLog(@"Debug: %s : %s", __PRETTY_FUNCTION__, [_string UTF8String]);
                break;
            case REDIS_REPLY_ARRAY:
                for (int i = 0; i < r->elements; i++) {
                    [_elements addObject: [[RedisReply alloc] initWithReply:r->element[i]]];
                }
                break;
        }
    }
    
    return self;
}

- (void)setType:(int)type
{
    _type = type;
}

- (int)type
{
    return _type;
}

- (void)setString:(NSString *)string
{
    _string = string;
    _type = REDIS_REPLY_STRING;
}

- (NSString *)string
{
    return _string;
}

- (void)setInteger:(NSNumber*)integer
{
    _integer = integer;
    _type = REDIS_REPLY_INTEGER;
}

- (NSNumber*)integer
{
    return _integer;
}

- (void)addObject:(RedisReply*)item
{
    [_elements addObject: item];
    
    if (_type != REDIS_REPLY_ARRAY) {
        _type = REDIS_REPLY_ARRAY;
    }
}

- (id)value
{
    switch (_type) {
        case REDIS_REPLY_ARRAY:
            return _elements;
        case REDIS_REPLY_INTEGER:
            return _integer;
        default:
            return _string;
    }
}

- (NSDictionary*)dictionary
{
    NSMutableDictionary* hash = [[NSMutableDictionary alloc] init];
    
    if ([self isArray]) {
        
        NSMutableString* tmpkey = [[NSMutableString alloc] init];
        
        for (RedisReply* item in _elements) {
            if ([tmpkey length] == 0) {
                [tmpkey setString: [item string]];
            } else {
                [hash setObject:[item string] forKey: tmpkey];
                [tmpkey setString: @""];
            }
        }
        
    }

    return [[NSDictionary alloc] initWithDictionary: hash];
}

- (NSArray*)array
{
    NSMutableArray* list = [[NSMutableArray alloc] init];
    
    if ([self isArray]) {
        for (RedisReply* item in _elements) {
            [list addObject: [item string]];
        }
    }
    
    return list;
}

- (NSMutableArray*)elements
{
    return _elements;
}

- (BOOL)isError
{
    return (_type == REDIS_REPLY_ERROR);
}

- (BOOL)isNil
{
    return (_type == REDIS_REPLY_NIL);
}

- (BOOL)isStatus
{
    return (_type == REDIS_REPLY_STATUS);
}

- (BOOL)isString
{
    return (_type == REDIS_REPLY_STRING);
}

- (BOOL)isInteger
{
    return (_type == REDIS_REPLY_INTEGER);
}

- (BOOL)isArray
{
    return (_type == REDIS_REPLY_ARRAY);
}

- (NSString *)description
{
    return @"";
}

@end
