//
//  NSAttributedString+Header.h
//  buster
//
//  Created by Tamas Nemeth on 10/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString(Header)

+ (NSAttributedString *)attributedStringWithFormat: (NSString *)formatString
											values: (NSArray *)values
										specifiers: (NSArray *)specifiers;
@end
