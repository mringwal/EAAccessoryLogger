/*
 * Copyright (C) 2013 Matthias Ringwald
 */

#import <ExternalAccessory/ExternalAccessory.h>

@interface NSString (BTstack)
+(NSString*) stringForData:(const uint8_t*) data withSize:(uint16_t) size;
@end

@implementation NSString (BTstatck)
+(NSString*) stringForData:(const uint8_t*) data withSize:(uint16_t) size{
    NSMutableString *output = [NSMutableString stringWithCapacity:size * 3];
    for(int i = 0; i < size; i++){
        [output appendFormat:@"%02x ",data[i]];
    }
    return output;
}
@end

%hook EAInputStream
- (NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len{
    NSInteger result = %orig;
    NSString * data = @"";
    if (result > 0){
        data = [NSString stringForData:buffer withSize:result];
    }
    NSLog(@"EAAccessoryLogger: READ(%p,%u) = %d, data: %@", buffer, len, result, data);
    return result;
}
%end

%hook EAOutputStream
- (NSInteger)write:(const uint8_t *)buffer maxLength:(NSUInteger)len{
    NSInteger result = %orig;
    NSString * data = [NSString stringForData:buffer withSize:len];
    NSLog(@"EAAccessoryLogger: WRITE(%p,%u) = %d, data: %@", buffer, len, result, data);
    return result;
}
%end

%hook EASession
-(id)initWithAccessory:(EAAccessory *)accessory forProtocol:(NSString *)protocolString{
    NSLog(@"EAAccessoryLogger: session (%p) created for accessory %@ with protocol: %@", self, accessory, protocolString);
    return %orig;
}
%end
