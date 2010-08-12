//
//  $Id$
//
//  SPHTMLExporter.m
//  sequel-pro
//
//  Created by Stuart Connolly (stuconnolly.com) on April 24, 2010
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

#import "SPHTMLExporter.h"
#import "SPExportUtilities.h"

@implementation SPHTMLExporter

@synthesize delegate;

/**
 * Initialise an instance of SPHTMLExporter using the supplied delegate.
 *
 * @param exportDelegate The exporter delegate
 *
 * @return The initialised instance
 */
- (id)initWithDelegate:(NSObject *)exportDelegate
{
	if ((self = [super init])) {
		SPExportDelegateConformsToProtocol(exportDelegate, @protocol(SPHTMLExporterProtocol));
		
		[self setDelegate:exportDelegate];
	}
	
	return self;
}

/**
 * Start the HTML export process. This method is automatically called when an instance of this class
 * is placed on an NSOperationQueue. Do not call it directly as there is no manual multithreading.
 */
- (void)main
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	[pool release];
}

@end
