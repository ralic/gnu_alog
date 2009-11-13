--
--  Copyright (c) 2009,
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

with Ada.Exceptions;
with Ada.Task_Identification;

with Alog.Facilities;
with Alog.Transforms;

--  Tasked Logger instance. Facilities can be attached to this logger instance
--  in order to log to different targets simultaneously. This instance provides
--  task-safe concurrent logging.
package Alog.Tasked_Logger is

   type Facility_Update_Handle is
   not null access procedure (Facility_Handle : Facilities.Handle);
   --  Handle to facility update procedure.

   task type Instance (Init : Boolean := False) is

      entry Attach_Facility (Facility : Facilities.Handle);
      --  Attach a facility to tasked logger instance.

      entry Attach_Default_Facility;
      --  Attach default facility to tasked logger instance.

      entry Detach_Facility (Name : String);
      --  Detach a facility from tasked logger instance.

      entry Detach_Default_Facility;
      --  Detach default facility from tasked logger instance.

      entry Facility_Count (Count : out Natural);
      --  Return number of attached facilites.

      entry Update
        (Name    : String;
         Process : Facility_Update_Handle);
      --  Update a specific facility identified by 'Name'. Call the 'Process'
      --  procedure to perform the update operation. Clear the last exception
      --  occurrence for the caller if none occurred or replace existing
      --  occurrence with new raised exception.

      entry Iterate (Process : Facility_Update_Handle);
      --  Call 'Process' for all attached facilities.

      entry Attach_Transform (Transform : Transforms.Handle);
      --  Attach a transform to tasked logger instance.

      entry Detach_Transform (Name : String);
      --  Detach a transform from tasked logger instance.

      entry Transform_Count (Count : out Natural);
      --  Return number of attached transforms.

      entry Log_Message
        (Source : String := "";
         Level  : Log_Level;
         Msg    : String;
         Caller : Ada.Task_Identification.Task_Id :=
           Ada.Task_Identification.Null_Task_Id);
      --  Log a message. The Write_Message() procedure of all attached
      --  facilities is called. Depending on the Log-Threshold set, the message
      --  is logged to different targets (depending on the facilites)
      --  automatically. Clear the last exception occurrence for the caller if
      --  none occurred or replace existing occurrence with new raised
      --  exception.
      --  If caller is not specified the executing task's ID is used instead.
      --  Since Log_Message'Caller can not be used as default parameter the
      --  entry checks if the variable is set to 'Null_Task_Id' in the body.
      --
      --  If source is specified the logger checks if there is an existing
      --  loglevel entry for this source in the sources map. If an associated
      --  loglevel is found the message is processed only if the specified
      --  loglevel 'Level' is greater or equal than the one in the map.
      --  If no entry is found the message is only processed if the specified
      --  loglevel 'Level' is greater or equal than the logger's loglevel.

      entry Clear;
      --  Clear tasked logger instance. Detach and teardown all attached
      --  facilities and transforms and clear any stored exceptions.

      entry Get_Last_Exception
        (Occurrence : out Ada.Exceptions.Exception_Occurrence;
         Caller     :     Ada.Task_Identification.Task_Id :=
           Ada.Task_Identification.Null_Task_Id);
      --  Return last known Exception_Occurrence. If no exception occured return
      --  Null_Occurrence.
      --  If caller is not specified the executing task's ID is used instead.
      --  Since Get_Last_Exception'Caller can not be used as default parameter
      --  the entry checks if the variable is set to 'Null_Task_Id' in the body.

      entry Set_Loglevel (Level : Log_Level);
      --  Set given loglevel for logger.

      entry Get_Loglevel (Level : out Log_Level);
      --  Return current logger loglevel.

      entry Set_Source_Loglevel
        (Source : String;
         Level  : Log_Level);
      --  Set given loglevel for specified source. If source is already present
      --  the loglevel is updated.

      entry Get_Source_Loglevel
        (Source :     String;
         Level  : out Log_Level);
      --  Return loglevel for given source. Raises No_Source_Loglevel exception
      --  if no entry for given source is found.

      entry Shutdown;
      --  Explicitly shutdown tasked logger.

   end Instance;
   --  Tasked logger instance. The Init discriminant defines whether or not a
   --  default 'stdout' (FD facility without logfile set) is attached
   --  automatically. Default is 'False'. Set Init to 'True' if you want to make
   --  sure minimal stdout logging is possible as soon as a new logger is
   --  instantiated.

   type Handle is access all Instance;
   --  Handle to tasked logger type.

end Alog.Tasked_Logger;
