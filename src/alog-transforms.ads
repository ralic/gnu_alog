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

with Ada.Strings.Unbounded;
with Ada.Strings.Unbounded.Hash;
with Ada.Containers;

--  Abstract package Transforms. Provides methods
--  used by all Alog transforms.
package Alog.Transforms is

   type Instance is abstract tagged limited private;
   --  Abstract type transform instance. All tranforms in the
   --  Alog framework must implement this type.

   subtype Class is Instance'Class;

   type Handle is access all Class;

   function "=" (Left  : Handle;
                 Right : Handle) return Boolean;
   --  Equal function.

   procedure Set_Name (Transform : in out Instance'Class; Name : in String);
   --  Set transform name.

   function Get_Name (Transform : in Instance'Class) return String;
   --  Get transform name.

   function Hash (Element : Alog.Transforms.Handle)
                  return Ada.Containers.Hash_Type;
   --  Return Hash value of transform.

   function Transform_Message (Transform : in Instance;
                            Level    : in Log_Level;
                            Msg      : in String) return String is abstract;
   --  Transform message with specified log level.

   procedure Setup (Transform : in out Instance) is abstract;
   --  Each transform must provide a Setup-procedure. These procedures
   --  are called by logger instances when attaching Transforms.
   --  All needed operations prior to transforming log messages
   --  should be done here.

   procedure Teardown (Transform : in out Instance) is abstract;
   --  Each transform must provide a Teardown-procedure. These procedures
   --  are called by logger instances when detaching Transforms or when
   --  the logger object gets out of scope.

private

   type Instance is abstract tagged
   limited record
      Name      : Ada.Strings.Unbounded.Unbounded_String :=
        Ada.Strings.Unbounded.To_Unbounded_String ("sample-transform");
      --  Transform Name. Names must be unique.
   end record;

end Alog.Transforms;
