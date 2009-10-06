//
//  $Id$
//
//  SPExporter.m
//  sequel-pro
//
//  Created by Stuart Connolly (stuconnolly.com) on August 29, 2009
//  Copyright (c) 2009 Stuart Connolly. All rights reserved.
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
//
//  More info at <http://code.google.com/p/sequel-pro/>

#import "SPExporter.h"

@implementation SPExporter

@synthesize delegate;
@synthesize didEndSelector;
@synthesize exportProgressValue;
@synthesize exportProcessIsRunning;
@synthesize exportOutputEncoding;

/**
 * Initialise an instance of SPCSVExporter using the supplied delegate and set some default values.
 */
- (id)initWithDelegate:(id)exportDelegate
{
	if ((self = [super init])) {
		[self setDelegate:exportDelegate];
		
		[self setExportProgressValue:0];
		[self setExportProcessIsRunning:NO];
		
		// Default the output encoding to UTF-8
		[self setExportOutputEncoding:NSUTF8StringEncoding];
		
		[self setDidEndSelector:@selector(csvDataAvailable:)];
	}
	
	return self;
}

/**
 *
 */
- (void)main
{
	@throw [NSException exceptionWithName:@"NSOperation main() call" reason:@"Can't call NSOperation's main() method in SPExpoter, must be overriden in subclass." userInfo:nil];
}

@end
