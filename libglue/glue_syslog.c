/*
 * Copyright (c) 2011,
 * Reto Buerki, Adrian-Ken Rueegsegger
 *
 * This file is part of Alog.
 *
 * Alog is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; either version 2.1 of the License, or
 * (at your option) any later version.
 *
 * Alog is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with Alog; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
 * MA  02110-1301  USA
 *
 * Wrapper for syslog C function which has variable arguments, see GNAT User's
 * Guide, section 2.10.2, Calling Conventions:
 *   http://gcc.gnu.org/onlinedocs/gnat_ugn_unw/Calling-Conventions.html
 */

#include <syslog.h>

void syslog_wrapper(int priority, const char *message)
{
	syslog(priority, "%s", message);
}
