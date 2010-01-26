//
//  GNEditingTable.h
//  LayerManager
//
//  Created by iComps on 1/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GNEditingTable : UITableViewController {
	NSArray *cells;
}

- initWithCells : (NSArray *)cells;

@end