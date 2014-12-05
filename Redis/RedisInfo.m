//
//  RedisInfo.m
//  Redis
//
//  Created by Axel Etcheverry on 02/09/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import "RedisInfo.h"
#include <ctype.h>

@implementation RedisInfo

@synthesize server      = _server;
@synthesize clients     = _clients;
@synthesize memory      = _memory;
@synthesize persistence = _persistence;
@synthesize stats       = _stats;
@synthesize replication = _replication;
@synthesize cpu         = _cpu;
@synthesize keyspace    = _keyspace;

- (instancetype)init
{
    if ((self = [super init])) {
        _server         = [[NSMutableDictionary alloc] init];
        _clients        = [[NSMutableDictionary alloc] init];
        _memory         = [[NSMutableDictionary alloc] init];
        _persistence    = [[NSMutableDictionary alloc] init];
        _stats          = [[NSMutableDictionary alloc] init];
        _replication    = [[NSMutableDictionary alloc] init];
        _cpu            = [[NSMutableDictionary alloc] init];
        _keyspace       = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (instancetype)initWithInfo:(NSString *)info
{
    if ((self = [super init])) {
        _server         = [[NSMutableDictionary alloc] init];
        _clients        = [[NSMutableDictionary alloc] init];
        _memory         = [[NSMutableDictionary alloc] init];
        _persistence    = [[NSMutableDictionary alloc] init];
        _stats          = [[NSMutableDictionary alloc] init];
        _replication    = [[NSMutableDictionary alloc] init];
        _cpu            = [[NSMutableDictionary alloc] init];
        _keyspace       = [[NSMutableDictionary alloc] init];
        
        [self parse: info];
    }
    
    return self;
}

- (void)parse:(NSString *)info
{
    RedisInfoToken state = RedisInfoTokenSection;
    
    NSMutableString* section    = [[NSMutableString alloc] init];
    NSMutableString* key        = [[NSMutableString alloc] init];
    NSMutableString* val        = [[NSMutableString alloc] init];
    
    for (NSUInteger i = 0; i < [info length]; i++) {
        char chr = [info characterAtIndex: i];
        
        switch (state) {
            case RedisInfoTokenSection:
                if (chr == '#') {
                    continue;
                }
                
                if ((chr == ' ') && ([section length] == 0)) {
                    continue;
                }
                
                if (chr == '\n' || chr == '\r') {
                    state = RedisInfoTokenKey;
                    continue;
                }
                
                [section appendString: [NSString stringWithFormat: @"%c" , tolower(chr)]];
                
                break;
                
            case RedisInfoTokenKey:
                
                if (chr == '\n' && [key length] == 0) {
                    continue;
                }
                
                if ((chr == ' ') && ([key length] == 0)) {
                    continue;
                }
                
                if (chr == '#' || chr == '\n') {
                    state = RedisInfoTokenSection;
                    
                    [section setString: @""];
                    
                    continue;
                }
                
                if (chr == ':') {
                    state = RedisInfoTokenVal;
                    continue;
                }
                
                [key appendString: [NSString stringWithFormat: @"%c" , tolower(chr)]];
                
                break;
                
            case RedisInfoTokenVal:
                
                if (chr == '\n' || chr == '\r') {
                    state = RedisInfoTokenKey;
                    
                    [self addInfo: section key: key val: [NSString stringWithString: val]];
                    
                    [key setString: @""];
                    [val setString: @""];
                    
                    continue;
                }
                
                [val appendString: [NSString stringWithFormat: @"%c" , tolower(chr)]];
                
                break;
        }
        
    }
}

- (void)addInfo:(NSString*)section key:(NSString*)keyname val:(NSString*)value
{
    if ([section isEqualToString: @"server"]) {
        [_server setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"clients"]) {
        [_clients setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"memory"]) {
        [_memory setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"persistence"]) {
        [_persistence setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"stats"]) {
        [_stats setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"replication"]) {
        [_replication setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"cpu"]) {
        [_cpu setObject: value forKey: keyname];
    } else if ([section isEqualToString: @"keyspace"]) {
        [_keyspace setObject: value forKey: keyname];
    }
}

- (NSMutableDictionary *)server
{
    return _server;
}

@end
