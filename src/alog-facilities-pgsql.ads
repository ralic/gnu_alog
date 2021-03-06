--
--  Copyright (c) 2008-2009,
--  Reto Buerki, Adrian-Ken Rueegsegger
--  secunet SwissIT AG
--
--  This file is part of Alog.
--
--  Alog is free software; you can redistribute it and/or modify
--  it under the terms of the GNU Lesser General Public License as published
--  by the Free Software Foundation; either version 2.1 of the License, or
--  (at your option) any later version.
--
--  Alog is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with Alog; if not, write to the Free Software
--  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston,
--  MA  02110-1301  USA
--

with APQ.PostgreSQL.Client;

--  PGSQL facility. Used to log to a Postgresql database.
package Alog.Facilities.Pgsql is

   type Instance is new Alog.Facilities.Instance with private;
   --  PGSQL logging facility.

   type Handle is access all Instance;

   overriding
   procedure Setup (Facility : in out Instance);
   --  Implementation of Setup-procedure.

   overriding
   procedure Teardown (Facility : in out Instance);
   --  Implementation of Teardown-procedure.

   procedure Set_Host_Name (Facility : in out Instance; Hostname : String);
   --  Set hostname of database server.

   function Get_Host_Name (Facility : Instance) return String;
   --  Get hostname of database server.

   procedure Set_Host_Address (Facility : in out Instance; Address : String);
   --  Set ip address of database server.

   procedure Set_Host_Port (Facility : in out Instance; Port : Natural);
   --  Set port of database server.

   function Get_Host_Port (Facility : Instance) return Natural;
   --  Get port of database server.

   procedure Set_SQL_Trace
     (Facility : in out Instance;
      Filename :        String;
      Mode     :        APQ.Trace_Mode_Type);
   --  Set SQL trace parameters.

   procedure Toggle_SQL_Trace
     (Facility : in out Instance;
      State    :        Boolean);
   --  Toggles tracing of SQL statements.

   function Is_SQL_Trace (Facility : Instance) return Boolean;
   --  Tells whether sql tracing is enabled.

   procedure Set_DB_Name (Facility : in out Instance; DB_Name : String);
   --  Set name of database.

   function Get_DB_Name (Facility : Instance) return String;
   --  Get name of database.

   procedure Set_Table_Name (Facility : in out Instance; Table_Name : String);
   --  Set name of database table.

   function Get_Table_Name (Facility : Instance) return String;
   --  Get name of database table.

   procedure Set_Level_Column_Name
     (Facility    : in out Instance;
      Column_Name : String);
   --  Set name of log level column.

   function Get_Level_Column_Name (Facility : Instance) return String;
   --  Get name of log level column.

   procedure Set_Timestamp_Column_Name
     (Facility    : in out Instance;
      Column_Name : String);
   --  Set name of log level column.

   function Get_Timestamp_Column_Name (Facility : Instance) return String;
   --  Get name of timestamp column.

   procedure Set_Message_Column_Name
     (Facility    : in out Instance;
      Column_Name : String);
   --  Set name of log message column.

   function Get_Message_Column_Name (Facility : Instance) return String;
   --  Get name of log message column.

   procedure Set_Credentials
     (Facility : in out Instance;
      Username :        String;
      Password :        String);
   --  Set credentials for the database connection.

   function Get_Credentials (Facility : Instance) return String;
   --  Get credentials of database connection. Only the username is returned.

   procedure Close_Connection (Facility : in out Instance);
   --  Close open database connection.

private

   overriding
   procedure Write
     (Facility : Instance;
      Level    : Log_Level := Info;
      Msg      : String);
   --  Implementation of the Write procedure for PGSQL.

   type Log_SQL_Table is tagged record
      Name             : Unbounded_String := To_Unbounded_String ("alog");
      Level_Column     : Unbounded_String := To_Unbounded_String ("level");
      Timestamp_Column : Unbounded_String := To_Unbounded_String ("timestamp");
      Message_Column   : Unbounded_String := To_Unbounded_String ("message");
   end record;
   --  Holds Table/Column name information.

   type Instance is new Alog.Facilities.Instance with record
      Log_Connection   : APQ.PostgreSQL.Client.Connection_Type;
      --  Database connection used for logging.

      Trace_Filename   : Unbounded_String :=
        To_Unbounded_String ("./trace.sql");
      Trace_Mode       :  APQ.Trace_Mode_Type := APQ.Trace_APQ;
      --  SQL trace parameters

      Log_Table        : Log_SQL_Table;
      --  Table to insert messages
   end record;

end Alog.Facilities.Pgsql;
