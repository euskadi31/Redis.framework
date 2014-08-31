//
//  Redis.h
//  Redis
//
//  Created by Axel Etcheverry on 30/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "hiredis.h"
#import "RedisReply.h"

@interface Redis : NSObject
{
    redisContext* _redis;
}

@property (nonatomic) NSString* host;
@property (nonatomic) int port;
@property (nonatomic) int timeout;

- (instancetype)init;

- (instancetype)initWithHost:(NSString*)host;

- (instancetype)initWithPort:(int)port;

- (instancetype)initWithHost:(NSString *)host port:(int)port;

// Connect to redis server
- (BOOL)connect;

// Reconnect to redis server
- (BOOL)reconnect;

// Check if connected to redis server
- (BOOL)isConnected;

// send redis comment
- (RedisReply*)command:(char*)format, ...;

// Change the selected database for the current connection
- (BOOL)select:(NSInteger)db;

// Ping the server
- (BOOL)ping;

// Authenticate to the server
- (BOOL)auth:(NSString*)password;

// Set the string value of a key
- (BOOL)set:(NSString*)key value:(NSString*)val;

- (NSString*)get:(NSString*)key;

- (void)dealloc;

@end
