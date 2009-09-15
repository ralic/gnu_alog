--
--  Copyright (c) 2008,
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

with Ada.Directories;
with Ada.Exceptions.Is_Null_Occurrence;

with Ahven;

with Alog.Helpers;
with Alog.Logger;
with Alog.Tasked_Logger;
with Alog.Facilities.File_Descriptor;
with Alog.Facilities.Syslog;
with Alog.Facilities.Mock;
with Alog.Transforms.Casing;

package body Tasked_Logger_Tests is

   use Ahven;
   use Alog;

   -------------------------------------------------------------------------

   procedure Attach_Transform is
      Log       : Tasked_Logger.Instance (Init => False);
      Transform : constant Transforms.Handle := new Transforms.Casing.Instance;
      Count     : Natural := Natural'Last;
   begin
      Log.Transform_Count (Count => Count);

      Assert (Condition => Count = 0,
              Message   => "transform count not 0");

      Log.Attach_Transform (Transform => Transform);
      Log.Transform_Count (Count => Count);
      Assert (Condition => Count = 1,
              Message => "could not attach transform");

      begin
         Log.Attach_Transform (Transform => Transform);
         Fail (Message => "attached duplicate transform");

      exception
         when Logger.Transform_Already_Present =>
            null;
      end;
   end Attach_Transform;

   -------------------------------------------------------------------------

   procedure Default_Facility_Handling is
      Logger1 : Tasked_Logger.Instance (Init => False);
      Logger2 : Tasked_Logger.Instance (Init => True);
      F_Count : Natural := Natural'Last;
   begin
      Logger1.Attach_Default_Facility;
      Logger1.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 1,
              Message   => "Unable to attach facility");

      Logger1.Attach_Default_Facility;
      Logger1.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 1,
              Message   => "Attached facility twice");

      Logger1.Detach_Default_Facility;
      Logger1.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 0,
              Message   => "Unable to detach facility");

      Logger2.Attach_Default_Facility;
      Logger2.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 1,
              Message   => "Attached facility to initialzed logger");

      Logger2.Detach_Default_Facility;
      Logger2.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 0,
              Message   => "Unable to detach facility from initialized logger");
   end Default_Facility_Handling;

   -------------------------------------------------------------------------

   procedure Detach_Facility_Unattached is
      Log      : Tasked_Logger.Instance (Init => False);
      Facility : Facilities.Handle :=
        new Facilities.Syslog.Instance;
   begin
      begin
         Facility.Set_Name ("Syslog_Facility");
         Log.Detach_Facility (Name => Facility.Get_Name);
         Fail (Message => "could detach unattached facility");

      exception
         when Logger.Facility_Not_Found =>
            --  Free not attached facility, this is not done by the logger
            --  (since it was never attached).
            Alog.Logger.Free (Facility);
      end;

      declare
         F_Count : Natural := Natural'Last;
      begin

         --  Tasking_Error will be raised if tasked logger has terminated due to
         --  an unhandled exception.

         Log.Facility_Count (Count => F_Count);

      end;

   end Detach_Facility_Unattached;

   -------------------------------------------------------------------------

   procedure Detach_Transform is
      Log       : Tasked_Logger.Instance (Init => False);
      Transform : constant Transforms.Handle := new Transforms.Casing.Instance;
      Count     : Natural := 0;
   begin
      Transform.Set_Name ("Casing_Transform");
      Log.Attach_Transform (Transform => Transform);
      Log.Transform_Count (Count => Count);
      Assert (Condition => Count = 1,
              Message   => "Unable to attach transform");

      Log.Detach_Transform (Name => Transform.Get_Name);
      Log.Transform_Count (Count => Count);
      Assert (Condition => Count = 0,
              Message   => "Unable to detach transform");
   end Detach_Transform;

   -------------------------------------------------------------------------

   procedure Detach_Transform_Unattached is
      Log       : Tasked_Logger.Instance (Init => False);
      Transform : Transforms.Handle :=
        new Transforms.Casing.Instance;
   begin
      begin
         Transform.Set_Name ("Casing_Transform");
         Log.Detach_Transform (Name => Transform.Get_Name);
         Fail (Message => "could detach unattached transform");

      exception
         when Logger.Transform_Not_Found =>
            --  Free not attached Transform, this is not done by the logger
            --  (since it was never attached).
            Alog.Logger.Free (Transform);
      end;

      declare
         T_Count : Natural := Natural'Last;
      begin

         --  Tasking_Error will be raised if tasked logger has terminated due to
         --  an unhandled exception.

         Log.Transform_Count (Count => T_Count);

      end;

   end Detach_Transform_Unattached;

   -------------------------------------------------------------------------

   procedure Finalize (T : in out Testcase) is

      use Ahven.Framework;
      use Alog.Facilities;

      Filename : constant String := "./data/Tasked_Log_One_FD_Facility";
   begin
      if Ada.Directories.Exists (Name => Filename) then
         Ada.Directories.Delete_File (Name => Filename);
      end if;

      Finalize (Test_Case (T));
   end Finalize;

   -------------------------------------------------------------------------

   procedure Initialize (T : in out Testcase) is
   begin
      Set_Name (T, "Tests for Alog tasked Logger");
      Ahven.Framework.Add_Test_Routine
        (T, Detach_Facility_Unattached'Access,
         "detach not attached facility");
      Ahven.Framework.Add_Test_Routine
        (T, Attach_Transform'Access,
         "attach a transform");
      Ahven.Framework.Add_Test_Routine
        (T, Detach_Transform_Unattached'Access,
         "detach not attached transform");
      Ahven.Framework.Add_Test_Routine
        (T, Log_One_FD_Facility'Access,
         "log with tasked logger");
      Ahven.Framework.Add_Test_Routine
        (T, Verify_Logger_Initialization'Access,
         "tasked logger initialization behavior");
      Ahven.Framework.Add_Test_Routine
        (T, Attach_Transform'Access,
         "tasked attach a transform");
      Ahven.Framework.Add_Test_Routine
        (T, Detach_Facility_Unattached'Access,
         "tasked detach not attached facility");
      Ahven.Framework.Add_Test_Routine
        (T, Detach_Transform'Access,
         "tasked detach transform");
      Ahven.Framework.Add_Test_Routine
        (T, Detach_Transform_Unattached'Access,
         "tasked detach not attached transform");
      Ahven.Framework.Add_Test_Routine
        (T, Logger_Exception_Handling'Access,
         "tasked logger exception handling");
      Ahven.Framework.Add_Test_Routine
        (T, Default_Facility_Handling'Access,
         "tasked default facility handling");
   end Initialize;

   -------------------------------------------------------------------------

   procedure Log_One_FD_Facility is
      Log          : Tasked_Logger.Instance;
      F_Count      : Natural;
      Fd_Facility1 : constant Facilities.Handle :=
        new Facilities.File_Descriptor.Instance;
      Fd_Facility2 : constant Facilities.Handle :=
        new Facilities.File_Descriptor.Instance;

      Testfile     : constant String := "./data/Tasked_Log_One_FD_Facility";
      Reffile      : constant String := "./data/Log_One_FD_Facility.ref";
   begin
      Fd_Facility1.Set_Name (Name => "Fd_Facility1");
      Fd_Facility1.Toggle_Write_Timestamp (State => False);

      Facilities.File_Descriptor.Handle
        (Fd_Facility1).Set_Logfile (Path => Testfile);

      Log.Attach_Facility (Facility => Fd_Facility1);
      Log.Attach_Facility (Facility => Fd_Facility2);

      Log.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 2,
              Message   => "facility count not 2");

      Log.Detach_Facility (Name => Fd_Facility2.Get_Name);
      Log.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 1,
              Message   => "facility count not 1");

      Log.Log_Message (Level => DEBU,
                       Msg   => "Logger testmessage, one fd facility");

      Log.Clear;

      Assert (Condition => Helpers.Assert_Files_Equal
              (Filename1 => Reffile,
               Filename2 => Testfile),
              Message   => "files not equal");
   end Log_One_FD_Facility;

   -------------------------------------------------------------------------

   procedure Logger_Exception_Handling is
      use Ada.Exceptions;

      Log           : Tasked_Logger.Instance;
      Mock_Facility : constant Facilities.Handle :=
        new Facilities.Mock.Instance;
      EO            : Exception_Occurrence;
   begin
      Log.Get_Last_Exception (Occurrence => EO);
      Assert
        (Condition => Is_Null_Occurrence (X => EO),
         Message   => "Exception not Null_Occurence");

      Log.Attach_Facility (Facility => Mock_Facility);
      Log.Log_Message (Level => DEBU,
                       Msg   => "Test message");

      Log.Get_Last_Exception (Occurrence => EO);
      Assert
        (Condition => Exception_Name (X => EO) = "CONSTRAINT_ERROR",
         Message   => "Expected Constraint_Error");
      Assert
        (Condition => Exception_Message (X => EO) =
           Facilities.Mock.Exception_Message,
         Message   => "Found wrong exception message");

      Log.Detach_Facility (Name => Mock_Facility.Get_Name);
      Log.Log_Message (Level => DEBU,
                       Msg   => "Test message 2");

      Log.Get_Last_Exception (Occurrence => EO);
      Assert
        (Condition => Is_Null_Occurrence (X => EO),
         Message   => "Exception not reset");
   end Logger_Exception_Handling;

   -------------------------------------------------------------------------

   procedure Verify_Logger_Initialization is
      Logger1 : Tasked_Logger.Instance;
      Logger2 : Tasked_Logger.Instance (Init => True);
      F_Count : Natural := Natural'Last;
   begin

      Logger1.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 0,
              Message   => "logger1 not empty");

      Logger2.Facility_Count (Count => F_Count);
      Assert (Condition => F_Count = 1,
              Message   => "logger2 empty");
   end Verify_Logger_Initialization;

end Tasked_Logger_Tests;
