//
//  TNBSearchModel.m
//  buster
//
//  Created by Tamas Nemeth on 07/06/15.
//  Copyright (c) 2015 Tamas Nemeth. All rights reserved.
//

#import "TNBSearchModel.h"
#import "TNBBaseMovieItem.h"

#import "TNBNetworkRequest.h"
#import "TNBNetworkManager.h"

@interface TNBSearchModel()

@property (nonatomic, strong, readwrite) NSMutableArray *movies;

@property (nonatomic, assign, readwrite) EModelState currentState;

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSString *query;
@end

@implementation TNBSearchModel

- (void)setQuery: (NSString *)query {
	if (![self.query isEqualToString:query]) {
		_query = query;

		[self reset];

		[self loadCurrentPage];
	}

}

- (void)loadNextPage {
	self.currentPage ++;
	[self loadCurrentPage];
}

- (void)loadCurrentPage {
	self.currentState = self.currentPage > 1 ? EModelStateLoadingMore : EModelStateLoading;

	[[TNBNetworkManager sharedInstance] search: self.query
										  page: self.currentPage
									  complete: ^(TNBNetworkRequest *operation, id responseObject) {
										  NSDictionary *responseDictionary = DYNAMIC_CAST(responseObject, NSDictionary);

										  NSArray *movieDescriptors = DYNAMIC_CAST(responseDictionary[@"results"], NSArray);
										  for (id obj in movieDescriptors) {
											  NSDictionary *movieDict = DYNAMIC_CAST(obj, NSDictionary);
											  if (movieDict) {
												  TNBBaseMovieItem *movieItem = [[TNBBaseMovieItem alloc] initWithDictionary:movieDict];
												  [self.movies addObject:movieItem];
											  }
										  }

										  if (self.movies.count > 0) {
											  NSNumber *numberOfPages = DYNAMIC_CAST(responseDictionary[@"total_pages"], NSNumber);
											  self.currentState = self.currentPage < numberOfPages.unsignedIntegerValue ? EModelStateHasContent : EModelStateHasAllContent;
										  } else {
											  self.currentState = EModelStateEmpty;
										  }

									  } fail: ^(TNBNetworkRequest *operation, NSError *error) {
										  self.currentState = EModelStateError;
									  }];
}


- (void)reset {
	self.currentPage = 1;
	self.movies = [NSMutableArray array];
	self.currentState = EModelStateInitial;
}

@end
