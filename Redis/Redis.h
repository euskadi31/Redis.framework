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
#import "RedisType.h"
#import "RedisInfo.h"

@interface Redis : NSObject
{
    redisContext* _redis;
}

@property (nonatomic) NSString* host;
@property (nonatomic) int port;
@property (nonatomic) int timeout;
@property (nonatomic, getter = isMulti) BOOL isMulti;


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

// send redis command with array
- (RedisReply*)commandWithArray:(NSArray*)args;

// Mark the start of a transaction block
- (BOOL)multi;

// Execute all commands issued after MULTI
- (RedisReply*)exec;

// Change the selected database for the current connection
- (BOOL)select:(NSInteger)db;

// Ping the server
- (BOOL)ping;

// Authenticate to the server
- (BOOL)auth:(NSString*)password;

// Set the string value of a key
- (BOOL)set:(NSString*)key value:(NSString*)val;

// Get the value of a key
- (NSString*)get:(NSString*)key;

// Increment the integer value of a key by one
- (NSNumber*)incr:(NSString*)key;

// Increment the integer value of a key by the given amount
- (NSNumber*)incr:(NSString*)key by:(NSNumber*)value;

// Decrement the integer value of a key by one
- (NSNumber*)decr:(NSString*)key;

// Decrement the integer value of a key by the given number
- (NSNumber*)decr:(NSString*)key by:(NSNumber*)value;

// Delete a key
- (NSNumber*)del:(NSString*)key, ...;

// Determine if a key exists
- (BOOL)exists:(NSString*)key;

// Set a key's time to live in seconds
- (BOOL)expire:(NSString*)key seconds:(NSNumber*)value;

// Set the expiration for a key as a UNIX timestamp
- (BOOL)expire:(NSString*)key at:(NSDate*)value;

// Get the time to live for a key
- (NSNumber*)ttl:(NSString*)key;

// Remove all keys from the current database
- (BOOL)flushdb;

// Remove all keys from all databases
- (BOOL)flushall;

// Determine the type stored at key
- (RedisType)type:(NSString*)key;

// Get information and statistics about the server
- (RedisInfo*)info;



- (const char**)cVectorFromArray:(NSArray*)array;

- (void)dealloc;

@end
