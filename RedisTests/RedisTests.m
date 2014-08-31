//
//  RedisTests.m
//  RedisTests
//
//  Created by Axel Etcheverry on 30/08/2014.
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
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    RedisReply* reply = [redis command:"GET foo"];
    
    XCTAssertTrue([reply isString]);
    XCTAssertEqualObjects([reply value], @"bar");
}

- (void)testGet
{
    Redis* redis = [[Redis alloc] init];
    
    XCTAssertTrue([redis connect]);
    
    XCTAssertTrue([redis set:@"foo" value:@"bar"]);
    
    XCTAssertEqualObjects([redis get:@"foo"], @"bar");
}

/*
- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}*/

@end
