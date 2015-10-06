//ScrollingTextView.h:
#import <Cocoa/Cocoa.h>
@interface ScrollingTextView : NSView {
    NSTimer * scroller;
    NSPoint point;
    NSString * text;
    NSTimeInterval speed;
    CGFloat stringWidth;
    NSInteger pause;
    NSMutableDictionary *textAttrib;
    bool boldText;
    NSInteger thisWidth;
}

@property (nonatomic, copy) NSString * text;
@property (nonatomic) NSTimeInterval speed;

- (void)setBold:(bool)newBold;
- (void)setWidth:(NSInteger)newWidth;

@end