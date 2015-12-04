//
//  MMXMessage+S3FileAttachment.m
//  SendFileDemo
//
//  Created by Jason Ferguson on 9/2/15.
//  Copyright (c) 2015 Magnet Systems, Inc. All rights reserved.
//

#import "MMXMessage+S3FileAttachment.h"
#import <AFAmazonS3Manager/AFAmazonS3Manager.h>
#import <AFAmazonS3Manager/AFAmazonS3ResponseSerializer.h>
#import <MMX/MMXMessage_Private.h>
#import "Constants.h"

@implementation MMXMessage (S3FileAttachment)

- (void)sendWithFileAttachment:(NSString *)pathToFile
				  saveToS3Path:(NSString *)savePath
					  progress:(void (^)(float percentComplete))progress
					   success:(void (^)(NSURL * fileURL))success
					   failure:(void (^)(NSError *error))failure {
	
	AFAmazonS3Manager *s3Manager = [[AFAmazonS3Manager alloc] initWithAccessKeyID:kS3_AccessKeyID secret:kS3_Secret];
	s3Manager.requestSerializer.region = AFAmazonS3USWest2Region;
	s3Manager.requestSerializer.bucket = kS3_Bucket;
	
	[s3Manager putObjectWithFile:pathToFile destinationPath:savePath parameters:nil progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
		
//		NSLog(@"%f%% Uploaded", (totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100));
		
		progress((totalBytesWritten / (totalBytesExpectedToWrite * 1.0f) * 100));
		
	} success:^(id responseObject) {
		
		AFAmazonS3ResponseObject *response = (AFAmazonS3ResponseObject *)responseObject;
		
		NSLog(@"Upload Complete to URL %@", response.URL);
		
		NSMutableDictionary *content = self.messageContent.mutableCopy;
        content[@"url"] = response.URL.absoluteString;
        self.messageContent = content;
        [self sendWithSuccess:^(NSSet *invalidUsers) {
			if (success) {
				success(response.URL);
			}
		} failure:^(NSError *error) {
			if (failure) {
				failure(error);
			}
		}];
		
	} failure:^(NSError *error) {
		
		NSLog(@"Error uploading file.\nError = %@", error.localizedDescription);
		if (failure) {
			failure(error);
		}
	}];
}

@end
