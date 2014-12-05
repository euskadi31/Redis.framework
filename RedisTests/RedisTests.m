//
//  RedisTests.m
//  Redis
//
//  Created by Axel Etcheverry on 31/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Redis.h"

@interface RedisTests : XCTestCase

@end

@implementation RedisTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


- (void)testInit
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertEqualObjects([redis host], @"127.0.0.1");
    XCTAssertEqual([redis port], 6379);
}

- (void)testInitWithHost
{
    Redis* redis = [[Redis alloc] initWithHost:@"localhost"];
    
    XCTAssertEqualObjects([redis host], @"localhost");
    XCTAssertEqual([redis port], 6379);
}

- (void)testInitWithPort
{
    Redis* redis = [[Redis alloc] initWithPort: 1337];
    
    XCTAssertEqualObjects([redis host], @"127.0.0.1");
    XCTAssertEqual([redis port], 1337);
}

- (void)testInitWithHostAndPort
{
    Redis* redis = [[Redis alloc] initWithHost:@"localhost" port: 1337];
    
    XCTAssertEqualObjects([redis host], @"localhost");
    XCTAssertEqual([redis port], 1337);
}

- (void)testHost
{
    Redis* redis = [[Redis alloc] init];
    
    [redis setHost:@"localhost"];
    
    XCTAssertEqualObjects([redis host], @"localhost");
    XCTAssertEqual([redis port], 6379);
}

- (void)testPort
{
    Redis* redis = [[Redis alloc] init];
    
    [redis setPort: 1337];
    
    XCTAssertEqualObjects([redis host], @"127.0.0.1");
    XCTAssertEqual([redis port], 1337);
}

- (void)testConnect
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
}

- (void)testReconnect
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis reconnect]);
}

- (void)testIsConnected
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertFalse([redis isConnected]);
}

- (void)testCommand
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    RedisReply* reply = [redis command:"SET foo bar"];
    
    XCTAssertTrue([reply isStatus]);
    XCTAssertEqualObjects([reply value], @"OK");
    
    reply = [redis command:"GET foo"];
    
    XCTAssertTrue([reply isString]);
    XCTAssertEqualObjects([reply value], @"bar");
    
    reply = [redis command:"SET toto %s", "bar1"];
    
    XCTAssertTrue([reply isStatus]);
    XCTAssertEqualObjects([reply value], @"OK");
    
    reply = [redis command:"GET toto"];
    
    XCTAssertTrue([reply isString]);
    XCTAssertEqualObjects([reply value], @"bar1");
    
    [redis command:"FLUSHDB"];
}

- (void)testSelect
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis select: 4]);
}

- (void)testPing
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis ping]);
}

- (void)testSet
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    RedisReply* reply = [redis command:"GET foo"];
    
    XCTAssertTrue([reply isString]);
    XCTAssertEqualObjects([reply value], @"bar");
    
    [redis command:"FLUSHDB"];
}

- (void)testGet
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    XCTAssertEqualObjects([redis get:@"foo"], @"bar");
    
    [redis command:"FLUSHDB"];
}

- (void)testIncr
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertEqualObjects([redis incr:@"test"], @1);
    
    XCTAssertTrue([redis set:@"test" value:@"bar"]);
    
    XCTAssertThrows([redis incr:@"test"]);
    
    XCTAssertEqualObjects([redis incr:@"hits" by: @2], @2);
    
    [redis command:"FLUSHDB"];
}

- (void)testDecr
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertEqualObjects([redis incr:@"test"], @1);
    
    XCTAssertEqualObjects([redis decr:@"test"], @0);
    
    XCTAssertTrue([redis set:@"test" value:@"bar"]);
    
    XCTAssertThrows([redis decr:@"test"]);
    
    XCTAssertEqualObjects([redis incr:@"hits" by: @2], @2);
    
    XCTAssertEqualObjects([redis decr:@"hits" by: @2], @0);
    
    [redis command:"FLUSHDB"];
}

- (void)testDel
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertEqualObjects([redis incr:@"test"], @1);
    
    XCTAssertEqualObjects([redis del: @"test"], @1);
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    XCTAssertTrue([redis set:@"foo1" value:@"bar1"]);
    
    NSNumber* r = [redis del:@"foo", @"foo1"];
    
    XCTAssertEqualObjects(r, @2);

    [redis command:"FLUSHDB"];
}

- (void)testMulti
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertFalse([redis isMulti]);
    
    XCTAssertTrue([redis multi]);
    
    XCTAssertTrue([redis isMulti]);
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    RedisReply* reply = [redis exec];
    
    XCTAssertFalse([redis isMulti]);
    
    XCTAssertTrue([reply isArray]);
    
    XCTAssertTrue([[[reply elements] objectAtIndex: 0] isStatus]);
    
    [redis command:"FLUSHDB"];
}

- (void)testExists
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertFalse([redis exists:@"foo"]);
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    XCTAssertTrue([redis exists:@"foo"]);
    
    [redis command:"FLUSHDB"];
}

- (void)testExpire
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    XCTAssertTrue([redis expire:@"foo" seconds:@2]);
    
    XCTAssertTrue([redis exists:@"foo"]);
    
    [NSThread sleepForTimeInterval: 3];
    
    XCTAssertFalse([redis exists:@"foo"]);
    
    [redis command:"FLUSHDB"];
}


- (void)testExpireat
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    NSDate* date = [[NSDate date] dateByAddingTimeInterval: 2];
    
    XCTAssertTrue([redis expire:@"foo" at: date]);
    
    XCTAssertTrue([redis exists:@"foo"]);
    
    [NSThread sleepForTimeInterval: 2];
    
    XCTAssertFalse([redis exists:@"foo"]);
    
    [redis command:"FLUSHDB"];
}

- (void)testTtl
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    [redis command:"FLUSHDB"];
    
    XCTAssertTrue([redis set: @"foo" value: @"bar"]);
    
    XCTAssertTrue([redis expire: @"foo" seconds: @50]);
    
    XCTAssertEqualObjects([redis ttl: @"foo"], @50);
    
    [redis command:"FLUSHDB"];
}

- (void)testFlushdb
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    XCTAssertTrue([redis flushdb]);
}

- (void)testType
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis flushdb]);
    
    XCTAssertTrue([redis set: @"foo" value: @"bar"]);
    
    XCTAssertEqual([redis type:@"foo"], RedisTypeString);
    
    XCTAssertTrue([redis incr: @"foo1"]);
    
    XCTAssertEqual([redis type:@"foo"], RedisTypeString);
    
    [redis command:"RPUSH mylist hello"];
    
    XCTAssertEqual([redis type:@"mylist"], RedisTypeList);
    
    [redis command:"HSET myhash field1 Hello"];
    
    XCTAssertEqual([redis type:@"myhash"], RedisTypeHash);
    
    [redis command:"SADD myset Hello"];
    
    XCTAssertEqual([redis type:@"myset"], RedisTypeSet);
    
    [redis command:"ZADD myzset 1 one"];
    
    XCTAssertEqual([redis type:@"myzset"], RedisTypeZset);
    
    XCTAssertTrue([redis flushdb]);
}

- (void)testInfo
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis flushdb]);
    
    XCTAssertTrue([redis set: @"foo" value: @"bar"]);
    
    RedisInfo* info = [redis info];
    
    XCTAssertNotEqual([[info server] count], 0);
    
    XCTAssertEqualObjects([info server][@"tcp_port"], @"6379");
    
    XCTAssertTrue([redis flushdb]);
}

/*
- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}
*/
@end
