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

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _host       = @"127.0.0.1";
        _port       = 6379;
        _timeout    = 5;
        
        return self;
    } else {
        return nil;
    }
}

- (instancetype)initWithHost:(NSString *)host
{
    if ((self = [super init])) {
        _host       = host;
        _port       = 6379;
        _timeout    = 5;
    }
    
    return self;
}

- (instancetype)initWithPort:(int)port
{
    if ((self = [super init])) {
        _host       = @"127.0.0.1";
        _port       = port;
        _timeout    = 5;
    }
    
    return self;
}

- (instancetype)initWithHost:(NSString *)host port:(int)port
{
    if ((self = [super init])) {
        _host       = host;
        _port       = port;
        _timeout    = 5;
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
        }
    }
    
    return [self connect];
}

- (BOOL)isConnected
{
    if (_redis != NULL) {
        if ((_redis->err)) {
            return NO;
        }
        return YES;
    }
    
    return NO;
}

- (RedisReply*)command:(char*)format, ...
{
    if (_redis != NULL) {
        va_list ap;
        va_start(ap, format);
        
        @synchronized(self) {
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
    
    RedisReply* reply = [[RedisReply alloc] init];
    
    return reply;
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
    
    if ([reply isStatus] && [[reply string] isEqualToString: @"OK"]) {
        return YES;
    }
    
    return NO;
}

- (NSString*)get:(NSString*)key
{
    RedisReply* reply = [self command:"GET %s", [key UTF8String]];
    
    if ([reply isString]) {
        return [reply string];
    }
    
    return @"";
}


- (void)dealloc
{
    redisFree(_redis);
}

@end
