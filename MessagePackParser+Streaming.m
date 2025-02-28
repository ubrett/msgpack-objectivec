//
//  MessagePackParser+Streaming.m
//  msgpack-objectivec
//
//  Created by Kentaro Matsumae on 2013/01/18.
//  Copyright (c) 2013 kenmaz.net. All rights reserved.
//

#import "MessagePackParser+Streaming.h"
#include "msgpack.h"

static const int kUnpackerBufferSize = 1024;

@interface MessagePackParser ()
// Implemented in MessagePackParser.m
+(id) createUnpackedObject:(msgpack_object)obj;
@end

@implementation MessagePackParser (Streaming)

- (id)init {
    self = [super init];
    if (self) {
        msgpack_unpacker_init(self.unpacker, kUnpackerBufferSize);
    }
    return self;
}

- (id)initWithBufferSize:(int)bufferSize {
    if (self = [super init]) {
        msgpack_unpacker_init(self.unpacker, bufferSize);
    }
    return self;
}

// Feed chunked messagepack data into buffer.
- (void)feed:(NSData*)chunk {
    msgpack_unpacker* unpacker = self.unpacker;
    msgpack_unpacker_reserve_buffer(unpacker, [chunk length]);
    memcpy(msgpack_unpacker_buffer(unpacker), [chunk bytes], [chunk length]);
    msgpack_unpacker_buffer_consumed(unpacker, [chunk length]);
}

// Put next parsed messagepack data. If there is not sufficient data, return nil.
- (id)next {
    id unpackedObject = nil;
    msgpack_unpacked result;
    msgpack_unpacked_init(&result);
    if (msgpack_unpacker_next(self.unpacker, &result)) {
        msgpack_object obj = result.data;
        unpackedObject = [MessagePackParser createUnpackedObject:obj];
    }
    msgpack_unpacked_destroy(&result);
    
#if !__has_feature(objc_arc)
    return [unpackedObject autorelease];
#else
    return unpackedObject;
#endif
}

@end
