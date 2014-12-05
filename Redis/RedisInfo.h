//
//  RedisInfo.h
//  Redis
//
//  Created by Axel Etcheverry on 02/09/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RedisInfoToken) {
    RedisInfoTokenSection,
    RedisInfoTokenKey,
    RedisInfoTokenVal
};

@interface RedisInfo : NSObject

@property (nonatomic) NSMutableDictionary* server;
@property (nonatomic) NSMutableDictionary* clients;
@property (nonatomic) NSMutableDictionary* memory;
@property (nonatomic) NSMutableDictionary* persistence;
@property (nonatomic) NSMutableDictionary* stats;
@property (nonatomic) NSMutableDictionary* replication;
@property (nonatomic) NSMutableDictionary* cpu;
@property (nonatomic) NSMutableDictionary* keyspace;

- (instancetype)init;

- (instancetype)initWithInfo:(NSString*)info;

- (void)parse:(NSString*)info;

- (void)addInfo:(NSString*)section key:(NSString*)key val:(NSString*)val;

@end
