//
//  $Id$
//
//  SPStringAdditions.m
//  sequel-pro
//
//  Created by Stuart Connolly (stuconnolly.com) on Jan 28, 2009
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

#import "SPStringAdditions.h"
#import "RegexKitLite.h"
#import "SPDatabaseDocument.h"

// Defined to suppress warnings
@interface NSObject (SPBundleMethods)

- (NSString *)lastBundleBlobFilesDirectory;
- (void)setLastBundleBlobFilesDirectory:(NSString *)path;

@end

// Defined to suppress warnings
@interface NSObject (SPWindowControllerTabMethods)

- (id)selectedTableDocument;

@end

@interface NSString (PrivateAPI)

- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b andOf:(NSInteger)c;

@end

@implementation NSString (SPStringAdditions)

/*
 * Returns a human readable version string of the supplied byte size.
 */
+ (NSString *)stringForByteSize:(long long)byteSize
{
	double size = byteSize;
	
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];
	
	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
	
	if (size < 1023) {
		[numberFormatter setFormat:@"#,##0 B"];
		
		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:size]];
	}
	
	size = (size / 1024);
	
	if (size < 1023) {
		[numberFormatter setFormat:@"#,##0.0 KiB"];
		
		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:size]];
	}
	
	size = (size / 1024);
	
	if (size < 1023) {
		[numberFormatter setFormat:@"#,##0.0 MiB"];
		
		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:size]];
	}
	
	size = (size / 1024);
	
	if (size < 1023) {
		[numberFormatter setFormat:@"#,##0.0 GiB"];
		
		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:size]];
	}

	size = (size / 1024);
	
	[numberFormatter setFormat:@"#,##0.0 TiB"];
	
	return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:size]];
}

/**
 * Returns a human readable version string of the supplied time interval.
 */ 
+ (NSString *)stringForTimeInterval:(double)timeInterval
{
	NSNumberFormatter *numberFormatter = [[[NSNumberFormatter alloc] init] autorelease];

	[numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];

	// For time periods of less than one millisecond, display a localised "< 0.1 ms"
	if (timeInterval < 0.0001) {
		[numberFormatter setFormat:@"< #,##0.0 ms"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:0.1]];
	}

	if (timeInterval < 0.1) {
		timeInterval = (timeInterval * 1000);
		[numberFormatter setFormat:@"#,##0.0 ms"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}
	if (timeInterval < 1) {
		timeInterval = (timeInterval * 1000);
		[numberFormatter setFormat:@"#,##0 ms"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}
	
	if (timeInterval < 10) {
		[numberFormatter setFormat:@"#,##0.00 s"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}

	if (timeInterval < 100) {
		[numberFormatter setFormat:@"#,##0.0 s"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}

	if (timeInterval < 300) {
		[numberFormatter setFormat:@"#,##0 s"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}

	if (timeInterval < 3600) {
		timeInterval = (timeInterval / 60);
		[numberFormatter setFormat:@"#,##0 min"];

		return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
	}

	timeInterval = (timeInterval / 3600);
	[numberFormatter setFormat:@"#,##0 hours"];

	return [numberFormatter stringFromNumber:[NSNumber numberWithDouble:timeInterval]];
}

/**
 * Returns a new created UUID string.
 */
+ (NSString*)stringWithNewUUID
{
	// Create a new UUID
	CFUUIDRef uuidObj = CFUUIDCreate(nil);

	// Get the string representation of the UUID
	NSString *newUUID = (NSString*)CFUUIDCreateString(nil, uuidObj);
	CFRelease(uuidObj);
	return [newUUID autorelease];
}

/**
 * Returns ROT13 representation
 */
- (NSString *)rot13
{
	NSMutableString *holder = [[NSMutableString alloc] init];
	unichar theChar;
	NSUInteger i;

	for(i = 0; i < [self length]; i++) {
		theChar = [self characterAtIndex:i];
		if(theChar <= 122 && theChar >= 97) {
			if(theChar + 13 > 122)
				theChar -= 13;
			else 
				theChar += 13;
			[holder appendFormat:@"%C", (char)theChar];


		} else if(theChar <= 90 && theChar >= 65) {
			if((int)theChar + 13 > 90)
				theChar -= 13;
			else
				theChar += 13;

			[holder appendFormat:@"%C", theChar];

		} else {
			[holder appendFormat:@"%C", theChar];
		}
	}

	return [NSString stringWithString:holder];
}

/**
 * Escapes HTML special characters.
 */
- (NSString *)HTMLEscapeString
{
	NSMutableString *mutableString = [NSMutableString stringWithString:self];
	
	[mutableString replaceOccurrencesOfString:@"&" withString:@"&amp;"
									  options:NSLiteralSearch
										range:NSMakeRange(0, [mutableString length])];
	
	[mutableString replaceOccurrencesOfString:@"<" withString:@"&lt;"
									  options:NSLiteralSearch
										range:NSMakeRange(0, [mutableString length])];
	
	[mutableString replaceOccurrencesOfString:@">" withString:@"&gt;"
									  options:NSLiteralSearch
										range:NSMakeRange(0, [mutableString length])];
	
	[mutableString replaceOccurrencesOfString:@"\"" withString:@"&quot;"
									  options:NSLiteralSearch
										range:NSMakeRange(0, [mutableString length])];
	
	return [NSString stringWithString:mutableString];
}

/**
 * Returns the string quoted with backticks as required for MySQL identifiers
 * eg.:  tablename    =>   `tablename`
 *       my`table     =>   `my``table`
 */
- (NSString *)backtickQuotedString
{
	return [NSString stringWithFormat: @"`%@`", [self stringByReplacingOccurrencesOfString:@"`" withString:@"``"]];
}

/**
 * Returns the string quoted with ticks as required for MySQL identifiers
 * eg.:  tablename    =>   'tablename'
 *       my'table     =>   'my''table'
 */
- (NSString *)tickQuotedString
{
	return [NSString stringWithFormat: @"'%@'", [self stringByReplacingOccurrencesOfString:@"'" withString:@"''"]];
}

/**
 *
 */
- (NSString *)replaceUnderscoreWithSpace
{
	return [self stringByReplacingOccurrencesOfString:@"_" withString:@" "];
}

/**
 * Returns a 'CREATE VIEW SYNTAX' string a bit more readable
 * If the string doesn't match it returns the unchanged string.
 */
- (NSString *)createViewSyntaxPrettifier
{
	NSRange searchRange = NSMakeRange(0, [self length]);
	NSRange matchedRange;
	NSError *err = NULL;
	NSMutableString *tblSyntax = [NSMutableString stringWithCapacity:[self length]];
	NSString * re = @"(.*?) AS select (.*?) (from.*)";
	
	// create view syntax
	matchedRange = [self rangeOfRegex:re options:(RKLMultiline|RKLDotAll) inRange:searchRange capture:1 error:&err];
	
	if(!matchedRange.length || matchedRange.length > [self length]) return([self description]);
	
	[tblSyntax appendString:[self substringWithRange:matchedRange]];
	[tblSyntax appendString:@"\nAS select\n   "];
	
	// match all column definitions, split them by ',', and rejoin them by '\n'
	matchedRange = [self rangeOfRegex:re options:(RKLMultiline|RKLDotAll) inRange:searchRange capture:2 error:&err];
	
	if(!matchedRange.length || matchedRange.length > [self length]) return([self description]);
	
	[tblSyntax appendString:
		[[[self substringWithRange:matchedRange] componentsSeparatedByString:@"`,`"] componentsJoinedByString:@"`,\n   `"]];
	
	// from ... at a new line
	matchedRange = [self rangeOfRegex:re options:(RKLMultiline|RKLDotAll) inRange:searchRange capture:3 error:&err];
	
	if(!matchedRange.length || matchedRange.length > [self length]) return([self description]);
	
	[tblSyntax appendString:@"\n"];
	[tblSyntax appendString:[self substringWithRange:matchedRange]];
	
	// where clause at a new line if given
	[tblSyntax replaceOccurrencesOfString:@" where (" withString:@"\nwhere (" options:NSLiteralSearch range:NSMakeRange(0, [tblSyntax length])];
	
	return(tblSyntax);
}

/**
 * Returns an array of serialised NSRanges, each representing a line within the string
 * which is at least partially covered by the NSRange supplied.
 * Each line includes the line termination character(s) for the line.  As per
 * lineRangeForRange, lines are split by CR, LF, CRLF, U+2028 (Unicode line separator),
 * or U+2029 (Unicode paragraph separator).
 */
- (NSArray *)lineRangesForRange:(NSRange)aRange
{
	NSMutableArray *lineRangesArray = [NSMutableArray array];
	NSRange currentLineRange;

	// Check that the range supplied is valid - if not return an empty array.
	if (aRange.location == NSNotFound || aRange.location + aRange.length > [self length])
		return lineRangesArray;

	// Get the range of the first string covered by the specified range, and add it to the array
	currentLineRange = [self lineRangeForRange:NSMakeRange(aRange.location, 0)];
	[lineRangesArray addObject:NSStringFromRange(currentLineRange)];

	// Loop through until the line end matches or surpasses the end of the specified range
	while (currentLineRange.location + currentLineRange.length < aRange.location + aRange.length) {
		currentLineRange = [self lineRangeForRange:NSMakeRange(currentLineRange.location + currentLineRange.length, 0)];
		[lineRangesArray addObject:NSStringFromRange(currentLineRange)];
	}

	// Return the constructed array of ranges
	return lineRangesArray;
}

/**
 * Returns the string by removing the characters in the supplied set and options.
 */
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)charSet options:(NSUInteger)mask
{
	NSRange                 range;
	NSMutableString*        newString = [NSMutableString string];
	NSUInteger                len = [self length];
	
	mask &= ~NSBackwardsSearch;
	range = NSMakeRange (0, len);
	
	while (range.length)
	{
		NSRange substringRange;
		NSUInteger pos = range.location;
		
		range = [self rangeOfCharacterFromSet:charSet options:mask range:range];
		if (range.location == NSNotFound)
			range = NSMakeRange (len, 0);
		
		substringRange = NSMakeRange (pos, range.location - pos);
		[newString appendString:[self 
								 substringWithRange:substringRange]];
		
		range.location += range.length;
		range.length = len - range.location;
	}
	
	return newString;
}

/**
 * Convenience method to access the above method with no options.
 */
- (NSString *)stringByRemovingCharactersInSet:(NSCharacterSet *)charSet
{
	return [self stringByRemovingCharactersInSet:charSet options:0];
}

/**
 * Calculate the distance between two string case-insensitively
 */
- (CGFloat)levenshteinDistanceWithWord:(NSString *)stringB
{
	// normalize strings
	NSString * stringA = [NSString stringWithString: self];
	[stringA stringByTrimmingCharactersInSet:
	[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	[stringB stringByTrimmingCharactersInSet:
	[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	stringA = [stringA lowercaseString];
	stringB = [stringB lowercaseString];

	NSInteger k, i, j, cost, * d, distance;

	NSInteger n = [stringA length];
	NSInteger m = [stringB length];	

	if( n++ != 0 && m++ != 0 ) {

		d = malloc( sizeof(NSInteger) * m * n );

		for( k = 0; k < n; k++)
			d[k] = k;

		for( k = 0; k < m; k++)
			d[ k * n ] = k;

		for( i = 1; i < n; i++ )
		for( j = 1; j < m; j++ ) {

			if( [stringA characterAtIndex: i-1] == [stringB characterAtIndex: j-1] )
				cost = 0;
			else
				cost = 1;

			d[ j * n + i ] = [self smallestOf: d [ (j - 1) * n + i ] + 1
				andOf: d[ j * n + i - 1 ] +  1
				andOf: d[ (j - 1) * n + i -1 ] + cost ];
		}

		distance = d[ n * m - 1 ];

		free( d );

		return distance;
	}
	
	return 0.0f;
}

/**
 * Create the GeomFromText() string according to a possible SRID value
 */
- (NSString*)getGeomFromTextString
{

	NSString *geomStr = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	if(![self rangeOfString:@")"].length || [self length] < 5) return @"NULL";

	// No SRID
	if([geomStr hasSuffix:@")"])
		return [NSString stringWithFormat:@"GeomFromText('%@')", geomStr];
	// Has SRID
	else {
		NSUInteger idx = [geomStr length]-1;
		while(idx>1) {
			if([geomStr characterAtIndex:idx] == ')')
				break;
			idx--;
		}
		return [NSString stringWithFormat:@"GeomFromText('%@'%@)",
			[geomStr substringToIndex:idx+1], [geomStr substringFromIndex:idx+1]];
	}

}

#ifndef SP_REFACTOR /* run self as bash commands */
/**
 * Run self as BASH command(s) and return the result.
 * This task can be interrupted by pressing ⌘.
 *
 * @param shellEnvironment A dictionary of environment variable values whose keys are the variable names.
 *
 * @param path The current directory for the bash command. If path is nil, the current directory is inherited from the process that created the receiver (normally /).
 *
 * @param caller The SPDatabaseDocument which invoked that command to register the command for cancelling; if nil the command won't be registered.
 *
 * @param name The menu title of the command.
 *
 * @param theError If not nil and the bash command failed it contains the returned error message as NSLocalizedDescriptionKey
 * 
 */
- (NSString *)runBashCommandWithEnvironment:(NSDictionary*)shellEnvironment atCurrentDirectoryPath:(NSString*)path callerInstance:(id)caller contextInfo:(NSDictionary*)contextInfo error:(NSError**)theError
{

	NSFileManager *fm = [NSFileManager defaultManager];

	BOOL userTerminated = NO;
	BOOL redirectForScript = NO;
	BOOL isDir = NO;

	NSMutableArray *scriptHeaderArguments = [NSMutableArray array];
	NSString *scriptPath = @"";
	NSString *uuid = (contextInfo && [contextInfo objectForKey:SPBundleFileInternalexecutionUUID]) ? [contextInfo objectForKey:SPBundleFileInternalexecutionUUID] : [NSString stringWithNewUUID];
	NSString *stdoutFilePath = [NSString stringWithFormat:@"%@_%@", SPBundleTaskOutputFilePath, uuid];
	NSString *scriptFilePath = [NSString stringWithFormat:@"%@_%@", SPBundleTaskScriptCommandFilePath, uuid];

	[fm removeItemAtPath:scriptFilePath error:nil];
	[fm removeItemAtPath:stdoutFilePath error:nil];
	if([[NSApp delegate] lastBundleBlobFilesDirectory] != nil)
		[fm removeItemAtPath:[[NSApp delegate] lastBundleBlobFilesDirectory] error:nil];

	if([shellEnvironment objectForKey:SPBundleShellVariableBlobFileDirectory])
		[[NSApp delegate] setLastBundleBlobFilesDirectory:[shellEnvironment objectForKey:SPBundleShellVariableBlobFileDirectory]];

	// Parse first line for magic header #! ; if found save the script content and run the command after #! with that file.
	// This allows to write perl, ruby, osascript scripts natively.
	if([self length] > 3 && [self hasPrefix:@"#!"] && [shellEnvironment objectForKey:SPBundleShellVariableBundlePath]) {

		NSRange firstLineRange = NSMakeRange(2, [self rangeOfString:@"\n"].location - 2);

		[scriptHeaderArguments setArray:[[self substringWithRange:firstLineRange] componentsSeparatedByString:@" "]];

		while([scriptHeaderArguments containsObject:@""])
			[scriptHeaderArguments removeObject:@""];

		if([scriptHeaderArguments count])
			scriptPath = [scriptHeaderArguments objectAtIndex:0];

		if([scriptPath hasPrefix:@"/"] && [fm fileExistsAtPath:scriptPath isDirectory:&isDir] && !isDir) {
			NSString *script = [self substringWithRange:NSMakeRange(NSMaxRange(firstLineRange), [self length] - NSMaxRange(firstLineRange))];
			NSError *writeError = nil;
			[script writeToFile:scriptFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
			if(writeError == nil) {
				redirectForScript = YES;
				[scriptHeaderArguments addObject:scriptFilePath];
			} else {
				NSBeep();
				NSLog(@"Couldn't write script file.");
			}
		}
	} else {
		[scriptHeaderArguments addObject:@"/bin/sh"];
		NSError *writeError = nil;
		[self writeToFile:scriptFilePath atomically:YES encoding:NSUTF8StringEncoding error:&writeError];
		if(writeError == nil) {
			redirectForScript = YES;
			[scriptHeaderArguments addObject:scriptFilePath];
		} else {
			NSBeep();
			NSLog(@"Couldn't write script file.");
		}
	}

	NSTask *bashTask = [[NSTask alloc] init];
	[bashTask setLaunchPath:@"/bin/bash"];

	NSMutableDictionary *theEnv = [NSMutableDictionary dictionary];
	[theEnv setDictionary:shellEnvironment];

	[theEnv setObject:[[NSBundle mainBundle] pathForResource:@"appicon" ofType:@"icns"] forKey:SPBundleShellVariableIconFile];
	[theEnv setObject:[NSString stringWithFormat:@"%@/Contents/Resources", [[NSBundle mainBundle] bundlePath]] forKey:SPBundleShellVariableAppResourcesDirectory];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionNone] forKey:SPBundleShellVariableExitNone];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionReplaceSection] forKey:SPBundleShellVariableExitReplaceSelection];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionReplaceContent] forKey:SPBundleShellVariableExitReplaceContent];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionInsertAsText] forKey:SPBundleShellVariableExitInsertAsText];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionInsertAsSnippet] forKey:SPBundleShellVariableExitInsertAsSnippet];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionShowAsHTML] forKey:SPBundleShellVariableExitShowAsHTML];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionShowAsTextTooltip] forKey:SPBundleShellVariableExitShowAsTextTooltip];
	[theEnv setObject:[NSNumber numberWithInteger:SPBundleRedirectActionShowAsHTMLTooltip] forKey:SPBundleShellVariableExitShowAsHTMLTooltip];

	// Create and set an unique process ID for each SPDatabaseDocument which has to passed
	// for each sequelpro:// scheme command as user to be able to identify the url scheme command.
	// Furthermore this id is used to communicate with the called command as file name.
	id doc = nil;
	if([[[NSApp mainWindow] delegate] respondsToSelector:@selector(selectedTableDocument)])
		doc = [[[NSApp mainWindow] delegate] selectedTableDocument];
		// Check if connected
		if([doc getConnection] == nil)
			doc = nil;
	else {
		for (NSWindow *aWindow in [NSApp orderedWindows]) {
			if([[[[aWindow windowController] class] description] isEqualToString:@"SPWindowController"]) {
				if([[[aWindow windowController] documents] count] && [[[[[[aWindow windowController] documents] objectAtIndex:0] class] description] isEqualToString:@"SPDatabaseDocument"]) {
					// Check if connected
					if([[[[aWindow windowController] documents] objectAtIndex:0] getConnection])
						doc = [[[aWindow windowController] documents] objectAtIndex:0];
					else
						doc = nil;
				}
			}
			if(doc) break;
		}
	}

	if(doc != nil) {

		[doc setProcessID:uuid];

		[theEnv setObject:uuid forKey:SPBundleShellVariableProcessID];
		[theEnv setObject:[NSString stringWithFormat:@"%@%@", SPURLSchemeQueryInputPathHeader, uuid] forKey:SPBundleShellVariableQueryFile];
		[theEnv setObject:[NSString stringWithFormat:@"%@%@", SPURLSchemeQueryResultPathHeader, uuid] forKey:SPBundleShellVariableQueryResultFile];
		[theEnv setObject:[NSString stringWithFormat:@"%@%@", SPURLSchemeQueryResultStatusPathHeader, uuid] forKey:SPBundleShellVariableQueryResultStatusFile];
		[theEnv setObject:[NSString stringWithFormat:@"%@%@", SPURLSchemeQueryResultMetaPathHeader, uuid] forKey:SPBundleShellVariableQueryResultMetaFile];

		if([doc shellVariables])
			[theEnv addEntriesFromDictionary:[doc shellVariables]];

		if([theEnv objectForKey:SPBundleShellVariableCurrentEditedColumnName] && [[theEnv objectForKey:SPBundleShellVariableDataTableSource] isEqualToString:@"content"])
			[theEnv setObject:[theEnv objectForKey:SPBundleShellVariableSelectedTable] forKey:SPBundleShellVariableCurrentEditedTable];

	}

	if(theEnv != nil && [theEnv count])
		[bashTask setEnvironment:theEnv];

	if(path != nil)
		[bashTask setCurrentDirectoryPath:path];
	else if([shellEnvironment objectForKey:SPBundleShellVariableBundlePath] && [fm fileExistsAtPath:[shellEnvironment objectForKey:SPBundleShellVariableBundlePath] isDirectory:&isDir] && isDir)
		[bashTask setCurrentDirectoryPath:[shellEnvironment objectForKey:SPBundleShellVariableBundlePath]];

	// STDOUT will be redirected to SPBundleTaskOutputFilePath in order to avoid nasty pipe programming due to block size reading
	if([shellEnvironment objectForKey:SPBundleShellVariableInputFilePath])
		[bashTask setArguments:[NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@ > %@ < %@", [scriptHeaderArguments componentsJoinedByString:@" "], stdoutFilePath, [shellEnvironment objectForKey:SPBundleShellVariableInputFilePath]], nil]];
	else
		[bashTask setArguments:[NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@ > %@", [scriptHeaderArguments componentsJoinedByString:@" "], stdoutFilePath], nil]];

	NSPipe *stderr_pipe = [NSPipe pipe];
	[bashTask setStandardError:stderr_pipe];
	NSFileHandle *stderr_file = [stderr_pipe fileHandleForReading];
	[bashTask launch];
	NSInteger pid = -1;
	if(caller != nil && [caller respondsToSelector:@selector(registerActivity:)]) {
		// register command
		pid = [bashTask processIdentifier];
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:pid], @"pid",
																		(contextInfo)?:[NSDictionary dictionary], @"contextInfo",
																		@"bashcommand", @"type",
																		[[NSDate date] descriptionWithCalendarFormat:@"%H:%M:%S" timeZone:nil locale:[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]], @"starttime",
																		nil];
		[caller registerActivity:dict];
	}

	// Listen to ⌘. to terminate
	while(1) {
		if(![bashTask isRunning] || [bashTask processIdentifier] == 0) break;
		NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                   untilDate:[NSDate distantPast]
                                      inMode:NSDefaultRunLoopMode
                                     dequeue:YES];
		usleep(1000);
		if(!event) continue;
		if ([event type] == NSKeyDown) {
			unichar key = [[event characters] length] == 1 ? [[event characters] characterAtIndex:0] : 0;
			if (([event modifierFlags] & NSCommandKeyMask) && key == '.') {
				[bashTask terminate];
				userTerminated = YES;
				break;
			}
			[NSApp sendEvent:event];
		} else {
			[NSApp sendEvent:event];
		}
	}

	[bashTask waitUntilExit];

	// unregister BASH command if it was registered
	if(pid > 0) {
		[caller removeRegisteredActivity:pid];
	}

	// Remove files
	[fm removeItemAtPath:scriptFilePath error:nil];
	if([theEnv objectForKey:SPBundleShellVariableQueryFile])
		[fm removeItemAtPath:[theEnv objectForKey:SPBundleShellVariableQueryFile] error:nil];
	if([theEnv objectForKey:SPBundleShellVariableQueryResultFile])
		[fm removeItemAtPath:[theEnv objectForKey:SPBundleShellVariableQueryResultFile] error:nil];
	if([theEnv objectForKey:SPBundleShellVariableQueryResultStatusFile])
		[fm removeItemAtPath:[theEnv objectForKey:SPBundleShellVariableQueryResultStatusFile] error:nil];
	if([theEnv objectForKey:SPBundleShellVariableQueryResultMetaFile])
		[fm removeItemAtPath:[theEnv objectForKey:SPBundleShellVariableQueryResultMetaFile] error:nil];
	if([theEnv objectForKey:SPBundleShellVariableInputTableMetaData])
		[fm removeItemAtPath:[theEnv objectForKey:SPBundleShellVariableInputTableMetaData] error:nil];

	// If return from bash re-activate Sequel Pro
	[NSApp activateIgnoringOtherApps:YES];

	NSInteger status = [bashTask terminationStatus];
	NSData *errdata  = [stderr_file readDataToEndOfFile];

	// Check STDERR
	if([errdata length] && (status < SPBundleRedirectActionNone || status > SPBundleRedirectActionLastCode)) {
		[fm removeItemAtPath:stdoutFilePath error:nil];

		if(status == 9 || userTerminated) return @"";
		if(theError != NULL) {
			NSMutableString *errMessage = [[[NSMutableString alloc] initWithData:errdata encoding:NSUTF8StringEncoding] autorelease];
			[errMessage replaceOccurrencesOfString:[NSString stringWithFormat:@"%@: ", scriptFilePath] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [errMessage length])];
			*theError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain 
													code:status 
												userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																errMessage,
																NSLocalizedDescriptionKey, 
																nil]] autorelease];
		} else {
			NSBeep();
		}
		return @"";
	}

	// Read STDOUT saved to file 
	if([fm fileExistsAtPath:stdoutFilePath isDirectory:nil]) {
		NSString *stdoutContent = [NSString stringWithContentsOfFile:stdoutFilePath encoding:NSUTF8StringEncoding error:nil];
		if(bashTask) [bashTask release], bashTask = nil;
		[fm removeItemAtPath:stdoutFilePath error:nil];
		if(stdoutContent != nil) {
			if (status == 0) {
				return stdoutContent;
			} else {
				if(theError != NULL) {
					if(status == 9 || userTerminated) return @"";
					NSMutableString *errMessage = [[[NSMutableString alloc] initWithData:errdata encoding:NSUTF8StringEncoding] autorelease];
					[errMessage replaceOccurrencesOfString:SPBundleTaskScriptCommandFilePath withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [errMessage length])];
					*theError = [[[NSError alloc] initWithDomain:NSPOSIXErrorDomain 
															code:status 
														userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																		errMessage,
																		NSLocalizedDescriptionKey, 
																		nil]] autorelease];
				} else {
					NSBeep();
				}
				if(status > SPBundleRedirectActionNone && status <= SPBundleRedirectActionLastCode)
					return stdoutContent;
				else
					return @"";
			}
		} else {
			NSLog(@"Couldn't read return string from “%@” by using UTF-8 encoding.", self);
			NSBeep();
		}
	}

	if (bashTask) [bashTask release];
	[fm removeItemAtPath:stdoutFilePath error:nil];
	return @"";
}

/**
 * Run self as BASH command(s) and return the result.
 * This task can be interrupted by pressing ⌘.
 *
 * @param shellEnvironment A dictionary of environment variable values whose keys are the variable names.
 *
 * @param path The current directory for the bash command. If path is nil, the current directory is inherited from the process that created the receiver (normally /).
 *
 * @param theError If not nil and the bash command failed it contains the returned error message as NSLocalizedDescriptionKey
 * 
 */
- (NSString *)runBashCommandWithEnvironment:(NSDictionary*)shellEnvironment atCurrentDirectoryPath:(NSString*)path error:(NSError**)theError
{
	return [self runBashCommandWithEnvironment:shellEnvironment atCurrentDirectoryPath:path callerInstance:nil contextInfo:nil error:theError];
}
#endif

/**
 * Returns the minimum of a, b and c.
 */
- (NSInteger)smallestOf:(NSInteger)a andOf:(NSInteger)b andOf:(NSInteger)c
{
	NSInteger min = a;
	
	if (b < min) min = b;

	if (c < min) min = c;

	return min;
}

@end
