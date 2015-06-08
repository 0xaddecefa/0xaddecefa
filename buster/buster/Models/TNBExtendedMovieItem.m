//
//  TNBExtendedMovieItem.m
//  buster
//
//  Created by Tamas Nemeth on 08/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBExtendedMovieItem.h"

@implementation TNBExtendedMovieItem

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [super initWithDictionary:dictionary];
	if (self) {
		//the extra content could be parsed here, same way as it is in the base class
	}
	return self;
}

@end
