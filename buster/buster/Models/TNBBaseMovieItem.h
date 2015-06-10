//
//  TNBBaseMovieItem.h
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TNBBaseMovieItem : NSObject

@property (nonatomic, strong, readonly) NSNumber *movieId;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSNumber *voteAverage;

@property (nonatomic, strong, readonly) NSString *originalLanguage;
@property (nonatomic, strong, readonly) NSString *originalTitle;

@property (nonatomic, strong, readonly) NSString *overview;

@property (nonatomic, strong, readonly) NSString *posterPath;
@property (nonatomic, strong, readonly) NSString *backdropPath;

- (id)initWithDictionary: (NSDictionary *)dictionary;

@end
