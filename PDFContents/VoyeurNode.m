/* Voyeur - VoyeurNode.m
*
* Author: Derek Clegg
* Created 8 November 2002
*
* Copyright (c) 2003-2004 Apple Computer, Inc.
* All rights reserved.
*/

/* IMPORTANT: This Apple software is supplied to you by Apple Computer,
Inc. ("Apple") in consideration of your agreement to the following terms,
and your use, installation, modification or redistribution of this Apple
software constitutes acceptance of these terms.  If you do not agree with
these terms, please do not use, install, modify or redistribute this Apple
software.

In consideration of your agreement to abide by the following terms, and
subject to these terms, Apple grants you a personal, non-exclusive
license, under Apple's copyrights in this original Apple software (the
"Apple Software"), to use, reproduce, modify and redistribute the Apple
Software, with or without modifications, in source and/or binary forms;
provided that if you redistribute the Apple Software in its entirety and
without modifications, you must retain this notice and the following text
and disclaimers in all such redistributions of the Apple Software.
Neither the name, trademarks, service marks or logos of Apple Computer,
Inc. may be used to endorse or promote products derived from the Apple
Software without specific prior written permission from Apple. Except as
expressly stated in this notice, no other rights or licenses, express or
implied, are granted by Apple herein, including but not limited to any
patent rights that may be infringed by your derivative works or by other
works in which the Apple Software may be incorporated.

The Apple Software is provided by Apple on an "AS IS" basis.  APPLE MAKES
NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND OPERATION
ALONE OR IN COMBINATION WITH YOUR PRODUCTS.

IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED AND
WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), STRICT
LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE POSSIBILITY
OF SUCH DAMAGE. */

#import "VoyeurNode.h"


@implementation VoyeurNode

/* Initialize a VoyeurNode with the catalog of a PDF document. */

- (id)initWithCatalog:(CGPDFDictionaryRef)dictionary
{
    self = [self init];
    if (self == nil)
	return nil;

    type = kCGPDFObjectTypeDictionary;
    catalog = dictionary;
	
    return self;
}

/* Initialize a VoyeurNode with a PDF object. */

- (id)initWithObject:(CGPDFObjectRef)obj name:(NSString *)string
{
    self = [self init];
    if (self == nil)
	return nil;
	
    object = obj;
    name = [string copy];
    type = CGPDFObjectGetType(object);

    return self;
}

- (NSString *)name
{
    return name;
}

- (CGPDFObjectType)type
{
    return type;
}

- (NSString *)typeAsString
{
    switch (type) {
    case kCGPDFObjectTypeBoolean:
	return @"Boolean";
    case kCGPDFObjectTypeInteger:
	return @"Integer";
    case kCGPDFObjectTypeReal:
	return @"Real";
    case kCGPDFObjectTypeName:
	return @"Name";
    case kCGPDFObjectTypeString:
	return @"String";
    case kCGPDFObjectTypeArray:
	return @"Array";
    case kCGPDFObjectTypeDictionary:
	return @"Dictionary";
    case kCGPDFObjectTypeStream:
	return @"Stream";
    case kCGPDFObjectTypeNull:
    default:
	return nil;
    }
}

- (CGPDFObjectRef)object
{
    return object;
}

- (NSString *)value
{
    const char *n;
    CGPDFReal real;
    CGPDFInteger integer;
    CGPDFBoolean boolean;
    CGPDFStringRef string;
	
    switch (type) {
    case kCGPDFObjectTypeNull:
	return @"null";
			
    case kCGPDFObjectTypeBoolean:
	CGPDFObjectGetValue(object, type, &boolean);
	return boolean ? @"true" : @"false";
			
    case kCGPDFObjectTypeInteger:
	CGPDFObjectGetValue(object, type, &integer);
	return [NSString stringWithFormat:@"%d", (int)integer];
			
    case kCGPDFObjectTypeReal:
	CGPDFObjectGetValue(object, type, &real);
	return [NSString stringWithFormat:@"%g", (double)real];
			
    case kCGPDFObjectTypeName:
	CGPDFObjectGetValue(object, type, &n);
	return [NSString stringWithFormat:@"/%s", n];
			
    case kCGPDFObjectTypeString:
	CGPDFObjectGetValue(object, type, &string);
	return (__bridge NSString *)CGPDFStringCopyTextString(string);
			
    case kCGPDFObjectTypeArray:
    case kCGPDFObjectTypeDictionary:
    case kCGPDFObjectTypeStream:
    default:
	return @"";
    }
}

static void
addItems(const char *key, CGPDFObjectRef object, void *info)
{
    NSString *string;
    NSMutableArray *children;
    VoyeurNode *node;
	
    children = (__bridge NSMutableArray *)(info);
    string = [[NSString alloc] initWithFormat:@"/%s", key];
    node = [[VoyeurNode alloc] initWithObject:object name:string];
    if (node != nil) {
        [children addObject:node];
    }
}

- (NSArray *)children
{
    size_t k, count;
    CGPDFObjectRef obj;
    CGPDFArrayRef array;
    CGPDFStreamRef stream;
    CGPDFDictionaryRef dict;
    NSString *string;
    VoyeurNode *node;
	
    if (children != nil)
	return children;

    switch (type) {
    case kCGPDFObjectTypeArray:
	CGPDFObjectGetValue(object, kCGPDFObjectTypeArray, &array);
	count = CGPDFArrayGetCount(array);
	children = [[NSMutableArray alloc] initWithCapacity:count];
	for (k = 0; k < count; k++) {
	    CGPDFArrayGetObject(array, k, &obj);
	    string = [[NSString alloc] initWithFormat:@"%d", (int)k];
	    node = [[VoyeurNode alloc] initWithObject:obj name:string];
	    if (node != nil) {
		[children addObject:node];
	    }
	}
	break;
			
    case kCGPDFObjectTypeDictionary:
	if (catalog != nil) {
	    dict = catalog;
	} else {
	    CGPDFObjectGetValue(object, kCGPDFObjectTypeDictionary, &dict);
	}
	count = CGPDFDictionaryGetCount(dict);
	children = [[NSMutableArray alloc] initWithCapacity:count];
	CGPDFDictionaryApplyFunction(dict, &addItems, (__bridge void *)(children));
	break;
			
    case kCGPDFObjectTypeStream:
	CGPDFObjectGetValue(object, kCGPDFObjectTypeStream, &stream);
	dict = CGPDFStreamGetDictionary(stream);
	count = CGPDFDictionaryGetCount(dict);
	children = [[NSMutableArray alloc] initWithCapacity:count];
	CGPDFDictionaryApplyFunction(dict, &addItems, (__bridge void *)(children));
	break;
			
    default:
	return nil;
    }

    return children;
}

- (VoyeurNode *)childrenForName:(NSString *)key
{
    NSArray *_children = [self children];
    for (VoyeurNode *node in _children) {
        if ([node.name isEqualToString:key]) {
            return node;
        }
    }
    return nil;
}

@end

