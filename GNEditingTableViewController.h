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
}

- (id)initWithFields:(NSArray *)fields;

- (void)addUserInputToField:(NSString *)input;

@end