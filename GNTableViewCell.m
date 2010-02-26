//
//  GNTableViewCell.m
//  LayerManager
//
//  Created by Jake Kring on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GNTableViewCell.h"


@implementation GNTableViewCell
@synthesize cellView=_cellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        CGRect cellFrame = CGRectMake(0.0, 0.0, self.contentView.bounds.size.width,
									 self.contentView.bounds.size.height);
        self.cellView = [[GNCellView alloc] initWithFrame:cellFrame];
        self.cellView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.contentView addSubview:self.cellView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
//////
@implementation GNCellView

- (void)setContentString:(NSString *)newContentString{
	if (contentString != newContentString){
		[contentString release];
		contentString = [newContentString retain];
	}
	[self setNeedsDisplay];
	
}

- (NSString *)getContentString{
	return contentString;
}

void CGContextAddRoundedRect (CGContextRef context, CGRect rect, int corner_radius) {
	int x_left = rect.origin.x;
	int x_left_center = rect.origin.x + corner_radius;
	int x_right_center = rect.origin.x + rect.size.width - corner_radius;
	int x_right = rect.origin.x + rect.size.width;
	int y_top = rect.origin.y;
	int y_top_center = rect.origin.y + corner_radius;
	int y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
	int y_bottom = rect.origin.y + rect.size.height;
	
	/* Begin! */
	CGContextBeginPath(context);
	CGContextMoveToPoint(context, x_left, y_top_center);
	
	/* First corner */
	CGContextAddArcToPoint(context, x_left, y_top, x_left_center, y_top, corner_radius);
	CGContextAddLineToPoint(context, x_right_center, y_top);
	
	/* Second corner */
	CGContextAddArcToPoint(context, x_right, y_top, x_right, y_top_center, corner_radius);
	CGContextAddLineToPoint(context, x_right, y_bottom_center);
	
	/* Third corner */
	CGContextAddArcToPoint(context, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
	CGContextAddLineToPoint(context, x_left_center, y_bottom);
	
	/* Fourth corner */
	CGContextAddArcToPoint(context, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
	CGContextAddLineToPoint(context, x_left, y_top_center);
	
	/* Done */
	CGContextClosePath(context);
	
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGRect outerRect = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
	CGContextSetRGBFillColor(context, 0, 0, 0, 0.5);
	CGContextAddRoundedRect(context, outerRect, 10);
	CGContextFillPath(context);
	CGContextSetLineWidth(context, 10);
	CGContextSetRGBStrokeColor(context, 1, 1, 1, 1.0);
	CGContextAddRoundedRect(context, outerRect, 10);
	CGContextStrokePath(context);
	CGContextSetRGBFillColor(context, 1, 1, 1, 1);
	CGPoint point = CGPointMake(outerRect.origin.x+10, outerRect.origin.y+10);
	[contentString drawAtPoint:point forWidth:outerRect.size.width withFont:[UIFont boldSystemFontOfSize:14] minFontSize:10 actualFontSize:NULL lineBreakMode:UILineBreakModeTailTruncation baselineAdjustment:UIBaselineAdjustmentAlignBaselines];

}

@end
