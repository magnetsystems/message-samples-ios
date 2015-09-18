//
//  MMXMessage+S3FileAttachment.h
//  SendFileDemo
//
//  Created by Jason Ferguson on 9/2/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import <MMX/MMX.h>

@interface MMXMessage (S3FileAttachment)

- (void)sendWithFileAttachment:(NSString *)pathToFile
				  saveToS3Path:(NSString *)savePath
					  progress:(void (^)(float percentComplete))progress
					   success:(void (^)(NSURL * fileURL))success
					   failure:(void (^)(NSError *error))failure;

@end
