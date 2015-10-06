//ScrollingTextView.m

#import "ScrollingTextView.h"
#import <math.h>

@implementation ScrollingTextView

@synthesize text;
@synthesize speed;

- (void) dealloc {
//    [text release];
    [scroller invalidate];
//    [super dealloc];
}

- (void) setText:(NSString *)newText {
//    [text release];
    
    if (! [text isEqualToString:newText])
    {
        text = [newText copy];
        point = NSZeroPoint;
                
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        NSFont *fontSettings;
        
        if (boldText == true)
        {
            fontSettings = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:11];
        } else {
            fontSettings = [fontManager fontWithFamily:@"Lucida Grande" traits:NSUnboldFontMask weight:0 size:11];
        }
        
        textAttrib = [[NSMutableDictionary alloc] init];
        [textAttrib setObject:fontSettings forKey:NSFontAttributeName];
        [textAttrib setObject:[NSColor colorWithSRGBRed:(61/100) green:(63/100) blue:(53/100) alpha:1] forKey:NSForegroundColorAttributeName];
        
        stringWidth = [newText sizeWithAttributes:textAttrib].width;
        
//        text = [NSString stringWithFormat:@"%f", stringWidth];

        if (scroller == nil && speed > 0 && text != nil)
        {
            scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
    
}

- (void) setSpeed:(NSTimeInterval)newSpeed {
    if (newSpeed != speed) {
        speed = newSpeed;
        
        [scroller invalidate];
        scroller = nil;
        if (speed > 0 && text != nil)
        {
            scroller = [NSTimer scheduledTimerWithTimeInterval:speed target:self selector:@selector(moveText:) userInfo:nil repeats:YES];
        }
    }
}

- (void) moveText:(NSTimer *)timer {
    
    
    if (pause > 50)
    {
        point.x = point.x - 1.0f;
    }
    
    pause = pause + 1;
    
    if (pause > stringWidth)
    {
        pause = 0;
    }
    
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *fontSettings;
    
    if (boldText == true)
    {
        fontSettings = [fontManager fontWithFamily:@"Lucida Grande" traits:NSBoldFontMask weight:0 size:11];
    } else {
        fontSettings = [fontManager fontWithFamily:@"Lucida Grande" traits:NSUnboldFontMask weight:0 size:11];
    }
    
    
    textAttrib = [[NSMutableDictionary alloc] init];
    [textAttrib setObject:fontSettings forKey:NSFontAttributeName];
    [textAttrib setObject:[NSColor colorWithSRGBRed:(61/100) green:(63/100) blue:(53/100) alpha:0.7] forKey:NSForegroundColorAttributeName];
    
    
    if (point.x + stringWidth < 0) {
//        point.x += dirtyRect.size.width;
        point.x += stringWidth;
    }
    
    if (stringWidth < thisWidth)
    {
        point.x = (thisWidth - stringWidth) / 2;
    }
    
    [text drawAtPoint:point withAttributes:textAttrib];
    
    if (point.x < 0)
    {
        NSPoint otherPoint = point;
//        otherPoint.x += dirtyRect.size.width;
        otherPoint.x += stringWidth;
        
        [text drawAtPoint:otherPoint withAttributes:textAttrib];
    }
}

- (void)setBold:(bool)newBold
{
    boldText = newBold;
}

- (void)setWidth:(NSInteger)newWidth
{
    thisWidth = newWidth;
}

@end
