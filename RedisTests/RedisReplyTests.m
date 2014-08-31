//
//  RedisReplyTests.m
//  Redis
//
//  Created by Axel Etcheverry on 31/08/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RedisReply.h"
#import "hiredis.h"

@interface RedisReplyTests : XCTestCase

@end

@implementation RedisReplyTests

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
    RedisReply* reply = [[RedisReply alloc] init];
    
    XCTAssertEqual([reply type], REDIS_REPLY_NIL);
    XCTAssertEqualObjects([reply string], @"");
    XCTAssertEqualObjects([reply integer], 0);
}

- (void)testType
{
    RedisReply* reply = [[RedisReply alloc] init];
    
    XCTAssertEqual([reply type], REDIS_REPLY_NIL);
    XCTAssertFalse([reply isError]);
    XCTAssertTrue([reply isNil]);
    XCTAssertFalse([reply isStatus]);
    XCTAssertFalse([reply isString]);
    XCTAssertFalse([reply isInteger]);
    XCTAssertFalse([reply isArray]);
    
    [reply setType: REDIS_REPLY_ERROR];
    
    XCTAssertEqual([reply type], REDIS_REPLY_ERROR);
    XCTAssertTrue([reply isError]);
    XCTAssertFalse([reply isNil]);
    XCTAssertFalse([reply isStatus]);
    XCTAssertFalse([reply isString]);
    XCTAssertFalse([reply isInteger]);
    XCTAssertFalse([reply isArray]);
    
    [reply setType: REDIS_REPLY_STATUS];
    
    XCTAssertEqual([reply type], REDIS_REPLY_STATUS);
    XCTAssertFalse([reply isError]);
    XCTAssertFalse([reply isNil]);
    XCTAssertTrue([reply isStatus]);
    XCTAssertFalse([reply isString]);
    XCTAssertFalse([reply isInteger]);
    XCTAssertFalse([reply isArray]);

    [reply setType: REDIS_REPLY_STRING];
    
    XCTAssertEqual([reply type], REDIS_REPLY_STRING);
    XCTAssertFalse([reply isError]);
    XCTAssertFalse([reply isNil]);
    XCTAssertFalse([reply isStatus]);
    XCTAssertTrue([reply isString]);
    XCTAssertFalse([reply isInteger]);
    XCTAssertFalse([reply isArray]);
    
    [reply setType: REDIS_REPLY_INTEGER];
    
    XCTAssertEqual([reply type], REDIS_REPLY_INTEGER);
    XCTAssertFalse([reply isError]);
    XCTAssertFalse([reply isNil]);
    XCTAssertFalse([reply isStatus]);
    XCTAssertFalse([reply isString]);
    XCTAssertTrue([reply isInteger]);
    XCTAssertFalse([reply isArray]);
    
    [reply setType: REDIS_REPLY_ARRAY];
    
    XCTAssertEqual([reply type], REDIS_REPLY_ARRAY);
    XCTAssertFalse([reply isError]);
    XCTAssertFalse([reply isNil]);
    XCTAssertFalse([reply isStatus]);
    XCTAssertFalse([reply isString]);
    XCTAssertFalse([reply isInteger]);
    XCTAssertTrue([reply isArray]);
}

- (void)testString
{
    RedisReply* reply = [[RedisReply alloc] init];
    
    [reply setString:@"foo"];
    
    XCTAssertEqual([reply type], REDIS_REPLY_STRING);
    XCTAssertEqualObjects([reply string], @"foo");
}

- (void)testInteger
{
    RedisReply* reply = [[RedisReply alloc] init];
    
    [reply setInteger: [[NSNumber alloc] initWithInteger:12345]];
    
    XCTAssertEqual([reply type], REDIS_REPLY_INTEGER);
    XCTAssertEqualObjects([reply integer], [[NSNumber alloc] initWithInteger:12345]);
}

- (void)testInitWithReply
{
    redisReply *reply = (redisReply*)malloc(sizeof(redisReply));
    reply->type = REDIS_REPLY_STRING;
    
    char buf[6] = "hello";
    
    reply->str = buf;
    reply->len = sizeof(buf)-1;
    
    RedisReply* r = [[RedisReply alloc] initWithReply: reply];
    
    free(reply);
    
    XCTAssertEqual([r type], REDIS_REPLY_STRING);
    XCTAssertEqualObjects([r string], @"hello");
}

- (void)testDictionary
{
    RedisReply* r = [[RedisReply alloc] init];
    
    [r setType: REDIS_REPLY_ARRAY];
    
    XCTAssertEqual([[r elements] count], 0);
    
    RedisReply* r1 = [[RedisReply alloc] init];
    RedisReply* r2 = [[RedisReply alloc] init];
    RedisReply* r3 = [[RedisReply alloc] init];
    RedisReply* r4 = [[RedisReply alloc] init];
    
    [r1 setType: REDIS_REPLY_STRING];
    [r1 setString: @"name"];
    
    [r2 setType: REDIS_REPLY_STRING];
    [r2 setString: @"Axel Etcheverry"];
    
    [r3 setType: REDIS_REPLY_STRING];
    [r3 setString: @"email"];
    
    [r4 setType: REDIS_REPLY_STRING];
    [r4 setString: @"axel@dacteev.com"];
    
    [r addObject: r1];
    [r addObject: r2];
    [r addObject: r3];
    [r addObject: r4];
    
    XCTAssertEqual([[r elements] count], 4);
    
    NSDictionary* hash = [r dictionary];
    
    XCTAssertEqual([hash count], 2);
    
    XCTAssertEqualObjects(hash[@"name"], @"Axel Etcheverry");
    XCTAssertEqualObjects(hash[@"email"], @"axel@dacteev.com");
}

- (void)testArray
{
    RedisReply* r = [[RedisReply alloc] init];

    XCTAssertEqual([[r elements] count], 0);
    
    RedisReply* r1 = [[RedisReply alloc] init];
    RedisReply* r2 = [[RedisReply alloc] init];
    RedisReply* r3 = [[RedisReply alloc] init];
    RedisReply* r4 = [[RedisReply alloc] init];
    
    [r1 setType: REDIS_REPLY_STRING];
    [r1 setString: @"item 1"];
    
    [r2 setType: REDIS_REPLY_STRING];
    [r2 setString: @"item 2"];
    
    [r3 setType: REDIS_REPLY_STRING];
    [r3 setString: @"item 3"];
    
    [r4 setType: REDIS_REPLY_STRING];
    [r4 setString: @"item 4"];
    
    XCTAssertEqual([r type], REDIS_REPLY_NIL);
    
    [r addObject: r1];
    
    XCTAssertEqual([r type], REDIS_REPLY_ARRAY);
    
    [r addObject: r2];
    [r addObject: r3];
    [r addObject: r4];
    
    XCTAssertEqual([[r elements] count], 4);
    
    NSArray* list = [r array];
    
    XCTAssertEqual([list count], 4);
    
    XCTAssertEqualObjects([list objectAtIndex: 0], @"item 1");
    XCTAssertEqualObjects([list objectAtIndex: 1], @"item 2");
    XCTAssertEqualObjects([list objectAtIndex: 2], @"item 3");
    XCTAssertEqualObjects([list objectAtIndex: 3], @"item 4");
}

- (void)testValue
{
    RedisReply* reply = [[RedisReply alloc] init];
    
    [reply setString:@"foo"];
    
    XCTAssertEqualObjects([reply value], @"foo");
    
    reply = [[RedisReply alloc] init];
    
    [reply setInteger: [[NSNumber alloc] initWithInt: 1234]];
    
    XCTAssertEqualObjects([reply value], [[NSNumber alloc] initWithInt: 1234]);
    
    reply = [[RedisReply alloc] init];
    
    RedisReply* r1 = [[RedisReply alloc] init];
    RedisReply* r2 = [[RedisReply alloc] init];
    RedisReply* r3 = [[RedisReply alloc] init];
    RedisReply* r4 = [[RedisReply alloc] init];
    
    [r1 setType: REDIS_REPLY_STRING];
    [r1 setString: @"name"];
    
    [r2 setType: REDIS_REPLY_STRING];
    [r2 setString: @"Axel Etcheverry"];
    
    [r3 setType: REDIS_REPLY_STRING];
    [r3 setString: @"email"];
    
    [r4 setType: REDIS_REPLY_STRING];
    [r4 setString: @"axel@dacteev.com"];
    
    [reply addObject: r1];
    [reply addObject: r2];
    [reply addObject: r3];
    [reply addObject: r4];

    XCTAssertEqualObjects([reply value], [reply elements]);
}

@end
