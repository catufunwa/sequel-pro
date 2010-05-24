//
//  $Id$
//
//  SPCSVExporterProtocol.h
//  sequel-pro
//
//  Created by Stuart Connolly (stuconnolly.com) on April 15, 2010
//  Copyright (c) 2010 Stuart Connolly. All rights reserved.
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

@class SPCSVExporter;

/**
 * @protocol SPCSVExporterProtocol SPCSVExporterProtocol.h
 *
 * @author Stuart Connolly http://stuconnolly.com/ 
 *
 * CSV exporter delegate protocol.
 */
@protocol SPCSVExporterProtocol

/**
 * Called when the CSV export process is about to begin. 
 *
 * @param SPCSVExporter The expoter calling the method.
 */
- (void)csvExportProcessWillBegin:(SPCSVExporter *)exporter;

/**
 * Called when the CSV export process is complete.
 *
 * @param SPCSVExporter The expoter calling the method.
 */
- (void)csvExportProcessComplete:(SPCSVExporter *)exporter;

/**
 * Called when the progress of the CSV export process is updated.
 *
 * @param SPCSVExporter The expoter calling the method.
 */
- (void)csvExportProcessProgressUpdated:(SPCSVExporter *)exporter;

/**
 * Called when the CSV export process is about to begin writing data to disk.
 *
 * @param SPCSVExporter The expoter calling the method.
 */
- (void)csvExportProcessWillBeginWritingData:(SPCSVExporter *)exporter;

@end
