//
//  NSStreamAdditions.h
//  TableTopClient
//
//  Created by student on 14/10/13.
//  Copyright (c) 2014年 student. All rights reserved.
//

#import <assert.h>
@interface NSStream (MyAdditions)

+ (void)getStreamsToHostNamed:(NSString *)hostName
                         port:(NSInteger)port
                  inputStream:(NSInputStream **)inputStreamPtr
                 outputStream:(NSOutputStream **)outputStreamPtr;

@end
