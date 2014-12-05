//
//  Redis.m
//  Redis
//
//  Created by Axel Etcheverry on 30/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import "Redis.h"
#import "hiredis.h"

@implementation Redis

@synthesize host    = _host;
@synthesize port    = _port;
@synthesize timeout = _timeout;
@synthesize isMulti = _isMulti;


- (instancetype)init
{
    if ((self = [super init])) {
        _host       = @"127.0.0.1";
        _port       = 6379;
        _timeout    = 5;
        _isMulti    = NO;
    }
    
    return self;
}


- (instancetype)initWithHost:(NSString *)host
{
    if ((self = [super init])) {
        _host       = host;
        _port       = 6379;
        _timeout    = 5;
        _isMulti    = NO;
    }
    
    return self;
}


- (instancetype)initWithPort:(int)port
{
    if ((self = [super init])) {
        _host       = @"127.0.0.1";
        _port       = port;
        _timeout    = 5;
        _isMulti    = NO;
    }
    
    return self;
}


- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if ((self = [super init])) {
        _host       = host;
        _port       = port;
        _timeout    = 5;
        _isMulti    = NO;
    }
    
    return self;
}


- (void) setHost:(NSString *)host
{
    _host = host;
}


- (NSString *)host
{
    return _host;
}


- (void)setPort:(int)port
{
    _port = port;
}


- (int)port
{
    return _port;
}


- (void)setTimeout:(int)timeout
{
    _timeout = timeout;
}


- (int)timeout
{
    return _timeout;
}


- (BOOL)connect
{
    struct timeval timeout = {
        _timeout,
        0
    };
    
    _redis = redisConnectWithTimeout(
        [_host UTF8String],
        _port,
        timeout
    );
    
    return [self isConnected];
}


- (BOOL)reconnect
{
    if (_redis != NULL) {
        if (!_redis->flags) {
            redisFree(_redis);
            _redis = NULL;
        }
    }
    
    return [self connect];
}


- (BOOL)isConnected
{
    if (_redis != NULL) {
        
        if ((_redis->err)) {
            return NO;
        } else if (!(_redis->flags & REDIS_CONNECTED)) {
            return NO;
        }
        
        return YES;
    }
    
    return NO;
}


- (RedisReply*)command:(char*)format, ...
{
    if (_redis != NULL) {
        @synchronized(self) {
            va_list ap;
            va_start(ap, format);
            
            redisReply* rr = (redisReply*)redisvCommand(
                _redis,
                format,
                ap
            );
            
            RedisReply* reply = [[RedisReply alloc] initWithReply: rr];
            
            freeReplyObject(rr);
            
            va_end(ap);
            
            return reply;
        }
    }
    
    return [[RedisReply alloc] init];
}


- (RedisReply*)commandWithArray:(NSArray*)args
{
    if (_redis != NULL) {
        @synchronized(self) {
            
            redisReply* rr = (redisReply*)redisCommandArgv(
                _redis,
                (int)[args count],
                [self cVectorFromArray: args],
                NULL
            );
            
            RedisReply* reply = [[RedisReply alloc] initWithReply: rr];
            
            freeReplyObject(rr);
            
            return reply;
        }
    }
    
    return [[RedisReply alloc] init];
}


- (const char**)cVectorFromArray:(NSArray*)array
{
	char ** vector = malloc(sizeof(char*) * (int)[array count]);
	NSEnumerator * e = [array objectEnumerator];
	id o;
    
	while (o = [e nextObject]) {
		int i = (int)[array indexOfObject:o];
        
		if ([o isKindOfClass:[NSString class]]) {
			vector[i] = (char*)[o UTF8String];
		} else if ([o isKindOfClass:[NSNumber class]]) {
			vector[i] = (char*)[[o stringValue] UTF8String];
		}
	}
    
	return (const char**)vector;
}


- (BOOL)multi
{
    RedisReply* reply = [self command:"MULTI"];

    if ([reply isStatus]) {
        _isMulti = YES;
        
        return [[reply string] isEqualToString: @"OK"];
    }
    
    return NO;
}


- (RedisReply *)exec
{
    if (_isMulti) {
        
        _isMulti = NO;
        
        RedisReply* reply = [self command:"EXEC"];
        
        if ([reply isArray]) {
            return reply;
        }
    }
    
    @throw [[NSException alloc] initWithName: @"RuntimeException"
                                      reason: @"No multi transaction"
                                    userInfo: nil
            ];
}


- (BOOL)isMulti
{
    return _isMulti;
}


- (BOOL)select:(NSInteger)db
{
    RedisReply* reply = [self command:"SELECT %d", db];
    
    if ([reply isStatus] && [[reply string] isEqualToString: @"OK"]) {
        return YES;
    }
    
    return NO;
}


- (BOOL)ping
{
    RedisReply* reply = [self command:"PING"];
    
    if ([[reply string] isEqualToString: @"PONG"]) {
        return YES;
    }
    
    return NO;
}


- (BOOL)auth:(NSString*)password
{
    RedisReply* reply = [self command:"AUTH %b", [password UTF8String], [password length]];
    
    if ([reply isError]) {
        return NO;
    }
    
    return YES;
}


- (BOOL)set:(NSString*)key value:(NSString*)val
{
    RedisReply* reply = [self command:"SET %s %b", [key UTF8String], [val UTF8String], [val length]];
    
    NSString* expected = @"OK";
    
    if (_isMulti) {
        expected = @"QUEUED";
    }

    if ([reply isStatus] && [[reply string] isEqualToString: expected]) {
        return YES;
    }
    
    return NO;
}


- (NSString*)get:(NSString*)key
{
    RedisReply* reply = [self command:"GET %s", [key UTF8String]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @"";
        }
    }
    
    if ([reply isString]) {
        return [reply string];
    }
    
    return @"";
}


- (NSNumber*)incr:(NSString*)key
{
    RedisReply* reply = [self command:"INCR %s", [key UTF8String]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    if ([reply isError]) {
        @throw [[NSException alloc] initWithName: @"RuntimeException"
                                          reason: @"value is not an integer or out of range"
                                        userInfo: nil
        ];
    }
    
    return [reply integer];
}


- (NSNumber*)incr:(NSString *)key by:(NSNumber*)value
{
    RedisReply* reply = [self command:"INCRBY %s %lld", [key UTF8String], [value longLongValue]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    if ([reply isError]) {
        @throw [[NSException alloc] initWithName: @"RuntimeException"
                                          reason: @"value is not an integer or out of range"
                                        userInfo: nil
        ];
    }
    
    return [reply integer];
}


- (NSNumber*)decr:(NSString*)key
{
    RedisReply* reply = [self command:"DECR %s", [key UTF8String]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    if ([reply isError]) {
        @throw [[NSException alloc] initWithName: @"RuntimeException"
                                          reason: @"value is not an integer or out of range"
                                        userInfo: nil
        ];
    }
    
    return [reply integer];
}


- (NSNumber*)decr:(NSString*)key by:(NSNumber*)value
{
    RedisReply* reply = [self command:"DECRBY %s %lld", [key UTF8String], [value longLongValue]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    if ([reply isError]) {
        @throw [[NSException alloc] initWithName: @"RuntimeException"
                                          reason: @"value is not an integer or out of range"
                                        userInfo: nil
        ];
    }
    
    return [reply integer];
}


- (NSNumber*)del:(NSString*)key, ...
{
    va_list args;
    va_start(args, key);
    
    NSMutableArray* data = [[NSMutableArray alloc] init];
    
    [data addObject: @"DEL"];
    
    for (NSString *arg = key; arg != nil; arg = va_arg(args, NSString*)) {
        [data addObject: arg];
    }
    
    va_end(args);
    
    RedisReply* reply = [self commandWithArray: data];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    if ([reply isError]) {
        return @0;
    }
    
    return [reply integer];
}


- (BOOL)exists:(NSString*)key
{
    RedisReply* reply = [self command:"EXISTS %s", [key UTF8String]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return YES;
        }
    }

    return [[reply integer] isEqualToNumber:@1];
}


- (BOOL)expire:(NSString*)key seconds:(NSNumber*)value
{
    RedisReply* reply = [self command:"EXPIRE %s %lld", [key UTF8String], [value longLongValue]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return YES;
        }
    }
    
    return [[reply integer] isEqualToNumber:@1];
}


- (BOOL)expire:(NSString*)key at:(NSDate*)value
{
    RedisReply* reply = [self command:"EXPIREAT %s %lld", [key UTF8String], (long)[value timeIntervalSince1970]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return YES;
        }
    }
    
    return [[reply integer] isEqualToNumber:@1];
}


- (NSNumber*)ttl:(NSString*)key
{
    RedisReply* reply = [self command:"TTL %s", [key UTF8String]];
    
    if (_isMulti) {
        if ([reply isStatus] && [[reply string] isEqualToString: @"QUEUED"]) {
            return @0;
        }
    }
    
    return [reply integer];
}


- (BOOL)flushdb
{
    RedisReply* reply = [self command:"FLUSHDB"];
    
    NSString* expected = @"OK";
    
    if (_isMulti) {
        expected = @"QUEUED";
    }
    
    if ([reply isStatus] && [[reply string] isEqualToString: expected]) {
        return YES;
    }
    
    return NO;
}


- (BOOL)flushall
{
    RedisReply* reply = [self command:"FLUSHALL"];
    
    NSString* expected = @"OK";
    
    if (_isMulti) {
        expected = @"QUEUED";
    }
    
    if ([reply isStatus] && [[reply string] isEqualToString: expected]) {
        return YES;
    }
    
    return NO;
}


- (RedisType)type:(NSString*)key
{
    RedisReply* reply = [self command:"TYPE %s", [key UTF8String]];
    
    if ([reply isStatus]) {
        
        if ([[reply string] isEqualToString:@"string"]) {
            return RedisTypeString;
        } else if ([[reply string] isEqualToString:@"list"]) {
            return RedisTypeList;
        } else if ([[reply string] isEqualToString:@"set"]) {
            return RedisTypeSet;
        } else if ([[reply string] isEqualToString:@"zset"]) {
            return RedisTypeZset;
        } else if ([[reply string] isEqualToString:@"hash"]) {
            return RedisTypeHash;
        }
    }
    
    return RedisTypeUnknown;
}


- (RedisInfo *)info
{
    RedisReply* reply = [self command:"INFO"];
    
    if ([reply isString]) {
        return [[RedisInfo alloc] initWithInfo:[reply string]];
    }
    
    return [[RedisInfo alloc] init];
}


- (void)dealloc
{
    if (_redis != NULL) {
        redisFree(_redis);
        _redis = NULL;
    }
}

@end
