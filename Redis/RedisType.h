//
//  RedisType.h
//  Redis
//
//  Created by Axel Etcheverry on 02/09/2014.
//  Copyright (c) 2014 Axel Etcheverry. All rights reserved.
//

typedef NS_ENUM(NSInteger, RedisType) {
    RedisTypeUnknown,
    RedisTypeString,
    RedisTypeList,
    RedisTypeSet,
    RedisTypeZset,
    RedisTypeHash
};