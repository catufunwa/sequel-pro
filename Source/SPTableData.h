//
//  $Id$
//
//  SPTableData.h
//  sequel-pro
//
//  Created by Rowan Beentje on 24/01/2009.
//  Copyright 2009 Arboreal. All rights reserved.
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

@class SPDatabaseDocument, SPTablesList, SPMySQLConnection;

@interface SPTableData : NSObject 
{
	IBOutlet SPDatabaseDocument* tableDocumentInstance;
	IBOutlet SPTablesList* tableListInstance;

	NSMutableArray *columns;
	NSMutableArray *columnNames;
	NSMutableArray *constraints;
	NSArray *triggers;
	NSMutableDictionary *status;
	NSMutableArray *primaryKeyColumns;
	
	NSString *tableEncoding;
	NSString *tableCreateSyntax;
	
	SPMySQLConnection *mySQLConnection;

	pthread_mutex_t dataProcessingLock;

	BOOL tableHasAutoIncrementField;
}

@property (readonly, assign) BOOL tableHasAutoIncrementField;

- (void) setConnection:(SPMySQLConnection *)theConnection;
- (NSString *) tableEncoding;
- (NSString *) tableCreateSyntax;
- (NSArray *) columns;
- (NSDictionary *) columnWithName:(NSString *)colName;
- (NSArray *) columnNames;
- (NSDictionary *) columnAtIndex:(NSInteger)index;
- (NSArray *) getConstraints;
- (NSArray *) triggers;
- (BOOL) columnIsBlobOrText:(NSString *)colName;
- (BOOL) columnIsGeometry:(NSString *)colName;
- (NSString *) statusValueForKey:(NSString *)aKey;
- (void)setStatusValue:(NSString *)value forKey:(NSString *)key;
- (NSDictionary *) statusValues;
- (void) resetAllData;
- (void) resetStatusData;
- (void) resetColumnData;
- (BOOL) updateInformationForCurrentTable;
- (NSDictionary *) informationForTable:(NSString *)tableName;
- (BOOL) updateInformationForCurrentView;
- (NSDictionary *) informationForView:(NSString *)viewName;
- (BOOL) updateStatusInformationForCurrentTable;
- (BOOL) updateTriggersForCurrentTable;
- (NSDictionary *) parseFieldDefinitionStringParts:(NSArray *)definitionParts;
- (NSArray *) primaryKeyColumnNames;

#ifdef SP_REFACTOR /* glue */
- (void)setTableDocumentInstance:(SPDatabaseDocument*)doc;
- (void)setTableListInstance:(SPTablesList*)list;
#endif

@end
