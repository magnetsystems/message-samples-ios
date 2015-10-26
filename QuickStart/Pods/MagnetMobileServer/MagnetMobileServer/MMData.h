/**
 * Copyright (c) 2012-2014 Magnet Systems, Inc. All rights reserved.
 */
 
#import <Mantle/Mantle.h>

@interface MMData : MTLModel

/**
* The name associated with this data object.
*/
@property(nonatomic, copy) NSString *name;

/**
* The file name associated with this data object.
*/
@property(nonatomic, copy) NSString *fileName;

/**
 * The mime type associated with this data object.
 */
@property(nonatomic, copy) NSString *mimeType;

/**
 * The actual binary data.
 */
@property(nonatomic, strong) NSData *binaryData;

@end
