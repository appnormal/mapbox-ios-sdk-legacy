//
//  RMEllipse.m
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMEllipse.h"

#import "RMAnnotation.h"
#import "RMGlobalConstants.h"
#import "RMEllipseAnnotation.h"
#import "RMMapView.h"
#import "RMMarker.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees) / 180.0f)

@implementation RMEllipse {
    __weak RMMapView *_mapView;
    CAShapeLayer *_shapeLayer;
}

#pragma mark - Lifecycle

- (instancetype)initWithView:(RMMapView *)aMapView
{
    if (self = [super init]) {
        self.masksToBounds = NO;
        
        _mapView = aMapView;
        
        _shapeLayer = [CAShapeLayer new];
        [self addSublayer:_shapeLayer];
        
        self.lineWidth = 2.0f;
        self.strokeColor = [UIColor blackColor];
        self.fillColor = [UIColor clearColor];
        
        [self updateEllipsePathAnimated:NO];
    }
    return self;
}

#pragma mark - Setters

@dynamic lineWidth, strokeColor, fillColor, tilt;

- (void)setTilt:(CGFloat)tilt
{
    self.affineTransform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(tilt));
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    _shapeLayer.strokeColor = strokeColor.CGColor;
    [self updateEllipsePathAnimated:NO];
}

- (void)setFillColor:(UIColor *)fillColor
{
    _shapeLayer.fillColor = fillColor.CGColor;
    [self updateEllipsePathAnimated:NO];
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _shapeLayer.lineWidth = lineWidth;
    [self updateEllipsePathAnimated:NO];
}

#pragma mark - Overrides

- (void)setPosition:(CGPoint)position animated:(BOOL)animated
{
    [self setPosition:position];
    [self updateEllipsePathAnimated:animated];
}

#pragma mark - Draw

- (void)updateEllipsePathAnimated:(BOOL)animated
{
    CGFloat width = self.widthInMeters / [_mapView metersPerPixel];
    CGFloat height = self.heightInMeters / [_mapView metersPerPixel];
    
    CGRect shapeBounds = CGRectMake(0, 0, width, height);
    CGRect bounds = self.bounds;
    bounds.size.width = width;
    bounds.size.height = height;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddEllipseInRect(path, nil, shapeBounds);
    
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.fromValue = [NSValue valueWithPointer:_shapeLayer.path];
        pathAnimation.toValue = [NSValue valueWithPointer:path];
        [_shapeLayer addAnimation:pathAnimation forKey:@"animatePath"];
    }
    
    _shapeLayer.path = path;
    CGPathRelease(path);
    self.bounds = bounds;
}

@end
