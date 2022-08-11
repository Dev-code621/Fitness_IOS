//
//  MBCircularProgressBarLayer.h
//  MBCircularProgressBar
//
//  Created by Mati Bot on 7/9/15.
//  Copyright (c) 2015 Mati Bot All rights reserved.
//

@import QuartzCore;

/**
 * The MBCircularProgressBarLayer class is a CALayer subclass that represents the underlying layer
 * of MBCircularProgressBarView.
 */
@interface MBCircularProgressBarLayer : CALayer

/**
 * Set a partial angle for the progress bar	[0,100]
 */
@property (nonatomic,assign) CGFloat  progressAngle;

/**
 * Progress bar rotation (Clockewise)	[0,100]
 */
@property (nonatomic,assign) CGFloat  progressRotationAngle;

/**
 * The value of the progress bar
 */
@property (nonatomic,assign) CGFloat  value;

/**
 * The maximum possible value, used to calculate the progress (value/maxValue)	[0,∞)
 */
@property (nonatomic,assign) CGFloat  maxValue;

/**
 * Animation duration in seconds
 */
@property (nonatomic,assign) NSTimeInterval  animationDuration;

/**
 * The font of value
 */
@property(nonatomic, strong) UIFont* valueFont;

/**
 * The font of unit
 */
@property (nonatomic,assign) UIFont*  unitFont;

/**
 * The string that represents the units, usually %
 */
@property (nonatomic,copy)   NSString *unitString;

/**
 * The color of the value and unit text
 */
@property (nonatomic,strong) UIColor  *fontColor;

/**
 * The width of the progress bar (user space units)	[0,∞)
 */
@property (nonatomic,assign) CGFloat    progressLineWidth;

/**
 * The color of the progress bar
 */
@property (nonatomic,strong) UIColor    *progressColor;

/**
 * The color of the progress bar frame
 */
@property (nonatomic,strong) UIColor    *progressStrokeColor;

/**
 * The shape of the progress bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2}
 */
@property (nonatomic,assign) CGLineCap  progressCapType;

/**
 * The width of the background bar (user space units)	[0,∞)
 */
@property (nonatomic,assign) CGFloat    emptyLineWidth;

/**
 * The shape of the background bar cap	{kCGLineCapButt=0, kCGLineCapRound=1, kCGLineCapSquare=2}
 */
@property (nonatomic,assign) CGLineCap  emptyCapType;

/**
 * The color of the background bar
 */
@property (nonatomic,strong) UIColor    *emptyLineColor;
/**
 * The color of the background bar stroke line
 */
@property (nonatomic,strong) UIColor    *emptyLineStrokeColor;

/*
 * Number of decimal places of the value [0,∞)
 */
@property (nonatomic,assign)  NSInteger decimalPlaces;

/**
 * The value to be displayed in the center
 */
@property (nonatomic,assign)  CGFloat   valueDecimalFontSize;

/**
 * Should show unit screen
 */
@property (nonatomic,assign)  BOOL      showUnitString;

/**
 * The offset to apply to the unit / value text
 */
@property (nonatomic,assign)  CGPoint   textOffset;

/**
 * Should show value string
 */
@property (nonatomic,assign)  BOOL      showValueString;

/**
 * Show label value as countdown
 * Default is NO
 */
@property (nonatomic,assign)  BOOL      countdown;

@end
