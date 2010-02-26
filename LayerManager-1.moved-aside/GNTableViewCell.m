//
//  GNTableViewCell.m
//  LayerManager
//
//  Created by Jake Kring on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNTableViewCell.h"


@implementation GNTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		CGRect cellFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width,
									 self.contentView.bounds.size.height);
        cellView = [[GNCellView alloc] initWithFrame:cellFrame];
        cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:cellView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)drawRect:(CGRect)rect {
	
    // set up #define constants and fonts here ...
    // set up text colors for main and secondary text in normal and highlighted cell states...
	
    CGRect contentRect = self.bounds;
    if (!self.editing) {
        CGFloat boundsX = contentRect.origin.x;
        CGPoint point;
        CGFloat actualFontSize;
        CGSize size;
		
        point = CGPointMake(boundsX + LEFT_COLUMN_OFFSET, LOWER_ROW_TOP);
        [contentString drawAtPoint:point forWidth:LEFT_COLUMN_WIDTH withFont:secondaryFont minFontSize:MIN_SECONDARY_FONT_SIZE actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

    }
}

- (void)dealloc {
    [super dealloc];
}


@end

///////

@implementation GNCellView

@synthesize contentString=_contentString;

@end
