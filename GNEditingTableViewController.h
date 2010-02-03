//
//  GNEditingTableViewController.h
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GNEditingTableViewController : UITableViewController {
	NSArray *fields;
	NSInteger *currentField;
	NSMutableArray *userInput;


}

- (id)initWithFields:(NSArray *)fields;

- (void)addUserInput:(NSString *)input toField:(NSInteger)index;

- (NSInteger)getCurrentField;

@end