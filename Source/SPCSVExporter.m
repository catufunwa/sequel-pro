//
//  $Id$
//
//  SPCSVExporter.m
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

#import "SPCSVExporter.h"
#import "SPArrayAdditions.h"

@implementation SPCSVExporter

@synthesize csvDataArray;
@synthesize csvDataResult;

@synthesize csvOutputFieldNames;
@synthesize csvFieldSeparatorString;
@synthesize csvEnclosingCharacterString;
@synthesize csvEscapeString;
@synthesize csvLineEndingString;
@synthesize csvNULLString;
@synthesize csvTableColumnNumericStatus;

/**
 * Start the CSV data conversion process. This method is automatically called when an instance of this object
 * is placed on an NSOperationQueue. Do not call it directly as there is no manual multithreading.
 */
- (void)main
{		
	@try {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		
		NSMutableString *csvString     = [NSMutableString string];
		NSMutableString *csvData       = [NSMutableString string];
		NSMutableString *csvCellString = [NSMutableString string];

		NSArray *csvRow;
		NSScanner *csvNumericTester;
		NSString *escapedEscapeString, *escapedFieldSeparatorString, *escapedEnclosingString, *escapedLineEndString, *dataConversionString;

		id csvCell;
		BOOL csvCellIsNumeric;
		BOOL quoteFieldSeparators = [[self csvEnclosingCharacterString] isEqualToString:@""];
	
		NSUInteger i, totalRows, csvCellCount = 0;
		
		// Check that we have all the required info before starting the export
		if ((![self csvOutputFieldNames]) ||
			(![self csvFieldSeparatorString]) ||
			(![self csvEscapeString]) ||
			(![self csvLineEndingString]) ||
			(![self csvTableColumnNumericStatus]))
		{
			return;
		}
			 
		// Check that the CSV output options are not just empty strings or empty arrays
		if (([[self csvFieldSeparatorString] isEqualToString:@""]) ||
			([[self csvEscapeString] isEqualToString:@""]) ||
			([[self csvLineEndingString] isEqualToString:@""]) ||
			([[self csvTableColumnNumericStatus] count] == 0)) 
		{
			return;
		}
		
		// Check that we have at least some data to export
		if ((![self csvDataArray]) && (![self csvDataResult])) return;
				
		// Mark the process as running
		[self setExportProcessIsRunning:YES];
		
		// Detect and restore special characters being used as terminating or line end strings
		NSMutableString *tempSeparatorString = [NSMutableString stringWithString:[self csvFieldSeparatorString]];
		
		// Escape tabs, line endings and carriage returns
		[tempSeparatorString replaceOccurrencesOfString:@"\\t" withString:@"\t"
												options:NSLiteralSearch
												  range:NSMakeRange(0, [tempSeparatorString length])];
		
		[tempSeparatorString replaceOccurrencesOfString:@"\\n" withString:@"\n"
												options:NSLiteralSearch
												  range:NSMakeRange(0, [tempSeparatorString length])];
		
		[tempSeparatorString replaceOccurrencesOfString:@"\\r" withString:@"\r"
												options:NSLiteralSearch
												  range:NSMakeRange(0, [tempSeparatorString length])];
		
		// Set the new field separator string
		[self setCsvFieldSeparatorString:[NSString stringWithString:tempSeparatorString]];
		
		NSMutableString *tempLineEndString = [NSMutableString stringWithString:[self csvLineEndingString]];
		
		// Escape tabs, line endings and carriage returns
		[tempLineEndString replaceOccurrencesOfString:@"\\t" withString:@"\t"
											  options:NSLiteralSearch
												range:NSMakeRange(0, [tempLineEndString length])];
		
		
		[tempLineEndString replaceOccurrencesOfString:@"\\n" withString:@"\n"
											  options:NSLiteralSearch
												range:NSMakeRange(0, [tempLineEndString length])];
		
		[tempLineEndString replaceOccurrencesOfString:@"\\r" withString:@"\r"
											  options:NSLiteralSearch
												range:NSMakeRange(0, [tempLineEndString length])];
		
		// Set the new line ending string
		[self setCsvLineEndingString:[NSString stringWithString:tempLineEndString]];
		
		// Set up escaped versions of strings for substitution within the loop
		escapedEscapeString         = [[self csvEscapeString] stringByAppendingString:[self csvEscapeString]];
		escapedFieldSeparatorString = [[self csvEscapeString] stringByAppendingString:[self csvFieldSeparatorString]];
		escapedEnclosingString      = [[self csvEscapeString] stringByAppendingString:[self csvEnclosingCharacterString]];
		escapedLineEndString        = [[self csvEscapeString] stringByAppendingString:[self csvLineEndingString]];
		
		// Set up the starting row; for supplied arrays, which include the column
		// headers as the first row, decide whether to skip the first row.
		NSUInteger currentRowIndex = 0;
		
		[csvData setString:@""];
		
		if (([self csvDataArray]) && (![self csvOutputFieldNames])) currentRowIndex++;
		
		// Drop into the processing loop
		NSAutoreleasePool *csvExportPool = [[NSAutoreleasePool alloc] init];
		
		NSUInteger currentPoolDataLength = 0;
		
		while (1) 
		{
			// Retrieve the next row from the supplied data, either directly from the array...
			if ([self csvDataArray]) {
				csvRow = NSArrayObjectAtIndex([self csvDataArray], currentRowIndex);
			} 
			// Or by reading an appropriate row from the streaming result
			else {
				// If still requested to read the field names, get the field names
				if ([self csvOutputFieldNames]) {
					csvRow = [[self csvDataResult] fetchFieldNames];
					[self setCsvOutputFieldNames:NO];
				} 
				else {
					csvRow = [[self csvDataResult] fetchNextRowAsArray];
					
					if (!csvRow) break;
				}
			}
			
			// Get the cell count if we don't already have it stored
			if (!csvCellCount) csvCellCount = [csvRow count];
						
			[csvString setString:@""];
			
			for (i = 0 ; i < csvCellCount; i++) 
			{
				csvCell = NSArrayObjectAtIndex(csvRow, i);
								
				// For NULL objects supplied from a queryResult, add an unenclosed null string as per prefs
				if ([csvCell isKindOfClass:[NSNull class]]) {
					[csvString appendString:[self csvNULLString]];
					
					if (i < (csvCellCount - 1)) [csvString appendString:[self csvFieldSeparatorString]];
					
					continue;
				}
				
				// Retrieve the contents of this cell
				if ([csvCell isKindOfClass:[NSData class]]) {
					dataConversionString = [[NSString alloc] initWithData:csvCell encoding:[self exportOutputEncoding]];
					
					if (dataConversionString == nil) {
						dataConversionString = [[NSString alloc] initWithData:csvCell encoding:NSASCIIStringEncoding];
					}
					
					[csvCellString setString:[NSString stringWithString:dataConversionString]];
					[dataConversionString release];
				} 
				else {
					[csvCellString setString:[csvCell description]];
				}
				
				// For NULL values supplied via an array add the unenclosed null string as set in preferences
				if ([csvCellString isEqualToString:[self csvNULLString]]) {
					[csvString appendString:[self csvNULLString]];
				} 
				// Add empty strings as a pair of enclosing characters.
				else if ([csvCellString length] == 0) {
					[csvString appendString:[self csvEnclosingCharacterString]];
					[csvString appendString:[self csvEnclosingCharacterString]];
				}
				else {
					// If an array of bools supplying information as to whether the column is numeric has been supplied, use it.
					if ([self csvTableColumnNumericStatus] != nil) {
						csvCellIsNumeric = [NSArrayObjectAtIndex([self csvTableColumnNumericStatus], i) boolValue];
					} 
					// Otherwise, first test whether this cell contains data
					else if ([NSArrayObjectAtIndex(csvRow, i) isKindOfClass:[NSData class]]) {
						csvCellIsNumeric = NO;
					} 
					// Or fall back to testing numeric content via an NSScanner.
					else {
						csvNumericTester = [NSScanner scannerWithString:csvCellString];
						
						csvCellIsNumeric = [csvNumericTester scanFloat:nil] && 
						[csvNumericTester isAtEnd] && 
						([csvCellString characterAtIndex:0] != '0' || 
						 [csvCellString length] == 1 || 
						 ([csvCellString length] > 1 && 
						  [csvCellString characterAtIndex:1] == '.'));
					}
					
					// Escape any occurrences of the escaping character
					[csvCellString replaceOccurrencesOfString:[self csvEscapeString]
												   withString:escapedEscapeString
													  options:NSLiteralSearch
														range:NSMakeRange(0, [csvCellString length])];
					
					// Escape any occurrences of the enclosure string
					if (![[self csvEscapeString] isEqualToString:[self csvEnclosingCharacterString]]) {
						[csvCellString replaceOccurrencesOfString:[self csvEnclosingCharacterString]
													   withString:escapedEnclosingString
														  options:NSLiteralSearch
															range:NSMakeRange(0, [csvCellString length])];
					}
					
					// Escape occurrences of the line end character
					[csvCellString replaceOccurrencesOfString:[self csvLineEndingString]
												   withString:escapedLineEndString
													  options:NSLiteralSearch
														range:NSMakeRange(0, [csvCellString length])];
					
					// If the string isn't quoted or otherwise enclosed, escape occurrences of the field separators
					if (quoteFieldSeparators || csvCellIsNumeric) {
						[csvCellString replaceOccurrencesOfString:[self csvFieldSeparatorString]
													   withString:escapedFieldSeparatorString
														  options:NSLiteralSearch
															range:NSMakeRange(0, [csvCellString length])];
					}
					
					// Write out the cell data by appending strings - this is significantly faster than stringWithFormat.
					if (csvCellIsNumeric) {
						[csvString appendString:csvCellString];
					} 
					else {
						[csvString appendString:[self csvEnclosingCharacterString]];
						[csvString appendString:csvCellString];
						[csvString appendString:[self csvEnclosingCharacterString]];
					}
				}
				
				if (i < ([csvRow count] - 1)) [csvString appendString:[self csvFieldSeparatorString]];
			}
			
			// Append the line ending to the string for this row, and record the length processed for pool flushing
			[csvString appendString:[self csvLineEndingString]];
			[csvData appendString:csvString];
						
			currentPoolDataLength += [csvString length];
			
			currentRowIndex++;
			
			// Update the progress value
			if (totalRows) [self setExportProgressValue:(((i + 1) * 100) / totalRows)];
			
			// If an array was supplied and we've processed all rows, break
			if ([self csvDataArray] && (totalRows == currentRowIndex)) break;
			
			// Drain the autorelease pool as required to keep memory usage low
			if (currentPoolDataLength > 250000) {
				[csvExportPool drain];
				csvExportPool = [[NSAutoreleasePool alloc] init];
			}
		}
				
		// Assign the resulting CSV data to the expoter's export data
		[self setExportData:csvData];
		
		// Mark the process as not running
		[self setExportProcessIsRunning:NO];
		
		// Call the delegate's didEndSelector while passing this exporter to it
		[[self delegate] performSelectorOnMainThread:[self didEndSelector] withObject:self waitUntilDone:NO];
		
		[pool release];
	}
	@catch(NSException *e) {
		
	}
}

/**
 * Dealloc
 */
- (void)dealloc
{
	[csvDataArray release], csvDataArray = nil;
	[csvDataResult release], csvDataResult = nil;
	[csvFieldSeparatorString release], csvFieldSeparatorString = nil;
	[csvEnclosingCharacterString release], csvEnclosingCharacterString = nil;
	[csvEscapeString release], csvEscapeString = nil;
	[csvLineEndingString release], csvLineEndingString = nil;
	[csvNULLString release], csvNULLString = nil;
	[csvTableColumnNumericStatus release], csvTableColumnNumericStatus = nil;
	
	[super dealloc];
}

@end
