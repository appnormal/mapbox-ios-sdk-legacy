//
//  RMEllipse.m
//  MapView
//
//  Created by Rick van der Linde on 08/03/17.
//
//

#import "RMEllipse.h"

#import "RMMapView.h"

#define DEGREES_TO_RADIANS(degrees)((M_PI * degrees) / 180.0f)

@implementation RMEllipse
{
    __weak RMMapView *_mapView;
    NSDictionary *_geometry;
    CAShapeLayer *_shapeLayer;
}

#pragma mark - Lifecycle

- (instancetype)initWithView:(RMMapView *)aMapView geometry:(NSDictionary *)geometry
{
    self = [super init];
    if (self) {
        self.masksToBounds = NO;
        
        _mapView = aMapView;
        _geometry = [geometry copy];
        
        _shapeLayer = [CAShapeLayer new];
        _shapeLayer.lineWidth = [_geometry[@"options"][@"stroke"] floatValue];
        [self addSublayer:_shapeLayer];
        
        [self updateEllipsePathAnimated:NO];
    }
    return self;
}

#pragma mark - Setters

@dynamic color;

- (void)setColor:(UIColor *)color
{
    NSDictionary *options = _geometry[@"options"];
    _shapeLayer.fillColor = [color colorWithAlphaComponent:[options[@"fillOpacity"] floatValue]].CGColor;
    _shapeLayer.strokeColor = [color colorWithAlphaComponent:[options[@"opacity"] floatValue]].CGColor;
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
    NSDictionary *radii = _geometry[@"radii"];
    CGFloat widthInMeters = [radii[@"x"] floatValue];
    CGFloat width = widthInMeters / [_mapView metersPerPixel];
    CGFloat heightInMeters = [radii[@"y"] floatValue];
    CGFloat height = heightInMeters / [_mapView metersPerPixel];
    
    self.bounds = (CGRect) {
        self.position,
        width,
        height
    };
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    transform = CGAffineTransformRotate(transform, DEGREES_TO_RADIANS([_geometry[@"tilt"] floatValue]));
    transform = CGAffineTransformTranslate(transform, -CGRectGetMidX(self.bounds), -CGRectGetMidY(self.bounds));
    CGPathAddEllipseInRect(path, &transform, self.bounds);
    
    if (animated) {
        CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
        pathAnimation.duration = [CATransaction animationDuration];
        pathAnimation.fromValue = [NSValue valueWithPointer:_shapeLayer.path];
        pathAnimation.toValue = [NSValue valueWithPointer:path];
        [_shapeLayer addAnimation:pathAnimation forKey:@"animatePath"];
    }
    
    _shapeLayer.path = path;
    
    CGPathRelease(path);
}

@end
