//
//  CHKUtils.m
//  ChatKit
//
//  Created by Vladimir Yevdokimov on 3/18/16.
//  Copyright © 2016 Vladimir Yevdokimov. All rights reserved.
//

#import "CHKUtils.h"

@implementation CHKUtils


+ (NSBundle *)chk_bundle
{
    return [NSBundle bundleForClass:[CHKUtils class]];

}

+ (id)chk_imageNamed:(NSString *)name
{
    NSBundle *bundle = [CHKUtils chk_bundle];
    NSString *path = [bundle pathForResource:name ofType:@"png" inDirectory:@"Sources"];
    return [UIImage imageWithContentsOfFile:path];
}

@end
