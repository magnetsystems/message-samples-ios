/**
 * Copyright (c) 2012-2015 Magnet Systems, Inc. All rights reserved.
 */

#import "MMPasswordResetMethod.h"

@implementation MMPasswordResetMethodContainer

+ (NSDictionary *)mappings {
  return @{ 
      @"NOTIFICATION" : @(MMPasswordResetMethodNOTIFICATION),
      @"OLDPASSWORD" : @(MMPasswordResetMethodOLDPASSWORD),
      @"OTP" : @(MMPasswordResetMethodOTP)
  };
}

@end