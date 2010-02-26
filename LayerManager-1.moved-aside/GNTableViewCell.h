//
//  GNTableViewCell.h
//  LayerManager
//
//  Created by Jake Kring on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GNCellView;

@interface GNTableViewCell : UITableViewCell {

	GNCellView *cellView;
}

@end
////////

@interface GNCellView : UIView{
	NSString *_contentString;
	BOOL editing;
}

@property (nonatomic, copy) NSString *contentString;
@property (nonatomic, getter=isEditing) BOOL editing;

@end

