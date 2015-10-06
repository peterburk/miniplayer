//
//  AVWindow.m
//  Window Accessory View
//
//  Created by Matt Patenaude on 3/3/09.
//  Copyright (C) 2009 Matt Patenaude.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "AVPanel.h"


@implementation AVPanel

#pragma mark Deallocator
- (void)dealloc
{
	[_AVWaccessoryView release];
	[super dealloc];
}

#pragma mark Methods
- (NSView *)titlebarAccessoryView
{
	return _AVWaccessoryView;
}
- (void)setTitlebarAccessoryView:(NSView *)theView
{
    
    [[[[self contentView] superview] superview] setFrame:NSMakeRect(0, 0, 0, 0)];
    
	if (_AVWaccessoryView)
	{
		[_AVWaccessoryView removeFromSuperview];
		[_AVWaccessoryView release];
		_AVWaccessoryView = nil;
	}
	_AVWaccessoryView = [theView retain];
	
	if (_AVWaccessoryView)
	{
		NSView *themeFrame = [[self contentView] superview];
		NSRect bounds = [themeFrame frame];
                
        
		NSRect aV = [_AVWaccessoryView frame];
		[_AVWaccessoryView setFrame:NSMakeRect(bounds.size.width - aV.size.width, bounds.size.height - 2 - aV.size.height, aV.size.width, aV.size.height)];
		
		[themeFrame addSubview:_AVWaccessoryView];
	}
}

@end
