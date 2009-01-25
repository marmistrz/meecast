/* vim: set sw=4 ts=4 et: */
/*
 * This file is part of Other Maemo Weather(omweather)
 *
 * Copyright (C) 2006 Vlad Vasiliev
 * Copyright (C) 2006 Pavel Fialko
 * 	for the code
 *        
 * Copyright (C) 2008 Andrew Zhilin
 *		      az@pocketpcrussia.com 
 *	for default icon set (Glance)
 *
 * This software is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1 of
 * the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this software; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301 USA
*/
/*******************************************************************************/
#ifndef _weather_stations_h
#define _weather_stations_h 1
/*******************************************************************************/
#include "weather-common.h"
/*******************************************************************************/
GtkListStore* create_items_list(const char *path, const char *filename,
				long start, long end, long *items_number);
int parse_country_string(const char *string, Country_item *result);
int parse_region_string(const char *string, Region_item *result);
int parse_station_string(const char *string, Station *result);
/*******************************************************************************/
sqlite3* open_database(const char *path, const char *filename);
void close_database(sqlite3 *database);
GtkListStore* create_countries_list(sqlite3 *database);
GtkListStore* create_regions_list(sqlite3 *database, int country_id, int *region_count);
GtkListStore* create_stations_list(sqlite3 *database, int region_id);
GtkListStore* create_sources_list(sqlite3 *database, int country_id, int *source_count);
int countries_callback(void *user_data, int argc, char **argv, char **azColName);
int regions_callback(void *user_data, int argc, char **argv, char **azColName);
int stations_callback(void *user_data, int argc, char **argv, char **azColName);
int sources_callback(void *user_data, int argc, char **argv, char **azColName);
/*******************************************************************************/
#endif
